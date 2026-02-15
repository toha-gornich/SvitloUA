//
//  NotificationSettingsView.swift
//  SvitloUA
//
//  Created by Горніч Антон on 09.02.2026.
//

import SwiftUI

struct NotificationSettingsView: View {
    @StateObject private var notificationManager = NotificationManager.shared
    @State private var notifyBefore = 15
    @State private var enableDailySummary = false
    @State private var showingSettings = false
    
    var body: some View {
        Form {
            Section {
                if notificationManager.isAuthorized {
                    Label("Сповіщення увімкнено", systemImage: "checkmark.circle.fill")
                        .foregroundColor(.green)
                } else {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Сповіщення вимкнено")
                            .foregroundColor(.secondary)
                        
                        Button {
                            Task {
                                let granted = await notificationManager.requestAuthorization()
                                
                                if !granted {
                                   
                                    showingSettings = true
                                }
                            }
                        } label: {
                            Label("Увімкнути сповіщення", systemImage: "bell.badge")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding(.vertical, 8)
                }
            } header: {
                Text("Статус")
            } footer: {
                if !notificationManager.isAuthorized {
                    Text("Дозвольте сповіщення, щоб отримувати попередження про відключення світла")
                }
            }
            
            Section("Попередження про відключення") {
                Picker("Попереджати за", selection: $notifyBefore) {
                    Text("5 хвилин").tag(5)
                    Text("15 хвилин").tag(15)
                    Text("30 хвилин").tag(30)
                    Text("1 година").tag(60)
                }
                .onChange(of: notifyBefore) { _, newValue in
                
                    if let slots = PowerDataManager.shared.todaySchedule?.slots {
                        NotificationManager.shared.scheduleNotificationsForToday(
                            slots: slots,
                            minutesBefore: newValue
                        )
                    }
                }
            }
            .disabled(!notificationManager.isAuthorized)
        }
        .scrollContentBackground(.hidden)
        .appBackground()
        .navigationTitle("Сповіщення")
        .alert("Увімкніть сповіщення", isPresented: $showingSettings) {
            Button("Налаштування") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Скасувати", role: .cancel) {}
        } message: {
            Text("Перейдіть в Налаштування > SvitloUA > Сповіщення та увімкніть їх")
        }
        .onAppear {
            notificationManager.checkAuthorization()
        }
        
    }
}

#Preview {
    NotificationSettingsView()
}
