//
//  APIConfiguration.swift
//  SvitloUA
//
//  Created by Горніч Антон on 24.01.2026.
//

import Foundation


enum AppEnvironment: String {
    case development
    case production
    
    var baseURL: URL {
        switch self {
        case .development:
            return URL(string: "https://api.yasno.com.ua/api/v1/")!
        case .production:
            return URL(string: "https://api.yasno.com.ua/api/v1/")!
        }
    }
}

