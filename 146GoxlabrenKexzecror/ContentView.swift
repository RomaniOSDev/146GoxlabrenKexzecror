//
//  ContentView.swift
//  146GoxlabrenKexzecror
//
//  Created by Roman on 4/26/26.
//

import SwiftUI
import UIKit

struct ContentView: View {
    @StateObject private var app = AppData()
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        Group {
            if app.hasSeenOnboarding {
                MainView()
            } else {
                OnboardingView()
            }
        }
        .environmentObject(app)
        .background(AppColor.background.ignoresSafeArea())
        .preferredColorScheme(.dark)
        .tint(AppColor.primary)
        .onAppear {
            WindowBackgroundSync.apply()
            LocalNotificationService.reschedule(using: app)
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active {
                WindowBackgroundSync.apply()
            }
        }
        .onChange(of: app.remindFocusOn) { _, _ in LocalNotificationService.reschedule(using: app) }
        .onChange(of: app.dayReviewOn) { _, _ in LocalNotificationService.reschedule(using: app) }
        .onChange(of: app.focusReminderMinuteOfDay) { _, _ in
            LocalNotificationService.reschedule(using: app)
        }
        .onChange(of: app.dayReviewMinuteOfDay) { _, _ in LocalNotificationService.reschedule(using: app) }
        .onOpenURL { url in
            openURLForFocusShortcut(url, app: app)
        }
        .onContinueUserActivity(AppURLScheme.userActivityType) { activity in
            continueUserActivityForFocus(activity, app: app)
        }
    }
}

@MainActor
private func openURLForFocusShortcut(_ url: URL, app: AppData) {
    guard url.scheme?.lowercased() == AppURLScheme.scheme else { return }
    let h = (url.host ?? "").lowercased()
    if !h.isEmpty, h != AppURLScheme.openURLHost { return }
    let comp = URLComponents(url: url, resolvingAgainstBaseURL: true)
    var m = 25
    if let s = comp?.queryItems?.first(where: { $0.name == "m" })?.value, let n = Int(s) {
        m = min(90, max(2, n))
    }
    var lv = 0
    if let s = comp?.queryItems?.first(where: { $0.name == "l" })?.value, let n = Int(s) {
        lv = min(GameLevels.count - 1, max(0, n))
    }
    app.requestFocusFromShortcut(levelIndex: lv, minutes: Double(m))
}

@MainActor
private func continueUserActivityForFocus(_ activity: NSUserActivity, app: AppData) {
    guard activity.activityType == AppURLScheme.userActivityType,
          let info = activity.userInfo
    else { return }
    let m = (info["minutes"] as? NSNumber)?.intValue
        ?? (info["m"] as? NSNumber)?.intValue
    let lv = (info["level"] as? NSNumber)?.intValue
    let mClamped = min(90, max(2, m ?? 25))
    let lClamped = min(GameLevels.count - 1, max(0, lv ?? 0))
    app.requestFocusFromShortcut(levelIndex: lClamped, minutes: Double(mClamped))
}

#Preview {
    ContentView()
}
