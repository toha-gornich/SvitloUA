//
//  UserSettings.swift
//  SvitloUA
//
//  Created by Горніч Антон on 23.01.2026.
//


import Foundation
import SwiftUI
import Charts
import WidgetKit

struct UserSettings: Codable {
    var region: String
    var group: String
    var notificationsEnabled: Bool
    
    static let `default` = UserSettings(
        region: "kiev",
        group: "1.1",
        notificationsEnabled: true
    )
}