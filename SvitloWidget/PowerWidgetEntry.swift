//
//  PowerWidgetEntry.swift
//  SvitloUA
//
//  Created by Горніч Антон on 10.02.2026.
//


import WidgetKit
import SwiftUI

struct PowerWidgetEntry: TimelineEntry {
    let date: Date
    let currentStatus: PowerStatus
    let nextOutage: String?
    let region: String
    let group: String
    let todaySlots: [TimeSlot]
    let scheduleStatus: String
    
    // Computed properties for convenience
    var upcomingSlots: [TimeSlot] {
        let now = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: now)
        let minute = calendar.component(.minute, from: now)
        let minutesFromMidnight = hour * 60 + minute
        
        return todaySlots.filter { $0.end > minutesFromMidnight }
    }
    
    var currentSlot: TimeSlot? {
        let now = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: now)
        let minute = calendar.component(.minute, from: now)
        let minutesFromMidnight = hour * 60 + minute
        
        return todaySlots.first {
            $0.start <= minutesFromMidnight && $0.end > minutesFromMidnight
        }
    }
    
    var nextOutageSlot: TimeSlot? {
        let now = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: now)
        let minute = calendar.component(.minute, from: now)
        let minutesFromMidnight = hour * 60 + minute
        
        return todaySlots.first {
            $0.start > minutesFromMidnight &&
            ($0.type == .definite || $0.type == .possible)
        }
    }
    
    var todayOutageDuration: String {
        let totalMinutes = todaySlots
            .filter { $0.type == .definite || $0.type == .possible }
            .reduce(0) { $0 + ($1.end - $1.start) }
        
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60
        
        if minutes == 0 {
            return String(format: NSLocalizedString("hours_format", comment: "Hours format"), hours)
        } else {
            return String(format: NSLocalizedString("hours_minutes_format", comment: "Hours and minutes format"), hours, minutes)
        }
    }
    
    var isScheduleActive: Bool {
        return scheduleStatus == "ScheduleApplies"
    }
}
