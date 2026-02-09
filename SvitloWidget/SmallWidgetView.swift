//
//  SmallWidgetView.swift
//  SvitloUA
//
//  Created by Горніч Антон on 24.01.2026.
//


import WidgetKit
import SwiftUI

struct SmallWidgetView: View {
    let entry: PowerWidgetEntry
    
    var body: some View {
        VStack(spacing: 8) {
            // Status icon
            Image(systemName: entry.currentStatus.icon)
                .font(.system(size: 40))
                .foregroundColor(entry.currentStatus.color)
            
            // Status text
            Text(entry.currentStatus.text)
                .font(.headline)
                .fontWeight(.bold)
                .minimumScaleFactor(0.8)
            
            // Group info
            Text("Група \(entry.group)")
                .font(.caption2)
                .foregroundColor(.secondary)
            
            
            // Next outage or current slot
            if let nextOutage = entry.nextOutage {
                VStack(spacing: 2) {
                    Text("Наступне відлючення")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text(nextOutage)
                        .font(.caption)
                        .fontWeight(.semibold)
                }
            } else if let current = entry.currentSlot {
                Text("Until \(current.endTime)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .appBackground()
    }
    
}
