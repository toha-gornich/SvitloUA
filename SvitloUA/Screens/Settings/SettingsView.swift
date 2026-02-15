//
//  SettingsView.swift
//  SvitloUA
//
//  Created by Горніч Антон on 23.01.2026.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var dataManager: PowerDataManager
    @StateObject private var notificationManager = NotificationManager.shared
    @State private var showingHelp = false
    
    let regions: [(code: String, name: String)] = [
        ("kiev", NSLocalizedString("city_kyiv", comment: "Kiev city name")),
    ]
    
    let groups = ["1.1", "1.2", "2.1", "2.2", "3.1", "3.2", "4.1", "4.2", "5.1", "5.2", "6.1", "6.2"]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Локація")) {
                    Picker("City", selection: $dataManager.settings.region) {
                        ForEach(regions, id: \.code) { region in
                            Text(region.name).tag(region.code)
                        }
                    }
                    .onChange(of: dataManager.settings.region) {
                        dataManager.saveSettings()
                        Task {
                            await dataManager.refreshSchedule()
                        }
                    }
                    
                    Picker("Група", selection: $dataManager.settings.group) {
                        ForEach(groups, id: \.self) { group in
                            Text(group).tag(group)
                        }
                    }
                    .onChange(of: dataManager.settings.group) {
                        dataManager.saveSettings()
                        Task {
                            await dataManager.refreshSchedule()
                        }
                    }
                    
                    Button(action: {
                        showingHelp = true
                    }) {
                        HStack {
                            Image(systemName: "questionmark.circle.fill")
                                .foregroundColor(.blue)
                            Text("Як дізнатись свою групу?")
                                .foregroundColor(.blue)
                        }
                    }
                }
                
                Section(header: Text("Сповіщення")) {
                    Toggle("Увімкнути сповіщення", isOn: $dataManager.settings.notificationsEnabled)
                        .onChange(of: dataManager.settings.notificationsEnabled) { _, enabled in
                            if enabled && !notificationManager.isAuthorized {
                                Task {
                                    let granted = await notificationManager.requestAuthorization()
                                    if !granted {
                                        await MainActor.run {
                                            dataManager.settings.notificationsEnabled = false
                                        }
                                    }
                                }
                            }
                            dataManager.saveSettings()
                        }
                    
                    // Статус
                    if(!notificationManager.isAuthorized){
                    if dataManager.settings.notificationsEnabled {
                        HStack {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(notificationManager.isAuthorized ? .green : .red)
                                Text( "Заборонено в системі")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    // Детальні налаштування
                    NavigationLink {
                        NotificationSettingsView()
                    } label: {
                        Label("Налаштування сповіщень", systemImage: "bell.badge")
                    }
                    .disabled(!dataManager.settings.notificationsEnabled)
                }
                
                Section(header: Text("Дані")) {
                    Button("Оновити графік") {
                        Task {
                            await dataManager.refreshSchedule()
                        }
                    }
                }
                
                Section(header: Text("Про додаток")) {
                    HStack {
                        Text("Версія")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color("BackgroundColor"))
            .navigationTitle("Налаштування")
            .sheet(isPresented: $showingHelp) {
                HelpView()
            }
            .onAppear {
                notificationManager.checkAuthorization()
            }
        }
    }
}
