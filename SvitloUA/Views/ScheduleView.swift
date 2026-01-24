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
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Current Status Card
                    CurrentStatusCard()
                    
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
        }
    }
}

// MARK: - Empty Schedule Card
struct EmptyScheduleCard: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.system(size: 40))
                .foregroundColor(.secondary)
            
            Text("Графік не знайдено")
                .font(.headline)
            
            Text("Спробуйте оновити дані або перевірте налаштування регіону та групи")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}
