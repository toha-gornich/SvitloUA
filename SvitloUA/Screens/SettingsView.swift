//
//  SettingsView.swift
//  SvitloUA
//
//  Created by Горніч Антон on 23.01.2026.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var dataManager: PowerDataManager
    @State private var showingHelp = false
    
    let regions = [
        ("kiev", "Київ"),
        ("dnipro", "Дніпро")
    ]
    
    let groups = ["1.1", "1.2", "2.1", "2.2", "3.1", "3.2", "4.1", "4.2", "5.1", "5.2", "6.1", "6.2"]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Локація")) {
                    Picker("Місто", selection: $dataManager.settings.region) {
                        ForEach(regions, id: \.0) { region in
                            Text(region.1).tag(region.0)
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
                    
                    // Help Button
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
                        .onChange(of: dataManager.settings.notificationsEnabled) {
                            dataManager.saveSettings()
                        }
                }
                
                Section(header: Text("Дані")) {
                    Button("Оновити графік") {
                        Task {
                            await dataManager.refreshSchedule()
                        }
                    }
                    
                    Button("Очистити історію", role: .destructive) {
                        dataManager.events = []
                        dataManager.saveEvents()
                    }
                }
                
                Section(header: Text("Про додаток")) {
                    HStack {
                        Text("Версія")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    Button(action: {
                        showingHelp = true
                    }) {
                        HStack {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(.blue)
                            Text("Довідка")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            .navigationTitle("Налаштування")
            .sheet(isPresented: $showingHelp) {
                HelpView()
            }
        }
        .appBackground()
    }
}
