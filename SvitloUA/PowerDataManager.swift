//
//  PowerDataManager.swift
//  SvitloUA
//
//  Created by Горніч Антон on 23.01.2026.
//


import Foundation
import SwiftUI
import Charts
import WidgetKit

class PowerDataManager: ObservableObject {
    static let shared = PowerDataManager()
    
    @Published var settings: UserSettings
    @Published var events: [PowerEvent] = []
    @Published var todaySchedule: [TimeSlot] = []
    @Published var tomorrowSchedule: [TimeSlot] = []
    @Published var isLoading = false
    @Published var currentStatus: PowerStatus = .unknown
    
    private let settingsKey = "UserSettings"
    private let eventsKey = "PowerEvents"
    
    init() {
        self.settings = Self.loadSettings()
        self.events = Self.loadEvents()
        Task {
            await refreshSchedule()
        }
    }
    
    private static func loadSettings() -> UserSettings {
        guard let data = UserDefaults.standard.data(forKey: "UserSettings"),
              let settings = try? JSONDecoder().decode(UserSettings.self, from: data) else {
            return .default
        }
        return settings
    }
    
    private static func loadEvents() -> [PowerEvent] {
        guard let data = UserDefaults.standard.data(forKey: "PowerEvents"),
              let events = try? JSONDecoder().decode([PowerEvent].self, from: data) else {
            return []
        }
        return events
    }
    
    func saveSettings() {
        if let data = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(data, forKey: settingsKey)
        }
    }
    
    func saveEvents() {
        if let data = try? JSONEncoder().encode(events) {
            UserDefaults.standard.set(data, forKey: eventsKey)
        }
    }
    
    func addEvent(_ event: PowerEvent) {
        events.insert(event, at: 0)
        if events.count > 1000 {
            events = Array(events.prefix(1000))
        }
        saveEvents()
    }
    
    func refreshSchedule() async {
        await MainActor.run {
            isLoading = true
        }
        
        do {
            let (today, tomorrow) = try await YasnoAPIService.shared.getScheduleForRegionAndGroup(
                region: settings.region,
                group: settings.group
            )
            
            await MainActor.run {
                self.todaySchedule = today
                self.tomorrowSchedule = tomorrow
                self.updateCurrentStatus()
                self.isLoading = false
            }
        } catch {
            print("Error fetching schedule: \(error)")
            await MainActor.run {
                isLoading = false
            }
        }
    }
    
    private func updateCurrentStatus() {
        let now = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: now)
        let minute = calendar.component(.minute, from: now)
        let currentTime = Double(hour) + Double(minute) / 60.0
        
        if let slot = todaySchedule.first(where: { $0.start <= currentTime && currentTime < $0.end }) {
            currentStatus = slot.isOutage ? .off : .on
        } else {
            currentStatus = .on
        }
    }
    
    func getStatistics() -> (today: Int, week: Int, month: Int) {
        let now = Date()
        let calendar = Calendar.current
        
        let todayEvents = events.filter {
            calendar.isDateInToday($0.timestamp) && $0.status == .off
        }
        
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: now)!
        let weekEvents = events.filter {
            $0.timestamp > weekAgo && $0.status == .off
        }
        
        let monthAgo = calendar.date(byAdding: .day, value: -30, to: now)!
        let monthEvents = events.filter {
            $0.timestamp > monthAgo && $0.status == .off
        }
        
        return (todayEvents.count, weekEvents.count, monthEvents.count)
    }
}