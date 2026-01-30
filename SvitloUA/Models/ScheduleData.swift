//
//  ScheduleData.swift
//  SvitloUA
//
//  Created by Горніч Антон on 30.01.2026.
//


import Foundation

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