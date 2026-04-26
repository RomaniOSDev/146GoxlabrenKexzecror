//
//  StreakView.swift
//  146GoxlabrenKexzecror
//

import SwiftUI

struct StreakView: View {
    var streak: Int

    var body: some View {
        HStack(spacing: 10) {
            RoundedRectangle(cornerRadius: 4, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [AppColor.accent, AppColor.primary],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 8, height: 28)
            VStack(alignment: .leading, spacing: 2) {
                Text("Current streak")
                    .font(.caption)
                    .foregroundColor(AppColor.textSecondary)
                Text("\(streak) days in a row")
                    .font(.headline)
                    .foregroundColor(AppColor.textPrimary)
            }
        }
    }
}
