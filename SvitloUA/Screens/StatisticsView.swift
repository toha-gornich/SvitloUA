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

// MARK: - Quick Add Event Card
struct QuickAddEventCard: View {
    @Binding var showingAddEvent: Bool
    
    var body: some View {
        Button(action: {
            showingAddEvent = true
        }) {
            HStack {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Додати подію вручну")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("Якщо було відключення поза графіком")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color.blue.opacity(0.1))
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Recent Events with Actions
struct RecentEventsCardWithActions: View {
    @EnvironmentObject var dataManager: PowerDataManager
    @State private var eventToDelete: PowerEvent?
    @State private var showingDeleteAlert = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Останні події")
                    .font(.headline)
                
                Spacer()
                
                if !dataManager.events.isEmpty {
                    Text("\(dataManager.events.count) всього")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal)
            
            if dataManager.events.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "clock.badge.exclamationmark")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)
                    
                    Text("Немає записів")
                        .foregroundColor(.secondary)
                    
                    Text("Додайте подію вручну або зачекайте автоматичного відстеження")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .frame(maxWidth: .infinity)
                .padding()
            } else {
                ForEach(dataManager.events.prefix(15)) { event in
                    EventRowWithActions(
                        event: event,
                        onDelete: {
                            eventToDelete = event
                            showingDeleteAlert = true
                        }
                    )
                }
                .padding(.horizontal)
                
                if dataManager.events.count > 15 {
                    Text("Показано 15 з \(dataManager.events.count)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 8)
                }
            }
        }
        .padding(.vertical)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
        .alert("Видалити подію?", isPresented: $showingDeleteAlert) {
            Button("Скасувати", role: .cancel) { }
            Button("Видалити", role: .destructive) {
                if let event = eventToDelete {
                    deleteEvent(event)
                }
            }
        } message: {
            Text("Цю дію неможливо скасувати")
        }
    }
    
    private func deleteEvent(_ event: PowerEvent) {
        if let index = dataManager.events.firstIndex(where: { $0.id == event.id }) {
            dataManager.events.remove(at: index)
            dataManager.saveEvents()
        }
    }
}

// MARK: - Event Row with Actions
struct EventRowWithActions: View {
    let event: PowerEvent
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            Circle()
                .fill(event.status == .on ? Color.green : Color.red)
                .frame(width: 10, height: 10)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(event.status.rawValue)
                    .font(.subheadline)
                
                Text(event.timestamp, style: .time)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(event.timestamp, style: .date)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
                    .font(.caption)
            }
            .buttonStyle(.borderless)
        }
        .padding(.vertical, 6)
    }
}

#Preview {
    StatisticsView()
        .environmentObject(PowerDataManager.shared)
}
