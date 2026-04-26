//
//  AppDelegate.swift
//  146GoxlabrenKexzecror
//
//  Created by Roman on 4/26/26.
//

import UIKit
import UserNotifications

class AppDelegate: UIResponder, UIApplicationDelegate {
    private let notificationDelegate = AppNotificationCenterDelegate()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        Self.configureGlobalChrome()
        UNUserNotificationCenter.current().delegate = notificationDelegate
        return true
    }

    /// Navigation / scroll / window defaults that otherwise draw `systemBackground` (black in dark mode)
    /// above SwiftUI gradients.
    static func configureGlobalChrome() {
        let title = UIColor(white: 1.0, alpha: 1.0)
        let bar = UINavigationBarAppearance()
        bar.configureWithTransparentBackground()
        bar.backgroundColor = .clear
        bar.shadowColor = .clear
        bar.titleTextAttributes = [.foregroundColor: title]
        bar.largeTitleTextAttributes = [.foregroundColor: title]
        UINavigationBar.appearance().isTranslucent = true
        UINavigationBar.appearance().tintColor = UIColor(named: "AppPrimary")
        UINavigationBar.appearance().standardAppearance = bar
        UINavigationBar.appearance().compactAppearance = bar
        UINavigationBar.appearance().scrollEdgeAppearance = bar
        if #available(iOS 15.0, *) {
            UINavigationBar.appearance().compactScrollEdgeAppearance = bar
        }

        UIScrollView.appearance().backgroundColor = .clear
        UITableView.appearance().backgroundColor = .clear

        if let bg = UIColor(named: "AppBackground") {
            UIWindow.appearance().backgroundColor = bg
        } else {
            UIWindow.appearance().backgroundColor = UIColor(red: 0.2, green: 0.231, blue: 0.392, alpha: 1)
        }
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

