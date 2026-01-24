//
//  NetworkManager+Yasno.swift.swift
//  SvitloUA
//
//  Created by Горніч Антон on 24.01.2026.
//

import Foundation


extension NetworkManager:YasnoServiceProtocol {
    
    func fetchSchedule() async throws -> YasnoScheduleResponse {
        print("📡 Fetching schedule...")
        
        let url = YasnoEndpoints.schedule.url
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            if let httpResponse = response as? HTTPURLResponse {
                print("✅ Status: \(httpResponse.statusCode)")
            }
            
            let decoder = JSONDecoder()
            let scheduleResponse = try decoder.decode(YasnoScheduleResponse.self, from: data)
            
            print("✅ Schedule loaded, components: \(scheduleResponse.components.count)")
            
            return scheduleResponse
            
        } catch let decodingError as DecodingError {
            print("❌ Decoding error: \(decodingError)")
            throw decodingError
            
        } catch {
            print("❌ Error: \(error.localizedDescription)")
            throw error
        }
    }
    
    func getScheduleForRegionAndGroup(region: String, group: String) async throws -> [TimeSlot] {
        print("📍 Request: region '\(region)', group '\(group)'")
        
        let response = try await fetchSchedule()
        
        guard let component = response.components.first(where: { $0.templateName == "electricity-outages-daily-schedule" }) else {
            print("❌ Schedule component not found")
            throw NSError(domain: "YasnoAPI", code: 404, userInfo: [NSLocalizedDescriptionKey: "Schedule component not found"])
        }
        
        guard let scheduleData = component.schedule else {
            print("❌ Schedule data is missing")
            throw NSError(domain: "YasnoAPI", code: 404, userInfo: [NSLocalizedDescriptionKey: "Schedule data is missing"])
        }
        
        guard let regionSchedule = scheduleData[region] else {
            print("❌ Region '\(region)' not found")
            throw NSError(domain: "YasnoAPI", code: 404, userInfo: [NSLocalizedDescriptionKey: "Schedule for region '\(region)' not found"])
        }
        
        let groupKey = "group_\(group)"
        
        guard let weekSchedule = regionSchedule.groups[groupKey] else {
            print("❌ Group '\(groupKey)' not found")
            throw NSError(domain: "YasnoAPI", code: 404, userInfo: [NSLocalizedDescriptionKey: "Group '\(group)' not found"])
        }
        
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: Date())
        let dayIndex = weekday == 1 ? 6 : weekday - 2
        
        guard dayIndex < weekSchedule.count else {
            print("❌ Invalid day index")
            throw NSError(domain: "YasnoAPI", code: 500, userInfo: [NSLocalizedDescriptionKey: "Invalid day index"])
        }
        
        let todaySlots = weekSchedule[dayIndex]
        
        print("✅ Got \(todaySlots.count) slots")
        
        return todaySlots
    }
}
