//
//  RoutineEnhancerViewModel.swift
//  146GoxlabrenKexzecror
//

import Combine
import Foundation
import SwiftUI

struct RoutineBlockItem: Identifiable, Equatable {
    let id: UUID
    let title: String
    let minutes: Int
    let weight: Int
}

@MainActor
final class RoutineEnhancerViewModel: ObservableObject {
    @Published var items: [RoutineBlockItem] = []
    @Published var isFinished = false
    @Published var stars: Int = 0
    @Published var resultDetail: String = ""
    @Published var draggingId: UUID?
    @Published var dragTranslation: CGFloat = 0
    @Published var dragIndex: Int?

    private var difficulty: Difficulty = .steady

    func start(level: Int, difficulty: Difficulty) {
        self.difficulty = difficulty
        isFinished = false
        stars = 0
        resultDetail = ""
        let n = min(6, max(3, difficulty.routineSlots + min(1, level / 2)))
        let baseTitles = [
            "Deep work block", "Inbox pass", "Planning", "Client reply",
            "Review", "Stabilize backlog", "Walk break", "Research slot"
        ]
        var rng = LCG(seed: UInt64(level) &* 19 &+ 3)
        items = (0..<n).map { i in
            let t = baseTitles[abs(rng.next() % baseTitles.count)]
            let m = 15 + (rng.next() % 3) * 5 + (level * 2)
            let w = 2 + (rng.next() % 4) + (i % 2) + (n - i) / 2
            return RoutineBlockItem(
                id: UUID(),
                title: "\(i + 1). \(t)",
                minutes: m,
                weight: w
            )
        }
    }

    var idealOrderIds: [UUID] {
        items.sorted { a, b in
            if a.weight != b.weight { return a.weight > b.weight }
            return a.minutes > b.minutes
        }
        .map { $0.id }
    }

    var alignmentScore: Double {
        let ideal = idealOrderIds
        var sum = 0
        let n = min(items.count, ideal.count)
        guard n > 0 else { return 0 }
        for (ui, u) in items.map(\.id).enumerated() {
            if let r = ideal.firstIndex(of: u) {
                sum += abs(ui - r)
            }
        }
        let maxPenalty = max(1, n * n)
        let s = 1.0 - Double(min(sum, maxPenalty)) / Double(maxPenalty)
        return max(0, min(1, s))
    }

    func completeSession() {
        let s = alignmentScore
        let t = difficulty.starStrictness
        if s >= t { stars = 3 }
        else if s >= t * 0.72 { stars = 2 }
        else if s >= t * 0.45 { stars = 1 }
        else { stars = 0 }
        resultDetail = String(
            format: "Alignment %.0f%%, blocks matched time weights.",
            s * 100
        )
        isFinished = true
    }

    func move(from: IndexSet, to: Int) {
        items.move(fromOffsets: from, toOffset: to)
    }

    func swapWithPrevious(at i: Int) {
        guard i > 0, i < items.count else { return }
        items.swapAt(i, i - 1)
    }

    func swapWithNext(at i: Int) {
        guard i >= 0, i < items.count - 1 else { return }
        items.swapAt(i, i + 1)
    }

    private struct LCG {
        private var state: UInt64
        init(seed: UInt64) { state = seed }
        mutating func next() -> Int {
            state = state &* 1_103_515_245 &+ 12_345
            return Int(state & 0x7fff)
        }
    }
}
