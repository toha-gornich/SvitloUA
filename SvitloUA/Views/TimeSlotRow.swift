//
//  TimeSlotRow.swift
//  SvitloUA
//
//  Created by Горніч Антон on 23.01.2026.
//

import SwiftUI

struct TimeSlotRow: View {
    let slot: TimeSlot
    let isPast: Bool
    
    init(slot: TimeSlot, isPast: Bool = false) {
        self.slot = slot
        self.isPast = isPast
    }
    
    var body: some View {
        HStack {
            // Status indicator
            Circle()
                .fill(slot.type.color)
                .frame(width: 12, height: 12)
            
            // Time range
            Text("\(slot.startTime) - \(slot.endTime)")
                .font(.system(.body, design: .monospaced))
                .foregroundColor(isPast ? .secondary : .primary)
            
            Spacer()
            
            // Status label
            Text(slot.type.statusText)
                .font(.subheadline)
                .foregroundColor(isPast ? .secondary : slot.type.color)
            
            // Optional icon for definite outages
            if slot.type == .definite {
                Image(systemName: "exclamationmark.circle.fill")
                    .foregroundColor(slot.type.color)
                    .font(.caption)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(slot.type.background(isPast: isPast))
        .cornerRadius(8)
        .opacity(isPast ? 0.5 : 1.0)
    }
    
    // MARK: - Computed Properties
    

    
//    private var slotBackground: Color {
//        switch slot.type {
//        case .definite:
//            return Color.red.opacity(isPast ? 0.05 : 0.1)
//        case .possible:
//            return Color.orange.opacity(isPast ? 0.05 : 0.1)
//        case .notPlanned:
//            return Color.green.opacity(isPast ? 0.05 : 0.1)
//        }
//    }
}

// MARK: - Enhanced Version with Duration
struct TimeSlotDetailRow: View {
    let slot: TimeSlot
    let isPast: Bool
    let isCurrent: Bool
    
    init(slot: TimeSlot, isPast: Bool = false, isCurrent: Bool = false) {
        self.slot = slot
        self.isPast = isPast
        self.isCurrent = isCurrent
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Status indicator with glow for current slot
            ZStack {
                if isCurrent {
                    Circle()
                        .fill(slotColor.opacity(0.3))
                        .frame(width: 20, height: 20)
                        .blur(radius: 4)
                }
                
                Circle()
                    .fill(slotColor)
                    .frame(width: 12, height: 12)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                // Time range
                HStack {
                    Text("\(slot.startTime) - \(slot.endTime)")
                        .font(.system(.body, design: .monospaced))
                        .fontWeight(isCurrent ? .semibold : .regular)
                    
                    // Only show "Зараз" for current slot
                    if isCurrent {
                        Text("Зараз")
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(slotColor.opacity(0.2))
                            .foregroundColor(slotColor)
                            .cornerRadius(4)
                    }
                }
                
                // Status and duration
                HStack {
                    Text(slotStatusText)
                        .font(.subheadline)
                        .foregroundColor(isPast ? .secondary : slotColor)
                    
                    Text("•")
                        .foregroundColor(.secondary)
                    
                    Text(durationText)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Icon
            Image(systemName: slotIcon)
                .foregroundColor(slotColor)
                .font(.title3)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(slotBackground)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isCurrent ? slotColor.opacity(0.5) : Color.clear, lineWidth: 2)
        )
        .opacity(isPast ? 0.5 : 1.0)
    }
    
    private var slotIcon: String {
        switch slot.type {
        case .definite:
            return "bolt.slash.fill"
        case .possible:
            return "bolt.badge.questionmark"
        case .notPlanned:
            return "bolt.fill"
        }
    }
    
    private var slotColor: Color {
        switch slot.type {
        case .definite: return .red
        case .possible: return .orange
        case .notPlanned: return .green
        }
    }
    private var slotStatusText: String {
        switch slot.type {
        case .definite:
            return NSLocalizedString("Відключення", comment: "Power outage status")
        case .possible:
            return NSLocalizedString("Можливе відключення", comment: "Possible power outage")
        case .notPlanned:
            return NSLocalizedString("Світло є", comment: "Power is on")
        }
    }
    
    private var slotBackground: Color {
        if isCurrent {
            return slotColor.opacity(0.15)
        }
        
        switch slot.type {
        case .definite: return Color.red.opacity(isPast ? 0.05 : 0.1)
        case .possible: return Color.orange.opacity(isPast ? 0.05 : 0.1)
        case .notPlanned: return Color.green.opacity(isPast ? 0.05 : 0.1)
        }
    }
    
    private var durationText: String {
        let duration = slot.end - slot.start
        let hours = duration / 60
        let minutes = duration % 60
        
        if hours > 0 && minutes > 0 {
            return "\(hours) год \(minutes) хв"
        } else if hours > 0 {
            return "\(hours) год"
        } else {
            return "\(minutes) хв"
        }
    }
}

// MARK: - Compact Version for Lists
struct TimeSlotCompactRow: View {
    let slot: TimeSlot
    
    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(slotColor)
                .frame(width: 8, height: 8)
            
            Text("\(slot.startTime)-\(slot.endTime)")
                .font(.system(.caption, design: .monospaced))
                .foregroundColor(slotColor)
            
            Spacer()
            
            Text(slot.type.rawValue)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
    
    private var slotColor: Color {
        switch slot.type {
        case .definite: return .red
        case .possible: return .orange
        case .notPlanned: return .green
        }
    }
}

// MARK: - Preview
struct TimeSlotRow_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            // Basic row
            TimeSlotRow(
                slot: TimeSlot(start: 480, end: 720, type: .definite),
                isPast: false
            )
            
            // Current slot (detail version)
            TimeSlotDetailRow(
                slot: TimeSlot(start: 720, end: 960, type: .possible),
                isPast: false,
                isCurrent: true
            )
            
            // Past slot
            TimeSlotDetailRow(
                slot: TimeSlot(start: 0, end: 240, type: .notPlanned),
                isPast: true,
                isCurrent: false
            )
            
            // Compact version
            TimeSlotCompactRow(
                slot: TimeSlot(start: 960, end: 1200, type: .definite)
            )
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
