//
//  RoutineEnhancerView.swift
//  146GoxlabrenKexzecror
//

import SwiftUI

struct RoutineEnhancerView: View {
    @EnvironmentObject private var app: AppData
    @StateObject private var viewModel = RoutineEnhancerViewModel()
    @Environment(\.dismiss) private var dismiss

    let levelIndex: Int
    @State private var resultOpen = false
    @State private var milestoneBanner = false
    @State private var recordedStars = 0
    @State private var recordedTitle = ""
    @State private var recordedDetail = ""

    var body: some View {
        ScrollView {
            ZStack(alignment: .top) {
                AppFloatingOrbs()
                VStack(alignment: .leading, spacing: 16) {
                    HStack(alignment: .top, spacing: 10) {
                        AppGradientIconBubble(
                            systemName: "list.number",
                            size: 24,
                            bubbleSize: 52,
                            strong: false
                        )
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Reorder")
                                .font(.headline)
                            Text("Drag to match the weights.")
                                .font(.caption2)
                                .foregroundColor(AppColor.textSecondary)
                        }
                    }

                    if app.bestStars(activity: .routine, level: levelIndex) > 0 {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Best run template")
                                .font(.caption.weight(.semibold))
                                .foregroundColor(AppColor.accent)
                            ForEach(Array(idealOrderTitles().enumerated()), id: \.offset) { _, line in
                                Text(line)
                                    .font(.caption2)
                                    .foregroundColor(AppColor.textSecondary)
                            }
                        }
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .appCardChrome(cornerRadius: 12, style: .compact)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(
                                    AppVisual.cardBorderGradient(strong: false),
                                    lineWidth: 1
                                )
                        )
                    }

                    RoutineBarChartView(items: viewModel.items)
                        .padding(12)
                        .appCardChrome(cornerRadius: 14, style: .standard)

                    LazyVStack(alignment: .leading, spacing: 10) {
                        ForEach(Array(viewModel.items.enumerated()), id: \.element.id) { index, item in
                            HStack(alignment: .top, spacing: 10) {
                                Text("\(item.minutes)m")
                                    .font(.caption.weight(.semibold))
                                    .foregroundColor(AppColor.accent)
                                    .frame(minWidth: 32, minHeight: 44, alignment: .topLeading)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(item.title)
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundColor(AppColor.textPrimary)
                                        .lineLimit(2)
                                        .minimumScaleFactor(0.7)
                                    Text("Load \(item.weight)")
                                        .font(.caption)
                                        .foregroundColor(AppColor.textSecondary)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(10)
                            .appCardChrome(cornerRadius: 10, style: .compact)
                            .offset(y: viewModel.dragIndex == index ? viewModel.dragTranslation * 0.1 : 0)
                            .gesture(
                                DragGesture(minimumDistance: 4)
                                    .onChanged { g in
                                        viewModel.dragIndex = index
                                        viewModel.dragTranslation = g.translation.height
                                    }
                                    .onEnded { g in
                                        if g.translation.height < -28 {
                                            viewModel.swapWithPrevious(at: index)
                                        } else if g.translation.height > 28 {
                                            viewModel.swapWithNext(at: index)
                                        }
                                        viewModel.dragIndex = nil
                                        viewModel.dragTranslation = 0
                                    }
                            )
                        }
                    }

                    Button {
                        Haptics.lightImpact()
                        let before = app.totalStars
                        viewModel.completeSession()
                        app.recordSession(
                            activity: .routine,
                            level: levelIndex,
                            stars: viewModel.stars,
                            detail: viewModel.resultDetail
                        )
                        let after = app.totalStars
                        milestoneBanner = after > 0 && after / 5 > before / 5
                        recordedStars = viewModel.stars
                        recordedTitle = "Routine session"
                        recordedDetail = viewModel.resultDetail
                        resultOpen = true
                    } label: {
                        Text("Finish and score")
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                            .foregroundColor(AppColor.textPrimary)
                            .frame(maxWidth: .infinity, minHeight: 44)
                            .background(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(AppVisual.primaryButtonFill)
                            )
                            .shadow(
                                color: AppColor.primary.opacity(0.4),
                                radius: 10,
                                y: 3
                            )
                    }
                }
                .padding(16)
            }
        }
        .appScreenBackground()
        .onAppear {
            resultOpen = false
            milestoneBanner = false
            viewModel.start(level: levelIndex, difficulty: app.selectedDifficulty)
        }
        .sheet(isPresented: $resultOpen) {
            ActivityResultView(
                title: recordedTitle,
                detail: recordedDetail,
                stars: recordedStars,
                showMilestoneBanner: $milestoneBanner,
                onNext: { resultOpen = false; dismiss() },
                onViewProgress: { resultOpen = false; dismiss() }
            )
            .environmentObject(app)
            .presentationBackground(AppColor.background)
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Routine Enhancer")
    }

    private func idealOrderTitles() -> [String] {
        let ordered = viewModel.idealOrderIds.compactMap { id in
            viewModel.items.first { $0.id == id }
        }
        return ordered.map { "• \($0.title) — load \($0.weight)" }
    }
}
