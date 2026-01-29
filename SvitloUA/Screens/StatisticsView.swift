//
//  StatisticsView.swift
//  SvitloUA
//
//  Created by Горніч Антон on 23.01.2026.
//
import SwiftUI

struct StatisticsView: View {
    @EnvironmentObject var dataManager: PowerDataManager
    @State private var showingHelp = false
    @State private var showingAddEvent = false
    @State private var showingExport = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Quick Add Button
                    QuickAddEventCard(showingAddEvent: $showingAddEvent)
                    
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
                    
                    // Recent Events with Edit/Delete options
                    RecentEventsCardWithActions()
                }
                .padding()
            }
            .navigationTitle("Статистика")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 16) {
                        Button(action: {
                            showingExport = true
                        }) {
                            Image(systemName: "square.and.arrow.up")
                        }
                        
                        Button(action: {
                            showingAddEvent = true
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title3)
                        }
                        
                        Button(action: {
                            showingHelp = true
                        }) {
                            Image(systemName: "questionmark.circle")
                        }
                    }
                }
            }
            .sheet(isPresented: $showingHelp) {
                HelpView()
                    .environmentObject(dataManager)
            }
            .sheet(isPresented: $showingAddEvent) {
                AddEventSheet()
                    .environmentObject(dataManager)
            }
            .sheet(isPresented: $showingExport) {
                ExportStatisticsView()
                    .environmentObject(dataManager)
            }
        }
    }
}


#Preview {
    StatisticsView()
        .environmentObject(PowerDataManager.shared)
}
