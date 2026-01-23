//
//  CurrentStatusCard.swift
//  SvitloUA
//
//  Created by Горніч Антон on 23.01.2026.
//


import Foundation
import SwiftUI
import Charts
import WidgetKit

struct CurrentStatusCard: View {
    @EnvironmentObject var dataManager: PowerDataManager
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: statusIcon)
                    .font(.system(size: 40))
                    .foregroundColor(statusColor)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(dataManager.currentStatus.rawValue)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Група \(dataManager.settings.group)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding()
            
            if let nextOutage = getNextOutage() {
                Divider()
                HStack {
                    Text("Наступне відключення:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(nextOutage)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
    
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
    
    private func getNextOutage() -> String? {
        let now = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: now)
        let minute = calendar.component(.minute, from: now)
        let currentTime = Double(hour) + Double(minute) / 60.0
        
        if let slot = dataManager.todaySchedule.first(where: { $0.start > currentTime && $0.isOutage }) {
            return "Сьогодні о \(slot.startTime)"
        } else if let slot = dataManager.tomorrowSchedule.first(where: { $0.isOutage }) {
            return "Завтра о \(slot.startTime)"
        }
        
        return nil
    }
}