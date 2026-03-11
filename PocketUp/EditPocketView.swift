//
//  EditPocketView.swift
//  PocketUp
//
//  Created by Erfan Yarahmadi on 10/03/26.
//


import SwiftUI

struct EditPocketView: View {
    @ObservedObject var vm: PocketsViewModel
    var pocket: Pocket?

    @Environment(\.dismiss) var dismiss

    @State private var name             = ""
    @State private var destination      = ""
    @State private var selectedIcon     = "bag.fill"
    @State private var selectedColorHex = "#3B82F6"
    @State private var selectedDays     = Set<Int>()
    @State private var departureTime    = Calendar.current.date(bySettingHour: 8,  minute: 0, second: 0, of: Date()) ?? Date()
    @State private var returnTime       = Calendar.current.date(bySettingHour: 17, minute: 0, second: 0, of: Date()) ?? Date()
    @State private var remindOnDepart   = true
    @State private var remindOnReturn   = true
    @State private var advanceMinutes   = 15
    @State private var isActive         = true
    @State private var activeSection    = 0

    private let icons = [
        "graduationcap.fill","briefcase.fill","dumbbell.fill","house.fill",
        "cart.fill","cross.case.fill","fork.knife","tram.fill",
        "airplane","beach.umbrella.fill","music.note","paintbrush.fill",
        "camera.fill","heart.fill","star.fill","flame.fill",
        "leaf.fill","gamecontroller.fill","book.fill","keyboard.fill"
    ]
    private let palette = [
        "#3B82F6","#EF4444","#10B981","#F59E0B","#8B5CF6",
        "#EC4899","#06B6D4","#84CC16","#F97316","#6366F1",
        "#14B8A6","#F43F5E","#A855F7","#22C55E","#EAB308"
    ]
    private let advanceOptions = [5,10,15,20,30,45,60]
    private let dayLetters = ["S","M","T","W","T","F","S"]

    var isEditing: Bool { pocket != nil }

    var body: some View {
        ZStack {
            DenimTheme.bgDeep.ignoresSafeArea()
            VStack(spacing: 0) {

                // ── Header ──────────────────────────────────────────────
                HStack {
                    Button("Cancel") { dismiss() }
                        .font(DenimTheme.bodyFont(16))
                        .foregroundColor(DenimTheme.fadedDenim)
                    Spacer()
                    Text(isEditing ? "Edit Pocket" : "New Pocket")
                        .font(DenimTheme.titleFont(18))
                        .foregroundColor(DenimTheme.fabricWhite)
                    Spacer()
                    Button("Save") { savePocket() }
                        .font(DenimTheme.bodyFont(16).weight(.semibold))
                        .foregroundColor(name.isEmpty ? DenimTheme.fadedDenim : DenimTheme.stitchGold)
                        .disabled(name.isEmpty)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)

                // ── Tab Bar ──────────────────────────────────────────────
                HStack(spacing: 0) {
                    ForEach(Array(["BASICS","SCHEDULE","LOOK"].enumerated()), id: \.offset) { idx, label in
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) { activeSection = idx }
                        } label: {
                            VStack(spacing: 8) {
                                Text(label)
                                    .font(DenimTheme.labelFont(12))
                                    .kerning(2)
                                    .foregroundColor(activeSection == idx ? DenimTheme.stitchGold : DenimTheme.fadedDenim)
                                    .padding(.top, 14)

                                Rectangle()
                                    .fill(activeSection == idx ? DenimTheme.stitchGold : Color.clear)
                                    .frame(height: 2)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)          // ← explicit tap height
                            .contentShape(Rectangle())  // ← makes whole area tappable
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .background(DenimTheme.bgMid)

                // ── Content ──────────────────────────────────────────────
                ScrollView {
                    Group {
                        if activeSection == 0      { basicsSection }
                        else if activeSection == 1 { scheduleSection }
                        else                       { lookSection }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                    .padding(.bottom, 60)
                }
            }
        }
        .onAppear { loadPocket() }
    }

    // MARK: - Basics
    private var basicsSection: some View {
        VStack(spacing: 16) {
            field(label: "POCKET NAME") {
                TextField("e.g. University, Gym...", text: $name)
                    .font(DenimTheme.bodyFont(16))
                    .foregroundColor(DenimTheme.fabricWhite)
                    .accentColor(DenimTheme.stitchGold)
            }
            field(label: "DESTINATION") {
                TextField("e.g. Campus Main Building", text: $destination)
                    .font(DenimTheme.bodyFont(16))
                    .foregroundColor(DenimTheme.fabricWhite)
                    .accentColor(DenimTheme.stitchGold)
            }
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("POCKET ACTIVE")
                        .font(DenimTheme.labelFont(10))
                        .kerning(3)
                        .foregroundColor(DenimTheme.stitchGold)
                    Text("Enable reminders for this pocket")
                        .font(DenimTheme.bodyFont(13))
                        .foregroundColor(DenimTheme.fadedDenim)
                }
                Spacer()
                Toggle("", isOn: $isActive).tint(DenimTheme.stitchGold)
            }
            .padding(16)
            .background(DenimTheme.bgCard)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    // MARK: - Schedule
    private var scheduleSection: some View {
        VStack(spacing: 16) {

            // Days of week
            VStack(alignment: .leading, spacing: 12) {
                Text("DAYS OF WEEK")
                    .font(DenimTheme.labelFont(10))
                    .kerning(3)
                    .foregroundColor(DenimTheme.stitchGold)
                HStack(spacing: 6) {
                    ForEach(0..<7) { i in
                        let day = i + 1
                        Button {
                            withAnimation(.spring(response: 0.25)) {
                                if selectedDays.contains(day) { selectedDays.remove(day) }
                                else { selectedDays.insert(day) }
                            }
                        } label: {
                            let isOn = selectedDays.contains(day)
                            Text(dayLetters[i])
                                .font(.system(size: 13, weight: .bold))
                                .frame(width: 38, height: 38)
                                .background(isOn ? (Color(hex: selectedColorHex) ?? .blue) : DenimTheme.bgDeep)
                                .foregroundColor(isOn ? .white : DenimTheme.fadedDenim)
                                .clipShape(Circle())
                                .overlay(Circle().strokeBorder(
                                    isOn ? (Color(hex: selectedColorHex) ?? .blue).opacity(0.5) : DenimTheme.fadedDenim.opacity(0.2),
                                    lineWidth: 1.5))
                        }
                        .buttonStyle(SpringButtonStyle())
                    }
                }
            }
            .padding(16)
            .background(DenimTheme.bgCard)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            // Departure time
            VStack(alignment: .leading, spacing: 12) {
                Text("DEPARTURE TIME")
                    .font(DenimTheme.labelFont(10))
                    .kerning(3)
                    .foregroundColor(DenimTheme.stitchGold)
                Toggle("Remind me before leaving", isOn: $remindOnDepart)
                    .font(DenimTheme.bodyFont(14))
                    .foregroundColor(DenimTheme.fabricWhite)
                    .tint(DenimTheme.stitchGold)
                if remindOnDepart {
                    DatePicker("", selection: $departureTime, displayedComponents: .hourAndMinute)
                        .datePickerStyle(.wheel)
                        .labelsHidden()
                        .colorScheme(.dark)
                        .frame(maxWidth: .infinity)
                    HStack {
                        Text("Remind me")
                            .font(DenimTheme.bodyFont(14))
                            .foregroundColor(DenimTheme.fabricWhite)
                        Picker("", selection: $advanceMinutes) {
                            ForEach(advanceOptions, id: \.self) { Text("\($0) min before").tag($0) }
                        }
                        .pickerStyle(.menu)
                        .tint(DenimTheme.stitchGold)
                    }
                }
            }
            .padding(16)
            .background(DenimTheme.bgCard)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            // Return time
            VStack(alignment: .leading, spacing: 12) {
                Text("RETURN TIME")
                    .font(DenimTheme.labelFont(10))
                    .kerning(3)
                    .foregroundColor(DenimTheme.stitchGold)
                Toggle("Remind me when leaving destination", isOn: $remindOnReturn)
                    .font(DenimTheme.bodyFont(14))
                    .foregroundColor(DenimTheme.fabricWhite)
                    .tint(DenimTheme.stitchGold)
                if remindOnReturn {
                    DatePicker("", selection: $returnTime, displayedComponents: .hourAndMinute)
                        .datePickerStyle(.wheel)
                        .labelsHidden()
                        .colorScheme(.dark)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(16)
            .background(DenimTheme.bgCard)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    // MARK: - Look
    private var lookSection: some View {
        VStack(spacing: 16) {

            // Live preview card
            ZStack {
                PocketShape(topCurveDepth: 22)
                    .fill(LinearGradient(
                        colors: [DenimTheme.bgCard, DenimTheme.bgMid],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    ))
                    .frame(height: 130)
                    .overlay(
                        PocketShape(topCurveDepth: 22)
                            .stroke(style: StrokeStyle(lineWidth: 1.5, dash: [5,4]))
                            .foregroundColor(DenimTheme.stitchGold.opacity(0.6))
                            .padding(3)
                    )
                HStack {
                    ZStack {
                        Circle()
                            .fill((Color(hex: selectedColorHex) ?? .blue).opacity(0.3))
                            .frame(width: 50, height: 50)
                        Image(systemName: selectedIcon)
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(Color(hex: selectedColorHex) ?? .blue)
                    }
                    VStack(alignment: .leading, spacing: 3) {
                        Text(name.isEmpty ? "Pocket Name" : name)
                            .font(DenimTheme.titleFont(18))
                            .foregroundColor(DenimTheme.fabricWhite)
                        Text(destination.isEmpty ? "Destination" : destination)
                            .font(DenimTheme.bodyFont(12))
                            .foregroundColor(DenimTheme.fadedDenim)
                    }
                    Spacer()
                }
                .padding(20)
            }

            // Colour picker
            VStack(alignment: .leading, spacing: 12) {
                Text("COLOUR")
                    .font(DenimTheme.labelFont(10))
                    .kerning(3)
                    .foregroundColor(DenimTheme.stitchGold)
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 12) {
                    ForEach(palette, id: \.self) { hex in
                        Button { selectedColorHex = hex } label: {
                            Circle()
                                .fill(Color(hex: hex) ?? .blue)
                                .frame(width: 44, height: 44)
                                .overlay(
                                    Circle()
                                        .strokeBorder(.white, lineWidth: selectedColorHex == hex ? 3 : 0)
                                        .padding(2)
                                )
                                .shadow(color: (Color(hex: hex) ?? .blue).opacity(0.5),
                                        radius: selectedColorHex == hex ? 8 : 0)
                        }
                    }
                }
            }
            .padding(16)
            .background(DenimTheme.bgCard)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            // Icon picker
            VStack(alignment: .leading, spacing: 12) {
                Text("ICON")
                    .font(DenimTheme.labelFont(10))
                    .kerning(3)
                    .foregroundColor(DenimTheme.stitchGold)
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 10) {
                    ForEach(icons, id: \.self) { icon in
                        Button { selectedIcon = icon } label: {
                            let isOn = selectedIcon == icon
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(isOn ? (Color(hex: selectedColorHex) ?? .blue).opacity(0.3) : DenimTheme.bgDeep)
                                    .frame(width: 50, height: 50)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .strokeBorder(
                                                isOn ? (Color(hex: selectedColorHex) ?? .blue) : Color.clear,
                                                lineWidth: 1.5
                                            )
                                    )
                                Image(systemName: icon)
                                    .font(.system(size: 22))
                                    .foregroundColor(isOn ? (Color(hex: selectedColorHex) ?? .blue) : DenimTheme.fadedDenim)
                            }
                        }
                    }
                }
            }
            .padding(16)
            .background(DenimTheme.bgCard)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    // MARK: - Helpers
    @ViewBuilder
    private func field<C: View>(label: String, @ViewBuilder content: () -> C) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(DenimTheme.labelFont(10))
                .kerning(3)
                .foregroundColor(DenimTheme.stitchGold)
            content()
                .padding(14)
                .background(DenimTheme.bgCard)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private func loadPocket() {
        guard let p = pocket else { return }
        name = p.name; destination = p.destination
        selectedIcon = p.icon; selectedColorHex = p.colorHex
        selectedDays = p.schedule.daysOfWeek
        departureTime = p.schedule.departureTime; returnTime = p.schedule.returnTime
        remindOnDepart = p.schedule.remindOnDepart; remindOnReturn = p.schedule.remindOnReturn
        advanceMinutes = p.schedule.advanceMinutes; isActive = p.isActive
    }

    private func savePocket() {
        var sched = PocketSchedule()
        sched.daysOfWeek     = selectedDays
        sched.departureTime  = departureTime
        sched.returnTime     = returnTime
        sched.remindOnDepart = remindOnDepart
        sched.remindOnReturn = remindOnReturn
        sched.advanceMinutes = advanceMinutes

        if var existing = pocket {
            existing.name        = name
            existing.destination = destination
            existing.icon        = selectedIcon
            existing.colorHex    = selectedColorHex
            existing.schedule    = sched
            existing.isActive    = isActive
            vm.updatePocket(existing)
        } else {
            vm.addPocket(Pocket(
                name:        name,
                destination: destination,
                icon:        selectedIcon,
                colorHex:    selectedColorHex,
                schedule:    sched
            ))
        }
        dismiss()
    }
}
