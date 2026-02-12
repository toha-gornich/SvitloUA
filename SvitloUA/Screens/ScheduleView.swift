//
//  ScheduleView.swift
//  SvitloUA
//
//  Created by Горніч Антон on 23.01.2026.
//

import SwiftUI

struct ScheduleView: View {
    @EnvironmentObject var dataManager: PowerDataManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Current status
                CurrentStatusCard()
                
                // Today's schedule
                ScheduleCard(
                    title: NSLocalizedString("Графік сьогодні", comment: "Today's schedule"),
                    slots: dataManager.allTodaySlots,
                    scheduleStatus: dataManager.todaySchedule?.status,
                    isToday: true,
                    showPastSlots: false
                )

                // Tomorrow's schedule
                ScheduleCard(
                    title: NSLocalizedString("Графік завтра", comment: "Tomorrow's schedule"),
                    slots: dataManager.allTomorrowSlots,
                    scheduleStatus: dataManager.tomorrowSchedule?.status,
                    isToday: false,
                    showPastSlots: true
                )
            }
            .padding()
        }
        .scrollContentBackground(.hidden)
        .appBackground()
        .navigationTitle("Schedule")
        .refreshable {
            await dataManager.refreshSchedule()
        }
    }
}

#Preview {
    ScheduleView()
        .environmentObject(PowerDataManager.shared)
}
