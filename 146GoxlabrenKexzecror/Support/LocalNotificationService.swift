//
//  LocalNotificationService.swift
//  146GoxlabrenKexzecror
//

import Foundation
import UserNotifications

@MainActor
enum LocalNotificationService {
    private static let focusId = "flow.remind.focus"
    private static let reviewId = "flow.review.daily"

    private static var center: UNUserNotificationCenter { .current() }

    /// Fetches authorization status and passes a one-line string for the UI.
    static func refreshStatusText(_ onUpdate: @escaping (String) -> Void) {
        center.getNotificationSettings { s in
            let line: String
            switch s.authorizationStatus {
            case .notDetermined: line = "Not set yet — you can allow alerts here."
            case .denied: line = "Denied in Settings — open Settings ▸ Notifications to enable."
            case .authorized, .provisional, .ephemeral: line = "Enabled — we can show reminders on schedule."
            @unknown default: line = "Status unknown"
            }
            DispatchQueue.main.async {
                onUpdate(line)
            }
        }
    }

    static func requestPermissionIfNeeded() async -> Bool {
        do {
            return try await center.requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }

    static func reschedule(using data: AppData) {
        center.removePendingNotificationRequests(withIdentifiers: [focusId, reviewId])
        if data.remindFocusOn {
            schedule(
                id: focusId,
                title: "Focus block",
                body: data.focusReminderBody(),
                minuteOfDay: data.focusReminderMinuteOfDay
            )
        }
        if data.dayReviewOn {
            schedule(
                id: reviewId,
                title: "Day review",
                body: "Review what you completed and set priorities for what’s next.",
                minuteOfDay: data.dayReviewMinuteOfDay
            )
        }
    }

    private static func schedule(id: String, title: String, body: String, minuteOfDay: Int) {
        let m = min(23 * 60 + 59, max(0, minuteOfDay))
        let h = m / 60
        let minC = m % 60
        var dc = DateComponents()
        dc.hour = h
        dc.minute = minC
        let trigger = UNCalendarNotificationTrigger(dateMatching: dc, repeats: true)
        let c = UNMutableNotificationContent()
        c.title = title
        c.body = body
        c.sound = .default
        let req = UNNotificationRequest(
            identifier: id,
            content: c,
            trigger: trigger
        )
        center.add(req) { _ in
        }
    }
}

@MainActor
final class AppNotificationCenterDelegate: NSObject, UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .sound, .list]
    }
}
