//
//  ChartDataPoint.swift
//  SvitloUA
//
//  Created by Горніч Антон on 23.01.2026.
//


import Foundation

struct ChartDataPoint: Identifiable {
    let id = UUID()
    let date: String
    let count: Int
}
