//
//  ScheduleView.swift
//  SvitloUA
//
//  Created by Горніч Антон on 23.01.2026.
//


import Foundation
import SwiftUI
import Charts
import WidgetKit

struct ScheduleView: View {
    @EnvironmentObject var dataManager: PowerDataManager
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Current Status Card
                    CurrentStatusCard()
                    
                    // Today's Schedule
                    ScheduleCard(title: "Сьогодні", slots: dataManager.todaySchedule)
                    
                    // Tomorrow's Schedule
                    ScheduleCard(title: "Завтра", slots: dataManager.tomorrowSchedule)
                }
                .padding()
            }
            .navigationTitle("Графік відключень")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        Task {
                            await dataManager.refreshSchedule()
                        }
                    }) {
                        Image(systemName: "arrow.clockwise")
                    }
                    .disabled(dataManager.isLoading)
                }
            }
            .refreshable {
                await dataManager.refreshSchedule()
            }
        }
    }
}