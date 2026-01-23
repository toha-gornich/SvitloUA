//
//  ScheduleCard.swift
//  SvitloUA
//
//  Created by Горніч Антон on 23.01.2026.
//


import Foundation
import SwiftUI
import Charts
import WidgetKit

struct ScheduleCard: View {
    let title: String
    let slots: [TimeSlot]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .padding(.horizontal)
            
            if slots.isEmpty {
                Text("Немає даних")
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                VStack(spacing: 8) {
                    ForEach(slots) { slot in
                        TimeSlotRow(slot: slot)
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}