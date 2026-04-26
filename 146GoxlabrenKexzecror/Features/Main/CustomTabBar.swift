//
//  CustomTabBar.swift
//  146GoxlabrenKexzecror
//

import SwiftUI

struct CustomTabBar: View {
    @Binding var selection: AppTab

    var body: some View {
        HStack(spacing: 0) {
            ForEach(AppTab.allCases) { tab in
                let isSelected = selection == tab
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        selection = tab
                    }
                } label: {
                    VStack(spacing: 4) {
                        ZStack {
                            if isSelected {
                                Circle()
                                    .fill(
                                        RadialGradient(
                                            colors: [
                                                AppColor.primary.opacity(0.4),
                                                Color.clear
                                            ],
                                            center: .center,
                                            startRadius: 2,
                                            endRadius: 32
                                        )
                                    )
                                    .frame(width: 48, height: 48)
                                    .blur(radius: 2)
                            }
                            Image(systemName: tab.systemImage)
                                .font(.system(size: 20, weight: .semibold))
                        }
                        .frame(height: 28)
                        Text(tab.label)
                            .font(.caption)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                        Group {
                            if isSelected {
                                Capsule()
                                    .fill(
                                        AppVisual.primaryButtonFill
                                    )
                            } else {
                                Capsule()
                                    .fill(Color.clear)
                            }
                        }
                        .frame(width: 36, height: 3)
                    }
                    .frame(maxWidth: .infinity, minHeight: 48)
                    .foregroundColor(isSelected ? AppColor.textPrimary : AppColor.textSecondary)
                }
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
        .background {
            ZStack(alignment: .top) {
                AppColor.background
                Rectangle()
                    .fill(AppColor.textSecondary.opacity(0.18))
                    .frame(height: 1)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .shadow(color: Color.black.opacity(0.18), radius: 12, y: -2)
    }
}
