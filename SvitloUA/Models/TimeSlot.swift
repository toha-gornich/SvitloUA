//
//  TimeSlot.swift
//  SvitloUA
//
//  Created by Горніч Антон on 30.01.2026.
//


import Foundation

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