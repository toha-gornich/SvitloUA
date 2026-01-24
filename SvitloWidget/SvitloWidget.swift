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
        print("📱 Widget: Placeholder викликано")
        return PowerWidgetEntry(
            date: Date(),
            currentStatus: .on,
            nextOutage: "14:00",
            region: "dnipro",
            group: "4.2",
            todaySlots: sampleSlots()
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (PowerWidgetEntry) -> Void) {
        print("📸 Widget: Snapshot викликано, isPreview: \(context.isPreview)")
        
        if context.isPreview {
            completion(placeholder(in: context))
        } else {
            Task {
                let entry = await createEntry()
                completion(entry)
            }
        }
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<PowerWidgetEntry>) -> Void) {
        print("⏰ Widget: Timeline викликано")
        
        Task {
            let entry = await createEntry()
            
            let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
            let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
            
            print("✅ Widget: Timeline створено з \(entry.todaySlots.count) слотами")
            completion(timeline)
        }
    }
    
    private func createEntry() async -> PowerWidgetEntry {
        let settings = loadSettings()
        
        print("🔧 Widget: Налаштування - регіон: '\(settings.region)', група: '\(settings.group)'")
        
        do {
            print("🌐 Widget: Починаємо запит до API...")
            
            let slots = try await YasnoAPIService.shared.getScheduleForRegionAndGroup(
                region: settings.region,
                group: settings.group
            )
            
            print("✅ Widget: API повернув \(slots.count) слотів")
            
            for (index, slot) in slots.prefix(3).enumerated() {
                print("   Слот \(index): \(slot.startTime)-\(slot.endTime), type: \(slot.type)")
            }
            
            let currentStatus = getCurrentStatus(from: slots)
            let nextOutage = getNextOutageTime(from: slots)
            
            print("📊 Widget: Статус - \(currentStatus), наступне відключення: \(nextOutage ?? "немає")")
            
            return PowerWidgetEntry(
                date: Date(),
                currentStatus: currentStatus,
                nextOutage: nextOutage,
                region: settings.region,
                group: settings.group,
                todaySlots: slots
            )
        } catch {
            print("❌ Widget: ПОМИЛКА - \(error.localizedDescription)")
            print("   Деталі помилки: \(error)")
            
            return PowerWidgetEntry(
                date: Date(),
                currentStatus: .unknown,
                nextOutage: nil,
                region: settings.region,
                group: settings.group,
                todaySlots: sampleSlots()
            )
        }
    }
    
    private func loadSettings() -> UserSettings {
        print("💾 Widget: Завантаження налаштувань...")
        
        if let groupDefaults = UserDefaults(suiteName: "group.ua.svitlo.app") {
            print("   ✓ App Group UserDefaults створено")
            
            if let data = groupDefaults.data(forKey: "UserSettings") {
                print("   ✓ Дані UserSettings знайдено (\(data.count) байт)")
                
                if let settings = try? JSONDecoder().decode(UserSettings.self, from: data) {
                    print("   ✅ Налаштування декодовано: \(settings.region), \(settings.group)")
                    return settings
                } else {
                    print("   ❌ Помилка декодування UserSettings")
                }
            } else {
                print("   ❌ UserSettings не знайдено в App Group")
            }
        } else {
            print("   ❌ Не вдалося створити App Group UserDefaults")
        }
        
        print("   ⚠️ Використовуємо дефолтні налаштування")
        return .default
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
    
    private func sampleSlots() -> [TimeSlot] {
        return [
            TimeSlot(start: 0, end: 4, type: "POSSIBLE_OUTAGE"),
            TimeSlot(start: 4, end: 11, type: "NotPlanned"),
            TimeSlot(start: 11, end: 14.5, type: "POSSIBLE_OUTAGE"),
            TimeSlot(start: 14.5, end: 21.5, type: "NotPlanned"),
            TimeSlot(start: 21.5, end: 24, type: "POSSIBLE_OUTAGE")
        ]
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
            
            // Right side - Today's schedule (БЕЗ ScrollView!)
            VStack(alignment: .leading, spacing: 6) {
                Text("Сьогодні")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                // Просто VStack замість ScrollView
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
            
            // Schedule list
            VStack(alignment: .leading, spacing: 4) {
                Text("Графік на сьогодні")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                if entry.todaySlots.isEmpty {
                    Text("Дані недоступні")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else {
                    VStack(spacing: 4) {
                        ForEach(entry.todaySlots.prefix(8)) { slot in
                            HStack(spacing: 6) {
                                Circle()
                                    .fill(slot.isOutage ? Color.red : Color.green)
                                    .frame(width: 8, height: 8)
                                
                                Text("\(slot.startTime) - \(slot.endTime)")
                                    .font(.caption)
                                    .foregroundColor(slot.isOutage ? .red : .green)
                                
                                Spacer()
                            }
                        }
                    }
                }
            }
            
            Spacer()
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
        case .systemExtraLarge:
            LargeWidgetView(entry: entry)
        case .accessoryCircular, .accessoryRectangular, .accessoryInline:
            SmallWidgetView(entry: entry)
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
