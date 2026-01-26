//
//  EventRowWithActions.swift
//  SvitloUA
//
//  Created by Горніч Антон on 26.01.2026.
//


import SwiftUI

struct EventRowWithActions: View {
    let event: PowerEvent
    let onDelete: () -> Void
    
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
            
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
                    .font(.caption)
            }
            .buttonStyle(.borderless)
        }
        .padding(.vertical, 6)
    }
}