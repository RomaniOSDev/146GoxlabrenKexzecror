//
//  FocusPulseViewModel.swift
//  146GoxlabrenKexzecror
//

import Combine
import Foundation
import SwiftUI

@MainActor
final class FocusPulseViewModel: ObservableObject {
    @Published var totalSeconds: Int = 0
    @Published var remaining: Int = 0
    @Published var isRunning = false
    @Published var isFinished = false
    @Published var stars: Int = 0
    @Published var resultDetail: String = ""
    private var timer: AnyCancellable?
    private var difficulty: Difficulty = .steady

    func start(level: Int, difficulty: Difficulty) {
        self.difficulty = difficulty
        isFinished = false
        isRunning = false
        stars = 0
        resultDetail = ""
        let base = 4 * 60 + level * 60
        let raw = Int(Double(base) * difficulty.focusLengthScale)
        totalSeconds = min(40 * 60, max(2 * 60, raw))
        remaining = totalSeconds
    }

    func setLength(minutes: Double) {
        guard !isRunning, !isFinished else { return }
        let m = min(90, max(2, minutes))
        totalSeconds = Int(m * 60)
        remaining = totalSeconds
    }

    func play() {
        guard !isFinished else { return }
        isRunning = true
        timer?.cancel()
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.tick()
            }
    }

    func pause() {
        isRunning = false
        timer?.cancel()
        timer = nil
    }

    private func tick() {
        guard isRunning, !isFinished else { return }
        if remaining > 0 {
            remaining -= 1
        }
        if remaining == 0 {
            finishSession(early: false)
        }
    }

    func finishSession(early: Bool) {
        guard !isFinished else { return }
        pause()
        isFinished = true
        let used = max(0, totalSeconds - remaining)
        let ratio = totalSeconds > 0 ? Double(used) / Double(totalSeconds) : 0
        if !early && remaining == 0 {
            stars = 3
            resultDetail = "Full focus window held from start to finish."
        } else {
            if ratio >= 0.96 { stars = 3 }
            else if ratio >= 0.82 { stars = 2 }
            else if ratio >= 0.5 { stars = 1 }
            else { stars = 0 }
            resultDetail = String(
                format: "Completion %.0f%%, pace matched your challenge.",
                ratio * 100
            )
        }
    }
}
