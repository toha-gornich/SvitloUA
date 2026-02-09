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
}
