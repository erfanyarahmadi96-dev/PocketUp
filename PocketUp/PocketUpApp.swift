//
//  PocketUpApp.swift
//  PocketUp
//
//  Created by Erfan Yarahmadi on 10/03/26.
//

import SwiftUI
import UserNotifications
import Combine

@main
struct PocketUpApp: App {
    @StateObject private var alertState: PocketAlertState = {
        return PocketAlertState.shared
    }()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
                .environmentObject(alertState)
                .fullScreenCover(item: $alertState.activePocket) { pocket in
                    PocketAlertView(
                        pocket: pocket,
                        onConfirmed: {
                            NotificationManager.shared.cancelAlarmChain(for: pocket)
                            alertState.activePocket = nil
                        },
                        onDismiss: {
                            alertState.snoozePocket(pocket)
                            alertState.activePocket = nil
                        }
                    )
                }
        }
    }
}
