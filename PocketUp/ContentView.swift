//
//  ContentView 2.swift
//  PocketUp
//
//  Created by Erfan Yarahmadi on 10/03/26.
//

import SwiftUI
import Combine
import UniformTypeIdentifiers

// Shared drag state — ItemDrawerView sets isDragging, ContentView reacts
class DragState: ObservableObject {
    @Published var isDragging = false

    private var locked = false
    private var lockTimer: Timer?
    private var dragTimeoutTimer: Timer?

    func startDrag() {
        guard !locked else { return }
        DispatchQueue.main.async {
            withAnimation(.spring(response: 0.28, dampingFraction: 0.85)) {
                self.isDragging = true
            }
        }
        // Safety timeout — if endDrag() is never called (cancelled drag),
        // automatically slide drawer back after 4 seconds
        dragTimeoutTimer?.invalidate()
        dragTimeoutTimer = Timer.scheduledTimer(withTimeInterval: 4.0, repeats: false) { [weak self] _ in
            self?.endDrag()
        }
    }

    func endDrag() {
        dragTimeoutTimer?.invalidate()
        dragTimeoutTimer = nil

        // Lock briefly to absorb spurious onDrag re-fires from iOS after drop
        locked = true
        lockTimer?.invalidate()
        lockTimer = Timer.scheduledTimer(withTimeInterval: 0.8, repeats: false) { [weak self] _ in
            self?.locked = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            withAnimation(.spring(response: 0.32, dampingFraction: 0.82)) {
                self.isDragging = false
            }
        }
    }
}

struct ContentView: View {
    @StateObject private var vm          = PocketsViewModel()
    @StateObject private var dragState   = DragState()
    @EnvironmentObject var alertState: PocketAlertState

    @State private var showingAddPocket  = false
    @State private var editingPocket: Pocket? = nil
    @State private var animateIn         = false
    @State private var drawerOpen        = false
    @State private var hoveredPocketId: UUID? = nil

    let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        NavigationStack {
            ZStack(alignment: .trailing) {
                DenimTextureBackground()

                // Invisible full-screen drop zone — catches drags dropped on empty space
                Color.clear
                    .ignoresSafeArea()
                    .onDrop(of: [.plainText], delegate: CancelDropDelegate(dragState: dragState))

                ScrollView {
                    VStack(spacing: 0) {
                        headerView
                            .padding(.top, 8)
                            .padding(.horizontal, 20)

                        pocketGrid
                            .padding(.horizontal, 16)
                            .padding(.top, 20)
                            .padding(.bottom, 120)
                    }
                }

                drawerToggleButton

                if drawerOpen {
                    if !dragState.isDragging {
                        Color.black.opacity(0.2)
                            .ignoresSafeArea()
                            .onTapGesture { closeDrawer() }
                            .transition(.opacity)
                    }
                    drawerPanel
                }
            }
            .navigationBarHidden(true)
            .animation(.spring(response: 0.32, dampingFraction: 0.82), value: drawerOpen)
            .animation(.spring(response: 0.28, dampingFraction: 0.85), value: dragState.isDragging)
        }
        .sheet(isPresented: $showingAddPocket) {
            EditPocketView(vm: vm, pocket: nil)
        }
        .sheet(item: $editingPocket) { pocket in
            EditPocketView(vm: vm, pocket: pocket)
        }
        .onAppear {
            withAnimation { animateIn = true }
            NotificationManager.shared.requestPermission()
        }
    }

    // MARK: - Pocket Grid
    private var pocketGrid: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(Array(vm.pockets.enumerated()), id: \.element.id) { index, pocket in
                NavigationLink(destination: PocketDetailView(pocket: pocket, vm: vm)) {
                    PocketCardView(pocket: pocket)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(DenimTheme.stitchGold, lineWidth: 2.5)
                                .opacity(hoveredPocketId == pocket.id ? 1 : 0)
                                .animation(.easeInOut(duration: 0.15), value: hoveredPocketId)
                        )
                        .offset(y: animateIn ? 0 : 60)
                        .opacity(animateIn ? 1 : 0)
                        .animation(
                            .spring(response: 0.5, dampingFraction: 0.75)
                                .delay(Double(index) * 0.07),
                            value: animateIn
                        )
                }
                .buttonStyle(PlainButtonStyle())
                .contextMenu {
                    Button { editingPocket = pocket } label: {
                        Label("Edit Pocket", systemImage: "pencil")
                    }
                    Button(role: .destructive) {
                        withAnimation(.spring()) { vm.deletePocket(pocket) }
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
                .onDrop(of: [.plainText], delegate: PocketDropDelegate(
                    pocket: pocket,
                    vm: vm,
                    dragState: dragState,
                    hoveredPocketId: $hoveredPocketId
                ))
            }

            // Ghost card — always last
            ghostPocketCard
                .offset(y: animateIn ? 0 : 60)
                .opacity(animateIn ? 1 : 0)
                .animation(
                    .spring(response: 0.5, dampingFraction: 0.75)
                        .delay(Double(vm.pockets.count) * 0.07),
                    value: animateIn
                )
        }
    }

    // MARK: - Ghost Pocket Card
    private var ghostPocketCard: some View {
        Button { showingAddPocket = true } label: {
            ZStack {
                PocketShape(topCurveDepth: 22)
                    .stroke(style: StrokeStyle(lineWidth: 2, dash: [8, 5]))
                    .foregroundColor(DenimTheme.stitchGold.opacity(0.3))
                PocketShape(topCurveDepth: 22)
                    .fill(DenimTheme.bgCard.opacity(0.2))
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(DenimTheme.bgCard.opacity(0.5))
                            .frame(width: 48, height: 48)
                            .overlay(
                                Circle()
                                    .strokeBorder(style: StrokeStyle(lineWidth: 1.5, dash: [4, 3]))
                                    .foregroundColor(DenimTheme.stitchGold.opacity(0.4))
                            )
                        Image(systemName: "plus")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(DenimTheme.stitchGold.opacity(0.55))
                    }
                    Text("NEW POCKET")
                        .font(DenimTheme.labelFont(10))
                        .kerning(2)
                        .foregroundColor(DenimTheme.fadedDenim.opacity(0.45))
                }
            }
            .frame(height: 180)
        }
        .buttonStyle(SpringButtonStyle())
        .opacity(0.75)
    }

    // MARK: - Drawer Toggle Button
    private var drawerToggleButton: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        drawerOpen ? closeDrawer() : openDrawer()
                    }
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(drawerOpen ? DenimTheme.stitchGold : DenimTheme.bgCard)
                            .frame(width: 52, height: 52)
                            .shadow(
                                color: DenimTheme.stitchGold.opacity(drawerOpen ? 0.5 : 0.25),
                                radius: 10, x: 0, y: 4
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .strokeBorder(
                                        style: StrokeStyle(lineWidth: 1.5, dash: [5, 4])
                                    )
                                    .foregroundColor(
                                        drawerOpen ? Color.clear : DenimTheme.stitchGold.opacity(0.4)
                                    )
                            )
                        Image(systemName: drawerOpen ? "xmark" : "bag.fill")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(drawerOpen ? DenimTheme.bgDeep : DenimTheme.stitchGold)
                            .rotationEffect(.degrees(drawerOpen ? 90 : 0))
                            .animation(.spring(response: 0.3), value: drawerOpen)
                    }
                }
                .buttonStyle(SpringButtonStyle())
                .padding(.trailing, 20)
                .padding(.bottom, 36)
            }
        }
    }

    // MARK: - Drawer Panel (60% width, slides off when dragging)
    private var drawerPanel: some View {
        GeometryReader { geo in
            HStack(spacing: 0) {
                Spacer()
                ItemDrawerView(vm: vm, dragState: dragState, onClose: closeDrawer)
                    // Slides fully off-screen to the right while dragging
                    .frame(width: geo.size.width * 0.60)
                    .offset(x: dragState.isDragging ? geo.size.width * 0.60 : 0)
                    .opacity(dragState.isDragging ? 0 : 1)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .shadow(color: .black.opacity(0.45), radius: 20, x: -6, y: 0)
            }
            .ignoresSafeArea(edges: .bottom)
        }
    }

    // MARK: - Header
    private var headerView: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 4) {
                Text("MY")
                    .font(DenimTheme.labelFont(13))
                    .foregroundColor(DenimTheme.stitchGold)
                    .kerning(4)
                Text("POCKETS")
                    .font(DenimTheme.titleFont(36))
                    .foregroundColor(DenimTheme.fabricWhite)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(vm.pockets.filter(\.isActive).count)")
                    .font(DenimTheme.titleFont(28))
                    .foregroundColor(DenimTheme.stitchGold)
                Text("active")
                    .font(DenimTheme.labelFont(11))
                    .foregroundColor(DenimTheme.fadedDenim)
                    .kerning(2)
            }
        }
        .padding(.bottom, 8)
    }

    private func openDrawer()  { drawerOpen = true }
    private func closeDrawer() { drawerOpen = false }
}

// MARK: - Cancel Drop Delegate (catches drags dropped on empty space)
struct CancelDropDelegate: DropDelegate {
    let dragState: DragState
    func performDrop(info: DropInfo) -> Bool {
        dragState.endDrag()
        return false
    }
}

// MARK: - Drop Delegate
struct PocketDropDelegate: DropDelegate {
    let pocket: Pocket
    let vm: PocketsViewModel
    let dragState: DragState
    @Binding var hoveredPocketId: UUID?

    func validateDrop(info: DropInfo) -> Bool {
        info.hasItemsConforming(to: [.plainText])
    }

    func dropEntered(info: DropInfo) {
        hoveredPocketId = pocket.id
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
    }

    func dropExited(info: DropInfo) {
        if hoveredPocketId == pocket.id { hoveredPocketId = nil }
    }

    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .copy)
    }

    func performDrop(info: DropInfo) -> Bool {
        hoveredPocketId = nil
        dragState.endDrag()

        guard let provider = info.itemProviders(for: [.plainText]).first else { return false }

        provider.loadItem(forTypeIdentifier: "public.plain-text", options: nil) { data, _ in
            guard let data = data as? Data,
                  let string = String(data: data, encoding: .utf8) else { return }

            let parts = string.split(separator: "|", maxSplits: 1).map(String.init)
            guard parts.count == 2 else { return }

            let emoji = parts[0]
            let name  = parts[1]

            guard !pocket.items.contains(where: { $0.name.lowercased() == name.lowercased() }) else {
                DispatchQueue.main.async {
                    let error = UINotificationFeedbackGenerator()
                    error.notificationOccurred(.error)
                }
                return
            }

            DispatchQueue.main.async {
                let item = PocketItem(name: name, emoji: emoji)
                vm.addItem(item, to: pocket)
                let success = UIImpactFeedbackGenerator(style: .medium)
                success.impactOccurred(intensity: 1.0)
            }
        }
        return true
    }
}

#Preview {
    ContentView()
        .environmentObject(PocketAlertState.shared)
}
