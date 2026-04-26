//
//  WindowBackgroundSync.swift
//  146GoxlabrenKexzecror
//  SwiftUI’s UIHostingController / navigation chrome can keep a black layer; sync UIKit window + VC tree.
//

import UIKit

enum WindowBackgroundSync {
    private static var appTint: UIColor {
        UIColor(named: "AppBackground")
            ?? UIColor(red: 0.2, green: 0.231, blue: 0.392, alpha: 1)
    }

    static func apply() {
        let bg = appTint
        for case let scene as UIWindowScene in UIApplication.shared.connectedScenes {
            for window in scene.windows {
                window.backgroundColor = bg
                if let root = window.rootViewController {
                    clearHostingAndNavigationBackgrounds(root)
                }
            }
        }
    }

    private static func clearHostingAndNavigationBackgrounds(_ vc: UIViewController) {
        vc.view.backgroundColor = .clear
        if let nav = vc as? UINavigationController {
            nav.view.backgroundColor = .clear
            nav.navigationBar.isTranslucent = true
        }
        for child in vc.children {
            clearHostingAndNavigationBackgrounds(child)
        }
        if let presented = vc.presentedViewController {
            clearHostingAndNavigationBackgrounds(presented)
        }
    }
}
