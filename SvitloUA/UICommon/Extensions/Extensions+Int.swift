//
//  Extensions+Int.swift
//  SvitloUA
//
//  Created by Горніч Антон on 09.02.2026.
//

import Foundation

extension Int {
    func toTimeString() -> String {
        let hours = self / 60
        let minutes = self % 60
        return String(format: "%02d:%02d", hours, minutes)
    }
}
