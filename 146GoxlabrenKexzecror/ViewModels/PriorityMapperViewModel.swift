//
//  PriorityMapperViewModel.swift
//  146GoxlabrenKexzecror
//

import Combine
import Foundation
import SwiftUI

struct PrioritizedTask: Identifiable, Equatable {
    let id: UUID
    let label: String
    var currentQuadrant: Int
    let targetQuadrant: Int
}

@MainActor
final class PriorityMapperViewModel: ObservableObject {
    @Published var tasks: [PrioritizedTask] = []
    @Published var isFinished = false
    @Published var stars: Int = 0
    @Published var resultDetail: String = ""

    private var difficulty: Difficulty = .steady

    func start(level: Int, difficulty: Difficulty) {
        self.difficulty = difficulty
        isFinished = false
        stars = 0
        resultDetail = ""
        let n = min(6, max(3, difficulty.priorityItemCount + min(1, level / 2)))
        let ideas = [
            "Prepare outline", "Follow up on email", "Tidy files",
            "Urgent call", "Draft proposal", "Schedule check-in", "Reconcile tasks",
            "Clarify scope", "Client notes", "Ship update"
        ]
        var r = LCG(state: UInt64(level) * 5 &+ 99)
        tasks = (0..<n).map { i in
            let tq = abs(r.next() % 4)
            let st = abs(r.next() % 4)
            return PrioritizedTask(
                id: UUID(),
                label: "\(i + 1) · \(ideas[abs(r.next() % ideas.count)])",
                currentQuadrant: st,
                targetQuadrant: tq
            )
        }
    }

    var matchRatio: Double {
        let c = tasks.count
        guard c > 0 else { return 0 }
        let ok = tasks.filter { $0.currentQuadrant == $0.targetQuadrant }.count
        return Double(ok) / Double(c)
    }

    func cycleQuadrant(for id: PrioritizedTask.ID) {
        guard !isFinished, let i = tasks.firstIndex(where: { $0.id == id }) else { return }
        tasks[i].currentQuadrant = (tasks[i].currentQuadrant + 1) % 4
    }

    func complete() {
        let t = difficulty.starStrictness
        let m = matchRatio
        if m >= t { stars = 3 }
        else if m >= t * 0.7 { stars = 2 }
        else if m >= t * 0.45 { stars = 1 }
        else { stars = 0 }
        resultDetail = String(
            format: "Map accuracy %.0f%%, quadrants line up with urgency and impact.",
            m * 100
        )
        isFinished = true
    }

    private struct LCG {
        private var state: UInt64
        init(state: UInt64) { self.state = state }
        mutating func next() -> Int {
            state = state &* 1_103_515_245 &+ 12_345
            return Int(state & 0x7fff)
        }
    }
}
