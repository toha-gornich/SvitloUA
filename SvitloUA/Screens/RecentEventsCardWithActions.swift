//
//  RecentEventsCardWithActions.swift
//  SvitloUA
//
//  Created by Горніч Антон on 26.01.2026.
//


import SwiftUI

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