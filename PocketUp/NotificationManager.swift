//
//  NotificationManager.swift
//  PocketUp
//
//  Created by Erfan Yarahmadi on 10/03/26.
//




import Foundation
import UserNotifications
import UIKit

class NotificationManager {
    static let shared = NotificationManager()
    private init() {}

    // MARK: - Permission (request Critical Alerts too)
    func requestPermission() {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge, .criticalAlert]) { granted, error in
                if let error = error {
                    print("❌ Notification permission error: \(error)")
                } else {
                    print(granted ? "✅ Notifications granted" : "⚠️ Notifications denied")
                }
                DispatchQueue.main.async {
                    self.registerCategories()
                }
            }
    }

    // MARK: - Register action categories
    private func registerCategories() {
        let confirmAction = UNNotificationAction(
            identifier: "CONFIRM_ACTION",
            title: "✅ I've got everything!",
            options: [.foreground]
        )
        let snoozeAction = UNNotificationAction(
            identifier: "SNOOZE_ACTION",
            title: "⏰ Snooze 5 minutes",
            options: []
        )
        let pocketCategory = UNNotificationCategory(
            identifier: "POCKET_REMINDER",
            actions: [confirmAction, snoozeAction],
            intentIdentifiers: [],
            options: [.customDismissAction]
        )
        UNUserNotificationCenter.current().setNotificationCategories([pocketCategory])
    }

    // MARK: - Schedule repeating alarm chain
    // Fires immediately, then every `repeatIntervalMinutes` until user confirms
    func scheduleAlarmChain(for pocket: Pocket, repeatIntervalMinutes: Int = 2) {
        let center = UNUserNotificationCenter.current()

        // Schedule 5 follow-up notifications (covers ~10 mins of nagging)
        for i in 0..<5 {
            let delay = TimeInterval(i * repeatIntervalMinutes * 60)
            scheduleAlarmNotification(for: pocket, delay: delay, index: i, center: center)
        }
        print("🔔 Alarm chain scheduled for \(pocket.name)")
    }

    private func scheduleAlarmNotification(
        for pocket: Pocket,
        delay: TimeInterval,
        index: Int,
        center: UNUserNotificationCenter
    ) {
        let itemList = pocket.essentialItems.prefix(3)
            .map { "\($0.emoji) \($0.name)" }.joined(separator: ", ")
        let body = itemList.isEmpty
            ? "Don't forget your items for \(pocket.destination)!"
            : "Don't forget: \(itemList)"

        let content           = UNMutableNotificationContent()
        content.title         = index == 0
            ? "🎒 \(pocket.name) — Time to Pack!"
            : "🎒 \(pocket.name) — Still need to pack!"
        content.body          = body
        content.categoryIdentifier = "POCKET_REMINDER"
        content.userInfo      = [
            "pocketId": pocket.id.uuidString,
            "type": "depart",
            "chainIndex": index
        ]

        // Use critical sound if available (bypasses silent mode)
        // Falls back to default if critical alerts not granted
        if #available(iOS 15.0, *) {
            content.interruptionLevel = .timeSensitive
        }
        content.sound = UNNotificationSound.defaultCritical

        let trigger = delay == 0
            ? UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            : UNTimeIntervalNotificationTrigger(timeInterval: delay, repeats: false)

        let identifier = "alarm_\(pocket.id.uuidString)_\(index)"
        let request    = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        center.add(request) { error in
            if let error = error {
                print("❌ Failed chain[\(index)]: \(error)")
            } else {
                let mins = Int(delay / 60)
                print("✅ Alarm chain[\(index)] in \(mins) min for \(pocket.name)")
            }
        }
    }

    // MARK: - Cancel alarm chain (call when user confirms)
    func cancelAlarmChain(for pocket: Pocket) {
        let ids = (0..<5).map { "alarm_\(pocket.id.uuidString)_\($0)" }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ids)
        print("🗑 Alarm chain cancelled for \(pocket.name)")
    }

    // MARK: - Schedule regular weekly notifications
    func scheduleNotifications(for pocket: Pocket) {
        guard pocket.isActive else { return }
        let center   = UNUserNotificationCenter.current()
        let calendar = Calendar.current
        let schedule = pocket.schedule

        for day in schedule.daysOfWeek {

            // Departure
            if schedule.remindOnDepart {
                guard let reminderDate = calendar.date(
                    byAdding: .minute,
                    value: -schedule.advanceMinutes,
                    to: schedule.departureTime
                ) else { continue }

                var comps     = calendar.dateComponents([.hour, .minute], from: reminderDate)
                comps.weekday = day
                comps.second  = 0

                let itemList = pocket.essentialItems.prefix(3)
                    .map { "\($0.emoji) \($0.name)" }.joined(separator: ", ")

                let content = UNMutableNotificationContent()
                content.title    = "🎒 \(pocket.name) — Time to Pack!"
                content.body     = itemList.isEmpty
                    ? "Don't forget your items for \(pocket.destination)!"
                    : "Don't forget: \(itemList)"
                content.categoryIdentifier = "POCKET_REMINDER"
                content.userInfo = ["pocketId": pocket.id.uuidString, "type": "depart"]
                content.sound    = UNNotificationSound.defaultCritical

                if #available(iOS 15.0, *) {
                    content.interruptionLevel = .timeSensitive
                }

                center.add(UNNotificationRequest(
                    identifier: "depart_\(pocket.id.uuidString)_\(day)",
                    content:    content,
                    trigger:    UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)
                )) { error in
                    if let error = error { print("❌ \(error)") }
                    else { print("✅ Weekly depart scheduled: \(pocket.name) weekday \(day)") }
                }
            }

            // Return
            if schedule.remindOnReturn {
                var comps     = calendar.dateComponents([.hour, .minute], from: schedule.returnTime)
                comps.weekday = day
                comps.second  = 0

                let content = UNMutableNotificationContent()
                content.title    = "🏠 Leaving \(pocket.destination)?"
                content.body     = "Make sure you haven't left anything behind!"
                content.categoryIdentifier = "POCKET_REMINDER"
                content.userInfo = ["pocketId": pocket.id.uuidString, "type": "return"]
                content.sound    = UNNotificationSound.defaultCritical

                if #available(iOS 15.0, *) {
                    content.interruptionLevel = .timeSensitive
                }

                center.add(UNNotificationRequest(
                    identifier: "return_\(pocket.id.uuidString)_\(day)",
                    content:    content,
                    trigger:    UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)
                )) { error in
                    if let error = error { print("❌ \(error)") }
                    else { print("✅ Weekly return scheduled: \(pocket.name) weekday \(day)") }
                }
            }
        }
    }

    func cancelNotifications(for pocket: Pocket) {
        let ids = (1...7).flatMap { day in [
            "depart_\(pocket.id.uuidString)_\(day)",
            "return_\(pocket.id.uuidString)_\(day)"
        ]}
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ids)
        cancelAlarmChain(for: pocket)
        print("🗑 All notifications cancelled for \(pocket.name)")
    }

    func rescheduleNotifications(for pocket: Pocket) {
        cancelNotifications(for: pocket)
        scheduleNotifications(for: pocket)
    }

    func debugPrintPending() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            print("📋 Pending notifications (\(requests.count)):")
            for r in requests {
                if let t = r.trigger as? UNCalendarNotificationTrigger {
                    print("  • \(r.identifier) → \(t.dateComponents)")
                } else if let t = r.trigger as? UNTimeIntervalNotificationTrigger {
                    print("  • \(r.identifier) → in \(Int(t.timeInterval))s")
                }
            }
        }
    }
}
