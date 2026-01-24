//
//  YasnoEndpoints.swift
//  SvitloUA
//
//  Created by Горніч Антон on 24.01.2026.
//

import Foundation


enum YasnoEndpoints {
    static let baseURL = URL(string: "https://yasno.ru/api/v1/")!

    case schedule
    
    
    var path: String {
        switch self {
        case .schedule:
            return "pages/home/schedule-turn-off-electricity"
        }
    }
    
    var url: URL {
        return APIConfiguration.shared.environment.baseURL.appendingPathComponentRaw(path)
    }
}
