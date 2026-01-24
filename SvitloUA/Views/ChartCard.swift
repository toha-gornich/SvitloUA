//
//  ChartCard.swift
//  SvitloUA
//
//  Created by Горніч Антон on 23.01.2026.
//


import Charts
import SwiftUI


struct ChartCard: View {
    @EnvironmentObject var dataManager: PowerDataManager
    
    var chartData: [ChartDataPoint] {
        let calendar = Calendar.current
        let last7Days = (0..<7).compactMap { i -> ChartDataPoint? in
            guard let date = calendar.date(byAdding: .day, value: -i, to: Date()) else { return nil }
            let dayEvents = dataManager.events.filter {
                calendar.isDate($0.timestamp, inSameDayAs: date) && $0.status == .off
            }
            let formatter = DateFormatter()
            formatter.dateFormat = "dd.MM"
            return ChartDataPoint(date: formatter.string(from: date), count: dayEvents.count)
        }.reversed()
        
        return Array(last7Days)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Відключення за тиждень")
                .font(.headline)
                .padding(.horizontal)
            
            Chart(chartData) { point in
                BarMark(
                    x: .value("День", point.date),
                    y: .value("Кількість", point.count)
                )
                .foregroundStyle(Color.red.gradient)
            }
            .frame(height: 200)
            .padding()
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}
