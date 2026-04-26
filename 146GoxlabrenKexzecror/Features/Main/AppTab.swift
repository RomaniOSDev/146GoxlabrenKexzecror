//
//  AppTab.swift
//  146GoxlabrenKexzecror
//

import Foundation

enum AppTab: Int, CaseIterable, Identifiable {
    case home
    case history
    case goals
    case settings

    var id: Int { rawValue }

    var label: String {
        switch self {
        case .home: return "Home"
        case .history: return "History"
        case .goals: return "Goals"
        case .settings: return "Settings"
        }
    }

    var systemImage: String {
        switch self {
        case .home: return "house.fill"
        case .history: return "clock.arrow.circlepath"
        case .goals: return "target"
        case .settings: return "gearshape.fill"
        }
    }
}
