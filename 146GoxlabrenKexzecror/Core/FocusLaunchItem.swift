//
//  FocusLaunchItem.swift
//  146GoxlabrenKexzecror
//

import Foundation

struct FocusLaunchItem: Identifiable, Equatable, Hashable {
    let id: UUID
    var levelIndex: Int
    var minutes: Double

    init(id: UUID = UUID(), levelIndex: Int, minutes: Double) {
        self.id = id
        self.levelIndex = levelIndex
        self.minutes = minutes
    }
}

/// Custom URL and Handoff for offline shortcuts (scene opens focus).
enum AppURLScheme {
    static let scheme = "goxlaflow"
    static let userActivityType = "com.goxlaflow.startFocus"
    static let openURLHost = "focus"

    static func focusURLString(minutes: Int, levelIndex: Int) -> String {
        "\(scheme)://\(openURLHost)?m=\(minutes)&l=\(levelIndex)"
    }
}
