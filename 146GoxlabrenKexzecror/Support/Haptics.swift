//
//  Haptics.swift
//  146GoxlabrenKexzecror
//

import UIKit

enum Haptics {
    static func lightImpact() {
        let g = UIImpactFeedbackGenerator(style: .light)
        g.impactOccurred()
    }

    static func success() {
        let n = UINotificationFeedbackGenerator()
        n.notificationOccurred(.success)
    }

    static func milestone() {
        let n = UINotificationFeedbackGenerator()
        n.notificationOccurred(.success)
    }
}
