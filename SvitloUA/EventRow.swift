//
//  EventRow.swift
//  SvitloUA
//
//  Created by Горніч Антон on 23.01.2026.
//


import Foundation
import SwiftUI
import Charts
import WidgetKit

struct EventRow: View {
    let event: PowerEvent
    
    var body: some View {
        HStack {
            Circle()
                .fill(event.status == .on ? Color.green : Color.red)
                .frame(width: 10, height: 10)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(event.status.rawValue)
                    .font(.subheadline)
                
                Text(event.timestamp, style: .time)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(event.timestamp, style: .date)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 6)
    }
}