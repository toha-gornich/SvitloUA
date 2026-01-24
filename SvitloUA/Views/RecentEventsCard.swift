//
//  RecentEventsCard.swift
//  SvitloUA
//
//  Created by Горніч Антон on 23.01.2026.
//


import SwiftUI

struct RecentEventsCard: View {
    @EnvironmentObject var dataManager: PowerDataManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Останні події")
                .font(.headline)
                .padding(.horizontal)
            
            if dataManager.events.isEmpty {
                Text("Немає записів")
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                ForEach(dataManager.events.prefix(10)) { event in
                    EventRow(event: event)
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}
