//
//  PowerWidget.swift
//  SvitloUA
//
//  Created by Горніч Антон on 24.01.2026.
//


import WidgetKit
import SwiftUI



struct PowerWidget: Widget {
    let kind: String = "PowerWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PowerWidgetProvider()) { entry in
            PowerWidgetView(entry: entry)
        }
        .configurationDisplayName("Svitlo UA")
        .description("Shows current power status and outage schedule")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}



struct PowerWidget_Previews: PreviewProvider {
    static var previews: some View {
        let sampleEntry = PowerWidgetEntry(
            date: Date(),
            currentStatus: .on,
            nextOutage: "14:00",
            region: "kyiv",
            group: "4.2",
            todaySlots: [
                TimeSlot(start: 0, end: 480, type: .notPlanned),      // 00:00 - 08:00
                TimeSlot(start: 480, end: 720, type: .definite),      // 08:00 - 12:00
                TimeSlot(start: 720, end: 960, type: .notPlanned),    // 12:00 - 16:00
                TimeSlot(start: 960, end: 1200, type: .possible),     // 16:00 - 20:00
                TimeSlot(start: 1200, end: 1440, type: .notPlanned)   // 20:00 - 24:00
            ],
            scheduleStatus: "ScheduleApplies"
        )
        
        Group {
            PowerWidgetView(entry: sampleEntry)
                .previewContext(WidgetPreviewContext(family: .systemSmall))
                .previewDisplayName("Small")
            
            PowerWidgetView(entry: sampleEntry)
                .previewContext(WidgetPreviewContext(family: .systemMedium))
                .previewDisplayName("Medium")
            
            PowerWidgetView(entry: sampleEntry)
                .previewContext(WidgetPreviewContext(family: .systemLarge))
                .previewDisplayName("Large")
        }
    }
}
