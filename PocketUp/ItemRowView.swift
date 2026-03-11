//
//  ItemRowView.swift
//  PocketUp
//
//  Created by Erfan Yarahmadi on 10/03/26.
//


import SwiftUI

// MARK: - Item Row
struct ItemRowView: View {
    let item: PocketItem

    var body: some View {
        HStack(spacing: 14) {
            Text(item.emoji)
                .font(.system(size: 24))
                .frame(width: 40, height: 40)
                .background(DenimTheme.bgDeep)
                .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 2) {
                Text(item.name)
                    .font(DenimTheme.bodyFont(15))
                    .foregroundColor(DenimTheme.fabricWhite)
                if !item.notes.isEmpty {
                    Text(item.notes)
                        .font(DenimTheme.bodyFont(12))
                        .foregroundColor(DenimTheme.fadedDenim)
                        .lineLimit(1)
                }
            }
            Spacer()
            if item.isEssential {
                Image(systemName: "star.fill")
                    .font(.system(size: 12))
                    .foregroundColor(DenimTheme.stitchGold)
            }
            Image(systemName: "chevron.right")
                .font(.system(size: 12))
                .foregroundColor(DenimTheme.fadedDenim.opacity(0.4))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(DenimTheme.bgCard)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Add / Edit Item Sheet
struct AddItemView: View {
    var existingItem: PocketItem? = nil
    var onSave: (PocketItem) -> Void

    @Environment(\.dismiss) var dismiss
    @State private var name        = ""
    @State private var emoji       = "📦"
    @State private var isEssential = false
    @State private var notes       = ""
    @State private var showPicker  = false

    private let suggestedEmojis = [
        "💻","📱","🔑","🪪","💳","📓","🎧","🔌","💊","🧴",
        "👛","🎒","☂️","📚","🍱","💧","🏋️","👓","🎽","🧤",
        "🌂","🔋","📷","🎮","✏️","📎","🗝️","💼","🎵","🧳"
    ]

    var isEditing: Bool { existingItem != nil }

    var body: some View {
        ZStack {
            DenimTheme.bgDeep.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 24) {

                    // Header bar
                    HStack {
                        Button("Cancel") { dismiss() }
                            .font(DenimTheme.bodyFont(16))
                            .foregroundColor(DenimTheme.fadedDenim)
                        Spacer()
                        Text(isEditing ? "Edit Item" : "New Item")
                            .font(DenimTheme.titleFont(18))
                            .foregroundColor(DenimTheme.fabricWhite)
                        Spacer()
                        Button("Save") {
                            var item = existingItem ?? PocketItem(name: "", emoji: "")
                            item.name = name; item.emoji = emoji
                            item.isEssential = isEssential; item.notes = notes
                            onSave(item); dismiss()
                        }
                        .font(DenimTheme.bodyFont(16).weight(.semibold))
                        .foregroundColor(name.isEmpty ? DenimTheme.fadedDenim : DenimTheme.stitchGold)
                        .disabled(name.isEmpty)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)

                    // Big emoji
                    VStack(spacing: 10) {
                        Button { withAnimation(.spring()) { showPicker.toggle() } } label: {
                            ZStack {
                                Circle().fill(DenimTheme.bgCard).frame(width: 90, height: 90)
                                    .overlay(Circle()
                                        .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [6,4]))
                                        .foregroundColor(DenimTheme.stitchGold.opacity(0.5)))
                                Text(emoji).font(.system(size: 44))
                            }
                        }
                        Text("Tap to change")
                            .font(DenimTheme.labelFont(11)).kerning(2)
                            .foregroundColor(DenimTheme.fadedDenim)
                    }

                    // Emoji grid
                    if showPicker {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
                            ForEach(suggestedEmojis, id: \.self) { e in
                                Button { emoji = e; showPicker = false } label: {
                                    Text(e).font(.system(size: 28))
                                        .frame(width: 48, height: 48)
                                        .background(emoji == e ? DenimTheme.stitchGold.opacity(0.3) : DenimTheme.bgCard)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }

                    // Fields
                    VStack(spacing: 12) {
                        fieldBlock(label: "ITEM NAME") {
                            TextField("e.g. Laptop, Student Card...", text: $name)
                                .font(DenimTheme.bodyFont(16))
                                .foregroundColor(DenimTheme.fabricWhite)
                                .accentColor(DenimTheme.stitchGold)
                        }
                        fieldBlock(label: "NOTES (optional)") {
                            TextField("Any extra note...", text: $notes)
                                .font(DenimTheme.bodyFont(15))
                                .foregroundColor(DenimTheme.fabricWhite)
                                .accentColor(DenimTheme.stitchGold)
                        }
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("ESSENTIAL").font(DenimTheme.labelFont(10)).kerning(3).foregroundColor(DenimTheme.stitchGold)
                                Text("Appears first in reminders").font(DenimTheme.bodyFont(12)).foregroundColor(DenimTheme.fadedDenim)
                            }
                            Spacer()
                            Toggle("", isOn: $isEssential).tint(DenimTheme.stitchGold)
                        }
                        .padding(14)
                        .background(DenimTheme.bgCard)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
        .onAppear {
            if let item = existingItem {
                name = item.name; emoji = item.emoji
                isEssential = item.isEssential; notes = item.notes
            }
        }
    }

    @ViewBuilder
    private func fieldBlock<C: View>(label: String, @ViewBuilder content: () -> C) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label).font(DenimTheme.labelFont(10)).kerning(3).foregroundColor(DenimTheme.stitchGold)
            content()
                .padding(14)
                .background(DenimTheme.bgCard)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}