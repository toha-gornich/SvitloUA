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
            case .definite: return "Відключення"
            case .possible: return "Можливе відключення"
            case .notPlanned: return "Світло є"
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
