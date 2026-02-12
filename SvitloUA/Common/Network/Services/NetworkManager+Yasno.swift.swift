//
//  NetworkManager+Yasno.swift.swift
//  SvitloUA
//
//  Created by Горніч Антон on 24.01.2026.
//

import Foundation
extension NetworkManager: YasnoServiceProtocol {
    
    func fetchSchedule(region: String, group: String) async throws -> GroupSchedule {
        print("📡 Fetching schedule for region: \(region), group: \(group)")
        
        let (regionId, dsoId) = getRegionParameters(for: region)
        let url = YasnoEndpoints.probableOutages(regionId: regionId, dsoId: dsoId).url
        
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        print("✅ Status: \(httpResponse.statusCode)")
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.serverError(statusCode: httpResponse.statusCode)
        }
        
        // Debug: print raw JSON
        if let jsonString = String(data: data, encoding: .utf8) {
        }
        
        let decoder = JSONDecoder()
        let apiResponse = try decoder.decode(YasnoAPIResponse.self, from: data)
        
        // Navigate through the structure
        guard let regionData = apiResponse.regions[String(regionId)] else {
            throw NetworkError.regionNotFound(regionId: regionId)
        }
        
        guard let dsoData = regionData.dsos[String(dsoId)] else {
            throw NetworkError.dsoNotFound(dsoId: dsoId)
        }
        
        guard let groupData = dsoData.groups[group] else {
            throw NetworkError.groupNotFound(group: group)
        }
        
        // Convert to GroupSchedule format
        let todaySlots = groupData.today ?? []
        let tomorrowSlots = groupData.tomorrow ?? []
        
        print("✅ Schedule loaded for group \(group)")
        print("   Today slots: \(todaySlots.count)")
        print("   Tomorrow slots: \(tomorrowSlots.count)")
        
        // Create DaySchedule objects
        let todaySchedule = todaySlots.isEmpty ? nil : DaySchedule(
            slots: todaySlots,
            date: ISO8601DateFormatter().string(from: Date()),
            status: "ScheduleApplies"
        )
        
        let calendar = Calendar.current
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: Date())!
        let tomorrowSchedule = tomorrowSlots.isEmpty ? nil : DaySchedule(
            slots: tomorrowSlots,
            date: ISO8601DateFormatter().string(from: tomorrow),
            status: "ScheduleApplies"
        )
        
        return GroupSchedule(
            today: todaySchedule,
            tomorrow: tomorrowSchedule,
            updatedOn: ISO8601DateFormatter().string(from: Date())
        )
    }
    
    func getScheduleForRegionAndGroup(region: String, group: String) async throws -> [TimeSlot] {
        print("📍 Request: region '\(region)', group '\(group)'")
        
        let groupSchedule = try await fetchSchedule(region: region, group: group)
        
        guard let todaySchedule = groupSchedule.today else {
            print("❌ Today's schedule not available")
            throw NetworkError.scheduleNotAvailable
        }
        
        let slots = todaySchedule.slots
        print("✅ Got \(slots.count) slots for today")
        
        for slot in slots {
            print("   \(slot.startTime) - \(slot.endTime): \(slot.type.displayName)")
        }
        
        return slots
    }
    
    private func getRegionParameters(for region: String) -> (regionId: Int, dsoId: Int) {
        switch region.lowercased() {
        case "kyiv", "kiev", "київ":
            return (25, 902)
        default:
            return (25, 902)
        }
    }
}
