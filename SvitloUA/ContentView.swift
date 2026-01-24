//
//  ContentView.swift
//  SvitloUA
//
//  Created by Горніч Антон on 23.01.2026.
//



import SwiftUI



struct ContentView: View {
    @EnvironmentObject var dataManager: PowerDataManager
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            ScheduleView()
                .tabItem {
                    Label("Графік", systemImage: "calendar")
                }
                .tag(0)
            
            StatisticsView()
                .tabItem {
                    Label("Статистика", systemImage: "chart.bar")
                }
                .tag(1)
            
            SettingsView()
                .tabItem {
                    Label("Налаштування", systemImage: "gear")
                }
                .tag(2)
        }
    }
}
