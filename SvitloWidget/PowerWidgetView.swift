//
//  PowerWidgetView.swift
//  SvitloUA
//
//  Created by Горніч Антон on 24.01.2026.
//


import WidgetKit
import SwiftUI

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