//
//  AppColorExtension.swift
//  146GoxlabrenKexzecror
//  Use AppColor — not Color.app* — to avoid clashing with asset-catalog / generated Color symbols.
//

import SwiftUI

enum AppColor {
    static var background: Color { Color("AppBackground") }
    static var surface: Color { Color("AppSurface") }
    static var primary: Color { Color("AppPrimary") }
    static var accent: Color { Color("AppAccent") }
    static var textPrimary: Color { Color("AppTextPrimary") }
    static var textSecondary: Color { Color("AppTextSecondary") }
}
