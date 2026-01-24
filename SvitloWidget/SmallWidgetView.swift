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
            HStack {
                Image(systemName: statusIcon)
                    .font(.title2)
                    .foregroundColor(statusColor)
                
                Spacer()
                
                Text(entry.group)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.currentStatus.rawValue)
                    .font(.headline)
                    .fontWeight(.bold)
                
                if let nextOutage = entry.nextOutage {
                    Text("Наступне: \(nextOutage)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(
            LinearGradient(
                gradient: Gradient(colors: [statusColor.opacity(0.2), statusColor.opacity(0.05)]),
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