//
//  PocketDetailView.swift
//  PocketUp
//
//  Created by Erfan Yarahmadi on 10/03/26.
//

import SwiftUI

struct PocketDetailView: View {
    @State var pocket: Pocket
    @ObservedObject var vm: PocketsViewModel
    @Environment(\.dismiss) var dismiss

    @State private var showingItemPicker = false
    @State private var editingItem: PocketItem? = nil
    @State private var showingEditPocket = false
    @State private var showDeleteConfirm = false
    @State private var animateItems      = false

    var body: some View {
        ZStack(alignment: .top) {
            DenimTextureBackground()

            ScrollView {
                VStack(spacing: 20) {
                    headerHero

                    scheduleStrip
                        .padding(.horizontal, 16)

                    if !pocket.essentialItems.isEmpty {
                        itemSection(title: "ESSENTIALS", items: pocket.essentialItems,
                                    icon: "star.fill", tint: DenimTheme.stitchGold)
                    }
                    if !pocket.regularItems.isEmpty {
                        itemSection(title: "ITEMS", items: pocket.regularItems,
                                    icon: "bag", tint: DenimTheme.fadedDenim)
                    }
                    if pocket.items.isEmpty {
                        emptyItemsPrompt
                    }

                    addItemButton
                        .padding(.horizontal, 16)
                        .padding(.bottom, 40)
                }
            }
            .ignoresSafeArea(edges: .top)

            customNavBar
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showingItemPicker) {
            ItemPickerView(pocket: pocket, vm: vm)
        }
        .sheet(item: $editingItem) { item in
            AddItemView(existingItem: item) { vm.updateItem($0, in: pocket); syncPocket() }
        }
        .sheet(isPresented: $showingEditPocket) {
            EditPocketView(vm: vm, pocket: pocket)
        }
        .confirmationDialog("Delete \(pocket.name)?", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
            Button("Delete", role: .destructive) { vm.deletePocket(pocket); dismiss() }
            Button("Cancel", role: .cancel) {}
        }
        .onAppear { withAnimation(.spring(response: 0.4)) { animateItems = true } }
        .onReceive(vm.$pockets) { pockets in
            if let updated = pockets.first(where: { $0.id == pocket.id }) { pocket = updated }
        }
    }

    // MARK: - Custom Nav Bar
    private var customNavBar: some View {
        HStack {
            Button { dismiss() } label: {
                HStack(spacing: 6) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                    Text("Back")
                        .font(DenimTheme.bodyFont(16))
                }
                .foregroundColor(DenimTheme.fabricWhite)
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
            }

            Spacer()

            Menu {
                Button { showingEditPocket = true } label: {
                    Label("Edit Pocket", systemImage: "pencil")
                }
                Button {
                    vm.toggleActive(pocket)
                    syncPocket()
                } label: {
                    Label(pocket.isActive ? "Deactivate" : "Activate",
                          systemImage: pocket.isActive ? "pause.circle" : "play.circle")
                }
                Divider()
                Button(role: .destructive) { showDeleteConfirm = true } label: {
                    Label("Delete Pocket", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis.circle.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(DenimTheme.fabricWhite, DenimTheme.fabricWhite.opacity(0.2))
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
            }
        }
        .padding(.horizontal, 8)
        .padding(.top, topSafeArea)
    }

    // MARK: - Hero Header
    private var headerHero: some View {
        ZStack(alignment: .bottomLeading) {
            Rectangle()
                .fill(LinearGradient(
                    colors: [
                        pocket.color.opacity(0.7),
                        pocket.color.opacity(0.35),
                        DenimTheme.bgDeep
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                ))
                .frame(height: heroHeight)

            Canvas { ctx, size in
                for i in stride(from: CGFloat(0), through: size.width, by: 8) {
                    var p = Path()
                    p.move(to:    CGPoint(x: i,                       y: 0))
                    p.addLine(to: CGPoint(x: i + size.height * 0.55, y: size.height))
                    ctx.stroke(p, with: .color(Color.white.opacity(0.04)), lineWidth: 1)
                }
            }
            .frame(height: heroHeight)

            LinearGradient(
                colors: [.clear, DenimTheme.bgDeep],
                startPoint: .init(x: 0.5, y: 0.6),
                endPoint: .bottom
            )
            .frame(height: heroHeight)

            HStack(alignment: .bottom, spacing: 16) {
                ZStack {
                    Circle()
                        .fill(pocket.color.opacity(0.3))
                        .frame(width: 76, height: 76)
                        .overlay(
                            Circle()
                                .stroke(style: StrokeStyle(lineWidth: 2, dash: [5, 4]))
                                .foregroundColor(DenimTheme.stitchGold.opacity(0.6))
                        )
                    Image(systemName: pocket.icon)
                        .font(.system(size: 34, weight: .semibold))
                        .foregroundColor(pocket.color)
                }

                VStack(alignment: .leading, spacing: 5) {
                    Text(pocket.name)
                        .font(DenimTheme.titleFont(30))
                        .foregroundColor(DenimTheme.fabricWhite)
                        .shadow(color: .black.opacity(0.4), radius: 4, x: 0, y: 2)
                    HStack(spacing: 6) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.system(size: 12))
                            .foregroundColor(DenimTheme.stitchGold)
                        Text(pocket.destination)
                            .font(DenimTheme.bodyFont(14))
                            .foregroundColor(DenimTheme.fadedDenim)
                    }
                    Text(pocket.isActive ? "● ACTIVE" : "○ PAUSED")
                        .font(DenimTheme.labelFont(10))
                        .kerning(2)
                        .foregroundColor(pocket.isActive ? Color.green : DenimTheme.fadedDenim)
                        .padding(.top, 2)
                }
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
    }

    // MARK: - Schedule Strip
    private var scheduleStrip: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("SCHEDULE")
                .font(DenimTheme.labelFont(11)).kerning(3)
                .foregroundColor(DenimTheme.stitchGold)

            HStack(spacing: 8) {
                HStack(spacing: 4) {
                    ForEach(0..<7) { i in
                        let isOn = pocket.schedule.daysOfWeek.contains(i + 1)
                        Text(["S","M","T","W","T","F","S"][i])
                            .font(.system(size: 11, weight: .bold))
                            .frame(width: 22, height: 28)
                            .background(isOn ? pocket.color.opacity(0.85) : DenimTheme.bgCard)
                            .foregroundColor(isOn ? .white : DenimTheme.fadedDenim.opacity(0.4))
                            .clipShape(Circle())
                            .overlay(Circle().strokeBorder(
                                isOn ? pocket.color.opacity(0.5) : DenimTheme.bgCard.opacity(0.3),
                                lineWidth: 1))
                    }
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    timeRow(icon: "arrow.up.circle.fill",   time: pocket.schedule.departureTime, label: "Leave")
                    timeRow(icon: "arrow.down.circle.fill", time: pocket.schedule.returnTime,    label: "Return")
                }
            }
        }
        .padding(16)
        .background(DenimTheme.bgCard)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .stitchBorder(color: DenimTheme.stitchGold.opacity(0.4))
    }

    private func timeRow(icon: String, time: Date, label: String) -> some View {
        HStack(spacing: 6) {
            Text(label).font(DenimTheme.labelFont(10)).foregroundColor(DenimTheme.fadedDenim).kerning(1)
            Image(systemName: icon).font(.system(size: 12)).foregroundColor(DenimTheme.stitchGold)
            Text(time, style: .time).font(DenimTheme.labelFont(13)).foregroundColor(DenimTheme.fabricWhite)
        }
    }

    // MARK: - Item Section
    private func itemSection(title: String, items: [PocketItem], icon: String, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: icon).font(.system(size: 11)).foregroundColor(tint)
                Text(title).font(DenimTheme.labelFont(11)).kerning(3).foregroundColor(tint)
                Spacer()
                Text("\(items.count)").font(DenimTheme.labelFont(11)).foregroundColor(DenimTheme.fadedDenim)
            }
            .padding(.horizontal, 16)

            VStack(spacing: 2) {
                ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                    itemRow(item: item)
                        .offset(x: animateItems ? 0 : -30)
                        .opacity(animateItems ? 1 : 0)
                        .animation(
                            .spring(response: 0.4, dampingFraction: 0.8).delay(Double(index) * 0.05),
                            value: animateItems
                        )
                }
            }
            .padding(.horizontal, 16)
        }
    }

    // MARK: - Item Row (tap to edit, minus button to remove, swipe to delete)
    private func itemRow(item: PocketItem) -> some View {
        HStack(spacing: 12) {
            Text(item.emoji)
                .font(.system(size: 22))
                .frame(width: 40, height: 40)
                .background(DenimTheme.bgMid)
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
                    .font(.system(size: 11))
                    .foregroundColor(DenimTheme.stitchGold)
            }

            // Inline remove button
            Button {
                withAnimation(.spring(response: 0.3)) {
                    vm.removeItem(item, from: pocket)
                }
                let impact = UIImpactFeedbackGenerator(style: .light)
                impact.impactOccurred()
            } label: {
                Image(systemName: "minus.circle.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(Color.red.opacity(0.75), DenimTheme.bgMid)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(DenimTheme.bgCard)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .onTapGesture { editingItem = item }
        // Swipe left to delete as alternative
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                withAnimation { vm.removeItem(item, from: pocket) }
            } label: {
                Label("Remove", systemImage: "trash")
            }
        }
    }

    // MARK: - Add Item Button
    private var addItemButton: some View {
        Button { showingItemPicker = true } label: {
            HStack {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 17))
                Text("ADD ITEMS")
                    .font(DenimTheme.labelFont(13))
                    .kerning(2)
            }
            .foregroundColor(DenimTheme.stitchGold)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .background(DenimTheme.bgCard)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .stitchBorder(color: DenimTheme.stitchGold.opacity(0.45))
        }
        .buttonStyle(SpringButtonStyle())
    }

    // MARK: - Empty Prompt
    private var emptyItemsPrompt: some View {
        VStack(spacing: 12) {
            Image(systemName: "bag")
                .font(.system(size: 36))
                .foregroundColor(DenimTheme.fadedDenim.opacity(0.4))
            Text("No items yet")
                .font(DenimTheme.bodyFont(16))
                .foregroundColor(DenimTheme.fadedDenim)
            Text("Tap \"ADD ITEMS\" below or drag\nfrom the drawer on the main screen")
                .font(DenimTheme.bodyFont(13))
                .foregroundColor(DenimTheme.fadedDenim.opacity(0.55))
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 36)
    }

    // MARK: - Helpers
    private func syncPocket() {
        if let updated = vm.pockets.first(where: { $0.id == pocket.id }) { pocket = updated }
    }

    private var topSafeArea: CGFloat {
        (UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.windows.first?.safeAreaInsets.top) ?? 44
    }

    private var heroHeight: CGFloat { topSafeArea + 220 }
}
