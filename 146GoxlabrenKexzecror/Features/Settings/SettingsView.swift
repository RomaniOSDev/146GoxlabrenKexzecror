//
//  SettingsView.swift
//  146GoxlabrenKexzecror
//

import StoreKit
import SwiftUI
import UIKit

struct SettingsView: View {
    @EnvironmentObject private var app: AppData
    @State private var showConfirmReset = false
    @State private var notifStatus: String = "…"
    @State private var notifButtonBusy = false

    var body: some View {
        ZStack {
            AppColor.background
                .ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    ZStack(alignment: .topLeading) {
                        AppFloatingOrbs()
                        HStack(spacing: 14) {
                            AppGradientIconBubble(systemName: "gearshape.2", size: 32, bubbleSize: 70)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Tuning")
                                    .font(.title2.weight(.bold))
                                Text("Your nudges & data")
                                    .font(.caption)
                                    .foregroundColor(AppColor.textSecondary)
                            }
                        }
                    }
                    .padding(.top, 4)
                    .padding(.bottom, 4)

                    AppScreenSectionHeader(
                        systemImage: "bell.badge.fill",
                        title: "Reminders",
                        subtitle: "On this device, when you want."
                    )

                    VStack(alignment: .leading, spacing: 12) {
                        Toggle("Remind to start focus", isOn: $app.remindFocusOn)
                        if app.remindFocusOn {
                            DatePicker(
                                "Time",
                                selection: minuteOfDayBinding($app.focusReminderMinuteOfDay),
                                displayedComponents: .hourAndMinute
                            )
                            .tint(AppColor.primary)
                        }
                    }
                    .appCard(cornerRadius: 18, style: .showcase, padding: 16)

                    VStack(alignment: .leading, spacing: 12) {
                        Toggle("Day review nudge", isOn: $app.dayReviewOn)
                        if app.dayReviewOn {
                            DatePicker(
                                "Time",
                                selection: minuteOfDayBinding($app.dayReviewMinuteOfDay),
                                displayedComponents: .hourAndMinute
                            )
                            .tint(AppColor.primary)
                        }
                    }
                    .appCard(cornerRadius: 18, style: .showcase, padding: 16)

                    HStack(alignment: .top, spacing: 8) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Notifications")
                                .font(.subheadline.weight(.semibold))
                                .foregroundColor(AppColor.textPrimary)
                            Text(notifStatus)
                                .font(.caption)
                                .foregroundColor(AppColor.textSecondary)
                        }
                        Spacer()
                        Button {
                            notifButtonBusy = true
                            Task {
                                let ok = await LocalNotificationService.requestPermissionIfNeeded()
                                notifStatus = ok ? "Allowed" : "Not allowed — enable in iOS Settings"
                                LocalNotificationService.reschedule(using: app)
                                notifButtonBusy = false
                            }
                        } label: {
                            Text(notifButtonBusy ? "…" : "Request")
                                .font(.subheadline.weight(.semibold))
                                .lineLimit(1)
                                .minimumScaleFactor(0.6)
                        }
                        .buttonStyle(.bordered)
                    }
                    .appCard(cornerRadius: 16, style: .hero, padding: 16)
                    .onAppear {
                        LocalNotificationService.refreshStatusText { notifStatus = $0 }
                    }

                    AppScreenSectionHeader(
                        systemImage: "target",
                        title: "Default tag",
                        subtitle: "New sessions log to…"
                    )

                    VStack(alignment: .leading, spacing: 12) {
                        Picker("Focus for sessions", selection: $app.defaultLogFocus) {
                            ForEach(FocusArea.allCases) { a in
                                Text(a.title)
                                    .tag(a)
                            }
                        }
                    }
                    .appCard(cornerRadius: 16, style: .standard, padding: 16)

                    AppScreenSectionHeader(
                        systemImage: "heart.text.square.fill",
                        title: "About"
                    )

                    VStack(alignment: .leading, spacing: 0) {
                        settingsLinkRow(
                            "Rate us",
                            systemImage: "star.fill",
                            action: rateApp
                        )
                        linkDivider
                        settingsLinkRow(
                            "Privacy",
                            systemImage: "hand.raised.fill",
                            action: { AppExternalURL.privacyPolicy.openInBrowser() }
                        )
                        linkDivider
                        settingsLinkRow(
                            "Terms",
                            systemImage: "doc.text.fill",
                            action: { AppExternalURL.termsOfUse.openInBrowser() }
                        )
                    }
                    .appCard(cornerRadius: 16, style: .showcase, padding: 0)

                    AppScreenSectionHeader(
                        systemImage: "chart.pie.fill",
                        title: "By the numbers"
                    )

                    VStack(alignment: .leading, spacing: 12) {
                        statRow("★ Stars", value: "\(app.totalStars)")
                        statRow("Tasks", value: "\(app.tasksCompleted)")
                        statRow("Streak", value: "\(app.streakLength) d")
                        statRow("Score", value: String(format: "%.0f/100", min(100, app.progressScore)))
                    }
                    .appCard(cornerRadius: 18, style: .showcase, padding: 16)

                    if app.history.isEmpty {
                        HStack(spacing: 6) {
                            Image(systemName: "sparkle")
                            Text("Play to unlock more insight.")
                        }
                        .font(.caption.weight(.medium))
                        .foregroundColor(AppColor.textSecondary)
                    }

                    Button {
                        showConfirmReset = true
                    } label: {
                        Text("Reset All Progress")
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                            .foregroundColor(AppColor.textPrimary)
                            .frame(maxWidth: .infinity)
                            .frame(minHeight: 44)
                            .background(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(
                                        LinearGradient(
                                            colors: [Color.white.opacity(0.08), AppColor.background.opacity(0.4)],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                            )
                            .shadow(color: Color.black.opacity(0.35), radius: 8, y: 4)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .stroke(
                                        AppVisual.cardBorderGradient(strong: true),
                                        lineWidth: 1.5
                                    )
                            )
                    }
                    .padding(.top, 8)
                }
                .padding(16)
            }
            .appScreenBackground()
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog(
            "This clears sessions, history, and saved tasks.",
            isPresented: $showConfirmReset,
            titleVisibility: .visible
        ) {
            Button("Reset Everything", role: .destructive) {
                app.resetAllProgress()
            }
        }
        .tint(AppColor.primary)
    }

    private func statRow(_ title: String, value: String) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .foregroundColor(AppColor.textSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Spacer(minLength: 8)
            Text(value)
                .foregroundColor(AppColor.textPrimary)
                .fontWeight(.semibold)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
    }

    @ViewBuilder
    private var linkDivider: some View {
        Rectangle()
            .fill(AppColor.textSecondary.opacity(0.18))
            .frame(height: 1)
            .padding(.leading, 16)
    }

    private func settingsLinkRow(
        _ title: String,
        systemImage: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: {
            Haptics.lightImpact()
            action()
        }) {
            HStack(spacing: 12) {
                Image(systemName: systemImage)
                    .font(.body)
                    .foregroundColor(AppColor.accent)
                    .frame(width: 24, alignment: .center)
                Text(title)
                    .font(.body.weight(.semibold))
                    .foregroundColor(AppColor.textPrimary)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(AppColor.textSecondary)
            }
            .padding(16)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func rateApp() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }
}

private func minuteOfDayBinding(
    _ binding: Binding<Int>
) -> Binding<Date> {
    let cal = Calendar.current
    return Binding(
        get: {
            let m = max(0, min(24 * 60 - 1, binding.wrappedValue))
            return cal.date(
                bySettingHour: m / 60,
                minute: m % 60,
                second: 0,
                of: cal.startOfDay(for: Date())
            ) ?? Date()
        },
        set: { d in
            let c = cal.dateComponents([.hour, .minute], from: d)
            let m = (c.hour ?? 0) * 60 + (c.minute ?? 0)
            binding.wrappedValue = max(0, min(24 * 60 - 1, m))
        }
    )
}

#Preview {
    AppNavigationRoot {
        SettingsView()
    }
    .environmentObject(AppData())
}
