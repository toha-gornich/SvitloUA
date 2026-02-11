//
//  PowerDataManager.swift
//  SvitloUA
//
//  Created by Горніч Антон on 23.01.2026.
//
import Foundation
import Combine
import WidgetKit

class PowerDataManager: ObservableObject {
    
    static let shared = PowerDataManager()
    
    @Published var settings: UserSettings
    @Published var todaySchedule: DaySchedule?
    @Published var tomorrowSchedule: DaySchedule?
    @Published var isLoading = false
    @Published var currentStatus: PowerStatus = .unknown
    @Published var lastUpdated: Date?
    
    private let settingsKey = "UserSettings"
    private let yasnoManager: YasnoServiceProtocol
    
    private var cancellables = Set<AnyCancellable>()
    
    init(yasnoManager: YasnoServiceProtocol = NetworkManager.shared) {
        self.settings = Self.loadSettings()
        self.yasnoManager = yasnoManager
        
        setupSettingsObserver()
        
        Task {
            await refreshSchedule()
        }
    }
    
    private func setupSettingsObserver() {
        $settings
            .dropFirst()
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                Task {
                    await self?.refreshSchedule()
                }
            }
            .store(in: &cancellables)
    }
    
    func saveSettings() {
        if let data = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(data, forKey: settingsKey)
            
            if let groupDefaults = UserDefaults(suiteName: "group.ua.svitlo.app") {
                groupDefaults.set(data, forKey: settingsKey)
            }
        }
        
        WidgetCenter.shared.reloadAllTimelines()
        print("🔄 Widget reload triggered after settings change")
    }
    
    
    // MARK: - Loading/Saving
    
    private static func loadSettings() -> UserSettings {
        guard let data = UserDefaults.standard.data(forKey: "UserSettings"),
              let settings = try? JSONDecoder().decode(UserSettings.self, from: data) else {
            return .default
        }
        return settings
    }


    // MARK: - Schedule
    
    func refreshSchedule() async {
        await MainActor.run {
            isLoading = true
        }
        
        do {
            let groupSchedule = try await yasnoManager.fetchSchedule(
                region: settings.region,
                group: settings.group
            )
            
            await MainActor.run {
                self.todaySchedule = groupSchedule.today
                self.tomorrowSchedule = groupSchedule.tomorrow
                self.updateCurrentStatus()
                self.lastUpdated = Date()
                self.isLoading = false
                
                print("✅ Schedule updated:")
                print("   Today: \(groupSchedule.today?.slots.count ?? 0) slots")
                print("   Tomorrow: \(groupSchedule.tomorrow?.slots.count ?? 0) slots")
                if let slots = groupSchedule.today?.slots {
                    NotificationManager.shared.scheduleNotificationsForToday(slots: slots)
                }
            }
        } catch {
            print("❌ Error fetching schedule: \(error)")
            await MainActor.run {
                isLoading = false
            }
        }
    }
    
    // MARK: - Current Status
    
    private func updateCurrentStatus() {
        guard let slots = todaySchedule?.slots else {
            currentStatus = .unknown
            return
        }
        
        let now = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: now)
        let minute = calendar.component(.minute, from: now)
        let minutesFromMidnight = hour * 60 + minute
        
        if let currentSlot = slots.first(where: {
            $0.start <= minutesFromMidnight && $0.end > minutesFromMidnight
        }) {
            switch currentSlot.type {
            case .definite, .possible:
                currentStatus = .off
            case .notPlanned:
                currentStatus = .on
            }
        } else {
            currentStatus = .unknown
        }
    }
    
    // MARK: - Helper Properties
    
    
    var upcomingSlots: [TimeSlot] {
        guard let slots = todaySchedule?.slots else { return [] }
        
        let now = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: now)
        let minute = calendar.component(.minute, from: now)
        let minutesFromMidnight = hour * 60 + minute
        
        return slots.filter { $0.end > minutesFromMidnight }
    }
    
    
    var allTodaySlots: [TimeSlot] {
        return todaySchedule?.slots ?? []
    }
    
    
    var allTomorrowSlots: [TimeSlot] {
        return tomorrowSchedule?.slots ?? []
    }
    
    
    var currentSlot: TimeSlot? {
        guard let slots = todaySchedule?.slots else { return nil }
        
        let now = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: now)
        let minute = calendar.component(.minute, from: now)
        let minutesFromMidnight = hour * 60 + minute
        
        return slots.first { $0.start <= minutesFromMidnight && $0.end > minutesFromMidnight }
    }
    
    
    var nextOutageSlot: TimeSlot? {
        guard let slots = todaySchedule?.slots else { return nil }
        
        let now = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: now)
        let minute = calendar.component(.minute, from: now)
        let minutesFromMidnight = hour * 60 + minute
        
        return slots.first {
            $0.start > minutesFromMidnight &&
            ($0.type == .definite || $0.type == .possible)
        }
    }
    
    
    var scheduleStatus: String {
        return todaySchedule?.status ?? "Unknown"
    }
    // MARK: - Додаткові корисні методи
    
    
    var todayOutageDuration: Int {
        guard let slots = todaySchedule?.slots else { return 0 }
        
        return slots
            .filter { $0.type == .definite || $0.type == .possible }
            .reduce(0) { $0 + ($1.end - $1.start) }
    }
    
    
    var todayOutagePercentage: Double {
        let totalMinutesInDay = 1440.0
        return Double(todayOutageDuration) / totalMinutesInDay * 100
    }
    
    var isPowerOn: Bool {
        return currentStatus == .on
    }
    
    var isPowerOff: Bool {
        return currentStatus == .off
    }
}
