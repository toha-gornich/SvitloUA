//
//  LargeWidgetView.swift
//  SvitloUA
//
//  Created by Горніч Антон on 24.01.2026.
//


import WidgetKit
import SwiftUI

struct LargeWidgetView: View {
    let entry: PowerWidgetEntry
    
    var body: some View {
        VStack(spacing: 12) {
            // Header
            HStack {
                Image(systemName: statusIcon)
                    .font(.title)
                    .foregroundColor(statusColor)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(entry.currentStatus.rawValue)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Група \(entry.group)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if let nextOutage = entry.nextOutage {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Наступне")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text(nextOutage)
                            .font(.caption)
                            .fontWeight(.semibold)
                    }
                }
            }
            
            Divider()
            
            // Schedule list
            VStack(alignment: .leading, spacing: 4) {
                Text("Графік на сьогодні")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                if entry.todaySlots.isEmpty {
                    Text("Дані недоступні")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else {
                    VStack(spacing: 4) {
                        ForEach(entry.todaySlots.prefix(8)) { slot in
                            HStack(spacing: 6) {
                                Circle()
                                    .fill(slot.isOutage ? Color.red : Color.green)
                                    .frame(width: 8, height: 8)
                                
                                Text("\(slot.startTime) - \(slot.endTime)")
                                    .font(.caption)
                                    .foregroundColor(slot.isOutage ? .red : .green)
                                
                                Spacer()
                            }
                        }
                    }
                }
            }
            
            Spacer()
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