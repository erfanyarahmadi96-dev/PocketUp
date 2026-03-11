//
//  PocketAlertView.swift
//  PocketUp
//
//  Created by Erfan Yarahmadi on 10/03/26.
//



import SwiftUI
import CoreMotion

struct PocketAlertView: View {
    let pocket: Pocket
    var onConfirmed: () -> Void
    var onDismiss: () -> Void

    @StateObject private var backTapDetector = BackTapDetector()

    @State private var isConfirmed    = false
    @State private var pulseScale: CGFloat = 1.0
    @State private var ripples: [RippleEffect] = []
    @State private var tapCount       = 0          // 0, 1, or 2
    @State private var firstTapFlash  = false

    var body: some View {
        ZStack {
            DenimTextureBackground()

            // Ripples
            ForEach(ripples) { ripple in
                Circle()
                    .stroke(pocket.color.opacity(ripple.opacity), lineWidth: 2)
                    .frame(width: ripple.size, height: ripple.size)
                    .offset(x: ripple.x, y: ripple.y)
            }

            VStack(spacing: 0) {
                Spacer()

                // Title + subtitle
                VStack(spacing: 12) {
                    Text(isConfirmed ? "GOT IT!" : "CHECK YOUR POCKET")
                        .font(DenimTheme.titleFont(isConfirmed ? 34 : 26))
                        .foregroundColor(isConfirmed ? .green : DenimTheme.stitchGold)
                        .kerning(4)
                        .animation(.spring(response: 0.3), value: isConfirmed)

                    Text(isConfirmed
                         ? "All packed for \(pocket.name)!"
                         : "Double tap the back of your phone\nto confirm you have everything")
                        .font(DenimTheme.bodyFont(16))
                        .foregroundColor(DenimTheme.fadedDenim)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }

                Spacer().frame(height: 48)

                // Pocket visual + tap counter
                ZStack {
                    // Pulse rings
                    if !isConfirmed {
                        ForEach(0..<3) { i in
                            Circle()
                                .stroke(pocket.color.opacity(0.12 - Double(i) * 0.03), lineWidth: 1.5)
                                .frame(width: 200 + CGFloat(i) * 44, height: 200 + CGFloat(i) * 44)
                                .scaleEffect(pulseScale + CGFloat(i) * 0.07)
                                .animation(
                                    .easeInOut(duration: 1.0)
                                        .repeatForever(autoreverses: true)
                                        .delay(Double(i) * 0.25),
                                    value: pulseScale
                                )
                        }
                    }

                    // Pocket shape
                    ZStack {
                        PocketShape(topCurveDepth: 28)
                            .fill(LinearGradient(
                                colors: isConfirmed
                                    ? [Color.green.opacity(0.4), Color.green.opacity(0.15)]
                                    : tapCount == 1
                                        ? [pocket.color.opacity(0.4), pocket.color.opacity(0.2)]
                                        : [DenimTheme.bgCard, DenimTheme.bgMid],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .animation(.easeInOut(duration: 0.2), value: tapCount)
                            .animation(.spring(response: 0.4), value: isConfirmed)

                        PocketShape(topCurveDepth: 28)
                            .stroke(style: StrokeStyle(lineWidth: 2, dash: [6, 4]))
                            .foregroundColor(
                                isConfirmed
                                    ? Color.green.opacity(0.9)
                                    : tapCount == 1
                                        ? pocket.color.opacity(0.9)
                                        : DenimTheme.stitchGold.opacity(0.5)
                            )
                            .animation(.easeInOut(duration: 0.2), value: tapCount)

                        // Icon
                        VStack(spacing: 10) {
                            Image(systemName: isConfirmed ? "checkmark.circle.fill" : pocket.icon)
                                .font(.system(size: 46, weight: .semibold))
                                .foregroundColor(isConfirmed ? .green : pocket.color)
                                .scaleEffect(isConfirmed ? 1.2 : 1.0)
                                .animation(.spring(response: 0.3, dampingFraction: 0.5), value: isConfirmed)

                            Text(pocket.name)
                                .font(DenimTheme.titleFont(17))
                                .foregroundColor(DenimTheme.fabricWhite)
                        }
                    }
                    .frame(width: 180, height: 180)
                }
                .frame(width: 300, height: 300)

                Spacer().frame(height: 36)

                // Tap counter dots
                if !isConfirmed {
                    tapCounterView
                }

                Spacer().frame(height: 20)

                // Instruction hint
                if !isConfirmed {
                    HStack(spacing: 8) {
                        Image(systemName: "iphone.rear.camera")
                            .font(.system(size: 14))
                            .foregroundColor(DenimTheme.fadedDenim.opacity(0.6))
                        Text("Tap the back of your phone twice")
                            .font(DenimTheme.labelFont(11))
                            .kerning(2)
                            .foregroundColor(DenimTheme.fadedDenim.opacity(0.6))
                    }
                }

                Spacer()

                // Snooze button
                if !isConfirmed {
                    Button {
                        HapticManager.shared.stopPocketAlert()
                        backTapDetector.stop()
                        onDismiss()
                    } label: {
                        Text("Snooze 5 minutes")
                            .font(DenimTheme.labelFont(11))
                            .kerning(2)
                            .foregroundColor(DenimTheme.fadedDenim.opacity(0.4))
                            .padding(.vertical, 10)
                            .padding(.horizontal, 20)
                    }
                    .padding(.bottom, 44)
                }
            }
        }
        .onAppear {
            // Start pulse animation
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                pulseScale = 1.07
            }
            // Start haptic + sound loop
            HapticManager.shared.startPocketAlert()

            // Start back tap detection
            backTapDetector.onDoubleTap = {
                handleDoubleTap()
            }
            backTapDetector.start()
        }
        .onDisappear {
            HapticManager.shared.stopPocketAlert()
            backTapDetector.stop()
        }
    }

    // MARK: - Tap Counter UI
    private var tapCounterView: some View {
        VStack(spacing: 10) {
            HStack(spacing: 16) {
                ForEach(0..<2) { i in
                    ZStack {
                        Circle()
                            .fill(i < tapCount
                                  ? pocket.color
                                  : DenimTheme.bgCard)
                            .frame(width: 44, height: 44)
                            .overlay(
                                Circle().strokeBorder(
                                    i < tapCount
                                        ? pocket.color
                                        : DenimTheme.fadedDenim.opacity(0.3),
                                    lineWidth: 1.5
                                )
                            )
                            .scaleEffect(i == tapCount - 1 && tapCount > 0 ? 1.25 : 1.0)
                            .animation(.spring(response: 0.25, dampingFraction: 0.5),
                                       value: tapCount)

                        if i < tapCount {
                            Image(systemName: "hand.tap.fill")
                                .font(.system(size: 18))
                                .foregroundColor(.white)
                        } else {
                            Text("\(i + 1)")
                                .font(DenimTheme.titleFont(16))
                                .foregroundColor(DenimTheme.fadedDenim.opacity(0.4))
                        }
                    }
                }
            }

            Text(tapCount == 0 ? "TAP TWICE" : tapCount == 1 ? "ONE MORE!" : "")
                .font(DenimTheme.labelFont(11))
                .kerning(3)
                .foregroundColor(tapCount == 1 ? pocket.color : DenimTheme.fadedDenim.opacity(0.5))
                .animation(.easeInOut, value: tapCount)
        }
    }

    // MARK: - Handle detection
    private func handleDoubleTap() {
        // Flash both dots then confirm
        withAnimation { tapCount = 1 }
        spawnRipple()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            withAnimation { tapCount = 2 }
            spawnRipple()
            spawnRipple()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                isConfirmed = true
            }
            HapticManager.shared.stopPocketAlert()
            backTapDetector.stop()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
            onConfirmed()
        }
    }

    // MARK: - Ripple
    private func spawnRipple() {
        let ripple = RippleEffect(
            id: UUID(),
            x: CGFloat.random(in: -40...40),
            y: CGFloat.random(in: -40...40),
            size: 20,
            opacity: 0.7
        )
        ripples.append(ripple)

        withAnimation(.easeOut(duration: 0.9)) {
            if let idx = ripples.firstIndex(where: { $0.id == ripple.id }) {
                ripples[idx].size    = 280
                ripples[idx].opacity = 0
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
            ripples.removeAll { $0.id == ripple.id }
        }
    }
}

// MARK: - Ripple Model
struct RippleEffect: Identifiable {
    let id: UUID
    var x: CGFloat
    var y: CGFloat
    var size: CGFloat
    var opacity: Double
}
