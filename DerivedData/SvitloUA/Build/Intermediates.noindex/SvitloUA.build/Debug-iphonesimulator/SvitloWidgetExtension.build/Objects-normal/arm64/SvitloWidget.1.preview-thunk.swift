import func SwiftUI.__designTimeFloat
import func SwiftUI.__designTimeString
import func SwiftUI.__designTimeInteger
import func SwiftUI.__designTimeBoolean

#sourceLocation(file: "/Users/call_the_ha/Desktop/Development/SvitloUA/SvitloWidget/SvitloWidget.swift", line: 1)
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
        print(__designTimeString("#6236_0", fallback: "📱 Widget: Placeholder викликано"))
        return PowerWidgetEntry(
            date: Date(),
            currentStatus: .on,
            nextOutage: __designTimeString("#6236_1", fallback: "14:00"),
            region: __designTimeString("#6236_2", fallback: "dnipro"),
            group: __designTimeString("#6236_3", fallback: "4.2"),
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
        print(__designTimeString("#6236_4", fallback: "⏰ Widget: Timeline викликано"))
        
        Task {
            let entry = await createEntry()
            
            let nextUpdate = Calendar.current.date(byAdding: .minute, value: __designTimeInteger("#6236_5", fallback: 15), to: Date())!
            let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
            
            print("✅ Widget: Timeline створено з \(entry.todaySlots.count) слотами")
            completion(timeline)
        }
    }
    
    private func createEntry() async -> PowerWidgetEntry {
        let settings = loadSettings()
        
        print("🔧 Widget: Налаштування - регіон: '\(settings.region)', група: '\(settings.group)'")
        
        do {
            print(__designTimeString("#6236_6", fallback: "🌐 Widget: Починаємо запит до API..."))
            
            let slots = try await YasnoAPIService.shared.getScheduleForRegionAndGroup(
                region: settings.region,
                group: settings.group
            )
            
            print("✅ Widget: API повернув \(slots.count) слотів")
            
            for (index, slot) in slots.prefix(__designTimeInteger("#6236_7", fallback: 3)).enumerated() {
                print("   Слот \(index): \(slot.startTime)-\(slot.endTime), type: \(slot.type)")
            }
            
            let currentStatus = getCurrentStatus(from: slots)
            let nextOutage = getNextOutageTime(from: slots)
            
            print("📊 Widget: Статус - \(currentStatus), наступне відключення: \(nextOutage ?? __designTimeString("#6236_8", fallback: "немає"))")
            
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
        print(__designTimeString("#6236_9", fallback: "💾 Widget: Завантаження налаштувань..."))
        
        if let groupDefaults = UserDefaults(suiteName: __designTimeString("#6236_10", fallback: "group.ua.svitlo.app")) {
            print(__designTimeString("#6236_11", fallback: "   ✓ App Group UserDefaults створено"))
            
            if let data = groupDefaults.data(forKey: __designTimeString("#6236_12", fallback: "UserSettings")) {
                print("   ✓ Дані UserSettings знайдено (\(data.count) байт)")
                
                if let settings = try? JSONDecoder().decode(UserSettings.self, from: data) {
                    print("   ✅ Налаштування декодовано: \(settings.region), \(settings.group)")
                    return settings
                } else {
                    print(__designTimeString("#6236_13", fallback: "   ❌ Помилка декодування UserSettings"))
                }
            } else {
                print(__designTimeString("#6236_14", fallback: "   ❌ UserSettings не знайдено в App Group"))
            }
        } else {
            print(__designTimeString("#6236_15", fallback: "   ❌ Не вдалося створити App Group UserDefaults"))
        }
        
        print(__designTimeString("#6236_16", fallback: "   ⚠️ Використовуємо дефолтні налаштування"))
        return .default
    }
    
    private func getCurrentStatus(from slots: [TimeSlot]) -> PowerStatus {
        let now = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: now)
        let minute = calendar.component(.minute, from: now)
        let currentTime = Double(hour) + Double(minute) / __designTimeFloat("#6236_17", fallback: 60.0)
        
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
        let currentTime = Double(hour) + Double(minute) / __designTimeFloat("#6236_18", fallback: 60.0)
        
        if let slot = slots.first(where: { $0.start > currentTime && $0.isOutage }) {
            return slot.startTime
        }
        return nil
    }
    
    private func sampleSlots() -> [TimeSlot] {
        return [
            TimeSlot(start: __designTimeInteger("#6236_19", fallback: 0), end: __designTimeInteger("#6236_20", fallback: 4), type: __designTimeString("#6236_21", fallback: "POSSIBLE_OUTAGE")),
            TimeSlot(start: __designTimeInteger("#6236_22", fallback: 4), end: __designTimeInteger("#6236_23", fallback: 11), type: __designTimeString("#6236_24", fallback: "NotPlanned")),
            TimeSlot(start: __designTimeInteger("#6236_25", fallback: 11), end: __designTimeFloat("#6236_26", fallback: 14.5), type: __designTimeString("#6236_27", fallback: "POSSIBLE_OUTAGE")),
            TimeSlot(start: __designTimeFloat("#6236_28", fallback: 14.5), end: __designTimeFloat("#6236_29", fallback: 21.5), type: __designTimeString("#6236_30", fallback: "NotPlanned")),
            TimeSlot(start: __designTimeFloat("#6236_31", fallback: 21.5), end: __designTimeInteger("#6236_32", fallback: 24), type: __designTimeString("#6236_33", fallback: "POSSIBLE_OUTAGE"))
        ]
    }
}

// MARK: - Small Widget View
struct SmallWidgetView: View {
    let entry: PowerWidgetEntry
    
    var body: some View {
        VStack(spacing: __designTimeInteger("#6236_34", fallback: 8)) {
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
            
            VStack(alignment: .leading, spacing: __designTimeInteger("#6236_35", fallback: 4)) {
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
                gradient: Gradient(colors: [statusColor.opacity(__designTimeFloat("#6236_36", fallback: 0.2)), statusColor.opacity(__designTimeFloat("#6236_37", fallback: 0.05))]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
    
    private var statusIcon: String {
        switch entry.currentStatus {
        case .on: return __designTimeString("#6236_38", fallback: "bolt.fill")
        case .off: return __designTimeString("#6236_39", fallback: "bolt.slash.fill")
        case .unknown: return __designTimeString("#6236_40", fallback: "questionmark.circle.fill")
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
        HStack(spacing: __designTimeInteger("#6236_41", fallback: 16)) {
            // Left side - Status
            VStack(alignment: .leading, spacing: __designTimeInteger("#6236_42", fallback: 8)) {
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
                    
                    VStack(alignment: .leading, spacing: __designTimeInteger("#6236_43", fallback: 2)) {
                        Text(__designTimeString("#6236_44", fallback: "Наступне відключення"))
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
            VStack(alignment: .leading, spacing: __designTimeInteger("#6236_45", fallback: 6)) {
                Text(__designTimeString("#6236_46", fallback: "Сьогодні"))
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                // Просто VStack замість ScrollView
                VStack(spacing: __designTimeInteger("#6236_47", fallback: 4)) {
                    ForEach(entry.todaySlots.prefix(__designTimeInteger("#6236_48", fallback: 4))) { slot in
                        HStack(spacing: __designTimeInteger("#6236_49", fallback: 4)) {
                            Circle()
                                .fill(slot.isOutage ? Color.red : Color.green)
                                .frame(width: __designTimeInteger("#6236_50", fallback: 6), height: __designTimeInteger("#6236_51", fallback: 6))
                            
                            Text("\(slot.startTime)-\(slot.endTime)")
                                .font(.system(size: __designTimeInteger("#6236_52", fallback: 9), design: .monospaced))
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
                gradient: Gradient(colors: [statusColor.opacity(__designTimeFloat("#6236_53", fallback: 0.15)), statusColor.opacity(__designTimeFloat("#6236_54", fallback: 0.05))]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
    
    private var statusIcon: String {
        switch entry.currentStatus {
        case .on: return __designTimeString("#6236_55", fallback: "bolt.fill")
        case .off: return __designTimeString("#6236_56", fallback: "bolt.slash.fill")
        case .unknown: return __designTimeString("#6236_57", fallback: "questionmark.circle.fill")
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
        VStack(spacing: __designTimeInteger("#6236_58", fallback: 12)) {
            // Header
            HStack {
                Image(systemName: statusIcon)
                    .font(.title)
                    .foregroundColor(statusColor)
                
                VStack(alignment: .leading, spacing: __designTimeInteger("#6236_59", fallback: 2)) {
                    Text(entry.currentStatus.rawValue)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Група \(entry.group)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if let nextOutage = entry.nextOutage {
                    VStack(alignment: .trailing, spacing: __designTimeInteger("#6236_60", fallback: 2)) {
                        Text(__designTimeString("#6236_61", fallback: "Наступне"))
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
            VStack(alignment: .leading, spacing: __designTimeInteger("#6236_62", fallback: 4)) {
                Text(__designTimeString("#6236_63", fallback: "Графік на сьогодні"))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                if entry.todaySlots.isEmpty {
                    Text(__designTimeString("#6236_64", fallback: "Дані недоступні"))
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else {
                    VStack(spacing: __designTimeInteger("#6236_65", fallback: 4)) {
                        ForEach(entry.todaySlots.prefix(__designTimeInteger("#6236_66", fallback: 8))) { slot in
                            HStack(spacing: __designTimeInteger("#6236_67", fallback: 6)) {
                                Circle()
                                    .fill(slot.isOutage ? Color.red : Color.green)
                                    .frame(width: __designTimeInteger("#6236_68", fallback: 8), height: __designTimeInteger("#6236_69", fallback: 8))
                                
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
                gradient: Gradient(colors: [statusColor.opacity(__designTimeFloat("#6236_70", fallback: 0.15)), statusColor.opacity(__designTimeFloat("#6236_71", fallback: 0.05))]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
    
    private var statusIcon: String {
        switch entry.currentStatus {
        case .on: return __designTimeString("#6236_72", fallback: "bolt.fill")
        case .off: return __designTimeString("#6236_73", fallback: "bolt.slash.fill")
        case .unknown: return __designTimeString("#6236_74", fallback: "questionmark.circle.fill")
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
            nextOutage: __designTimeString("#6236_75", fallback: "14:00"),
            region: __designTimeString("#6236_76", fallback: "kiev"),
            group: __designTimeString("#6236_77", fallback: "1.1"),
            todaySlots: [
                TimeSlot(start: __designTimeInteger("#6236_78", fallback: 0), end: __designTimeInteger("#6236_79", fallback: 8), type: __designTimeString("#6236_80", fallback: "NotPlanned")),
                TimeSlot(start: __designTimeInteger("#6236_81", fallback: 8), end: __designTimeInteger("#6236_82", fallback: 12), type: __designTimeString("#6236_83", fallback: "DEFINITE_OUTAGE")),
                TimeSlot(start: __designTimeInteger("#6236_84", fallback: 12), end: __designTimeInteger("#6236_85", fallback: 16), type: __designTimeString("#6236_86", fallback: "NotPlanned")),
                TimeSlot(start: __designTimeInteger("#6236_87", fallback: 16), end: __designTimeInteger("#6236_88", fallback: 20), type: __designTimeString("#6236_89", fallback: "DEFINITE_OUTAGE")),
                TimeSlot(start: __designTimeInteger("#6236_90", fallback: 20), end: __designTimeInteger("#6236_91", fallback: 24), type: __designTimeString("#6236_92", fallback: "NotPlanned"))
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
