//
//  YasnoEndpoints.swift
//  SvitloUA
//
//  Created by Горніч Антон on 24.01.2026.
//

import Foundation


enum YasnoEndpoints {
    static let baseURL = URL(string: "https://app.yasno.ua/api/blackout-service/public/")!
    
    case probableOutages(regionId: Int, dsoId: Int)
    
    var path: String {
        switch self {
        case .probableOutages:
            return "shutdowns/probable-outages"
        }
    }
    
    var url: URL {
        switch self {
        case .probableOutages(let regionId, let dsoId):
            var components = URLComponents(url: Self.baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: false)!
            components.queryItems = [
                URLQueryItem(name: "regionId", value: String(regionId)),
                URLQueryItem(name: "dsoId", value: String(dsoId))
            ]
            return components.url!
        }
    }
}
