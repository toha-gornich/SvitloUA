//
//  QuickLogButton.swift
//  SvitloUA
//
//  Created by Горніч Антон on 26.01.2026.
//


import SwiftUI

struct QuickLogButton: View {
    @EnvironmentObject var dataManager: PowerDataManager
    let status: PowerStatus
    @State private var showingConfirmation = false
    
    var body: some View {
        Button(action: {
            showingConfirmation = true
        }) {
            VStack(spacing: 6) {
                Image(systemName: status == .off ? "bolt.slash.fill" : "bolt.fill")
                    .font(.title3)
                
                Text(status == .off ? "Світла немає" : "Світло є")
                    .font(.caption2)
                    .fontWeight(.medium)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 60)
            .padding(.vertical, 12)
            .background(status == .off ? Color.red.opacity(0.1) : Color.green.opacity(0.1))
            .foregroundColor(status == .off ? .red : .green)
            .cornerRadius(10)
        }
        .buttonStyle(.plain)
        .alert("Зафіксувати подію?", isPresented: $showingConfirmation) {
            Button("Скасувати", role: .cancel) { }
            Button("Так") {
                logEvent()
            }
        } message: {
            Text("\(status.rawValue) зараз (\(Date().formatted(date: .omitted, time: .shortened)))")
        }
    }
    
    private func logEvent() {
        let event = PowerEvent(status: status)
        dataManager.addEvent(event)
    }
}