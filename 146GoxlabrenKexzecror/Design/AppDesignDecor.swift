//
//  AppDesignDecor.swift
//  146GoxlabrenKexzecror
//  Reusable orbs, hero symbols, and compact section headers — more image, less copy.
//

import SwiftUI

// MARK: - Backdrop orbs (behind cards / headers)

struct AppFloatingOrbs: View {
    var primaryBias: UnitPoint = .topLeading

    var body: some View {
        ZStack {
            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [
                            AppColor.primary.opacity(0.32),
                            AppColor.accent.opacity(0.12),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 2,
                        endRadius: 110
                    )
                )
                .frame(width: 220, height: 180)
                .offset(x: primaryBias == .topLeading ? -90 : 90, y: -30)
                .blur(radius: 28)
            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [
                            AppColor.accent.opacity(0.22),
                            AppColor.primary.opacity(0.08),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 2,
                        endRadius: 95
                    )
                )
                .frame(width: 200, height: 160)
                .offset(x: 100, y: 40)
                .blur(radius: 32)
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

// MARK: - Icon in glossy bubble

struct AppGradientIconBubble: View {
    var systemName: String
    var size: CGFloat = 56
    var bubbleSize: CGFloat = 96
    var strong: Bool = true

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            AppColor.primary.opacity(0.55),
                            AppColor.accent.opacity(0.35),
                            AppColor.surface
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: bubbleSize, height: bubbleSize)
                .shadow(color: AppColor.primary.opacity(0.4), radius: 16, y: 6)
                .shadow(color: Color.black.opacity(0.35), radius: 8, y: 4)
                .overlay(
                    Circle()
                        .stroke(AppVisual.cardBorderGradient(strong: strong), lineWidth: 1.25)
                )
            Image(systemName: systemName)
                .font(.system(size: size, weight: .semibold))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.white, AppColor.textPrimary],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
        }
    }
}

// MARK: - Section: icon + two lines max

struct AppScreenSectionHeader: View {
    var systemImage: String
    var title: String
    var subtitle: String?
    var titleStyle: SectionTitleStyle = .section

    enum SectionTitleStyle {
        case largeHero
        case section
    }

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [AppColor.primary.opacity(0.4), AppColor.accent.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 40, height: 40)
                    .shadow(color: AppColor.primary.opacity(0.25), radius: 6, y: 2)
                Image(systemName: systemImage)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(AppColor.textPrimary)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(titleStyle == .largeHero
                          ? .title2.weight(.bold)
                          : .headline.weight(.semibold))
                    .foregroundColor(AppColor.textPrimary)
                if let subtitle, !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(AppColor.textSecondary)
                        .lineLimit(2)
                }
            }
            Spacer(minLength: 0)
        }
    }
}

// MARK: - Empty / CTA art block

struct AppEmptyStatePanel: View {
    var systemName: String
    var line: String

    var body: some View {
        VStack(spacing: 20) {
            AppGradientIconBubble(systemName: systemName, size: 52, bubbleSize: 100)
            Text(line)
                .font(.subheadline.weight(.medium))
                .multilineTextAlignment(.center)
                .foregroundColor(AppColor.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(28)
    }
}
