//
//  GoxlabApp.swift
//  146GoxlabrenKexzecror
//  SwiftUI lifecycle: required for onOpenURL / onContinueUserActivity and predictable window chrome.
//

import SwiftUI

@main
struct GoxlabApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ZStack {
                AppColor.background
                    .ignoresSafeArea()
                ContentView()
            }
        }
    }
}
