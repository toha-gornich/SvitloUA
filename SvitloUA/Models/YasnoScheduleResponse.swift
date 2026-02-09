//
//  YasnoScheduleResponse.swift
//  SvitloUA
//
//  Created by Горніч Антон on 30.01.2026.
//


import Foundation
struct YasnoAPIResponse: Codable {
    let regions: [String: RegionData]
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        regions = try container.decode([String: RegionData].self)
    }
}
