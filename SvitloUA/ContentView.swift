//
//  ContentView.swift
//  SvitloUA
//
//  Created by Горніч Антон on 23.01.2026.
//



import Foundation
import SwiftUI
import Charts
import WidgetKit

// MARK: - API Models


// MARK: - Local Storage Models


// MARK: - API Service


// MARK: - Data Manager



// MARK: - Content View
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

// MARK: - Schedule View


// MARK: - Current Status Card


// MARK: - Schedule Card


// MARK: - Time Slot Row


// MARK: - Statistics View


// MARK: - Stat Card


// MARK: - Chart Card




// MARK: - Recent Events Card


// MARK: - Event Row


// MARK: - Settings View

