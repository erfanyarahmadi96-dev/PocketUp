//
//  ItemDrawerView.swift
//  PocketUp
//
//  Created by Erfan Yarahmadi on 11/03/26.
//


import SwiftUI
import Combine
import UniformTypeIdentifiers

struct ItemDrawerView: View {
    @ObservedObject var vm: PocketsViewModel
    @ObservedObject var dragState: DragState
    let onClose: () -> Void

    @AppStorage("pocketup_custom_library_items") private var customItemsData: Data = Data()
    @State private var customLibraryItems: [LibraryItem] = []
    @State private var searchText = ""
    @State private var selectedCategory: ItemCategory = .essentials
    @State private var showNewItemSheet = false
    @State private var newItemName = ""
    @State private var newItemEmoji = "📦"
    @State private var showEmojiPicker = false

    private let suggestedEmojis = [
        "📦","💻","📱","🔑","🪪","💳","📓","🎧","🔌","💊",
        "👛","🎒","☂️","📚","🍱","💧","🏋️","👓","🎽","🧤",
        "🌂","🔋","📷","🎮","✏️","📎","🗝️","💼","🎵","🧳"
    ]

    private var allItems: [LibraryItem] { ItemLibrary.items + customLibraryItems }

    private var displayedItems: [LibraryItem] {
        let base = selectedCategory == .custom
            ? customLibraryItems
            : ItemLibrary.items(for: selectedCategory)
        guard !searchText.isEmpty else { return base }
        return base.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    private var searchResults: [LibraryItem] {
        guard !searchText.isEmpty else { return [] }
        return allItems.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        VStack(spacing: 0) {
            drawerHeader
            searchBar
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
            categoryStrip
            Divider().background(DenimTheme.bgDeep)
            itemList
            newItemButton
        }
        .background(DenimTheme.bgCard)
        .onAppear { loadCustomItems() }
        .sheet(isPresented: $showNewItemSheet) {
            newItemSheet
        }
    }

    // MARK: - Header
    private var drawerHeader: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 2) {
                Text("ITEMS")
                    .font(DenimTheme.titleFont(18))
                    .foregroundColor(DenimTheme.fabricWhite)
                    .kerning(3)
                Text("Hold & drag to pocket")
                    .font(DenimTheme.bodyFont(14))
                    .foregroundColor(DenimTheme.fadedDenim)
            }
            Spacer()
            Button(action: onClose) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(DenimTheme.fadedDenim, DenimTheme.bgMid)
            }
        }
        .padding(.horizontal, 12)
        .padding(.top, 14)
        .padding(.bottom, 8)
    }

    // MARK: - Search
    private var searchBar: some View {
        HStack(spacing: 6) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 11))
                .foregroundColor(DenimTheme.fadedDenim)
            TextField("Search...", text: $searchText)
                .font(DenimTheme.bodyFont(12))
                .foregroundColor(DenimTheme.fabricWhite)
                .accentColor(DenimTheme.stitchGold)
            if !searchText.isEmpty {
                Button { searchText = "" } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 11))
                        .foregroundColor(DenimTheme.fadedDenim)
                }
            }
        }
        .padding(8)
        .background(DenimTheme.bgMid)
        .clipShape(RoundedRectangle(cornerRadius: 9))
    }

    // MARK: - Category Strip
    private var categoryStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 5) {
                ForEach(ItemCategory.allCases) { cat in
                    Button {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            selectedCategory = cat
                        }
                    } label: {
                        Text(cat.rawValue)
                            .font(DenimTheme.labelFont(9))
                            .kerning(0.5)
                            .foregroundColor(selectedCategory == cat ? DenimTheme.bgDeep : DenimTheme.fadedDenim)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 5)
                            .background(selectedCategory == cat ? DenimTheme.stitchGold : DenimTheme.bgMid)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(SpringButtonStyle())
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
        }
    }

    // MARK: - Item List
    private var itemList: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 3) {
                let items = searchText.isEmpty ? displayedItems : searchResults
                ForEach(items) { item in
                    DraggableItemRow(item: item, dragState: dragState)
                }
                if items.isEmpty && selectedCategory == .custom && searchText.isEmpty {
                    Text("No custom items yet")
                        .font(DenimTheme.bodyFont(12))
                        .foregroundColor(DenimTheme.fadedDenim.opacity(0.5))
                        .padding(.top, 24)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.horizontal, 8)
            .padding(.top, 6)
            .padding(.bottom, 10)
        }
    }

    // MARK: - New Item Button
    private var newItemButton: some View {
        Button {
            selectedCategory = .custom
            showNewItemSheet = true
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "plus.circle.fill").font(.system(size: 13))
                Text("New Item").font(DenimTheme.labelFont(14)).kerning(1.5)
            }
            .foregroundColor(DenimTheme.stitchGold)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(DenimTheme.bgMid)
            .overlay(Rectangle().frame(height: 1).foregroundColor(DenimTheme.bgDeep), alignment: .top)
        }
        .buttonStyle(SpringButtonStyle())
    }

    // MARK: - New Item Sheet
    private var newItemSheet: some View {
        ZStack {
            DenimTheme.bgDeep.ignoresSafeArea()
            VStack(spacing: 24) {
                HStack {
                    Button("Cancel") { showNewItemSheet = false }
                        .font(DenimTheme.bodyFont(16))
                        .foregroundColor(DenimTheme.fadedDenim)
                    Spacer()
                    Text("New Item")
                        .font(DenimTheme.titleFont(18))
                        .foregroundColor(DenimTheme.fabricWhite)
                    Spacer()
                    Button("Save") {
                        saveNewItem()
                        showNewItemSheet = false
                    }
                    .font(DenimTheme.bodyFont(16).weight(.semibold))
                    .foregroundColor(newItemName.isEmpty ? DenimTheme.fadedDenim : DenimTheme.stitchGold)
                    .disabled(newItemName.isEmpty)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)

                VStack(spacing: 8) {
                    Button { withAnimation { showEmojiPicker.toggle() } } label: {
                        ZStack {
                            Circle()
                                .fill(DenimTheme.bgCard)
                                .frame(width: 80, height: 80)
                                .overlay(Circle()
                                    .strokeBorder(style: StrokeStyle(lineWidth: 1.5, dash: [5, 4]))
                                    .foregroundColor(DenimTheme.stitchGold.opacity(0.5)))
                            Text(newItemEmoji).font(.system(size: 38))
                        }
                    }
                    Text("Tap to change")
                        .font(DenimTheme.labelFont(10)).kerning(2)
                        .foregroundColor(DenimTheme.fadedDenim)
                }

                if showEmojiPicker {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 10) {
                        ForEach(suggestedEmojis, id: \.self) { e in
                            Button { newItemEmoji = e; showEmojiPicker = false } label: {
                                Text(e).font(.system(size: 26))
                                    .frame(width: 44, height: 44)
                                    .background(newItemEmoji == e
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
                        .font(DenimTheme.labelFont(10)).kerning(3)
                        .foregroundColor(DenimTheme.stitchGold)
                    TextField("e.g. Gym Card...", text: $newItemName)
                        .font(DenimTheme.bodyFont(16))
                        .foregroundColor(DenimTheme.fabricWhite)
                        .accentColor(DenimTheme.stitchGold)
                        .padding(14)
                        .background(DenimTheme.bgCard)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal, 20)

                Spacer()
            }
        }
    }

    // MARK: - Logic
    private func saveNewItem() {
        guard !newItemName.isEmpty else { return }
        let libItem = LibraryItem(name: newItemName, emoji: newItemEmoji, category: .custom)
        customLibraryItems.append(libItem)
        persistCustomItems()
        newItemName = ""
        newItemEmoji = "📦"
    }

    private func loadCustomItems() {
        guard let decoded = try? JSONDecoder().decode([StoredLibraryItem].self, from: customItemsData) else { return }
        customLibraryItems = decoded.map { LibraryItem(name: $0.name, emoji: $0.emoji, category: .custom) }
    }

    private func persistCustomItems() {
        let stored = customLibraryItems.map { StoredLibraryItem(name: $0.name, emoji: $0.emoji) }
        if let encoded = try? JSONEncoder().encode(stored) { customItemsData = encoded }
    }
}

private struct StoredLibraryItem: Codable {
    let name: String
    let emoji: String
}

// MARK: - Draggable Item Row
struct DraggableItemRow: View {
    let item: LibraryItem
    @ObservedObject var dragState: DragState
    @State private var isDragging = false

    var body: some View {
        HStack(spacing: 8) {
            Text(item.emoji)
                .font(.system(size: 18))
                .frame(width: 32, height: 32)
                .background(DenimTheme.bgDeep)
                .clipShape(RoundedRectangle(cornerRadius: 7))

            Text(item.name)
                .font(DenimTheme.bodyFont(12))
                .foregroundColor(DenimTheme.fabricWhite)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 7)
        .background(
            RoundedRectangle(cornerRadius: 9)
                .fill(isDragging
                      ? DenimTheme.stitchGold.opacity(0.18)
                      : DenimTheme.bgMid.opacity(0.5))
        )
        .scaleEffect(isDragging ? 1.04 : 1.0)
        .animation(.spring(response: 0.2), value: isDragging)
        .onDrag {
            dragState.startDrag()
            isDragging = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                isDragging = false
            }
            return NSItemProvider(object: "\(item.emoji)|\(item.name)" as NSString)
        } preview: {
            // Custom drag preview
            HStack(spacing: 8) {
                Text(item.emoji).font(.system(size: 20))
                Text(item.name)
                    .font(DenimTheme.bodyFont(13))
                    .foregroundColor(DenimTheme.fabricWhite)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(DenimTheme.bgCard)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
}
