//
//  PocketItem.swift
//  PocketUp
//
//  Created by Erfan Yarahmadi on 10/03/26.
//


import Foundation
import SwiftUI

// MARK: - Pocket Item
struct PocketItem: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var name: String
    var emoji: String
    var isEssential: Bool = false
    var notes: String = ""

    init(id: UUID = UUID(), name: String, emoji: String, isEssential: Bool = false, notes: String = "") {
        self.id = id
        self.name = name
        self.emoji = emoji
        self.isEssential = isEssential
        self.notes = notes
    }
}

// MARK: - Schedule
struct PocketSchedule: Codable, Equatable {
    var daysOfWeek: Set<Int> = []   // 1=Sun, 2=Mon, ... 7=Sat
    var departureTime: Date = Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: Date()) ?? Date()
    var returnTime: Date = Calendar.current.date(bySettingHour: 17, minute: 0, second: 0, of: Date()) ?? Date()
    var remindOnDepart: Bool = true
    var remindOnReturn: Bool = true
    var advanceMinutes: Int = 15

    var dayNames: [String] {
        let all = ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"]
        return daysOfWeek.sorted().map { all[$0 - 1] }
    }
}

// MARK: - Pocket
struct Pocket: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var name: String
    var destination: String
    var icon: String
    var colorHex: String
    var items: [PocketItem] = []
    var schedule: PocketSchedule = PocketSchedule()
    var isActive: Bool = true
    var createdAt: Date = Date()

    var color: Color {
        Color(hex: colorHex) ?? .blue
    }
    var essentialItems: [PocketItem] { items.filter { $0.isEssential } }
    var regularItems:   [PocketItem] { items.filter { !$0.isEssential } }

    // MARK: Preview Data
    static var preview: Pocket {
        var p = Pocket(name: "University", destination: "Uni Campus", icon: "graduationcap.fill", colorHex: "#3B82F6")
        p.items = [
            PocketItem(name: "Laptop",       emoji: "💻", isEssential: true),
            PocketItem(name: "Phone Charger",emoji: "🔌", isEssential: true),
            PocketItem(name: "Student Card", emoji: "🪪", isEssential: true),
            PocketItem(name: "Water Bottle", emoji: "💧"),
            PocketItem(name: "Headphones",   emoji: "🎧"),
            PocketItem(name: "Notebook",     emoji: "📓"),
        ]
        p.schedule.daysOfWeek = [2,3,4,5,6]
        return p
    }

    static var previews: [Pocket] {
        var gym = Pocket(name: "Gym", destination: "FitLife Gym", icon: "dumbbell.fill", colorHex: "#EF4444")
        gym.items = [
            PocketItem(name: "Gym Card",    emoji: "🪪", isEssential: true),
            PocketItem(name: "Towel",       emoji: "🧺"),
            PocketItem(name: "Water Bottle",emoji: "💧"),
            PocketItem(name: "AirPods",     emoji: "🎧"),
        ]
        gym.schedule.daysOfWeek = [2,4,6]

        var work = Pocket(name: "Office", destination: "Work HQ", icon: "briefcase.fill", colorHex: "#10B981")
        work.items = [
            PocketItem(name: "Laptop", emoji: "💻", isEssential: true),
            PocketItem(name: "Badge",  emoji: "🪪", isEssential: true),
            PocketItem(name: "Notebook",emoji: "📓"),
        ]
        work.schedule.daysOfWeek = [2,3,4,5,6]

        return [preview, gym, work]
    }
}

// MARK: - Color Hex Extension
extension Color {
    init?(hex: String) {
        var h = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        h = h.hasPrefix("#") ? String(h.dropFirst()) : h
        guard h.count == 6, let val = UInt64(h, radix: 16) else { return nil }
        self.init(
            red:   Double((val >> 16) & 0xFF) / 255,
            green: Double((val >>  8) & 0xFF) / 255,
            blue:  Double( val        & 0xFF) / 255
        )
    }

    func toHex() -> String {
        let c = UIColor(self)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        c.getRed(&r, green: &g, blue: &b, alpha: &a)
        return String(format: "#%02X%02X%02X", Int(r*255), Int(g*255), Int(b*255))
    }
}