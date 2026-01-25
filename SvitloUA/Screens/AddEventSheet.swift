//
//  AddEventSheet.swift
//  SvitloUA
//
//  Created by Assistant on 25.01.2026.
//

import SwiftUI

struct AddEventSheet: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dataManager: PowerDataManager
    
    @State private var selectedStatus: PowerStatus = .off
    @State private var selectedDate = Date()
    @State private var selectedTime = Date()
    @State private var notes: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Тип події")) {
                    Picker("Статус", selection: $selectedStatus) {
                        HStack {
                            Circle()
                                .fill(Color.red)
                                .frame(width: 10, height: 10)
                            Text("Відключення")
                        }
                        .tag(PowerStatus.off)
                        
                        HStack {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 10, height: 10)
                            Text("Увімкнення")
                        }
                        .tag(PowerStatus.on)
                    }
                    .pickerStyle(.segmented)
                }
                
                Section(header: Text("Час події")) {
                    DatePicker("Дата", selection: $selectedDate, displayedComponents: .date)
                    DatePicker("Час", selection: $selectedTime, displayedComponents: .hourAndMinute)
                }
                
                Section(header: Text("Примітка (необов'язково)")) {
                    TextEditor(text: $notes)
                        .frame(height: 80)
                }
                
                Section {
                    Button(action: saveEvent) {
                        HStack {
                            Spacer()
                            Text("Зберегти подію")
                                .fontWeight(.semibold)
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Додати подію")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Скасувати") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func saveEvent() {
        // Combine date and time
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: selectedDate)
        let timeComponents = calendar.dateComponents([.hour, .minute], from: selectedTime)
        
        var combined = DateComponents()
        combined.year = dateComponents.year
        combined.month = dateComponents.month
        combined.day = dateComponents.day
        combined.hour = timeComponents.hour
        combined.minute = timeComponents.minute
        
        guard let timestamp = calendar.date(from: combined) else { return }
        
        // Create event with custom timestamp
        let event = PowerEvent(status: selectedStatus)
        
        // We need to create a custom event with the selected timestamp
        // Since PowerEvent doesn't support custom timestamp in init,
        // we'll need to add this to PowerDataManager
        dataManager.addCustomEvent(timestamp: timestamp, status: selectedStatus)
        
        dismiss()
    }
}

#Preview {
    AddEventSheet()
        .environmentObject(PowerDataManager.shared)
}
