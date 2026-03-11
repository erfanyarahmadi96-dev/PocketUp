//
//  ItemPickerView.swift
//  PocketUp
//
//  Created by Erfan Yarahmadi on 10/03/26.
//



import SwiftUI

struct ItemPickerView: View {
    let pocket: Pocket
    let vm: PocketsViewModel
    @Environment(\.dismiss) var dismiss

    private var existingNames: Set<String> {
        Set(pocket.items.map { $0.name.lowercased() })
    }

    @State private var selectedCategory: ItemCategory = .essentials
    @State private var searchText: String = ""
    @State private var selectedItems: Set<String> = []
    @State private var showCustomItem = false
    @State private var customName = ""
    @State private var customEmoji = "📦"
    @State private var customIsEssential = false
    @State private var showEmojiPicker = false

    @AppStorage("pocketup_custom_library_items") private var customItemsData: Data = Data()
    @State private var customLibraryItems: [LibraryItem] = []

    private let suggestedEmojis = [
        "📦","💻","📱","🔑","🪪","💳","📓","🎧","🔌","💊",
        "👛","🎒","☂️","📚","🍱","💧","🏋️","👓","🎽","🧤",
        "🌂","🔋","📷","🎮","✏️","📎","🗝️","💼","🎵","🧳"
    ]

    private var displayedItems: [LibraryItem] {
        let base: [LibraryItem] = selectedCategory == .custom
            ? customLibraryItems
            : ItemLibrary.items(for: selectedCategory)
        if searchText.isEmpty { return base }
        return base.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    private var searchResults: [LibraryItem] {
        guard !searchText.isEmpty else { return [] }
        let all = ItemLibrary.items + customLibraryItems
        return all.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        ZStack {
            DenimTheme.bgDeep.ignoresSafeArea()

            VStack(spacing: 0) {
                headerBar
                searchBar
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)

                if searchText.isEmpty {
                    categoryStrip
                    Divider().background(DenimTheme.bgMid)
                }

                itemGrid
            }
        }
        .onAppear { loadCustomItems() }
    }

    // MARK: - Header
    private var headerBar: some View {
        HStack {
            Button("Cancel") { dismiss() }
                .font(DenimTheme.bodyFont(16))
                .foregroundColor(DenimTheme.fadedDenim)

            Spacer()

            Text("Add Items")
                .font(DenimTheme.titleFont(18))
                .foregroundColor(DenimTheme.fabricWhite)

            Spacer()

            Button {
                addSelectedItems()
                dismiss()
            } label: {
                HStack(spacing: 4) {
                    Text("Add")
                    if !selectedItems.isEmpty {
                        Text("(\(selectedItems.count))")
                    }
                }
                .font(DenimTheme.bodyFont(16).weight(.semibold))
                .foregroundColor(selectedItems.isEmpty ? DenimTheme.fadedDenim : DenimTheme.stitchGold)
            }
            .disabled(selectedItems.isEmpty)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }

    // MARK: - Search Bar
    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(DenimTheme.fadedDenim)
                .font(.system(size: 15))
            TextField("Search items...", text: $searchText)
                .font(DenimTheme.bodyFont(15))
                .foregroundColor(DenimTheme.fabricWhite)
                .accentColor(DenimTheme.stitchGold)
            if !searchText.isEmpty {
                Button { searchText = "" } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(DenimTheme.fadedDenim)
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(DenimTheme.bgCard)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Category Strip
    private var categoryStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(ItemCategory.allCases) { cat in
                    Button {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            selectedCategory = cat
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: cat.icon)
                                .font(.system(size: 12, weight: .semibold))
                            Text(cat.rawValue)
                                .font(DenimTheme.labelFont(11))
                                .kerning(1)
                        }
                        .foregroundColor(selectedCategory == cat ? DenimTheme.bgDeep : DenimTheme.fadedDenim)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(selectedCategory == cat ? DenimTheme.stitchGold : DenimTheme.bgCard)
                        .clipShape(Capsule())
                    }
                    .buttonStyle(SpringButtonStyle())
                }

                // New Item button
                Button {
                    selectedCategory = .custom
                    showCustomItem = true
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 12, weight: .semibold))
                        Text("New Item")
                            .font(DenimTheme.labelFont(11))
                            .kerning(1)
                    }
                    .foregroundColor(DenimTheme.stitchGold)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(DenimTheme.bgCard)
                    .clipShape(Capsule())
                    .overlay(
                        Capsule()
                            .strokeBorder(style: StrokeStyle(lineWidth: 1.5, dash: [4, 3]))
                            .foregroundColor(DenimTheme.stitchGold.opacity(0.5))
                    )
                }
                .buttonStyle(SpringButtonStyle())
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
    }

    // MARK: - Item Grid
    private var itemGrid: some View {
        ScrollView {
            let items = searchText.isEmpty ? displayedItems : searchResults

            if items.isEmpty && selectedCategory == .custom && searchText.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "plus.circle.dashed")
                        .font(.system(size: 44))
                        .foregroundColor(DenimTheme.fadedDenim.opacity(0.4))
                    Text("No custom items yet")
                        .font(DenimTheme.bodyFont(16))
                        .foregroundColor(DenimTheme.fadedDenim)
                    Text("Tap \"New Item\" to create your own")
                        .font(DenimTheme.bodyFont(13))
                        .foregroundColor(DenimTheme.fadedDenim.opacity(0.6))
                }
                .padding(.top, 60)
            } else {
                LazyVGrid(
                    columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())],
                    spacing: 10
                ) {
                    ForEach(items) { item in
                        ItemPickerCell(
                            item: item,
                            isAlreadyAdded: existingNames.contains(item.name.lowercased()),
                            isSelected: selectedItems.contains(item.name),
                            onTap: { toggleItem(item) }
                        )
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 40)
            }
        }
        .sheet(isPresented: $showCustomItem) {
            customItemSheet
        }
    }

    // MARK: - Custom Item Sheet
    private var customItemSheet: some View {
        ZStack {
            DenimTheme.bgDeep.ignoresSafeArea()
            VStack(spacing: 24) {
                HStack {
                    Button("Cancel") { showCustomItem = false }
                        .font(DenimTheme.bodyFont(16))
                        .foregroundColor(DenimTheme.fadedDenim)
                    Spacer()
                    Text("New Item")
                        .font(DenimTheme.titleFont(18))
                        .foregroundColor(DenimTheme.fabricWhite)
                    Spacer()
                    Button("Add") {
                        saveCustomItem()
                        showCustomItem = false
                    }
                    .font(DenimTheme.bodyFont(16).weight(.semibold))
                    .foregroundColor(customName.isEmpty ? DenimTheme.fadedDenim : DenimTheme.stitchGold)
                    .disabled(customName.isEmpty)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)

                VStack(spacing: 8) {
                    Button { withAnimation { showEmojiPicker.toggle() } } label: {
                        ZStack {
                            Circle()
                                .fill(DenimTheme.bgCard)
                                .frame(width: 80, height: 80)
                                .overlay(
                                    Circle()
                                        .strokeBorder(style: StrokeStyle(lineWidth: 1.5, dash: [5, 4]))
                                        .foregroundColor(DenimTheme.stitchGold.opacity(0.5))
                                )
                            Text(customEmoji).font(.system(size: 38))
                        }
                    }
                    Text("Tap to change")
                        .font(DenimTheme.labelFont(10))
                        .kerning(2)
                        .foregroundColor(DenimTheme.fadedDenim)
                }

                if showEmojiPicker {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 10) {
                        ForEach(suggestedEmojis, id: \.self) { e in
                            Button { customEmoji = e; showEmojiPicker = false } label: {
                                Text(e).font(.system(size: 26))
                                    .frame(width: 44, height: 44)
                                    .background(customEmoji == e
                                                ? DenimTheme.stitchGold.opacity(0.3)
                                                : DenimTheme.bgCard)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .transition(.move(edge: .top).combined(with: .opacity))
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("ITEM NAME")
                        .font(DenimTheme.labelFont(10))
                        .kerning(3)
                        .foregroundColor(DenimTheme.stitchGold)
                    TextField("e.g. My Special Item...", text: $customName)
                        .font(DenimTheme.bodyFont(16))
                        .foregroundColor(DenimTheme.fabricWhite)
                        .accentColor(DenimTheme.stitchGold)
                        .padding(14)
                        .background(DenimTheme.bgCard)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal, 20)

                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("ESSENTIAL")
                            .font(DenimTheme.labelFont(10))
                            .kerning(3)
                            .foregroundColor(DenimTheme.stitchGold)
                        Text("Appears first in reminders")
                            .font(DenimTheme.bodyFont(12))
                            .foregroundColor(DenimTheme.fadedDenim)
                    }
                    Spacer()
                    Toggle("", isOn: $customIsEssential).tint(DenimTheme.stitchGold)
                }
                .padding(14)
                .background(DenimTheme.bgCard)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal, 20)

                Spacer()
            }
        }
    }

    // MARK: - Logic
    private func toggleItem(_ item: LibraryItem) {
        guard !existingNames.contains(item.name.lowercased()) else { return }
        withAnimation(.spring(response: 0.2)) {
            if selectedItems.contains(item.name) {
                selectedItems.remove(item.name)
            } else {
                selectedItems.insert(item.name)
            }
        }
    }

    private func addSelectedItems() {
        let allItems = ItemLibrary.items + customLibraryItems
        for name in selectedItems {
            if let lib = allItems.first(where: { $0.name == name }) {
                let item = PocketItem(name: lib.name, emoji: lib.emoji)
                vm.addItem(item, to: pocket)
            }
        }
    }

    private func saveCustomItem() {
        guard !customName.isEmpty else { return }
        let item = PocketItem(name: customName, emoji: customEmoji, isEssential: customIsEssential)
        vm.addItem(item, to: pocket)

        let libItem = LibraryItem(name: customName, emoji: customEmoji, category: .custom)
        customLibraryItems.append(libItem)
        persistCustomItems()

        customName = ""
        customEmoji = "📦"
        customIsEssential = false
    }

    private func loadCustomItems() {
        guard let decoded = try? JSONDecoder().decode([StoredLibraryItem].self, from: customItemsData) else { return }
        customLibraryItems = decoded.map { LibraryItem(name: $0.name, emoji: $0.emoji, category: .custom) }
    }

    private func persistCustomItems() {
        let stored = customLibraryItems.map { StoredLibraryItem(name: $0.name, emoji: $0.emoji) }
        if let encoded = try? JSONEncoder().encode(stored) {
            customItemsData = encoded
        }
    }
}

// MARK: - Codable wrapper for custom items
private struct StoredLibraryItem: Codable {
    let name: String
    let emoji: String
}

// MARK: - Item Picker Cell
struct ItemPickerCell: View {
    let item: LibraryItem
    let isAlreadyAdded: Bool
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                ZStack(alignment: .topTrailing) {
                    Text(item.emoji)
                        .font(.system(size: 32))
                        .frame(width: 56, height: 56)
                        .background(
                            isAlreadyAdded
                                ? DenimTheme.bgMid
                                : isSelected
                                    ? DenimTheme.stitchGold.opacity(0.25)
                                    : DenimTheme.bgCard
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .strokeBorder(
                                    isSelected
                                        ? DenimTheme.stitchGold
                                        : isAlreadyAdded
                                            ? DenimTheme.fadedDenim.opacity(0.15)
                                            : Color.clear,
                                    lineWidth: isSelected ? 2 : 1
                                )
                        )

                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(DenimTheme.stitchGold)
                            .background(Circle().fill(DenimTheme.bgDeep).padding(2))
                            .offset(x: 6, y: -6)
                    } else if isAlreadyAdded {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(DenimTheme.fadedDenim.opacity(0.5))
                            .background(Circle().fill(DenimTheme.bgDeep).padding(2))
                            .offset(x: 6, y: -6)
                    }
                }

                Text(item.name)
                    .font(DenimTheme.bodyFont(11))
                    .foregroundColor(
                        isAlreadyAdded
                            ? DenimTheme.fadedDenim.opacity(0.4)
                            : isSelected
                                ? DenimTheme.fabricWhite
                                : DenimTheme.fadedDenim
                    )
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 6)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? DenimTheme.stitchGold.opacity(0.08) : Color.clear)
            )
        }
        .buttonStyle(SpringButtonStyle())
        .disabled(isAlreadyAdded)
        .opacity(isAlreadyAdded ? 0.5 : 1.0)
    }
}
