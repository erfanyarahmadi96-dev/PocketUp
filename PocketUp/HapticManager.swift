//
//  HapticManager.swift
//  PocketUp
//
//  Created by Erfan Yarahmadi on 10/03/26.
//

import UIKit
import AVFoundation
import AudioToolbox

class HapticManager: NSObject, AVAudioPlayerDelegate {
    static let shared = HapticManager()
    private override init() { super.init() }

    private var hapticTimer: Timer?
    private var audioPlayer: AVAudioPlayer?
    private var isRunning = false

    // MARK: - Start
    func startPocketAlert() {
        guard !isRunning else { return }
        isRunning = true

        setupAudioSession()
        startLoopingSound()
        scheduleNextHapticBurst()
        print("🔔 Pocket alert started")
    }

    // MARK: - Stop
    func stopPocketAlert() {
        guard isRunning else { return }
        isRunning = false

        hapticTimer?.invalidate()
        hapticTimer = nil

        audioPlayer?.stop()
        audioPlayer = nil

        // Deactivate audio session
        try? AVAudioSession.sharedInstance().setActive(false,
            options: .notifyOthersOnDeactivation)

        // Play satisfying success pattern
        playSuccessHaptic()
        print("✅ Pocket alert stopped")
    }

    // MARK: - Audio Setup
    private func setupAudioSession() {
        do {
            // .playback category plays even when silent switch is ON
            try AVAudioSession.sharedInstance().setCategory(
                .playback,
                mode: .default,
                options: [.mixWithOthers, .duckOthers]
            )
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("❌ Audio session error: \(error)")
        }
    }

    private func startLoopingSound() {
        // Use a system sound file that exists on all iOS devices
        // This is the standard alarm/alert sound
        let soundURLs: [String] = [
            "/System/Library/Audio/UISounds/nano/AlertCalendarReminder01_Haptic.caf",
            "/System/Library/Audio/UISounds/alarm.caf",
            "/System/Library/Audio/UISounds/sms-received1.caf",
            "/System/Library/Audio/UISounds/Tock.caf"
        ]

        // Try each path until one works
        for path in soundURLs {
            let url = URL(fileURLWithPath: path)
            if let player = try? AVAudioPlayer(contentsOf: url) {
                player.delegate = self
                player.numberOfLoops = -1  // infinite loop
                player.volume = 0.9
                player.play()
                audioPlayer = player
                print("🔊 Playing sound: \(path)")
                return
            }
        }

        // Fallback: use AudioServicesPlaySystemSound in a timer loop
        print("⚠️ No system sound found, falling back to AudioServices")
        hapticTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { [weak self] _ in
            guard self?.isRunning == true else { return }
            AudioServicesPlayAlertSoundWithCompletion(SystemSoundID(1005)) { }
        }
    }

    // MARK: - Haptic Pattern Loop
    private func scheduleNextHapticBurst() {
        guard isRunning else { return }
        playHapticBurst()

        hapticTimer = Timer.scheduledTimer(withTimeInterval: 1.6, repeats: false) { [weak self] _ in
            self?.scheduleNextHapticBurst()
        }
    }

    private func playHapticBurst() {
        guard isRunning else { return }

        // 3-pulse pattern: strong - medium - strong
        let heavy  = UIImpactFeedbackGenerator(style: .heavy)
        let medium = UIImpactFeedbackGenerator(style: .medium)
        heavy.prepare()
        medium.prepare()

        heavy.impactOccurred(intensity: 1.0)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) { [weak self] in
            guard self?.isRunning == true else { return }
            medium.impactOccurred(intensity: 0.7)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.36) { [weak self] in
            guard self?.isRunning == true else { return }
            heavy.impactOccurred(intensity: 1.0)
        }
    }

    // MARK: - Success Pattern
    private func playSuccessHaptic() {
        let notification = UINotificationFeedbackGenerator()
        notification.prepare()
        notification.notificationOccurred(.success)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred(intensity: 0.8)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.30) {
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred(intensity: 0.5)
        }
    }

    // AVAudioPlayerDelegate — restart if it stops unexpectedly
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if isRunning { player.play() }
    }
}
