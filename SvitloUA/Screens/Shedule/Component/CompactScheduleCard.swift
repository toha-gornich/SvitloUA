//
//  CompactScheduleCard.swift
//  SvitloUA
//
//  Created by Горніч Антон on 09.02.2026.
//


import SwiftUI

struct CompactScheduleCard: View {
    let title: String
    let slots: [TimeSlot]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                if !slots.isEmpty {
                    Text("\(outageCount) відключень")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            if slots.isEmpty {
                Text("Немає даних")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.vertical, 4)
            } else {
                VStack(spacing: 4) {
                    ForEach(slots.prefix(3), id: \.start) { slot in
                        TimeSlotCompactRow(slot: slot)
                    }
                    
                    if slots.count > 3 {
                        Text("та ще \(slots.count - 3)...")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .padding(.top, 4)
                    }
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
    
    private var outageCount: Int {
        slots.filter { $0.type == .definite || $0.type == .possible }.count
    }
}