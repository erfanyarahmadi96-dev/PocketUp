//
//  AppDelegate.swift
//  PocketUp
//
//  Created by Erfan Yarahmadi on 11/03/26.
//


import SwiftUI
import UserNotifications
import Combine

// MARK: - AppDelegate to register delegate as early as possible
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        // Register notification delegate immediately at launch
        UNUserNotificationCenter.current().delegate = PocketAlertState.shared
        NotificationManager.shared.requestPermission()
        return true
    }
}

// MARK: - Alert State (singleton so delegate is always alive)
class PocketAlertState: NSObject, ObservableObject, UNUserNotificationCenterDelegate {

    static let shared = PocketAlertState()

    @Published var activePocket: Pocket? = nil

    private let saveKey = "pocketup_saved_pockets"

    private override init() {
        super.init()
    }

    // MARK: - Notification tapped from banner / lock screen
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        print("📲 Notification tapped: \(response.actionIdentifier)")
        let info = response.notification.request.content.userInfo

        switch response.actionIdentifier {
        case "CONFIRM_ACTION":
            if let pocketId = info["pocketId"] as? String,
               let pocket = loadPocket(id: pocketId) {
                NotificationManager.shared.cancelAlarmChain(for: pocket)
            }

        case "SNOOZE_ACTION":
            if let pocketId = info["pocketId"] as? String,
               let pocket = loadPocket(id: pocketId) {
                NotificationManager.shared.cancelAlarmChain(for: pocket)
                snoozePocket(pocket)
            }

        default:
            // User tapped the notification body → show full screen alert
            if let pocketId = info["pocketId"] as? String {
                showAlert(pocketId: pocketId)
            }
        }

        completionHandler()
    }

    // MARK: - Notification arrives while app is FOREGROUND
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        print("🔔 Foreground notification received")
        let info = notification.request.content.userInfo

        if let pocketId = info["pocketId"] as? String {
            showAlert(pocketId: pocketId)
        }

        completionHandler([.banner, .sound])
    }

    // MARK: - Show the alert screen
    func showAlert(pocketId: String) {
        guard let pocket = loadPocket(id: pocketId) else {
            print("❌ Could not load pocket: \(pocketId)")
            return
        }
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if self.activePocket == nil {
                print("✅ Showing alert for: \(pocket.name)")
                self.activePocket = pocket
            }
        }
    }

    // MARK: - Load pocket from UserDefaults
    private func loadPocket(id: String) -> Pocket? {
        guard let data    = UserDefaults.standard.data(forKey: saveKey),
              let pockets = try? JSONDecoder().decode([Pocket].self, from: data)
        else {
            print("❌ Failed to decode pockets")
            return nil
        }
        let found = pockets.first { $0.id.uuidString == id }
        print(found != nil ? "✅ Found pocket: \(found!.name)" : "❌ Pocket not found: \(id)")
        return found
    }

    // MARK: - Snooze
    func snoozePocket(_ pocket: Pocket) {
        let content           = UNMutableNotificationContent()
        content.title         = "🎒 \(pocket.name) — Still need to pack!"
        content.body          = "Don't forget your items for \(pocket.destination)!"
        content.categoryIdentifier = "POCKET_REMINDER"
        content.sound         = .default
        content.userInfo      = ["pocketId": pocket.id.uuidString, "type": "snooze"]

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5 * 60, repeats: false)
        UNUserNotificationCenter.current().add(
            UNNotificationRequest(
                identifier: "snooze_\(pocket.id.uuidString)_\(Date().timeIntervalSince1970)",
                content:    content,
                trigger:    trigger
            )
        )
        print("⏰ Snoozed \(pocket.name) for 5 min")
    }
}
