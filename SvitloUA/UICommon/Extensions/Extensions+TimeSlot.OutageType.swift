//
//  Extensions+TimeSlot.OutageType.swift
//  SvitloUA
//
//  Created by Горніч Антон on 09.02.2026.
//

import SwiftUI

extension TimeSlot.OutageType {
    var color: Color {
        switch self {
        case .definite: return .red
        case .possible: return .orange
        case .notPlanned: return .green
        }
    }
    
    var statusText: String {
        switch self {
        case .definite:
            return NSLocalizedString("Відключення", comment: "Power outage")
        case .possible:
            return NSLocalizedString("Можливе відключення", comment: "Possible power outage")
        case .notPlanned:
            return NSLocalizedString("Світло є", comment: "Power is on")
        }
    }
    
    var icon: String {
        switch self {
        case .definite: return "bolt.slash.fill"
        case .possible: return "bolt.badge.questionmark"
        case .notPlanned: return "bolt.fill"
        }
    }
    
    func background(isPast: Bool = false, isCurrent: Bool = false) -> Color {
        if isCurrent {
            return color.opacity(0.15)
        }
        return color.opacity(isPast ? 0.05 : 0.1)
    }
}
