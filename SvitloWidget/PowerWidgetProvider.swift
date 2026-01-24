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
    
    init( yasnoManager: YasnoServiceProtocol = NetworkManager.shared) {
        self.yasnoManager = yasnoManager
    }
    
    func placeholder(in context: Context) -> PowerWidgetEntry {
        print("📱 Widget: Placeholder викликано")
        return PowerWidgetEntry(
            date: Date(),
            currentStatus: .on,
            nextOutage: "14:00",
            region: "dnipro",
            group: "4.2",
            todaySlots: sampleSlots()
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (PowerWidgetEntry) -> Void) {
        print("📸 Widget: Snapshot викликано, isPreview: \(context.isPreview)")
        
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
        print("⏰ Widget: Timeline викликано")
        
        Task {
            let entry = await createEntry()
            
            let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
            let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
            
            print("✅ Widget: Timeline створено з \(entry.todaySlots.count) слотами")
            completion(timeline)
        }
    }
    
    private func createEntry() async -> PowerWidgetEntry {
        let settings = loadSettings()
        
        print("🔧 Widget: Налаштування - регіон: '\(settings.region)', група: '\(settings.group)'")
        
        do {
            print("🌐 Widget: Починаємо запит до API...")
            
            let slots = try await yasnoManager.getScheduleForRegionAndGroup(
                region: settings.region,
                group: settings.group
            )
            
            print("✅ Widget: API повернув \(slots.count) слотів")
            
            for (index, slot) in slots.prefix(3).enumerated() {
                print("   Слот \(index): \(slot.startTime)-\(slot.endTime), type: \(slot.type)")
            }
            
            let currentStatus = getCurrentStatus(from: slots)
            let nextOutage = getNextOutageTime(from: slots)
            
            print("📊 Widget: Статус - \(currentStatus), наступне відключення: \(nextOutage ?? "немає")")
            
            return PowerWidgetEntry(
                date: Date(),
                currentStatus: currentStatus,
                nextOutage: nextOutage,
                region: settings.region,
                group: settings.group,
                todaySlots: slots
            )
        } catch {
            print("❌ Widget: ПОМИЛКА - \(error.localizedDescription)")
            print("   Деталі помилки: \(error)")
            
            return PowerWidgetEntry(
                date: Date(),
                currentStatus: .unknown,
                nextOutage: nil,
                region: settings.region,
                group: settings.group,
                todaySlots: sampleSlots()
            )
        }
    }
    
    private func loadSettings() -> UserSettings {
        print("💾 Widget: Завантаження налаштувань...")
        
        if let groupDefaults = UserDefaults(suiteName: "group.ua.svitlo.app") {
            print("   ✓ App Group UserDefaults створено")
            
            if let data = groupDefaults.data(forKey: "UserSettings") {
                print("   ✓ Дані UserSettings знайдено (\(data.count) байт)")
                
                if let settings = try? JSONDecoder().decode(UserSettings.self, from: data) {
                    print("   ✅ Налаштування декодовано: \(settings.region), \(settings.group)")
                    return settings
                } else {
                    print("   ❌ Помилка декодування UserSettings")
                }
            } else {
                print("   ❌ UserSettings не знайдено в App Group")
            }
        } else {
            print("   ❌ Не вдалося створити App Group UserDefaults")
        }
        
        print("   ⚠️ Використовуємо дефолтні налаштування")
        return .default
    }
    
    private func getCurrentStatus(from slots: [TimeSlot]) -> PowerStatus {
        let now = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: now)
        let minute = calendar.component(.minute, from: now)
        let currentTime = Double(hour) + Double(minute) / 60.0
        
        if let slot = slots.first(where: { $0.start <= currentTime && currentTime < $0.end }) {
            return slot.isOutage ? .off : .on
        }
        return .on
    }
    
    private func getNextOutageTime(from slots: [TimeSlot]) -> String? {
        let now = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: now)
        let minute = calendar.component(.minute, from: now)
        let currentTime = Double(hour) + Double(minute) / 60.0
        
        if let slot = slots.first(where: { $0.start > currentTime && $0.isOutage }) {
            return slot.startTime
        }
        return nil
    }
    
    private func sampleSlots() -> [TimeSlot] {
        return [
            TimeSlot(start: 0, end: 4, type: "POSSIBLE_OUTAGE"),
            TimeSlot(start: 4, end: 11, type: "NotPlanned"),
            TimeSlot(start: 11, end: 14.5, type: "POSSIBLE_OUTAGE"),
            TimeSlot(start: 14.5, end: 21.5, type: "NotPlanned"),
            TimeSlot(start: 21.5, end: 24, type: "POSSIBLE_OUTAGE")
        ]
    }
}
