//
//  SvitloWidget.swift
//  SvitloWidget
//
//  Created by Горніч Антон on 23.01.2026.
//

import WidgetKit
import SwiftUI

// MARK: - Widget Entry
struct PowerWidgetEntry: TimelineEntry {
    let date: Date
    let currentStatus: PowerStatus
    let nextOutage: String?
    let region: String
    let group: String
    let todaySlots: [TimeSlot]
}

// MARK: - Widget Provider
struct PowerWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> PowerWidgetEntry {
        PowerWidgetEntry(
            date: Date(),
            currentStatus: .unknown,
            nextOutage: nil,
            region: "kiev",
            group: "1.1",
            todaySlots: []
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (PowerWidgetEntry) -> Void) {
        Task {
            let entry = await createEntry()
            completion(entry)
        }
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<PowerWidgetEntry>) -> Void) {
        Task {
            let entry = await createEntry()
            
            // Оновлюємо віджет кожні 15 хвилин
            let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
            let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
            
            completion(timeline)
        }
    }
    
    private func createEntry() async -> PowerWidgetEntry {
        let settings = loadSettings()
        
        do {
            let (todaySlots, _) = try await YasnoAPIService.shared.getScheduleForRegionAndGroup(
                region: settings.region,
                group: settings.group
            )
            
            let currentStatus = getCurrentStatus(from: todaySlots)
            let nextOutage = getNextOutageTime(from: todaySlots)
            
            return PowerWidgetEntry(
                date: Date(),
                currentStatus: currentStatus,
                nextOutage: nextOutage,
                region: settings.region,
                group: settings.group,
                todaySlots: todaySlots
            )
        } catch {
            return PowerWidgetEntry(
                date: Date(),
                currentStatus: .unknown,
                nextOutage: nil,
                region: settings.region,
                group: settings.group,
                todaySlots: []
            )
        }
    }
    
    private func loadSettings() -> UserSettings {
        guard let data = UserDefaults(suiteName: "group.ua.svitlo.app")?.data(forKey: "UserSettings"),
              let settings = try? JSONDecoder().decode(UserSettings.self, from: data) else {
            return .default
        }
        return settings
    }
    
    private func getCurrentStatus(from slots: [TimeSlot]) -> PowerStatus {
        let now = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: now)
        let minute = calendar.component(.minute, from: now)
        let currentTime = Double(hour) + Double(minute) / 60.0
        
        if let slot = slots.first(where: { $0.start <= currentTime && currentTime < $0.end }) {
            return slot.isOutage ? .off : .on
        }
        return .on
    }
    
    private func getNextOutageTime(from slots: [TimeSlot]) -> String? {
        let now = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: now)
        let minute = calendar.component(.minute, from: now)
        let currentTime = Double(hour) + Double(minute) / 60.0
        
        if let slot = slots.first(where: { $0.start > currentTime && $0.isOutage }) {
            return slot.startTime
        }
        return nil
    }
}

// MARK: - Small Widget View
struct SmallWidgetView: View {
    let entry: PowerWidgetEntry
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: statusIcon)
                    .font(.title2)
                    .foregroundColor(statusColor)
                
                Spacer()
                
                Text(entry.group)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.currentStatus.rawValue)
                    .font(.headline)
                    .fontWeight(.bold)
                
                if let nextOutage = entry.nextOutage {
                    Text("Наступне: \(nextOutage)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(
            LinearGradient(
                gradient: Gradient(colors: [statusColor.opacity(0.2), statusColor.opacity(0.05)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
    
    private var statusIcon: String {
        switch entry.currentStatus {
        case .on: return "bolt.fill"
        case .off: return "bolt.slash.fill"
        case .unknown: return "questionmark.circle.fill"
        }
    }
    
    private var statusColor: Color {
        switch entry.currentStatus {
        case .on: return .green
        case .off: return .red
        case .unknown: return .gray
        }
    }
}

// MARK: - Medium Widget View
struct MediumWidgetView: View {
    let entry: PowerWidgetEntry
    
    var body: some View {
        HStack(spacing: 16) {
            // Left side - Status
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: statusIcon)
                        .font(.largeTitle)
                        .foregroundColor(statusColor)
                    
                    Spacer()
                }
                
                Text(entry.currentStatus.rawValue)
                    .font(.title3)
                    .fontWeight(.bold)
                
                Text("Група \(entry.group)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if let nextOutage = entry.nextOutage {
                    Spacer()
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Наступне відключення")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text(nextOutage)
                            .font(.caption)
                            .fontWeight(.semibold)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Divider()
            
            // Right side - Today's schedule
            VStack(alignment: .leading, spacing: 6) {
                Text("Сьогодні")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                ScrollView {
                    VStack(spacing: 4) {
                        ForEach(entry.todaySlots.prefix(4)) { slot in
                            HStack(spacing: 4) {
                                Circle()
                                    .fill(slot.isOutage ? Color.red : Color.green)
                                    .frame(width: 6, height: 6)
                                
                                Text("\(slot.startTime)-\(slot.endTime)")
                                    .font(.system(size: 9, design: .monospaced))
                                    .foregroundColor(slot.isOutage ? .red : .green)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding()
        .background(
            LinearGradient(
                gradient: Gradient(colors: [statusColor.opacity(0.15), statusColor.opacity(0.05)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
    
    private var statusIcon: String {
        switch entry.currentStatus {
        case .on: return "bolt.fill"
        case .off: return "bolt.slash.fill"
        case .unknown: return "questionmark.circle.fill"
        }
    }
    
    private var statusColor: Color {
        switch entry.currentStatus {
        case .on: return .green
        case .off: return .red
        case .unknown: return .gray
        }
    }
}

// MARK: - Large Widget View
struct LargeWidgetView: View {
    let entry: PowerWidgetEntry
    
    var body: some View {
        VStack(spacing: 12) {
            // Header
            HStack {
                Image(systemName: statusIcon)
                    .font(.title)
                    .foregroundColor(statusColor)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(entry.currentStatus.rawValue)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Група \(entry.group)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if let nextOutage = entry.nextOutage {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Наступне")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text(nextOutage)
                            .font(.caption)
                            .fontWeight(.semibold)
                    }
                }
            }
            
            Divider()
            
            // Timeline view
            VStack(alignment: .leading, spacing: 8) {
                Text("Графік на сьогодні")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                TimelineView(slots: entry.todaySlots)
            }
        }
        .padding()
        .background(
            LinearGradient(
                gradient: Gradient(colors: [statusColor.opacity(0.15), statusColor.opacity(0.05)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
    
    private var statusIcon: String {
        switch entry.currentStatus {
        case .on: return "bolt.fill"
        case .off: return "bolt.slash.fill"
        case .unknown: return "questionmark.circle.fill"
        }
    }
    
    private var statusColor: Color {
        switch entry.currentStatus {
        case .on: return .green
        case .off: return .red
        case .unknown: return .gray
        }
    }
}

// MARK: - Timeline View
struct TimelineView: View {
    let slots: [TimeSlot]
    
    var body: some View {
        VStack(spacing: 6) {
            ForEach(slots) { slot in
                HStack(spacing: 8) {
                    // Time
                    Text("\(slot.startTime)")
                        .font(.system(size: 11, design: .monospaced))
                        .frame(width: 40, alignment: .leading)
                    
                    // Bar
                    GeometryReader { geometry in
                        let startPercent = slot.start / 24.0
                        let duration = (slot.end - slot.start) / 24.0
                        
                        Rectangle()
                            .fill(slot.isOutage ? Color.red : Color.green)
                            .frame(
                                width: geometry.size.width * duration,
                                height: 8
                            )
                            .offset(x: geometry.size.width * startPercent)
                    }
                    .frame(height: 8)
                    
                    // End time
                    Text("\(slot.endTime)")
                        .font(.system(size: 11, design: .monospaced))
                        .frame(width: 40, alignment: .trailing)
                }
            }
        }
    }
}

// MARK: - Widget Configuration
struct PowerWidget: Widget {
    let kind: String = "PowerWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PowerWidgetProvider()) { entry in
            PowerWidgetView(entry: entry)
        }
        .configurationDisplayName("Світло UA")
        .description("Показує поточний статус та графік відключень")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

// MARK: - Widget View (Main)
struct PowerWidgetView: View {
    @Environment(\.widgetFamily) var family
    let entry: PowerWidgetEntry
    
    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        case .systemLarge:
            LargeWidgetView(entry: entry)
        @unknown default:
            SmallWidgetView(entry: entry)
        }
    }
}

// MARK: - Widget Bundle
@main
struct SvitloWidgetBundle: WidgetBundle {
    var body: some Widget {
        PowerWidget()
    }
}

// MARK: - Preview
struct PowerWidget_Previews: PreviewProvider {
    static var previews: some View {
        let sampleEntry = PowerWidgetEntry(
            date: Date(),
            currentStatus: .on,
            nextOutage: "14:00",
            region: "kiev",
            group: "1.1",
            todaySlots: [
                TimeSlot(start: 0, end: 8, type: "NotPlanned"),
                TimeSlot(start: 8, end: 12, type: "DEFINITE_OUTAGE"),
                TimeSlot(start: 12, end: 16, type: "NotPlanned"),
                TimeSlot(start: 16, end: 20, type: "DEFINITE_OUTAGE"),
                TimeSlot(start: 20, end: 24, type: "NotPlanned")
            ]
        )
        
        Group {
            PowerWidgetView(entry: sampleEntry)
                .previewContext(WidgetPreviewContext(family: .systemSmall))
            
            PowerWidgetView(entry: sampleEntry)
                .previewContext(WidgetPreviewContext(family: .systemMedium))
            
            PowerWidgetView(entry: sampleEntry)
                .previewContext(WidgetPreviewContext(family: .systemLarge))
        }
    }
}
