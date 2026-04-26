//
//  AppVisualStyle.swift
//  146GoxlabrenKexzecror
//  Shared depth: screen gradients, card chrome, tab bar, shadows.
//

import SwiftUI

// MARK: - Card styles

enum AppCardStyle {
    /// Default elevated panels (settings, goals, focus).
    case standard
    /// Slightly larger shadow / radius (home widgets).
    case hero
    /// Flat chips, small controls, list insets.
    case compact
    /// Hero strips, empty states — strongest depth and rim light.
    case showcase
}

// MARK: - AppVisual (gradients + shadows)

enum AppVisual {
    static var screenTopGlow: LinearGradient {
        LinearGradient(
            colors: [
                AppColor.primary.opacity(0.18),
                AppColor.accent.opacity(0.06),
                Color.clear
            ],
            startPoint: .topLeading,
            endPoint: .center
        )
    }

    /// Very light edge darkening only (avoid stacking toward black with UIKit layers).
    static var screenVignette: LinearGradient {
        LinearGradient(
            colors: [
                Color.clear,
                AppColor.background.opacity(0.18)
            ],
            startPoint: .center,
            endPoint: .bottom
        )
    }

    static var screenSideWash: LinearGradient {
        LinearGradient(
            colors: [
                AppColor.accent.opacity(0.04),
                Color.clear,
                AppColor.primary.opacity(0.05)
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    static var primaryButtonFill: LinearGradient {
        LinearGradient(
            colors: [
                AppColor.primary,
                AppColor.primary.opacity(0.72)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static func cardBorderGradient(strong: Bool) -> LinearGradient {
        let a: CGFloat = strong ? 0.5 : 0.28
        return LinearGradient(
            colors: [
                AppColor.primary.opacity(a),
                AppColor.accent.opacity(strong ? 0.3 : 0.18),
                AppColor.textSecondary.opacity(0.12)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static func cardBodyGradient(for style: AppCardStyle) -> LinearGradient {
        switch style {
        case .standard, .hero:
            return LinearGradient(
                colors: [
                    Color.white.opacity(0.1),
                    AppColor.surface,
                    AppColor.background.opacity(0.55)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .showcase:
            return LinearGradient(
                colors: [
                    Color.white.opacity(0.14),
                    AppColor.primary.opacity(0.06),
                    AppColor.surface,
                    AppColor.background.opacity(0.5)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .compact:
            return LinearGradient(
                colors: [
                    Color.white.opacity(0.07),
                    AppColor.surface
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }

    static func cardShadows(for style: AppCardStyle) -> (color: Color, r: CGFloat, y: CGFloat, x: CGFloat) {
        switch style {
        case .standard:
            return (Color.black.opacity(0.38), 16, 8, 0)
        case .hero:
            return (Color.black.opacity(0.45), 22, 10, 0)
        case .showcase:
            return (Color.black.opacity(0.55), 28, 12, 0)
        case .compact:
            return (Color.black.opacity(0.28), 6, 3, 0)
        }
    }

}

// MARK: - Card background (reusable)

struct AppCardBackground: View {
    var cornerRadius: CGFloat
    var style: AppCardStyle

    var body: some View {
        let s = AppVisual.cardShadows(for: style)
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(AppVisual.cardBodyGradient(for: style))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(
                        AppVisual.cardBorderGradient(strong: style == .hero || style == .showcase),
                        lineWidth: style == .compact ? 0.75 : 1.15
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color.white.opacity(0.04), lineWidth: 0.5)
                    .padding(0.5)
            )
            .shadow(color: s.color, radius: s.r, x: s.x, y: s.y)
            .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 1)
    }
}

// MARK: - View extensions

struct AppScreenBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        ZStack(alignment: .top) {
            AppColor.background.ignoresSafeArea()
            AppVisual.screenTopGlow
                .ignoresSafeArea()
                .allowsHitTesting(false)
            AppVisual.screenVignette
                .ignoresSafeArea()
                .allowsHitTesting(false)
            AppVisual.screenSideWash
                .ignoresSafeArea()
                .allowsHitTesting(false)
            content
        }
    }
}

struct AppCardChromeModifier: ViewModifier {
    var cornerRadius: CGFloat
    var style: AppCardStyle

    func body(content: Content) -> some View {
        content
            .background(
                AppCardBackground(cornerRadius: cornerRadius, style: style)
            )
    }
}

extension View {
    /// Full-screen base: background color + top glow + bottom vignette (content stays in `content` layer; put this *around* the root).
    func appScreenBackground() -> some View {
        modifier(AppScreenBackgroundModifier())
    }

    /// Fills behind the view with a rounded, elevated surface (add your own padding).
    func appCardChrome(
        cornerRadius: CGFloat = 16,
        style: AppCardStyle = .standard
    ) -> some View {
        modifier(AppCardChromeModifier(cornerRadius: cornerRadius, style: style))
    }

    /// Padded block + card chrome in one step.
    func appCard(
        cornerRadius: CGFloat = 16,
        style: AppCardStyle = .standard,
        padding: CGFloat = 16
    ) -> some View {
        self
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .appCardChrome(cornerRadius: cornerRadius, style: style)
    }
}
