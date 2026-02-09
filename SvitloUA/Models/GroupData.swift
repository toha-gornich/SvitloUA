//
//  GroupData.swift
//  SvitloUA
//
//  Created by Горніч Антон on 09.02.2026.
//

import Foundation

struct GroupData: Codable {
    let slots: [String: [TimeSlot]]
    
    // Helper to get today's slots (key "0")
    var today: [TimeSlot]? {
        slots["0"]
    }
    
    // Helper to get tomorrow's slots (key "1")
    var tomorrow: [TimeSlot]? {
        slots["1"]
    }
}




struct RegionData: Codable {
    let dsos: [String: DSOData]
}

struct DSOData: Codable {
    let groups: [String: GroupData]
}
