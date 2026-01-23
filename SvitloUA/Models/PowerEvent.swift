//
//  PowerEvent.swift
//  SvitloUA
//
//  Created by Горніч Антон on 23.01.2026.
//


import Foundation
import SwiftUI
import Charts
import WidgetKit

struct PowerEvent: Codable, Identifiable {
    let id: UUID
    let timestamp: Date
    let status: PowerStatus
    let duration: TimeInterval
    
    init(status: PowerStatus, duration: TimeInterval = 0) {
        self.id = UUID()
        self.timestamp = Date()
        self.status = status
        self.duration = duration
    }
}