//
//  QuickAddEventCard.swift
//  SvitloUA
//
//  Created by Горніч Антон on 26.01.2026.
//


import SwiftUI

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