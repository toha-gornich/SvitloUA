//
//  CurrentStatusCard.swift
//  SvitloUA
//
//  Created by Горніч Антон on 23.01.2026.
//


import SwiftUI
struct CurrentStatusCard: View {
    @EnvironmentObject var dataManager: PowerDataManager
    
    var body: some View {
        VStack(spacing: 12) {
            // Main status section
            HStack {
                Image(systemName: statusIcon)
                    .font(.system(size: 40))
                    .foregroundColor(statusColor)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(statusText)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Група \(dataManager.settings.group)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    if let current = dataManager.currentSlot {
                        Text("До \(current.endTime)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
            }
            .padding()
            
            // Next outage info
            if let nextOutage = dataManager.nextOutageSlot {
                Divider()
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Наступне відключення:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("Сьогодні о \(nextOutage.startTime)")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        if nextOutage.type == .possible {
                            Text("Можливе")
                                .font(.caption2)
                                .foregroundColor(.orange)
                        }
                    }
                    
                    Spacer()
                    
                    // Time until next outage
                    if let timeUntil = getTimeUntilNextOutage(nextOutage) {
                        VStack(alignment: .trailing, spacing: 2) {
                            Text(timeUntil)
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(statusColor)
                            Text("залишилось")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom)
            } else if dataManager.isPowerOn {
                // No more outages today
                Divider()
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Більше відключень не заплановано")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            
            // Schedule status warning
            if dataManager.scheduleStatus != "ScheduleApplies" {
                Divider()
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                    Text("Графік не підтверджено")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
            }
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(.systemBackground),
                    statusColor.opacity(0.05)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
        .shadow(color: statusColor.opacity(0.2), radius: 8, x: 0, y: 4)
    }
    
    // MARK: - Computed Properties
    
    private var statusIcon: String {
        switch dataManager.currentStatus {
        case .on: return "bolt.fill"
        case .off: return "bolt.slash.fill"
        case .unknown: return "questionmark.circle.fill"
        }
    }
    
    private var statusColor: Color {
        switch dataManager.currentStatus {
        case .on: return .green
        case .off: return .red
        case .unknown: return .gray
        }
    }
    
    private var statusText: String {
        switch dataManager.currentStatus {
        case .on: return "Світло є"
        case .off: return "Відключення"
        case .unknown: return "Невідомо"
        }
    }
    
    private func getTimeUntilNextOutage(_ slot: TimeSlot) -> String? {
        let now = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: now)
        let minute = calendar.component(.minute, from: now)
        let minutesNow = hour * 60 + minute
        
        let minutesUntil = slot.start - minutesNow
        
        guard minutesUntil > 0 else { return nil }
        
        let hours = minutesUntil / 60
        let mins = minutesUntil % 60
        
        if hours > 0 {
            return "\(hours)год \(mins)хв"
        } else {
            return "\(mins)хв"
        }
    }
}
