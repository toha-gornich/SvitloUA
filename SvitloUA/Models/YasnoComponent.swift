//
//  YasnoComponent.swift
//  SvitloUA
//
//  Created by Горніч Антон on 23.01.2026.
//
import Foundation

struct YasnoScheduleResponse: Codable {
    let components: [YasnoComponent]
}

struct YasnoComponent: Codable {
    let templateName: String
    let availableRegions: [String]?
    let schedule: ScheduleData?
    
    enum CodingKeys: String, CodingKey {
        case templateName = "template_name"
        case availableRegions = "available_regions"
        case schedule
    }
}

struct ScheduleData: Codable {
    let regions: [String: RegionSchedule]
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.regions = try container.decode([String: RegionSchedule].self)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(regions)
    }
    
    subscript(region: String) -> RegionSchedule? {
        return regions[region]
    }
}

struct RegionSchedule: Codable {
    let groups: [String: [[TimeSlot]]]  // Масив масивів - кожен день тижня
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.groups = try container.decode([String: [[TimeSlot]]].self)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(groups)
    }
}

struct TimeSlot: Codable, Identifiable {
    var id = UUID()
    let start: Double
    let end: Double
    let type: String
    
    enum CodingKeys: String, CodingKey {
        case start, end, type
    }
    
    
    init(start: Double, end: Double, type: String) {
        self.start = start
        self.end = end
        self.type = type
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
