//
//  FocusPulseView.swift
//  146GoxlabrenKexzecror
//

import SwiftUI

struct FocusPulseView: View {
    @EnvironmentObject private var app: AppData
    @StateObject private var viewModel = FocusPulseViewModel()
    @Environment(\.dismiss) private var dismiss

    let levelIndex: Int
    var initialMinutes: Double?

    @State private var resultOpen = false
    @State private var milestoneBanner = false
    @State private var hasRecorded = false
    @State private var lengthMinutes: Double = 6
    @State private var focusIntention: String = ""

    private let templateStops: [Int] = [25, 50, 90]

    private var screenBackground: some View {
        ZStack(alignment: .top) {
            AppColor.background.ignoresSafeArea()
            AppFloatingOrbs()
            LinearGradient(
                colors: [AppColor.primary.opacity(0.16), Color.clear],
                startPoint: .topLeading,
                endPoint: .center
            )
            .ignoresSafeArea()
            .allowsHitTesting(false)
        }
    }

    var body: some View {
        ScrollView {
                VStack(alignment: .center, spacing: 16) {
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "target")
                            .font(.title2)
                            .foregroundStyle(AppVisual.primaryButtonFill)
                        Text("Full run = best stars. Set length, then go.")
                            .font(.caption.weight(.medium))
                            .foregroundColor(AppColor.textSecondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    HStack(spacing: 8) {
                        ForEach(templateStops, id: \.self) { m in
                            let isSelected = Int(lengthMinutes.rounded()) == m
                            Button {
                                Haptics.lightImpact()
                                lengthMinutes = Double(m)
                                viewModel.setLength(minutes: lengthMinutes)
                                app.recordRecentFocusChoice(minutes: m)
                            } label: {
                                Text("\(m) min")
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.7)
                                    .font(.caption.weight(.semibold))
                                    .foregroundColor(isSelected ? AppColor.background : AppColor.textPrimary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(templateChipBackground(isSelected: isSelected))
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Intention")
                            .font(.caption.weight(.semibold))
                            .foregroundColor(AppColor.textPrimary)
                        Text("One line. Optional but grounding.")
                            .font(.caption2)
                            .foregroundColor(AppColor.textSecondary)
                        TextField("e.g. ship the first draft, reply to the client", text: $focusIntention, axis: .vertical)
                            .lineLimit(1...2)
                            .textFieldStyle(.plain)
                            .padding(10)
                            .background(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(AppColor.surface)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                                            .stroke(AppColor.textSecondary.opacity(0.2), lineWidth: 1)
                                    )
                                    .shadow(color: Color.black.opacity(0.2), radius: 6, y: 2)
                            )
                            .foregroundColor(AppColor.textPrimary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    if !Set(templateStops).isSuperset(of: app.recentFocusDurations) {
                        HStack(spacing: 6) {
                            ForEach(
                                app.recentFocusDurations.filter { !templateStops.contains($0) }
                                    .prefix(5), id: \.self
                            ) { m in
                                Button {
                                    Haptics.lightImpact()
                                    lengthMinutes = Double(m)
                                    viewModel.setLength(minutes: lengthMinutes)
                                    app.recordRecentFocusChoice(minutes: m)
                                } label: {
                                    Text("Last \(m)m")
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.7)
                                        .font(.caption2.weight(.medium))
                                        .foregroundColor(AppColor.accent)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 6)
                                        .background(
                                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                                .stroke(AppColor.textSecondary.opacity(0.4), lineWidth: 1)
                                        )
                                }
                            }
                        }
                    }

                    ZStack {
                        FocusRingChartView(
                            progress: viewModel.totalSeconds == 0
                            ? 0
                            : 1.0 - (Double(viewModel.remaining) / Double(max(viewModel.totalSeconds, 1)))
                        )
                        .frame(width: 180, height: 180)
                        VStack(spacing: 4) {
                            Text(
                                timeString(viewModel.remaining)
                            )
                            .font(.title2.monospacedDigit().weight(.semibold))
                            .foregroundColor(AppColor.textPrimary)
                            if viewModel.isRunning {
                                Text("Running")
                                    .font(.caption)
                                    .foregroundColor(AppColor.accent)
                            } else {
                                Text(viewModel.isFinished ? "Session ended" : "Ready")
                                    .font(.caption)
                                    .foregroundColor(AppColor.textSecondary)
                            }
                        }
                    }
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Session length: \(String(format: "%.0f", lengthMinutes)) min")
                            .font(.subheadline)
                            .foregroundColor(AppColor.textPrimary)
                        Slider(
                            value: $lengthMinutes,
                            in: 2...90,
                            step: 1
                        )
                        .tint(AppColor.primary)
                    }

                    HStack(spacing: 8) {
                        if viewModel.isRunning {
                            Button {
                                Haptics.lightImpact()
                                viewModel.pause()
                            } label: {
                                label("Pause")
                            }
                        } else {
                            if !viewModel.isFinished {
                                Button {
                                    Haptics.lightImpact()
                                    app.recordRecentFocusChoice(
                                        minutes: min(90, max(2, Int(lengthMinutes.rounded())))
                                    )
                                    viewModel.play()
                                } label: {
                                    label("Start")
                                }
                            }
                        }
                        if !viewModel.isFinished {
                            Button {
                                Haptics.lightImpact()
                                let early = viewModel.remaining > 0
                                viewModel.finishSession(early: early)
                            } label: {
                                label(viewModel.isRunning && viewModel.remaining > 0 ? "End now" : "End session")
                            }
                        }
                    }
                }
                .padding(16)
        }
        .background(screenBackground)
        .onChange(of: lengthMinutes) { _, newV in
            if !viewModel.isRunning, !viewModel.isFinished {
                viewModel.setLength(minutes: newV)
            }
        }
        .onAppear {
            resultOpen = false
            milestoneBanner = false
            hasRecorded = false
            focusIntention = ""
            viewModel.start(level: levelIndex, difficulty: app.selectedDifficulty)
            if let im = initialMinutes, im >= 2, im <= 90 {
                lengthMinutes = im
                viewModel.setLength(minutes: im)
            } else {
                lengthMinutes = max(2, Double(viewModel.totalSeconds) / 60.0)
            }
        }
        .onChange(of: viewModel.isFinished) { done in
            if done, !hasRecorded {
                hasRecorded = true
                Haptics.success()
                let before = app.totalStars
                app.recordRecentFocusChoice(
                    minutes: min(90, max(2, Int(lengthMinutes.rounded())))
                )
                app.recordSession(
                    activity: .focus,
                    level: levelIndex,
                    stars: viewModel.stars,
                    detail: viewModel.resultDetail,
                    focusIntention: focusIntention.isEmpty
                        ? nil
                        : focusIntention
                )
                let after = app.totalStars
                milestoneBanner = after > 0 && after / 5 > before / 5
                resultOpen = true
            }
        }
        .userActivity(
            AppURLScheme.userActivityType,
            isActive: !viewModel.isFinished
        ) { a in
            a.title = "Start focus"
            a.isEligibleForSearch = true
            a.isEligibleForPrediction = true
            a.persistentIdentifier = "goxlaflow.focus.shortcut"
            a.addUserInfoEntries(from: [
                "minutes": NSNumber(value: min(90, max(2, Int(lengthMinutes)))),
                "level": NSNumber(value: levelIndex)
            ] as [AnyHashable: Any])
        }
        .sheet(isPresented: $resultOpen) {
            ActivityResultView(
                title: "Focus session",
                detail: viewModel.resultDetail,
                stars: viewModel.stars,
                showMilestoneBanner: $milestoneBanner,
                onNext: { resultOpen = false; dismiss() },
                onViewProgress: { resultOpen = false; dismiss() }
            )
            .environmentObject(app)
            .presentationBackground(AppColor.background)
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Focus Pulse")
    }

    private func timeString(_ sec: Int) -> String {
        let m = sec / 60
        let s = sec % 60
        return String(format: "%02d:%02d", m, s)
    }

    private func label(_ text: String) -> some View {
        Text(text)
            .lineLimit(1)
            .minimumScaleFactor(0.7)
            .frame(maxWidth: .infinity, minHeight: 44)
            .foregroundColor(AppColor.textPrimary)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(AppColor.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(AppColor.textSecondary.opacity(0.2), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.2), radius: 4, y: 2)
            )
    }

    private func templateChipBackground(isSelected: Bool) -> some View {
        RoundedRectangle(cornerRadius: 10, style: .continuous)
            .fill(
                isSelected
                ? LinearGradient(
                    colors: [AppColor.primary, AppColor.primary.opacity(0.72)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                : LinearGradient(
                    colors: [Color.white.opacity(0.06), AppColor.surface],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(isSelected ? Color.clear : AppColor.textSecondary.opacity(0.25), lineWidth: 1)
            )
            .shadow(
                color: isSelected ? AppColor.primary.opacity(0.45) : Color.black.opacity(0.25),
                radius: isSelected ? 10 : 4,
                y: isSelected ? 4 : 2
            )
    }
}

#Preview {
    NavigationStack {
        FocusPulseView(levelIndex: 0, initialMinutes: nil)
    }
    .environmentObject(AppData())
}
