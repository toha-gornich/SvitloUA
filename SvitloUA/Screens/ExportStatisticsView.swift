//
//  ExportStatisticsView.swift
//  SvitloUA
//
//  Created by Assistant on 25.01.2026.
//

import SwiftUI

struct ExportStatisticsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dataManager: PowerDataManager
    
    @State private var selectedFormat: ExportFormat = .csv
    @State private var selectedPeriod: ExportPeriod = .all
    @State private var showingShareSheet = false
    @State private var exportedFileURL: URL?
    
    enum ExportFormat: String, CaseIterable {
        case csv = "CSV"
        case json = "JSON"
        case text = "Текст"
    }
    
    enum ExportPeriod: String, CaseIterable {
        case today = "Сьогодні"
        case week = "Останні 7 днів"
        case month = "Останні 30 днів"
        case all = "Всі події"
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Формат експорту")) {
                    Picker("Формат", selection: $selectedFormat) {
                        ForEach(ExportFormat.allCases, id: \.self) { format in
                            Text(format.rawValue).tag(format)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section(header: Text("Період")) {
                    Picker("Період", selection: $selectedPeriod) {
                        ForEach(ExportPeriod.allCases, id: \.self) { period in
                            Text(period.rawValue).tag(period)
                        }
                    }
                }
                
                Section(header: Text("Попередній перегляд")) {
                    let events = filteredEvents()
                    
                    if events.isEmpty {
                        Text("Немає подій для експорту")
                            .foregroundColor(.secondary)
                    } else {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Кількість подій:")
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text("\(events.count)")
                                    .fontWeight(.semibold)
                            }
                            
                            HStack {
                                Text("Відключень:")
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text("\(events.filter { $0.status == .off }.count)")
                                    .foregroundColor(.red)
                                    .fontWeight(.semibold)
                            }
                            
                            HStack {
                                Text("Увімкнень:")
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text("\(events.filter { $0.status == .on }.count)")
                                    .foregroundColor(.green)
                                    .fontWeight(.semibold)
                            }
                            
                            if let first = events.last, let last = events.first {
                                Divider()
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Період:")
                                        .foregroundColor(.secondary)
                                        .font(.caption)
                                    
                                    Text("\(first.timestamp.formatted(date: .abbreviated, time: .shortened)) - \(last.timestamp.formatted(date: .abbreviated, time: .shortened))")
                                        .font(.caption2)
                                }
                            }
                        }
                    }
                }
                
                Section {
                    Button(action: exportData) {
                        HStack {
                            Spacer()
                            Image(systemName: "square.and.arrow.up")
                            Text("Експортувати")
                                .fontWeight(.semibold)
                            Spacer()
                        }
                    }
                    .disabled(filteredEvents().isEmpty)
                }
            }
            .navigationTitle("Експорт статистики")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Закрити") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingShareSheet) {
                if let url = exportedFileURL {
                    ShareSheet(items: [url])
                }
            }
        }
    }
    
    private func filteredEvents() -> [PowerEvent] {
        let calendar = Calendar.current
        let now = Date()
        
        switch selectedPeriod {
        case .today:
            return dataManager.events.filter { calendar.isDateInToday($0.timestamp) }
        case .week:
            let weekAgo = calendar.date(byAdding: .day, value: -7, to: now)!
            return dataManager.events.filter { $0.timestamp > weekAgo }
        case .month:
            let monthAgo = calendar.date(byAdding: .day, value: -30, to: now)!
            return dataManager.events.filter { $0.timestamp > monthAgo }
        case .all:
            return dataManager.events
        }
    }
    
    private func exportData() {
        let events = filteredEvents()
        guard !events.isEmpty else { return }
        
        let content: String
        let fileExtension: String
        
        switch selectedFormat {
        case .csv:
            content = generateCSV(events: events)
            fileExtension = "csv"
        case .json:
            content = generateJSON(events: events)
            fileExtension = "json"
        case .text:
            content = generateText(events: events)
            fileExtension = "txt"
        }
        
        // Save to temporary file
        let fileName = "SvitloUA_Export_\(Date().formatted(date: .numeric, time: .omitted)).\(fileExtension)"
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        do {
            try content.write(to: tempURL, atomically: true, encoding: .utf8)
            exportedFileURL = tempURL
            showingShareSheet = true
        } catch {
            print("Error saving file: \(error)")
        }
    }
    
    private func generateCSV(events: [PowerEvent]) -> String {
        var csv = "Дата,Час,Статус\n"
        
        for event in events.reversed() {
            let date = event.timestamp.formatted(date: .numeric, time: .omitted)
            let time = event.timestamp.formatted(date: .omitted, time: .shortened)
            csv += "\(date),\(time),\(event.status.rawValue)\n"
        }
        
        return csv
    }
    
    private func generateJSON(events: [PowerEvent]) -> String {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted
        
        if let data = try? encoder.encode(events.reversed()),
           let string = String(data: data, encoding: .utf8) {
            return string
        }
        
        return "[]"
    }
    
    private func generateText(events: [PowerEvent]) -> String {
        var text = "📊 Статистика відключень SvitloUA\n"
        text += "Група: \(dataManager.settings.group)\n"
        text += "Регіон: \(dataManager.settings.region)\n"
        text += "Експортовано: \(Date().formatted(date: .long, time: .shortened))\n"
        text += "\n" + String(repeating: "-", count: 50) + "\n\n"
        
        text += "Всього подій: \(events.count)\n"
        text += "Відключень: \(events.filter { $0.status == .off }.count)\n"
        text += "Увімкнень: \(events.filter { $0.status == .on }.count)\n"
        text += "\n" + String(repeating: "-", count: 50) + "\n\n"
        
        for event in events.reversed() {
            let icon = event.status == .off ? "🔴" : "🟢"
            let dateTime = event.timestamp.formatted(date: .abbreviated, time: .shortened)
            text += "\(icon) \(event.status.rawValue) - \(dateTime)\n"
        }
        
        return text
    }
}

// MARK: - Share Sheet
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    ExportStatisticsView()
        .environmentObject(PowerDataManager.shared)
}
