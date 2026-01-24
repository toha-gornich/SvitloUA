import func SwiftUI.__designTimeFloat
import func SwiftUI.__designTimeString
import func SwiftUI.__designTimeInteger
import func SwiftUI.__designTimeBoolean

#sourceLocation(file: "/Users/call_the_ha/Desktop/Development/SvitloUA/SvitloWidget/PowerWidget.swift", line: 1)
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
            nextOutage: __designTimeString("#6829_0", fallback: "14:00"),
            region: __designTimeString("#6829_1", fallback: "kiev"),
            group: __designTimeString("#6829_2", fallback: "1.1"),
            todaySlots: [
                TimeSlot(start: __designTimeInteger("#6829_3", fallback: 0), end: __designTimeInteger("#6829_4", fallback: 8), type: __designTimeString("#6829_5", fallback: "NotPlanned")),
                TimeSlot(start: __designTimeInteger("#6829_6", fallback: 8), end: __designTimeInteger("#6829_7", fallback: 12), type: __designTimeString("#6829_8", fallback: "DEFINITE_OUTAGE")),
                TimeSlot(start: __designTimeInteger("#6829_9", fallback: 12), end: __designTimeInteger("#6829_10", fallback: 16), type: __designTimeString("#6829_11", fallback: "NotPlanned")),
                TimeSlot(start: __designTimeInteger("#6829_12", fallback: 16), end: __designTimeInteger("#6829_13", fallback: 20), type: __designTimeString("#6829_14", fallback: "DEFINITE_OUTAGE")),
                TimeSlot(start: __designTimeInteger("#6829_15", fallback: 20), end: __designTimeInteger("#6829_16", fallback: 24), type: __designTimeString("#6829_17", fallback: "NotPlanned"))
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
