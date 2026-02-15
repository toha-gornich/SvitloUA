//
//  MediumWidgetView.swift
//  SvitloUA
//
//  Created by Горніч Антон on 24.01.2026.
//


import WidgetKit
import SwiftUI

struct MediumWidgetView: View {
    let entry: PowerWidgetEntry
    
    var body: some View {
        HStack(spacing: 20) {
            // Left side - Status
            VStack(alignment: .leading, spacing: 8) {
                Image(systemName: entry.currentStatus.icon)
                    .font(.title)
                    .foregroundColor(entry.currentStatus.color)
                
                Text(entry.currentStatus.text)
                    .font(.title3)
                    .fontWeight(.bold)
                
                Text("Група \(entry.group)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if let nextOutage = entry.nextOutage {
                    Spacer()
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Наступне відключення")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text(nextOutage)
                            .font(.caption)
                            .fontWeight(.semibold)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Divider()
                .opacity(0.3)
            
            // Right side - Today's schedule
            VStack(alignment: .leading, spacing: 6) {
                Text("Сьогодні")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                
                if entry.upcomingSlots.isEmpty {
                    Text("Відключень немає")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .frame(maxHeight: .infinity, alignment: .top)
                } else {
                    VStack(spacing: 4) {
                        ForEach(entry.upcomingSlots.prefix(4), id: \.start) { slot in
                            HStack(spacing: 4) {
                                Circle()
                                    .fill(slot.type.color)
                                    .frame(width: 6, height: 6)
                                
                                Text("\(slot.startTime)-\(slot.endTime)")
                                    .font(.system(size: 10, design: .monospaced))
                                    .foregroundColor(slot.type.color)
                                
                                Spacer()
                            }
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
        .containerBackground(for: .widget) {
            Color("WidgetBackground")
        }
        .padding(16)
    }
}
