//
//  Extensions+PowerStatus.swift
//  SvitloUA
//
//  Created by Горніч Антон on 09.02.2026.
//

import SwiftUI

extension PowerStatus {
    var icon: String {
        switch self {
        case .on: return "bolt.fill"
        case .off: return "bolt.slash.fill"
        case .unknown: return "questionmark.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .on: return .green
        case .off: return .red
        case .unknown: return .gray
        }
    }
    
    var text: String {
        switch self {
        case .on:
            return NSLocalizedString("Світло є", comment: "Power is on")
        case .off:
            return NSLocalizedString("Відключення", comment: "Power outage")
        case .unknown:
            return NSLocalizedString("Невідомо", comment: "Unknown power status")
        }
    }
}
