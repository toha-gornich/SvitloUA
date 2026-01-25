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

// MARK: - Quick Actions Card
struct QuickActionsCard: View {
    @Binding var showingAddEvent: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            // Add Event Button
            Button(action: {
                showingAddEvent = true
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Додати подію")
                            .font(.caption2)
                            .fontWeight(.regular)
//                            .font(.largeTitle)
                        
                        Text("Вручну")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .padding()
                .background(Color.blue.opacity(0.1))
                .foregroundColor(.blue)
                .cornerRadius(10)
            }
            .buttonStyle(.plain)
            
            // Quick Log Outage
            QuickLogButton(status: .off)
            
            // Quick Log Power On
            QuickLogButton(status: .on)
        }
    }
}

// MARK: - Quick Log Button
struct QuickLogButton: View {
    @EnvironmentObject var dataManager: PowerDataManager
    let status: PowerStatus
    @State private var showingConfirmation = false
    
    var body: some View {
        Button(action: {
            showingConfirmation = true
        }) {
            VStack(spacing: 6) {
                Image(systemName: status == .off ? "bolt.slash.fill" : "bolt.fill")
                    .font(.title3)
                
                Text(status == .off ? "Світла немає" : "Світло є")
                    .font(.caption2)
                    .fontWeight(.medium)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 60)
            .padding(.vertical, 12)
            .background(status == .off ? Color.red.opacity(0.1) : Color.green.opacity(0.1))
            .foregroundColor(status == .off ? .red : .green)
            .cornerRadius(10)
        }
        .buttonStyle(.plain)
        .alert("Зафіксувати подію?", isPresented: $showingConfirmation) {
            Button("Скасувати", role: .cancel) { }
            Button("Так") {
                logEvent()
            }
        } message: {
            Text("\(status.rawValue) зараз (\(Date().formatted(date: .omitted, time: .shortened)))")
        }
    }
    
    private func logEvent() {
        let event = PowerEvent(status: status)
        dataManager.addEvent(event)
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

#Preview {
    ScheduleView()
        .environmentObject(PowerDataManager.shared)
}
