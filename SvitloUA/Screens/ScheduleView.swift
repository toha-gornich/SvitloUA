//
//  ScheduleView.swift
//  SvitloUA
//
//  Created by Горніч Антон on 23.01.2026.
//

import SwiftUI

struct ScheduleView: View {
    @EnvironmentObject var dataManager: PowerDataManager
    @State private var showingAddEvent = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Current Status Card
                    CurrentStatusCard()
                    
                    // Quick Actions
                    QuickActionsCard(showingAddEvent: $showingAddEvent)
                    
                    // Schedule for the day
                    ScheduleCard(title: "Графік на сьогодні", slots: dataManager.schedule)
                    
                    // Optional: Show statistics or info card instead of tomorrow
                    if dataManager.schedule.isEmpty && !dataManager.isLoading {
                        EmptyScheduleCard()
                    }
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
                        if dataManager.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                        } else {
                            Image(systemName: "arrow.clockwise")
                        }
                    }
                    .disabled(dataManager.isLoading)
                }
            }
            .refreshable {
                await dataManager.refreshSchedule()
            }
            .sheet(isPresented: $showingAddEvent) {
                AddEventSheet()
                    .environmentObject(dataManager)
            }
        }
    }
}

#Preview {
    ScheduleView()
        .environmentObject(PowerDataManager.shared)
}
