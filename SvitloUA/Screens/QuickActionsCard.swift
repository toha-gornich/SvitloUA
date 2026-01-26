//
//  QuickActionsCard.swift
//  SvitloUA
//
//  Created by Горніч Антон on 26.01.2026.
//


import SwiftUI

struct QuickActionsCard: View {
    @Binding var showingAddEvent: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            // Add Event Button
            Button(action: {
                showingAddEvent = true
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Додати подію")
                            .font(.caption2)
                            .fontWeight(.regular)
//                            .font(.largeTitle)
                        
                        Text("Вручну")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .padding()
                .background(Color.blue.opacity(0.1))
                .foregroundColor(.blue)
                .cornerRadius(10)
            }
            .buttonStyle(.plain)
            
            // Quick Log Outage
            QuickLogButton(status: .off)
            
            // Quick Log Power On
            QuickLogButton(status: .on)
        }
    }
}