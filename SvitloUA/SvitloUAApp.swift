//
//  SvitloUAApp.swift
//  SvitloUA
//
//  Created by Горніч Антон on 23.01.2026.
//

import SwiftUI

@main
struct SvitloUAApp: App {
    @StateObject private var dataManager = PowerDataManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(dataManager)
        }
    }
}
