//
//  OnboardingView.swift
//  146GoxlabrenKexzecror
//  Onboarding matches app chrome: orbs, gradient symbol bubbles, showcase cards.
//

import SwiftUI

/// Shared model for onboarding slides (must be file-scoped for child views).
private struct OnboardingSlide {
    let title: String
    let message: String
    let heroSystemImage: String
    let secondarySymbols: [String]
}

struct OnboardingView: View {
    @EnvironmentObject private var app: AppData
    @State private var page: Int = 0

    private static let slides: [OnboardingSlide] = [
        OnboardingSlide(
            title: "Clarity → momentum",
            message: "Intent first. Then the block.",
            heroSystemImage: "scope",
            secondarySymbols: ["sun.max.fill", "arrow.up.right", "flame.fill"]
        ),
        OnboardingSlide(
            title: "Shape the line",
            message: "Map time. Tweak. Repeat.",
            heroSystemImage: "clock.arrow.circlepath",
            secondarySymbols: ["calendar", "slider.horizontal.3", "arrow.triangle.2.circlepath"]
        ),
        OnboardingSlide(
            title: "Stack small wins",
            message: "Every run is a data point.",
            heroSystemImage: "chart.line.uptrend.xyaxis",
            secondarySymbols: ["star.fill", "checkmark.seal", "target"]
        )
    ]

    var body: some View {
        ZStack {
            AppFloatingOrbs()
            VStack(spacing: 0) {
                brandHeader
                TabView(selection: $page) {
                    ForEach(0..<Self.slides.count, id: \.self) { i in
                        OnboardingPage(
                            pageIndex: i,
                            totalPages: Self.slides.count,
                            slide: Self.slides[i]
                        )
                        .tag(i)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.spring(response: 0.45, dampingFraction: 0.82), value: page)
                .tint(AppColor.primary)

                OnboardingPageIndicator(
                    count: Self.slides.count,
                    current: page
                )
                .padding(.top, 4)
                .padding(.bottom, 12)

                VStack(spacing: 0) {
                    RoundedRectangle(cornerRadius: 0.5, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color.clear, AppColor.textSecondary.opacity(0.35), Color.clear],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(height: 1)
                        .padding(.bottom, 16)

                    Button {
                        if page < Self.slides.count - 1 {
                            Haptics.lightImpact()
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.86)) {
                                page += 1
                            }
                        } else {
                            Haptics.success()
                            completeOnboarding()
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Text(page < Self.slides.count - 1 ? "Continue" : "Get started")
                            Image(systemName: page < Self.slides.count - 1 ? "arrow.right" : "checkmark")
                                .font(.headline.weight(.semibold))
                        }
                        .font(.headline)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .foregroundColor(AppColor.textPrimary)
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: 52)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(AppVisual.primaryButtonFill)
                        )
                        .shadow(
                            color: AppColor.primary.opacity(0.45),
                            radius: 16,
                            y: 5
                        )
                    }
                    .accessibilityIdentifier("onboardingPrimary")
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 8)
            }
        }
        .appScreenBackground()
    }

    private var brandHeader: some View {
        HStack(alignment: .center) {
            HStack(spacing: 12) {
                AppGradientIconBubble(
                    systemName: "waveform.path.ecg",
                    size: 20,
                    bubbleSize: 46,
                    strong: false
                )
                VStack(alignment: .leading, spacing: 2) {
                    Text("Gox flow")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.white, AppColor.primary.opacity(0.9)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    Text("Set up in a minute")
                        .font(.caption2)
                        .foregroundColor(AppColor.textSecondary)
                }
            }
            Spacer(minLength: 12)
            Button {
                completeOnboarding()
            } label: {
                Text("Skip")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(AppColor.textSecondary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.06))
                    )
                    .overlay(
                        Capsule()
                            .stroke(
                                AppVisual.cardBorderGradient(strong: false),
                                lineWidth: 0.9
                            )
                    )
            }
            .accessibilityIdentifier("onboardingSkip")
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 8)
    }

    private func completeOnboarding() {
        withAnimation(.easeInOut(duration: 0.3)) {
            app.hasSeenOnboarding = true
        }
    }
}

// MARK: - Page

private struct OnboardingPage: View {
    let pageIndex: Int
    let totalPages: Int
    let slide: OnboardingSlide

    var body: some View {
        ScrollView {
            ZStack(alignment: .top) {
                // Extra depth in scroll (parent already has orbs; subtle repeat here)
                AppFloatingOrbs(primaryBias: .topTrailing)
                    .opacity(0.85)
                VStack(alignment: .center, spacing: 0) {
                    ZStack {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        AppColor.primary.opacity(0.2),
                                        AppColor.accent.opacity(0.08),
                                        Color.clear
                                    ],
                                    center: .center,
                                    startRadius: 1,
                                    endRadius: 120
                                )
                            )
                            .frame(width: 200, height: 200)
                            .blur(radius: 1)

                        AppGradientIconBubble(
                            systemName: slide.heroSystemImage,
                            size: 58,
                            bubbleSize: 120,
                            strong: true
                        )
                    }
                    .padding(.vertical, 8)

                    HStack(spacing: 10) {
                        ForEach(Array(slide.secondarySymbols.enumerated()), id: \.offset) { _, name in
                            ZStack {
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(
                                        LinearGradient(
                                            colors: [Color.white.opacity(0.08), AppColor.background.opacity(0.5)],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                Image(systemName: name)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [AppColor.accent, AppColor.primary],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            }
                            .frame(width: 40, height: 40)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .stroke(
                                        AppVisual.cardBorderGradient(strong: false),
                                        lineWidth: 0.7
                                    )
                            )
                        }
                    }
                    .padding(.top, 4)
                    .padding(.bottom, 20)

                    VStack(alignment: .leading, spacing: 12) {
                        OnboardingTitleLine(title: slide.title, pageKey: pageIndex)
                        Text("Step \(pageIndex + 1) of \(totalPages)")
                            .font(.caption2.weight(.semibold))
                            .foregroundColor(AppColor.accent)
                            .textCase(.uppercase)
                            .tracking(0.8)
                        Text(slide.message)
                            .font(.subheadline.weight(.medium))
                            .foregroundColor(AppColor.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(20)
                    .appCard(
                        cornerRadius: 20,
                        style: .showcase,
                        padding: 0
                    )
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
        }
    }
}

// MARK: - Titles

private struct OnboardingTitleLine: View {
    var title: String
    var pageKey: Int
    @State private var didAppear = false

    var body: some View {
        Text(title)
            .font(.title2.weight(.bold))
            .lineLimit(3)
            .minimumScaleFactor(0.75)
            .foregroundStyle(
                LinearGradient(
                    colors: [Color.white, AppColor.primary.opacity(0.92), AppColor.accent.opacity(0.75)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .opacity(didAppear ? 1 : 0.2)
            .offset(y: didAppear ? 0 : 4)
            .onAppear {
                withAnimation(.easeOut(duration: 0.4)) { didAppear = true }
            }
            .onChange(of: pageKey) { _, _ in
                didAppear = false
                withAnimation(.easeOut(duration: 0.35)) { didAppear = true }
            }
    }
}

// MARK: - Page control

private struct OnboardingPageIndicator: View {
    var count: Int
    var current: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<count, id: \.self) { i in
                Group {
                    if i == current {
                        Capsule()
                            .fill(AppVisual.primaryButtonFill)
                            .frame(width: 28, height: 8)
                            .shadow(color: AppColor.primary.opacity(0.35), radius: 4, y: 1)
                    } else {
                        Circle()
                            .fill(AppColor.textSecondary.opacity(0.2))
                            .frame(width: 7, height: 7)
                            .overlay(
                                Circle()
                                    .stroke(AppColor.textSecondary.opacity(0.25), lineWidth: 0.5)
                            )
                    }
                }
                .animation(.spring(response: 0.35, dampingFraction: 0.75), value: current)
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 16)
        .background(
            Capsule()
                .fill(Color.white.opacity(0.05))
                .overlay(
                    Capsule()
                        .stroke(
                            AppVisual.cardBorderGradient(strong: false).opacity(0.6),
                            lineWidth: 0.8
                        )
                )
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Page \(current + 1) of \(count)")
    }
}

#Preview {
    OnboardingView()
        .environmentObject(AppData())
}
