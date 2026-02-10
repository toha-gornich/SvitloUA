//
//  SvitloUAApp.swift
//  SvitloUA
//
//  Created by Горніч Антон on 23.01.2026.
//

import SwiftUI
import UserNotifications

@main
struct SvitloUAApp: App {
    @StateObject private var dataManager = PowerDataManager.shared
    
    init() {
        setupTabBarAppearance()
        UNUserNotificationCenter.current().delegate = NotificationDelegate.shared
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(dataManager)
        }
    }
    
    private func setupTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        
        // Dark mode
        let darkAppearance = UITabBarAppearance()
        darkAppearance.configureWithOpaqueBackground()
        darkAppearance.backgroundColor = UIColor(red: 0.11, green: 0.11, blue: 0.12, alpha: 1.0) // Сірий
        
        // Light mode
        let lightAppearance = UITabBarAppearance()
        lightAppearance.configureWithOpaqueBackground()
        lightAppearance.backgroundColor = .white
        
        // implement
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}


class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationDelegate()
    
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .badge])
    }
    

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        print("📲 User tapped notification: \(response.notification.request.identifier)")
        completionHandler()
    }
}
