//
//  YasnoAPIService.swift
//  SvitloUA
//
//  Created by Горніч Антон on 23.01.2026.
//


import Foundation
import SwiftUI
import Charts
import WidgetKit

class YasnoAPIService {
    static let shared = YasnoAPIService()
    private let baseURL = "https://api.yasno.com.ua/api/v1/pages/home/schedule-turn-off-electricity"
    
    func fetchSchedule() async throws -> YasnoScheduleResponse {
        guard let url = URL(string: baseURL) else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let decoder = JSONDecoder()
        return try decoder.decode(YasnoScheduleResponse.self, from: data)
    }
    
    func getScheduleForRegionAndGroup(region: String, group: String) async throws -> (today: [TimeSlot], tomorrow: [TimeSlot]) {
        let response = try await fetchSchedule()
        
        guard let component = response.components.first(where: { $0.templateName == "electricity-outages-daily-schedule" }),
              let schedule = component.dailySchedule[region] else {
            throw NSError(domain: "YasnoAPI", code: 404, userInfo: [NSLocalizedDescriptionKey: "Schedule not found"])
        }
        
        let todaySlots = schedule.today.groups[group] ?? []
        let tomorrowSlots = schedule.tomorrow.groups[group] ?? []
        
        return (todaySlots, tomorrowSlots)
    }
}