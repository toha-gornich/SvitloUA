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
                Image(systemName: entry.currentStatus.icon)
                    .font(.title)
                    .foregroundColor(entry.currentStatus.color)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(entry.currentStatus.text)
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
            
            // Schedule status
            if !entry.isScheduleActive {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                    Text("Графік не підтвердженно")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
                .padding(.vertical, 4)
            }
            
            Divider()
            
            // Schedule list
            VStack(alignment: .leading, spacing: 4) {
                Text("Графік сьогодні")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                if entry.todaySlots.isEmpty {
                    Text("Дані не доступні")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else {
                    VStack(spacing: 4) {
                        ForEach(entry.todaySlots.prefix(8), id: \.start) { slot in
                            HStack(spacing: 8) {
                                Circle()
                                    .fill(slotColor(for: slot.type))
                                    .frame(width: 8, height: 8)
                                
                                Text("\(slot.startTime) - \(slot.endTime)")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(slotColor(for: slot.type))
                                
                                Spacer()
                                
                            }
                            .padding(.vertical, 2)
                            .opacity(isPastSlot(slot) ? 0.5 : 1.0)
                        }
                    }
                }
            }
            
            Spacer()
            
            // Footer stats
            HStack {
                Label("\(entry.todayOutageDuration)", systemImage: "clock.fill")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("Оновлено \(entry.date, style: .time)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(
            LinearGradient(
                gradient: Gradient(colors: [entry.currentStatus.color.opacity(0.15), entry.currentStatus.color.opacity(0.05)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
    
    private func slotColor(for type: TimeSlot.OutageType) -> Color {
        switch type {
        case .definite: return .red
        case .possible: return .orange
        case .notPlanned: return .green
        }
    }
    
    private func isPastSlot(_ slot: TimeSlot) -> Bool {
        let now = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: now)
        let minute = calendar.component(.minute, from: now)
        let minutesFromMidnight = hour * 60 + minute
        
        return slot.end <= minutesFromMidnight
    }
}
