//
//  RegionSchedule.swift
//  SvitloUA
//
//  Created by Горніч Антон on 30.01.2026.
//


import Foundation

struct RegionSchedule: Codable {
    let groups: [String: [[TimeSlot]]] 
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.groups = try container.decode([String: [[TimeSlot]]].self)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(groups)
    }
}