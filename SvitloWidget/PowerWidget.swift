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
        .configurationDisplayName("Світло UA")
        .description("Показує поточний статус та графік відключень")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}



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
