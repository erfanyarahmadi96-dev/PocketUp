//
//  BackTapDetector.swift
//  PocketUp
//
//  Created by Erfan Yarahmadi on 11/03/26.
//


import CoreMotion
import Combine

class BackTapDetector: ObservableObject {
    private let motionManager = CMMotionManager()
    private var tapTimestamps: [Date] = []
    private let tapThreshold: Double = 2.8        // g-force spike to count as a tap
    private let doubleTapWindow: TimeInterval = 0.8 // seconds between two taps
    private let minTimeBetweenTaps: TimeInterval = 0.15 // debounce

    var onDoubleTap: (() -> Void)?

    func start() {
        guard motionManager.isAccelerometerAvailable else {
            print("⚠️ Accelerometer not available")
            return
        }

        tapTimestamps.removeAll()
        motionManager.accelerometerUpdateInterval = 1.0 / 100.0 // 100 Hz

        motionManager.startAccelerometerUpdates(to: .main) { [weak self] data, error in
            guard let self = self, let data = data else { return }
            self.processAcceleration(data.acceleration)
        }
        print("🔍 Back tap detector started")
    }

    func stop() {
        motionManager.stopAccelerometerUpdates()
        tapTimestamps.removeAll()
        print("🛑 Back tap detector stopped")
    }

    private func processAcceleration(_ acc: CMAcceleration) {
        // Total acceleration magnitude (subtract gravity ~1g on Z axis)
        // When phone is flat, Z is ~1.0 due to gravity
        // A back tap produces a sharp spike in Z (away from screen direction)
        let zSpike = abs(acc.z)
        let totalMagnitude = sqrt(acc.x * acc.x + acc.y * acc.y + acc.z * acc.z)

        // We look for a sharp spike that exceeds threshold
        // The spike needs to be predominantly in Z (back of phone)
        guard zSpike > tapThreshold || totalMagnitude > tapThreshold + 0.5 else { return }

        let now = Date()

        // Debounce — ignore if too soon after last tap
        if let lastTap = tapTimestamps.last,
           now.timeIntervalSince(lastTap) < minTimeBetweenTaps {
            return
        }

        tapTimestamps.append(now)
        print("👆 Tap detected! magnitude=\(String(format: "%.2f", totalMagnitude)) z=\(String(format: "%.2f", zSpike))")

        // Clean old timestamps outside the double-tap window
        tapTimestamps = tapTimestamps.filter {
            now.timeIntervalSince($0) <= doubleTapWindow
        }

        // Check if we have 2 taps within the window
        if tapTimestamps.count >= 2 {
            tapTimestamps.removeAll()
            print("✅ Double back tap confirmed!")
            DispatchQueue.main.async {
                self.onDoubleTap?()
            }
        }
    }
}