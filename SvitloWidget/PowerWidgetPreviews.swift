//
//  PowerWidgetPreviews.swift
//  SvitloUATests
//
//  Created by Горніч Антон on 11.02.2026.
//


import WidgetKit
import SwiftUI

// MARK: - Small Widget Previews (Preview-Safe)
struct SmallWidgetPreviews: PreviewProvider {
    static var previews: some View {
        Group {
            SmallWidgetView(entry: normalEntry())
                .previewContext(WidgetPreviewContext(family: .systemSmall))
                .previewDisplayName("✅ Small - Normal")

            SmallWidgetView(entry: outageNowEntry())
                .previewContext(WidgetPreviewContext(family: .systemSmall))
                .previewDisplayName("❌ Small - Outage Now")

            SmallWidgetView(entry: errorEntry())
                .previewContext(WidgetPreviewContext(family: .systemSmall))
                .previewDisplayName("⚠️ Small - Error")
        }
    }

    // MARK: - Preview Entries

    static func normalEntry() -> PowerWidgetEntry {
        PowerWidgetEntry(
            date: Date(),
            currentStatus: .on,
            nextOutage: "14:00",
            region: "Київ",
            group: "2.2",
            todaySlots: previewSafeSlots(type: .notPlanned),
            scheduleStatus: "ScheduleApplies"
        )
    }

    static func outageNowEntry() -> PowerWidgetEntry {
        PowerWidgetEntry(
            date: Date(),
            currentStatus: .off,
            nextOutage: nil,
            region: "Київ",
            group: "2.2",
            todaySlots: previewSafeSlots(type: .definite),
            scheduleStatus: "ScheduleApplies"
        )
    }

    static func errorEntry() -> PowerWidgetEntry {
        PowerWidgetEntry(
            date: Date(),
            currentStatus: .unknown,
            nextOutage: nil,
            region: "Київ",
            group: "2.2",
            todaySlots: previewSafeSlots(type: .notPlanned),
            scheduleStatus: "Unknown"
        )
    }

    // MARK: - Preview Safe Slots
    static func previewSafeSlots(
        type: TimeSlot.OutageType
    ) -> [TimeSlot] {
        [
            TimeSlot(
                start: 0,
                end: 1440,
                type: type
            )
        ]
    }
}


// MARK: - Medium Widget Previews
struct MediumWidgetPreviews: PreviewProvider {
    static var previews: some View {
        Group {
            MediumWidgetView(entry: normalEntry())
                .previewContext(WidgetPreviewContext(family: .systemMedium))
                .previewDisplayName("✅ Medium - Normal")
            
            MediumWidgetView(entry: outageSoonEntry())
                .previewContext(WidgetPreviewContext(family: .systemMedium))
                .previewDisplayName("⏰ Medium - Outage Soon")
            
            MediumWidgetView(entry: errorEntry())
                .previewContext(WidgetPreviewContext(family: .systemMedium))
                .previewDisplayName("⚠️ Medium - Error")
        }
    }
    
    static func normalEntry() -> PowerWidgetEntry {
        PowerWidgetEntry(
            date: Date(),
            currentStatus: .on,
            nextOutage: "14:00",
            region: "Київ",
            group: "2.2",
            todaySlots: [
                TimeSlot(start: 0, end: 360, type: .notPlanned),
                TimeSlot(start: 360, end: 600, type: .definite),
                TimeSlot(start: 600, end: 900, type: .notPlanned),
                TimeSlot(start: 900, end: 1140, type: .possible),
                TimeSlot(start: 1140, end: 1440, type: .notPlanned)
            ],
            scheduleStatus: "ScheduleApplies"
        )
    }
    
    static func outageSoonEntry() -> PowerWidgetEntry {
        PowerWidgetEntry(
            date: Date(),
            currentStatus: .on,
            nextOutage: "13:45",
            region: "Київ",
            group: "2.2",
            todaySlots: [
                TimeSlot(start: 0, end: 825, type: .notPlanned),
                TimeSlot(start: 825, end: 1080, type: .definite),
                TimeSlot(start: 1080, end: 1440, type: .notPlanned)
            ],
            scheduleStatus: "ScheduleApplies"
        )
    }
    
    static func errorEntry() -> PowerWidgetEntry {
        PowerWidgetEntry(
            date: Date(),
            currentStatus: .unknown,
            nextOutage: nil,
            region: "Київ",
            group: "2.2",
            todaySlots: [],
            scheduleStatus: "Unknown"
        )
    }
}

// MARK: - Large Widget Previews
struct LargeWidgetPreviews: PreviewProvider {
    static var previews: some View {
        Group {
            LargeWidgetView(entry: fullScheduleEntry())
                .previewContext(WidgetPreviewContext(family: .systemLarge))
                .previewDisplayName("✅ Large - Full Schedule")
            
            LargeWidgetView(entry: manyOutagesEntry())
                .previewContext(WidgetPreviewContext(family: .systemLarge))
                .previewDisplayName("❌ Large - Many Outages")
            
            LargeWidgetView(entry: unconfirmedEntry())
                .previewContext(WidgetPreviewContext(family: .systemLarge))
                .previewDisplayName("⚠️ Large - Unconfirmed")
        }
    }
    
    static func fullScheduleEntry() -> PowerWidgetEntry {
        PowerWidgetEntry(
            date: Date(),
            currentStatus: .on,
            nextOutage: "11:00",
            region: "Київ",
            group: "4.2",
            todaySlots: [
                TimeSlot(start: 0, end: 240, type: .possible),
                TimeSlot(start: 240, end: 480, type: .notPlanned),
                TimeSlot(start: 480, end: 660, type: .definite),
                TimeSlot(start: 660, end: 900, type: .notPlanned),
                TimeSlot(start: 900, end: 1080, type: .possible),
                TimeSlot(start: 1080, end: 1260, type: .notPlanned),
                TimeSlot(start: 1260, end: 1440, type: .definite)
            ],
            scheduleStatus: "ScheduleApplies"
        )
    }
    
    static func manyOutagesEntry() -> PowerWidgetEntry {
        PowerWidgetEntry(
            date: Date(),
            currentStatus: .off,
            nextOutage: nil,
            region: "Київ",
            group: "2.2",
            todaySlots: [
                TimeSlot(start: 0, end: 180, type: .definite),
                TimeSlot(start: 180, end: 360, type: .notPlanned),
                TimeSlot(start: 360, end: 540, type: .definite),
                TimeSlot(start: 540, end: 720, type: .notPlanned),
                TimeSlot(start: 720, end: 900, type: .definite),
                TimeSlot(start: 900, end: 1080, type: .notPlanned),
                TimeSlot(start: 1080, end: 1260, type: .definite),
                TimeSlot(start: 1260, end: 1440, type: .notPlanned)
            ],
            scheduleStatus: "ScheduleApplies"
        )
    }
    
    static func unconfirmedEntry() -> PowerWidgetEntry {
        PowerWidgetEntry(
            date: Date(),
            currentStatus: .on,
            nextOutage: "14:00",
            region: "Київ",
            group: "3.1",
            todaySlots: [
                TimeSlot(start: 0, end: 480, type: .notPlanned),
                TimeSlot(start: 480, end: 720, type: .possible),
                TimeSlot(start: 720, end: 1440, type: .notPlanned)
            ],
            scheduleStatus: "Unconfirmed"
        )
    }
}
