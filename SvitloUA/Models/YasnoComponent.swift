//
//  YasnoComponent.swift
//  SvitloUA
//
//  Created by Горніч Антон on 23.01.2026.
//


import Foundation
import SwiftUI
import Charts
import WidgetKit

struct YasnoScheduleResponse: Codable {
    let components: [YasnoComponent]
}

struct YasnoComponent: Codable {
    let templateName: String
    let availableRegions: [String]
    let dailySchedule: [String: DailyScheduleData]
    
    enum CodingKeys: String, CodingKey {
        case templateName = "template_name"
        case availableRegions = "available_regions"
        case dailySchedule
    }
}

struct DailyScheduleData: Codable {
    let today: ScheduleDay
    let tomorrow: ScheduleDay
}

struct ScheduleDay: Codable {
    let title: String
    let groups: [String: [TimeSlot]]
}

struct TimeSlot: Codable, Identifiable {
    var id = UUID()
    let start: Double
    let end: Double
    let type: String
    
    enum CodingKeys: String, CodingKey {
        case start, end, type
    }
    
    var startTime: String {
        let hours = Int(start)
        let minutes = Int((start - Double(hours)) * 60)
        return String(format: "%02d:%02d", hours, minutes)
    }
    
    var endTime: String {
        let hours = Int(end)
        let minutes = Int((end - Double(hours)) * 60)
        return String(format: "%02d:%02d", hours, minutes)
    }
    
    var isOutage: Bool {
        type.contains("OUTAGE")
    }
}
