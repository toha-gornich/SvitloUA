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
        HStack(spacing: 16) {
            // Left side - Status
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: statusIcon)
                        .font(.largeTitle)
                        .foregroundColor(statusColor)
                    
                    Spacer()
                }
                
                Text(entry.currentStatus.rawValue)
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
            
            // Right side - Today's schedule (БЕЗ ScrollView!)
            VStack(alignment: .leading, spacing: 6) {
                Text("Сьогодні")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                // Просто VStack замість ScrollView
                VStack(spacing: 4) {
                    ForEach(entry.todaySlots.prefix(4)) { slot in
                        HStack(spacing: 4) {
                            Circle()
                                .fill(slot.isOutage ? Color.red : Color.green)
                                .frame(width: 6, height: 6)
                            
                            Text("\(slot.startTime)-\(slot.endTime)")
                                .font(.system(size: 9, design: .monospaced))
                                .foregroundColor(slot.isOutage ? .red : .green)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding()
        .background(
            LinearGradient(
                gradient: Gradient(colors: [statusColor.opacity(0.15), statusColor.opacity(0.05)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
    
    private var statusIcon: String {
        switch entry.currentStatus {
        case .on: return "bolt.fill"
        case .off: return "bolt.slash.fill"
        case .unknown: return "questionmark.circle.fill"
        }
    }
    
    private var statusColor: Color {
        switch entry.currentStatus {
        case .on: return .green
        case .off: return .red
        case .unknown: return .gray
        }
    }
}