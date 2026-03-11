//
//  LibraryItem.swift
//  PocketUp
//
//  Created by Erfan Yarahmadi on 10/03/26.
//


import Foundation

// MARK: - Library Item (template, not owned by any pocket)
struct LibraryItem: Identifiable, Hashable {
    let id: UUID = UUID()
    let name: String
    let emoji: String
    let category: ItemCategory
}

// MARK: - Categories
enum ItemCategory: String, CaseIterable, Identifiable {
    var id: String { rawValue }

    case tech        = "Tech"
    case documents   = "Documents"
    case health      = "Health"
    case gym         = "Gym & Sport"
    case food        = "Food & Drink"
    case clothing    = "Clothing"
    case school      = "School"
    case work        = "Work"
    case travel      = "Travel"
    case essentials  = "Essentials"
    case custom      = "My Items"

    var icon: String {
        switch self {
        case .tech:       return "laptopcomputer"
        case .documents:  return "doc.fill"
        case .health:     return "cross.case.fill"
        case .gym:        return "dumbbell.fill"
        case .food:       return "fork.knife"
        case .clothing:   return "tshirt.fill"
        case .school:     return "graduationcap.fill"
        case .work:       return "briefcase.fill"
        case .travel:     return "airplane"
        case .essentials: return "star.fill"
        case .custom:     return "person.fill"
        }
    }
}

// MARK: - The Library
struct ItemLibrary {

    static let items: [LibraryItem] = [

        // Essentials
        LibraryItem(name: "Phone",          emoji: "📱", category: .essentials),
        LibraryItem(name: "Wallet",         emoji: "👛", category: .essentials),
        LibraryItem(name: "Keys",           emoji: "🔑", category: .essentials),
        LibraryItem(name: "Earphones",      emoji: "🎧", category: .essentials),
        LibraryItem(name: "Water Bottle",   emoji: "💧", category: .essentials),
        LibraryItem(name: "Umbrella",       emoji: "☂️", category: .essentials),
        LibraryItem(name: "Sunglasses",     emoji: "🕶️", category: .essentials),
        LibraryItem(name: "Hand Sanitizer", emoji: "🧴", category: .essentials),
        LibraryItem(name: "Mask",           emoji: "😷", category: .essentials),
        LibraryItem(name: "Power Bank",     emoji: "🔋", category: .essentials),

        // Tech
        LibraryItem(name: "Laptop",         emoji: "💻", category: .tech),
        LibraryItem(name: "Tablet",         emoji: "📱", category: .tech),
        LibraryItem(name: "Charger",        emoji: "🔌", category: .tech),
        LibraryItem(name: "USB Cable",      emoji: "🔌", category: .tech),
        LibraryItem(name: "Mouse",          emoji: "🖱️", category: .tech),
        LibraryItem(name: "Keyboard",       emoji: "⌨️", category: .tech),
        LibraryItem(name: "Hard Drive",     emoji: "💾", category: .tech),
        LibraryItem(name: "USB Hub",        emoji: "🔌", category: .tech),
        LibraryItem(name: "Headphones",     emoji: "🎧", category: .tech),
        LibraryItem(name: "Camera",         emoji: "📷", category: .tech),
        LibraryItem(name: "Tripod",         emoji: "📷", category: .tech),
        LibraryItem(name: "Adapter",        emoji: "🔌", category: .tech),

        // Documents
        LibraryItem(name: "ID Card",        emoji: "🪪", category: .documents),
        LibraryItem(name: "Passport",       emoji: "📕", category: .documents),
        LibraryItem(name: "Student Card",   emoji: "🪪", category: .documents),
        LibraryItem(name: "Credit Card",    emoji: "💳", category: .documents),
        LibraryItem(name: "Insurance Card", emoji: "📋", category: .documents),
        LibraryItem(name: "Notebook",       emoji: "📓", category: .documents),
        LibraryItem(name: "Planner",        emoji: "📅", category: .documents),
        LibraryItem(name: "Resume",         emoji: "📄", category: .documents),
        LibraryItem(name: "Tickets",        emoji: "🎟️", category: .documents),
        LibraryItem(name: "Permission Slip",emoji: "📝", category: .documents),

        // Health
        LibraryItem(name: "Medication",     emoji: "💊", category: .health),
        LibraryItem(name: "Vitamins",       emoji: "💊", category: .health),
        LibraryItem(name: "Inhaler",        emoji: "💨", category: .health),
        LibraryItem(name: "First Aid Kit",  emoji: "🩹", category: .health),
        LibraryItem(name: "EpiPen",         emoji: "💉", category: .health),
        LibraryItem(name: "Face Cream",     emoji: "🧴", category: .health),
        LibraryItem(name: "Deodorant",      emoji: "🧴", category: .health),
        LibraryItem(name: "Tissues",        emoji: "🤧", category: .health),
        LibraryItem(name: "Lip Balm",       emoji: "💋", category: .health),
        LibraryItem(name: "Pain Relief",    emoji: "💊", category: .health),

        // Gym & Sport
        LibraryItem(name: "Gym Card",       emoji: "🪪", category: .gym),
        LibraryItem(name: "Towel",          emoji: "🧺", category: .gym),
        LibraryItem(name: "Gym Clothes",    emoji: "👕", category: .gym),
        LibraryItem(name: "Trainers",       emoji: "👟", category: .gym),
        LibraryItem(name: "Protein Shake",  emoji: "🥤", category: .gym),
        LibraryItem(name: "Gloves",         emoji: "🥊", category: .gym),
        LibraryItem(name: "Resistance Band",emoji: "💪", category: .gym),
        LibraryItem(name: "Yoga Mat",       emoji: "🧘", category: .gym),
        LibraryItem(name: "Lock",           emoji: "🔒", category: .gym),
        LibraryItem(name: "Sports Drink",   emoji: "🥤", category: .gym),
        LibraryItem(name: "Swim Goggles",   emoji: "🥽", category: .gym),
        LibraryItem(name: "Cap",            emoji: "🧢", category: .gym),

        // Food & Drink
        LibraryItem(name: "Lunch Box",      emoji: "🍱", category: .food),
        LibraryItem(name: "Snacks",         emoji: "🍪", category: .food),
        LibraryItem(name: "Coffee Mug",     emoji: "☕", category: .food),
        LibraryItem(name: "Thermos",        emoji: "🫖", category: .food),
        LibraryItem(name: "Cutlery",        emoji: "🍴", category: .food),
        LibraryItem(name: "Napkins",        emoji: "🧻", category: .food),
        LibraryItem(name: "Protein Bar",    emoji: "🍫", category: .food),
        LibraryItem(name: "Fruit",          emoji: "🍎", category: .food),

        // Clothing
        LibraryItem(name: "Jacket",         emoji: "🧥", category: .clothing),
        LibraryItem(name: "Scarf",          emoji: "🧣", category: .clothing),
        LibraryItem(name: "Hat",            emoji: "🎩", category: .clothing),
        LibraryItem(name: "Gloves",         emoji: "🧤", category: .clothing),
        LibraryItem(name: "Spare Shirt",    emoji: "👕", category: .clothing),
        LibraryItem(name: "Belt",           emoji: "👔", category: .clothing),
        LibraryItem(name: "Tie",            emoji: "👔", category: .clothing),
        LibraryItem(name: "Socks",          emoji: "🧦", category: .clothing),

        // School
        LibraryItem(name: "Textbook",       emoji: "📚", category: .school),
        LibraryItem(name: "Pencil Case",    emoji: "✏️", category: .school),
        LibraryItem(name: "Calculator",     emoji: "🔢", category: .school),
        LibraryItem(name: "Ruler",          emoji: "📏", category: .school),
        LibraryItem(name: "Highlighters",   emoji: "🖊️", category: .school),
        LibraryItem(name: "Folders",        emoji: "📁", category: .school),
        LibraryItem(name: "Scissors",       emoji: "✂️", category: .school),
        LibraryItem(name: "Glue",           emoji: "🖇️", category: .school),
        LibraryItem(name: "Eraser",         emoji: "📝", category: .school),

        // Work
        LibraryItem(name: "Work Badge",     emoji: "🪪", category: .work),
        LibraryItem(name: "Business Cards", emoji: "📇", category: .work),
        LibraryItem(name: "Presentation",   emoji: "💼", category: .work),
        LibraryItem(name: "Notepad",        emoji: "🗒️", category: .work),
        LibraryItem(name: "Pen",            emoji: "🖊️", category: .work),
        LibraryItem(name: "Meeting Notes",  emoji: "📋", category: .work),
        LibraryItem(name: "Laptop Stand",   emoji: "💻", category: .work),

        // Travel
        LibraryItem(name: "Boarding Pass",  emoji: "🎫", category: .travel),
        LibraryItem(name: "Travel Pillow",  emoji: "💤", category: .travel),
        LibraryItem(name: "Eye Mask",       emoji: "😴", category: .travel),
        LibraryItem(name: "Earplugs",       emoji: "🔇", category: .travel),
        LibraryItem(name: "Travel Adapter", emoji: "🔌", category: .travel),
        LibraryItem(name: "Sunscreen",      emoji: "🌞", category: .travel),
        LibraryItem(name: "Map",            emoji: "🗺️", category: .travel),
        LibraryItem(name: "Currency",       emoji: "💴", category: .travel),
        LibraryItem(name: "Travel Bag",     emoji: "🧳", category: .travel),
    ]

    // All categories that have items (excluding .custom which is user-created)
    static var populatedCategories: [ItemCategory] {
        ItemCategory.allCases.filter { $0 != .custom }
    }

    static func items(for category: ItemCategory) -> [LibraryItem] {
        items.filter { $0.category == category }
    }
}