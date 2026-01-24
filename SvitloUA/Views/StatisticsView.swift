//
//  StatisticsView.swift
//  SvitloUA
//
//  Created by Горніч Антон on 23.01.2026.
//


import SwiftUI

struct StatisticsView: View {
    @EnvironmentObject var dataManager: PowerDataManager
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Summary Cards
                    let stats = dataManager.getStatistics()
                    HStack(spacing: 12) {
                        StatCard(title: "Сьогодні", value: "\(stats.today)", subtitle: "відключень")
                        StatCard(title: "Тиждень", value: "\(stats.week)", subtitle: "відключень")
                        StatCard(title: "Місяць", value: "\(stats.month)", subtitle: "відключень")
                    }
                    
                    // Chart
                    if !dataManager.events.isEmpty {
                        ChartCard()
                    }
                    
                    // Recent Events
                    RecentEventsCard()
                }
                .padding()
            }
            .navigationTitle("Статистика")
        }
    }
}
