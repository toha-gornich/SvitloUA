//
//  NotificationManager.swift
//  SvitloUA
//
//  Created by Горніч Антон on 09.02.2026.
//
import Foundation
import UserNotifications

class NotificationManager: ObservableObject {
    
    static let shared = NotificationManager()
    
    @Published var isAuthorized = false
    
    private init() {
        checkAuthorization()
    }
    
    // MARK: - Authorization
    
    func requestAuthorization() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
            
            await MainActor.run {
                self.isAuthorized = granted
            }
            
            print(granted ? "✅ Notifications authorized" : "❌ Notifications denied")
            return granted
        } catch {
            print("❌ Error requesting authorization: \(error)")
            return false
        }
    }
    
    func checkAuthorization() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.isAuthorized = settings.authorizationStatus == .authorized
            }
        }
    }
    
    // MARK: - Schedule Notifications
    
    func scheduleOutageReminder(slot: TimeSlot, minutesBefore: Int = 15) {
        guard isAuthorized else {
            print("⚠️ Notifications not authorized")
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = "⚡ Увага!"
        content.body = "Світло вимкнуть о \(slot.startTime). Зарядіть пристрої!"
        content.sound = .default
        content.badge = 1
        
        
        let calendar = Calendar.current
        let now = Date()
        let notificationMinute = slot.start - minutesBefore
        
        guard notificationMinute > 0 else { return }
        
        var dateComponents = calendar.dateComponents([.year, .month, .day], from: now)
        dateComponents.hour = notificationMinute / 60
        dateComponents.minute = notificationMinute % 60
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "outage-\(slot.start)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Error scheduling notification: \(error)")
            } else {
                print("✅ Notification scheduled for \(slot.startTime)")
            }
        }
    }
    
    
    func schedulePowerOnNotification(slot: TimeSlot) {
        guard isAuthorized else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "💡 Світло повернулося!"
        content.body = "Планове відключення закінчилося о \(slot.endTime)"
        content.sound = .default
        
        let calendar = Calendar.current
        let now = Date()
        
        var dateComponents = calendar.dateComponents([.year, .month, .day], from: now)
        dateComponents.hour = slot.end / 60
        dateComponents.minute = slot.end % 60
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "power-on-\(slot.end)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Error: \(error)")
            } else {
                print("✅ Power-on notification scheduled for \(slot.endTime)")
            }
        }
    }
    
    

    func sendTestNotification() {
        let content = UNMutableNotificationContent()
        content.title = "🧪 Тестове сповіщення"
        content.body = "Сповіщення працюють правильно!"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
        print("🧪 Test notification scheduled in 5 seconds")
    }
    
    // MARK: - Manage Notifications
    
    
    func cancelAllNotifications() {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        center.removeAllDeliveredNotifications()
        print("🗑️ All notifications cancelled")
    }
    
    
    func cancelNotification(identifier: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    
    func scheduleNotificationsForToday(slots: [TimeSlot], minutesBefore: Int = 15) {
        
        cancelAllNotifications()
        
        let now = Date()
        let calendar = Calendar.current
        let currentMinute = calendar.component(.hour, from: now) * 60 + calendar.component(.minute, from: now)
        
        
        for slot in slots where slot.start > currentMinute && (slot.type == .definite || slot.type == .possible) {
            scheduleOutageReminder(slot: slot, minutesBefore: minutesBefore)
            schedulePowerOnNotification(slot: slot)
        }
    }
}
