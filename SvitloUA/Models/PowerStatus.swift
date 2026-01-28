//
//  PowerStatus.swift
//  SvitloUA
//
//  Created by Горніч Антон on 23.01.2026.
//


import Foundation

enum PowerStatus: String, Codable {
    case on = "Є світло"
    case off = "Немає світла"
    case unknown = "Невідомо"
}
