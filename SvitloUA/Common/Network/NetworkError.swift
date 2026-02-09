//
//  NetworkError.swift
//  SvitloUA
//
//  Created by Горніч Антон on 09.02.2026.
//

import Foundation

enum NetworkError: Error, LocalizedError {
    case invalidResponse
    case serverError(statusCode: Int)
    case regionNotFound(regionId: Int)
    case dsoNotFound(dsoId: Int)
    case groupNotFound(group: String)
    case scheduleNotAvailable
    
    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid server response"
        case .serverError(let code):
            return "Server error: \(code)"
        case .regionNotFound(let id):
            return "Region \(id) not found"
        case .dsoNotFound(let id):
            return "DSO \(id) not found"
        case .groupNotFound(let group):
            return "Group \(group) not found"
        case .scheduleNotAvailable:
            return "Schedule not available for today"
        }
    }
}
