//
//  PowerWidgetProvider.swift
//  SvitloUA
//
//  Created by Горніч Антон on 24.01.2026.
//


import WidgetKit
import SwiftUI

struct PowerWidgetProvider: TimelineProvider {
    
    private let yasnoManager: YasnoServiceProtocol
    
    init(yasnoManager: YasnoServiceProtocol = NetworkManager.shared) {
        self.yasnoManager = yasnoManager
    }
    
    func placeholder(in context: Context) -> PowerWidgetEntry {
        print("📱 Widget: Placeholder called")
        return PowerWidgetEntry(
            date: Date(),
            currentStatus: .on,
            nextOutage: "14:00",
            region: "kyiv",
            group: "4.2",
            todaySlots: sampleSlots(),
            scheduleStatus: "ScheduleApplies"
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (PowerWidgetEntry) -> Void) {
        print("📸 Widget: Snapshot called, isPreview: \(context.isPreview)")
        
        if context.isPreview {
            completion(placeholder(in: context))
        } else {
            Task {
                let entry = await createEntry()
                completion(entry)
            }
        }
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<PowerWidgetEntry>) -> Void) {
        print("⏰ Widget: Timeline called")
        
        Task {
            let entry = await createEntry()
            
            // Update every 15 minutes
            let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
            let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
            
            print("✅ Widget: Timeline created with \(entry.todaySlots.count) slots")
            completion(timeline)
        }
    }
    
    // MARK: - Create Entry (UPDATED for new API)
    
    private func createEntry() async -> PowerWidgetEntry {
        let settings = loadSettings()
        
        print("🔧 Widget: Settings - region: '\(settings.region)', group: '\(settings.group)'")
        
        do {
            print("🌐 Widget: Starting API request...")
            
            // Fetch full schedule for the group
            let groupSchedule = try await yasnoManager.fetchSchedule(
                region: settings.region,
                group: settings.group
            )
            
            guard let todaySchedule = groupSchedule.today else {
                print("⚠️ Widget: Today's schedule not available")
                return createErrorEntry(settings: settings)
            }
            
            print("✅ Widget: API returned \(todaySchedule.slots.count) slots")
            
            for (index, slot) in todaySchedule.slots.prefix(3).enumerated() {
                print("   Slot \(index): \(slot.startTime)-\(slot.endTime), type: \(slot.type)")
            }
            
            let currentStatus = getCurrentStatus(from: todaySchedule.slots)
            let nextOutage = getNextOutageTime(from: todaySchedule.slots)
            
            print("📊 Widget: Status - \(currentStatus), next outage: \(nextOutage ?? "none")")
            
            return PowerWidgetEntry(
                date: Date(),
                currentStatus: currentStatus,
                nextOutage: nextOutage,
                region: settings.region,
                group: settings.group,
                todaySlots: todaySchedule.slots,
                scheduleStatus: todaySchedule.status
            )
            
        } catch {
            print("❌ Widget: ERROR - \(error.localizedDescription)")
            print("   Error details: \(error)")
            
            return createErrorEntry(settings: settings)
        }
    }
    
    private func createErrorEntry(settings: UserSettings) -> PowerWidgetEntry {
        return PowerWidgetEntry(
            date: Date(),
            currentStatus: .unknown,
            nextOutage: nil,
            region: settings.region,
            group: settings.group,
            todaySlots: sampleSlots(),
            scheduleStatus: "Unknown"
        )
    }
    
    // MARK: - Settings
    
    private func loadSettings() -> UserSettings {
        print("💾 Widget: Loading settings...")
        
        if let groupDefaults = UserDefaults(suiteName: "group.ua.svitlo.app") {
            print("   ✓ App Group UserDefaults created")
            
            if let data = groupDefaults.data(forKey: "UserSettings") {
                print("   ✓ UserSettings data found (\(data.count) bytes)")
                
                if let settings = try? JSONDecoder().decode(UserSettings.self, from: data) {
                    print("   ✅ Settings decoded: \(settings.region), \(settings.group)")
                    return settings
                } else {
                    print("   ❌ Failed to decode UserSettings")
                }
            } else {
                print("   ❌ UserSettings not found in App Group")
            }
        } else {
            print("   ❌ Failed to create App Group UserDefaults")
        }
        
        print("   ⚠️ Using default settings")
        return .default
    }
    
    // MARK: - Status Helpers (UPDATED for minutes)
    
    private func getCurrentStatus(from slots: [TimeSlot]) -> PowerStatus {
        let now = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: now)
        let minute = calendar.component(.minute, from: now)
        let minutesFromMidnight = hour * 60 + minute
        
        if let slot = slots.first(where: {
            $0.start <= minutesFromMidnight && $0.end > minutesFromMidnight
        }) {
            switch slot.type {
            case .definite, .possible:
                return .off
            case .notPlanned:
                return .on
            }
        }
        return .on
    }
    
    private func getNextOutageTime(from slots: [TimeSlot]) -> String? {
        let now = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: now)
        let minute = calendar.component(.minute, from: now)
        let minutesFromMidnight = hour * 60 + minute
        
        if let slot = slots.first(where: {
            $0.start > minutesFromMidnight &&
            ($0.type == .definite || $0.type == .possible)
        }) {
            return slot.startTime
        }
        return nil
    }
    
    // MARK: - Sample Data
    
    private func sampleSlots() -> [TimeSlot] {
        return [
            TimeSlot(start: 0, end: 240, type: .possible),      // 00:00 - 04:00
            TimeSlot(start: 240, end: 660, type: .notPlanned),  // 04:00 - 11:00
            TimeSlot(start: 660, end: 870, type: .possible),    // 11:00 - 14:30
            TimeSlot(start: 870, end: 1290, type: .notPlanned), // 14:30 - 21:30
            TimeSlot(start: 1290, end: 1440, type: .possible)   // 21:30 - 24:00
        ]
    }
}

// MARK: - Widget Entry (UPDATED)

struct PowerWidgetEntry: TimelineEntry {
    let date: Date
    let currentStatus: PowerStatus
    let nextOutage: String?
    let region: String
    let group: String
    let todaySlots: [TimeSlot]
    let scheduleStatus: String
    
    // Computed properties for convenience
    var upcomingSlots: [TimeSlot] {
        let now = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: now)
        let minute = calendar.component(.minute, from: now)
        let minutesFromMidnight = hour * 60 + minute
        
        return todaySlots.filter { $0.end > minutesFromMidnight }
    }
    
    var currentSlot: TimeSlot? {
        let now = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: now)
        let minute = calendar.component(.minute, from: now)
        let minutesFromMidnight = hour * 60 + minute
        
        return todaySlots.first {
            $0.start <= minutesFromMidnight && $0.end > minutesFromMidnight
        }
    }
    
    var nextOutageSlot: TimeSlot? {
        let now = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: now)
        let minute = calendar.component(.minute, from: now)
        let minutesFromMidnight = hour * 60 + minute
        
        return todaySlots.first {
            $0.start > minutesFromMidnight &&
            ($0.type == .definite || $0.type == .possible)
        }
    }
    
    var todayOutageDuration: String {
        let totalMinutes = todaySlots
            .filter { $0.type == .definite || $0.type == .possible }
            .reduce(0) { $0 + ($1.end - $1.start) }
        
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60
        
        if minutes == 0 {
            return "\(hours) год"
        } else {
            return "\(hours) год \(minutes) хв"
        }
    }
    
    var isScheduleActive: Bool {
        return scheduleStatus == "ScheduleApplies"
    }
}
