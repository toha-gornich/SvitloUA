//
//  YasnoComponent.swift
//  SvitloUA
//
//  Created by Горніч Антон on 23.01.2026.
//
import Foundation

struct YasnoComponent: Codable {
    let templateName: String
    let availableRegions: [String]?
    let schedule: ScheduleData?
    
    enum CodingKeys: String, CodingKey {
        case templateName = "template_name"
        case availableRegions = "available_regions"
        case schedule
    }
}






