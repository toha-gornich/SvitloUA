//
//  DayShedule.swift
//  SvitloUA
//
//  Created by Горніч Антон on 09.02.2026.
//

import Foundation

struct DaySchedule: Codable {
    let slots: [TimeSlot]
    let date: String
    let status: String
}
