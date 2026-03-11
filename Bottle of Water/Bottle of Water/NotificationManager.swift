//
//  NotificationManager.swift
//  Bottle of Water
//
//  Created by Yiğit Bal on 8.01.2026.
//

import UserNotifications
import Foundation

struct NotificationManager {

    // MARK: - Permission

    static func requestPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            DispatchQueue.main.async { completion(granted) }
        }
    }

    static func checkPermissionStatus(completion: @escaping (UNAuthorizationStatus) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async { completion(settings.authorizationStatus) }
        }
    }

    // MARK: - Schedule

    /// Cancels all pending routine notifications and reschedules only enabled ones.
    static func scheduleRoutineNotifications(routines: [RoutineItem]) {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()

        for routine in routines where routine.isEnabled {
            let content = UNMutableNotificationContent()
            content.title = "💧 \(routine.name)"
            content.body = routine.prompt
            content.sound = .default

            var components = DateComponents()
            components.hour = routine.notificationHour
            components.minute = 0

            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
            let request = UNNotificationRequest(
                identifier: "routine_\(routine.id)",
                content: content,
                trigger: trigger
            )
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        }
    }

    static func cancelAll() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }

    // MARK: - Helpers

    static func hourLabel(_ hour: Int) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: Date())
        components.hour = hour
        components.minute = 0
        if let date = calendar.date(from: components) {
            return formatter.string(from: date)
        }
        return "\(hour):00"
    }
}
