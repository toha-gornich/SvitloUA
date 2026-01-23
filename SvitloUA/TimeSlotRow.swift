//
//  TimeSlotRow.swift
//  SvitloUA
//
//  Created by Горніч Антон on 23.01.2026.
//


import Foundation
import SwiftUI
import Charts
import WidgetKit

struct TimeSlotRow: View {
    let slot: TimeSlot
    
    var body: some View {
        HStack {
            Circle()
                .fill(slot.isOutage ? Color.red : Color.green)
                .frame(width: 12, height: 12)
            
            Text("\(slot.startTime) - \(slot.endTime)")
                .font(.system(.body, design: .monospaced))
            
            Spacer()
            
            Text(slot.isOutage ? "Відключення" : "Світло є")
                .font(.subheadline)
                .foregroundColor(slot.isOutage ? .red : .green)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(slot.isOutage ? Color.red.opacity(0.1) : Color.green.opacity(0.1))
        .cornerRadius(8)
    }
}