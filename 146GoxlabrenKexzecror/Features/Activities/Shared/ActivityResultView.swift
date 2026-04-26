//
//  ActivityResultView.swift
//  146GoxlabrenKexzecror
//

import SwiftUI

struct ActivityResultView: View {
    let title: String
    let detail: String
    let stars: Int
    @Binding var showMilestoneBanner: Bool
    @EnvironmentObject private var app: AppData
    var onNext: () -> Void
    var onViewProgress: () -> Void
    @State private var appearScale: CGFloat = 0.1
    @State private var glow: CGFloat = 0

    var body: some View {
        ZStack(alignment: .top) {
            if showMilestoneBanner {
                MilestoneBanner()
                    .transition(
                        .move(edge: .top)
                            .combined(with: .opacity)
                    )
                    .padding(.top, 4)
            }
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Session result")
                        .font(.headline)
                        .foregroundColor(AppColor.textPrimary)

                    HStack(alignment: .top, spacing: 12) {
                        StarRatingCanvas(starCount: stars, scale: appearScale, glow: glow)
                            .frame(width: 150, height: 46)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(title)
                                .font(.subheadline.weight(.semibold))
                                .foregroundColor(AppColor.textPrimary)
                            Text(detail)
                                .font(.footnote)
                                .foregroundColor(AppColor.textSecondary)
                        }
                    }

                    StreakView(streak: app.currentStreak)
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .appCardChrome(cornerRadius: 16, style: .standard)

                    VStack(alignment: .leading, spacing: 10) {
                        let completed = min(app.tasksCompleted, 999_999)
                        let score = min(100, app.progressScore)
                        Text("Cumulative: \(completed) successful sessions, score at \(String(format: "%.0f", score))%")
                            .font(.footnote)
                            .foregroundColor(AppColor.textSecondary)
                    }
                    HStack(spacing: 8) {
                        Button {
                            onViewProgress()
                        } label: {
                            Text("View Progress")
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                        }
                        .buttonStyle(SecondaryPillButtonStyle())
                        Button {
                            onNext()
                        } label: {
                            Text("Next Session")
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                        }
                        .buttonStyle(PrimaryPillButtonStyle())
                    }
                }
                .padding(16)
            }
        }
        .appScreenBackground()
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.65, blendDuration: 0.2)) {
                appearScale = 1.0
            }
            withAnimation(
                .easeInOut(duration: 0.35)
                    .repeatForever(autoreverses: true)
            ) {
                glow = 1.0
            }
            if showMilestoneBanner {
                Haptics.milestone()
            }
        }
    }
}

private struct MilestoneBanner: View {
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            RoundedRectangle(cornerRadius: 2, style: .continuous)
                .fill(AppColor.primary)
                .frame(width: 3, height: 28)
            VStack(alignment: .leading, spacing: 2) {
                Text("Milestone")
                    .font(.caption2.weight(.semibold))
                    .foregroundColor(AppColor.textPrimary)
                Text("You hit a new rhythm target—keep the cadence going.")
                    .font(.subheadline)
                    .foregroundColor(AppColor.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .appCardChrome(cornerRadius: 14, style: .standard)
        .padding(.horizontal, 12)
    }
}

private struct StarRatingCanvas: View {
    var starCount: Int
    var scale: CGFloat
    var glow: CGFloat

    var body: some View {
        HStack(spacing: 4) {
                ForEach(0..<3, id: \.self) { i in
                Canvas { c, s in
                    let center = CGPoint(x: s.width / 2, y: s.height / 2)
                    if i < starCount {
                        let path = starPath(
                            center: center,
                            outer: s.width * 0.4,
                            inner: s.width * 0.18
                        )
                        let on = AppColor.primary.opacity(0.45 + 0.45 * glow)
                        c.fill(
                            path,
                            with: .color(on)
                        )
                    } else {
                        let path = starPath(
                            center: center,
                            outer: s.width * 0.4,
                            inner: s.width * 0.18
                        )
                        let off = AppColor.textSecondary.opacity(0.2)
                        c.fill(
                            path,
                            with: .color(off)
                        )
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .scaleEffect(y: scale, anchor: .center)
    }

    private func starPath(center: CGPoint, outer: CGFloat, inner: CGFloat) -> Path {
        var p = Path()
        let n = 5
        for i in 0..<(n * 2) {
            let r: CGFloat
            if i % 2 == 0 { r = outer } else { r = inner }
            let t = -CGFloat.pi / 2 + (CGFloat(i) * CGFloat.pi) / CGFloat(n)
            let x = center.x + CGFloat(Foundation.cos(Double(t))) * r
            let y = center.y + CGFloat(Foundation.sin(Double(t))) * r
            if i == 0 { p.move(to: CGPoint(x: x, y: y)) } else { p.addLine(to: CGPoint(x: x, y: y)) }
        }
        p.closeSubpath()
        return p
    }
}

private struct PrimaryPillButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(AppColor.textPrimary)
            .frame(maxWidth: .infinity, minHeight: 44)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(AppVisual.primaryButtonFill)
                    .opacity(configuration.isPressed ? 0.86 : 1)
            )
            .shadow(
                color: AppColor.primary.opacity(0.4 * (configuration.isPressed ? 0.5 : 1)),
                radius: 10,
                y: 3
            )
    }
}

private struct SecondaryPillButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(AppColor.textPrimary)
            .frame(maxWidth: .infinity, minHeight: 44)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color.white.opacity(0.06), AppColor.background.opacity(0.4)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            )
            .shadow(color: Color.black.opacity(0.25), radius: 4, y: 2)
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(
                        AppVisual.cardBorderGradient(strong: false),
                        lineWidth: 1.5
                    )
            )
    }
}
