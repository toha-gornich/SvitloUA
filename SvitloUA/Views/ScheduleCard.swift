//
//  ScheduleCard.swift
//  SvitloUA
//
//  Created by Горніч Антон on 23.01.2026.
//


import SwiftUI

struct ScheduleCard: View {
    let title: String
    let slots: [TimeSlot]
    let scheduleStatus: String?
    let isToday: Bool
    let showPastSlots: Bool
    
    init(
        title: String,
        slots: [TimeSlot],
        scheduleStatus: String? = nil,
        isToday: Bool = true,
        showPastSlots: Bool = false
    ) {
        self.title = title
        self.slots = slots
        self.scheduleStatus = scheduleStatus
        self.isToday = isToday
        self.showPastSlots = showPastSlots
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with stats
            HStack {
                Text(title)
                    .font(.headline)
                
                Spacer()
                
                // Status indicators
                if !slots.isEmpty {
                    HStack(spacing: 12) {
                        // Schedule status for tomorrow
                        if !isToday {
                            scheduleStatusBadge
                        }
                        
                        // Outage count
                        if scheduleIsActive {
                            Label("\(outageCount)", systemImage: "bolt.slash.fill")
                                .font(.caption)
                                .foregroundColor(.red)
                            
                            // Total duration
                            Label(totalDurationText, systemImage: "clock.fill")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .padding(.horizontal)
            
            Divider()
            
            // Content based on schedule status
            Group {
                if slots.isEmpty {
                    emptyStateView
                } else if !scheduleIsActive && !isToday {
                    waitingForScheduleView
                } else {
                    slotsListView
                }
            }
        }
        .padding(.vertical)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
    
    // MARK: - Status Badge
    
    @ViewBuilder
    private var scheduleStatusBadge: some View {
        if scheduleStatus != nil {
            HStack(spacing: 4) {
                Circle()
                    .fill(statusColor)
                    .frame(width: 6, height: 6)
                
                Text(statusText)
                    .font(.caption2)
                    .foregroundColor(statusColor)
                    .lineLimit(1)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(statusColor.opacity(0.1))
            .cornerRadius(8)
        }
    }
    
    private var statusColor: Color {
        switch scheduleStatus {
        case "ScheduleApplies":
            return .green
        case "WaitingForSchedule":
            return .orange
        default:
            return .gray
        }
    }
    
    private var statusText: String {
        switch scheduleStatus {
        case "ScheduleApplies":
            return "Підтверджено"
        case "WaitingForSchedule":
            return "Очікується"
        default:
            return "Невідомо"
        }
    }
    
    private var scheduleIsActive: Bool {
        scheduleStatus == "ScheduleApplies" || isToday
    }
    
    // MARK: - Content Views
    
    private var emptyStateView: some View {
        VStack(spacing: 8) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.system(size: 40))
                .foregroundColor(.secondary)
            Text("Немає даних")
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
    }
    
    private var waitingForScheduleView: some View {
        VStack(spacing: 12) {
            Image(systemName: "clock.badge.questionmark")
                .font(.system(size: 40))
                .foregroundColor(.orange)
            
            Text("Графік ще не підтверджено")
                .font(.headline)
                .foregroundColor(.primary)
            
            Text("Перевірте пізніше графік на завтра")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .padding(.horizontal)
    }
    
    private var slotsListView: some View {
        ScrollView {
            VStack(spacing: 8) {
                ForEach(displayedSlots, id: \.start) { slot in
                    TimeSlotDetailRow(
                        slot: slot,
                        isPast: isToday && isPastSlot(slot),
                        isCurrent: isToday && isCurrentSlot(slot)
                    )
                }
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Computed Properties
    
    private var displayedSlots: [TimeSlot] {
        if !scheduleIsActive && !isToday {
            return []
        }
        
        if showPastSlots || !isToday {
            return slots
        } else {
            let minutesNow = getCurrentMinutes()
            return slots.filter { $0.end > minutesNow }
        }
    }
    
    private var outageCount: Int {
        slots.filter { $0.type == .definite || $0.type == .possible }.count
    }
    
    private var totalDurationText: String {
        let totalMinutes = slots
            .filter { $0.type == .definite || $0.type == .possible }
            .reduce(0) { $0 + ($1.end - $1.start) }
        
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60
        
        if hours > 0 && minutes > 0 {
            return "\(hours)год \(minutes)хв"
        } else if hours > 0 {
            return "\(hours)год"
        } else {
            return "\(minutes)хв"
        }
    }
    
    // MARK: - Helper Methods
    
    private func isPastSlot(_ slot: TimeSlot) -> Bool {
        let minutesNow = getCurrentMinutes()
        return slot.end <= minutesNow
    }
    
    private func isCurrentSlot(_ slot: TimeSlot) -> Bool {
        let minutesNow = getCurrentMinutes()
        return slot.start <= minutesNow && slot.end > minutesNow
    }
    
    private func getCurrentMinutes() -> Int {
        let calendar = Calendar.current
        let now = Date()
        let hour = calendar.component(.hour, from: now)
        let minute = calendar.component(.minute, from: now)
        return hour * 60 + minute
    }
}

// MARK: - Preview
struct ScheduleCards_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Current status card
                CurrentStatusCard()
                    .environmentObject(PowerDataManager.shared)
                
                // Today's schedule
                ScheduleCard(
                    title: "Графік на сьогодні",
                    slots: [
                        TimeSlot(start: 0, end: 480, type: .notPlanned),
                        TimeSlot(start: 480, end: 720, type: .definite),
                        TimeSlot(start: 720, end: 960, type: .notPlanned),
                        TimeSlot(start: 960, end: 1200, type: .possible),
                        TimeSlot(start: 1200, end: 1440, type: .notPlanned)
                    ],
                    showPastSlots: false
                )
                
                // Tomorrow's schedule (compact)
                CompactScheduleCard(
                    title: "Завтра",
                    slots: [
                        TimeSlot(start: 360, end: 600, type: .definite),
                        TimeSlot(start: 1020, end: 1260, type: .possible)
                    ]
                )
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
    }
}
