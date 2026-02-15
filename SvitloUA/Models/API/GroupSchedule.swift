//
//  GroupSchedule.swift
//  SvitloUA
//
//  Created by Горніч Антон on 09.02.2026.
//

import Foundation

struct GroupSchedule: Codable {
    let today: DaySchedule?
    let tomorrow: DaySchedule?
    let updatedOn: String
}
