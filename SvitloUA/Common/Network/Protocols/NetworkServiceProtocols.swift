//
//  NetworkServiceProtocols.swift
//  SvitloUA
//
//  Created by Горніч Антон on 24.01.2026.
//

import Foundation


protocol YasnoServiceProtocol {
    func fetchSchedule(region: String, group: String) async throws -> GroupSchedule
    func getScheduleForRegionAndGroup(region: String, group: String) async throws -> [TimeSlot]
}
