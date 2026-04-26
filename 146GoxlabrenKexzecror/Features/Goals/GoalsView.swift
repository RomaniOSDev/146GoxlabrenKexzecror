//
//  GoalsView.swift
//  146GoxlabrenKexzecror
//

import SwiftUI

struct GoalsView: View {
    @EnvironmentObject private var app: AppData
    var onAddTask: () -> Void
    @State private var selected: FocusArea = .deepWork

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                ZStack(alignment: .topLeading) {
                    AppFloatingOrbs(primaryBias: .topTrailing)
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(alignment: .top, spacing: 14) {
                            AppGradientIconBubble(
                                systemName: "map.fill",
                                size: 32,
                                bubbleSize: 72
                            )
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Focus")
                                    .font(.title2.weight(.bold))
                                    .foregroundColor(AppColor.textPrimary)
                                Text("Where the week leans")
                                    .font(.caption)
                                    .foregroundColor(AppColor.textSecondary)
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 4)

                Picker("Area", selection: $selected) {
                    ForEach(FocusArea.allCases) { a in
                        Text(a.title)
                            .tag(a)
                    }
                }
                .pickerStyle(.segmented)

                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 8) {
                        Image(systemName: selected.systemImage)
                            .font(.title3)
                            .foregroundStyle(AppVisual.primaryButtonFill)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("This aim")
                                .font(.caption.weight(.semibold))
                                .foregroundColor(AppColor.textSecondary)
                            Text(selected.title)
                                .font(.subheadline.weight(.semibold))
                                .foregroundColor(AppColor.textPrimary)
                        }
                        Spacer()
                    }
                    CustomTargetProgress(percent: app.achievementPercent(for: selected) / 100.0)
                }
                .appCard(cornerRadius: 18, style: .showcase, padding: 16)

                weeklyFocusCard(selected: selected)

                VStack(alignment: .leading, spacing: 10) {
                    AppScreenSectionHeader(
                        systemImage: "distribute.horizontal",
                        title: "Balance",
                        subtitle: "We normalize to 100%."
                    )
                    ForEach(FocusArea.allCases) { a in
                        HStack(alignment: .center, spacing: 10) {
                            Image(systemName: a.systemImage)
                                .font(.body)
                                .foregroundStyle(
                                    selected == a ? AppColor.primary : AppColor.textSecondary
                                )
                                .frame(width: 22)
                            VStack(alignment: .leading, spacing: 4) {
                                HStack(alignment: .firstTextBaseline) {
                                    Text(a.title)
                                        .font(.subheadline)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.7)
                                        .foregroundColor(AppColor.textPrimary)
                                    Spacer()
                                    Text(percentString(for: a))
                                        .font(.caption)
                                        .foregroundColor(AppColor.textSecondary)
                                }
                                Slider(
                                    value: weightBinding(for: a),
                                    in: 0.05...0.9,
                                    step: 0.01
                                )
                                .tint(AppColor.primary)
                            }
                        }
                    }
                }
                .appCard(cornerRadius: 18, style: .standard, padding: 16)
            }
            .padding(16)
        }
        .navigationTitle("Goals")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    onAddTask()
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 18, weight: .semibold))
                }
            }
        }
    }

    private func percentString(for area: FocusArea) -> String {
        let w = (app.focusTargets[area] ?? 0) * 100
        return String(format: "%.0f%%", w)
    }

    private func weightBinding(for area: FocusArea) -> Binding<Double> {
        Binding(
            get: { app.focusTargets[area] ?? 0.25 },
            set: { v in
                var m = app.focusTargets
                m[area] = v
                app.updateFocusTargets(m)
            }
        )
    }

    @ViewBuilder
    private func weeklyFocusCard(selected: FocusArea) -> some View {
        let s = app.sessionCountsByFocusLogLast7()
        let totalSessions = s.unlabeled + FocusArea.allCases
            .map { s.byArea[$0] ?? 0 }
            .reduce(0, +)
        let count = s.byArea[selected] ?? 0
        let share = totalSessions > 0 ? (Double(count) * 100.0 / Double(totalSessions)) : 0

        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "clock.arrow.circlepath")
                    .font(.title2)
                    .foregroundStyle(AppVisual.primaryButtonFill)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Last 7 days")
                        .font(.headline)
                    Text("Your share of tagged sessions")
                        .font(.caption2)
                        .foregroundColor(AppColor.textSecondary)
                }
            }
            if totalSessions == 0 {
                HStack(spacing: 8) {
                    Image(systemName: "calendar.badge.clock")
                        .font(.title2)
                        .foregroundColor(AppColor.textSecondary)
                    Text("No sessions this week yet.")
                        .font(.subheadline)
                        .foregroundColor(AppColor.textSecondary)
                }
            } else {
                HStack(alignment: .firstTextBaseline) {
                    Text("\(selected.title)")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(AppColor.textPrimary)
                    Spacer()
                    Text(String(format: "%.0f%% of %d", share, totalSessions))
                        .font(.subheadline)
                        .foregroundColor(AppColor.accent)
                }
                ProgressView(
                    value: min(1, max(0, share / 100.0))
                )
                .tint(AppColor.primary)
                if s.unlabeled > 0 {
                    Text("\(s.unlabeled) untagged")
                        .font(.caption2)
                        .foregroundColor(AppColor.textSecondary)
                }
            }
        }
        .appCard(cornerRadius: 18, style: .hero, padding: 16)
    }
}

private struct CustomTargetProgress: View {
    var percent: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ProgressView(value: min(1, max(0, percent)))
                .tint(AppColor.primary)
            Text("\(Int(percent * 100))% toward current aim")
                .font(.caption)
                .foregroundColor(AppColor.textSecondary)
        }
    }
}

#Preview {
    NavigationStack {
        GoalsView(onAddTask: { })
    }
    .environmentObject(AppData())
}
