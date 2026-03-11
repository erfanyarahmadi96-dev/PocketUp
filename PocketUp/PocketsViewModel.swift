//
//  PocketsViewModel.swift
//  PocketUp
//
//  Created by Erfan Yarahmadi on 10/03/26.
//


import Foundation
import SwiftUI
import Combine

@MainActor
class PocketsViewModel: ObservableObject {
    @Published var pockets: [Pocket] = []

    private let saveKey = "pocketup_saved_pockets"

    init() {
        load()
    }

    // MARK: - Pocket CRUD
    func addPocket(_ pocket: Pocket) {
        pockets.append(pocket)
        save()
        NotificationManager.shared.scheduleNotifications(for: pocket)
    }

    func updatePocket(_ pocket: Pocket) {
        if let idx = pockets.firstIndex(where: { $0.id == pocket.id }) {
            pockets[idx] = pocket
            save()
            NotificationManager.shared.rescheduleNotifications(for: pocket)
        }
    }

    func deletePocket(_ pocket: Pocket) {
        pockets.removeAll { $0.id == pocket.id }
        save()
        NotificationManager.shared.cancelNotifications(for: pocket)
    }

    func toggleActive(_ pocket: Pocket) {
        var updated = pocket
        updated.isActive.toggle()
        updatePocket(updated)
    }

    // MARK: - Item CRUD
    func addItem(_ item: PocketItem, to pocket: Pocket) {
        var updated = pocket
        updated.items.append(item)
        updatePocket(updated)
    }

    func removeItem(_ item: PocketItem, from pocket: Pocket) {
        var updated = pocket
        updated.items.removeAll { $0.id == item.id }
        updatePocket(updated)
    }

    func updateItem(_ item: PocketItem, in pocket: Pocket) {
        var updated = pocket
        if let idx = updated.items.firstIndex(where: { $0.id == item.id }) {
            updated.items[idx] = item
        }
        updatePocket(updated)
    }

    // MARK: - Persistence
    private func save() {
        if let data = try? JSONEncoder().encode(pockets) {
            UserDefaults.standard.set(data, forKey: saveKey)
        }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: saveKey),
              let decoded = try? JSONDecoder().decode([Pocket].self, from: data) else { return }
        pockets = decoded
    }
}
