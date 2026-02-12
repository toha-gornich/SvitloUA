//
//  TimeSlot.swift
//  SvitloUA
//
//  Created by Горніч Антон on 30.01.2026.
//


import Foundation

struct TimeSlot: Codable, Identifiable {
    let start: Int
    let end: Int
    let type: OutageType
    
    var id: String {
        "\(start)-\(end)"
    }
    
    enum OutageType: String, Codable {
        case definite = "Definite"
        case possible = "Possible"
        case notPlanned = "NotPlanned"
        
        var displayName: String {
            switch self {
            case .definite:
                return NSLocalizedString("Відключення", comment: "Power outage")
            case .possible:
                return NSLocalizedString("Можливе відключення", comment: "Possible power outage")
            case .notPlanned:
                return NSLocalizedString("Світло є", comment: "Power is on")
            }
        }
    }
    
    var startTime: String {
        start.toTimeString()
    }
    
    var endTime: String {
        end.toTimeString()
    }
}
