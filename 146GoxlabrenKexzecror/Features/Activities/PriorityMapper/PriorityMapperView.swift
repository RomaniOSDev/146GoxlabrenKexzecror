//
//  PriorityMapperView.swift
//  146GoxlabrenKexzecror
//

import SwiftUI

struct PriorityMapperView: View {
    @EnvironmentObject private var app: AppData
    @StateObject private var viewModel = PriorityMapperViewModel()
    @Environment(\.dismiss) private var dismiss

    let levelIndex: Int
    @State private var resultOpen = false
    @State private var milestoneBanner = false
    @State private var recordedStars = 0
    @State private var recordedDetail = ""

    var body: some View {
        ScrollView {
            ZStack(alignment: .top) {
                AppFloatingOrbs()
                VStack(alignment: .leading, spacing: 16) {
                    let counts = (0..<4).map { q in
                        viewModel.tasks.filter { $0.currentQuadrant == q }.count
                    }
                    HStack(alignment: .top, spacing: 10) {
                        AppGradientIconBubble(
                            systemName: "square.grid.2x2.fill",
                            size: 24,
                            bubbleSize: 52,
                            strong: false
                        )
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Map")
                                .font(.headline)
                            Text("Match the hidden mix.")
                                .font(.caption2)
                                .foregroundColor(AppColor.textSecondary)
                        }
                    }
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Quadrant")
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(AppColor.textPrimary)
                        PriorityQuadrantChartView(counts: counts)
                            .frame(height: 120)
                    }
                    .padding(10)
                    .appCardChrome(cornerRadius: 16, style: .showcase)

                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 6) {
                            Image(systemName: "hand.tap.fill")
                            Text("Tap to advance each task · find the mix.")
                        }
                        .font(.caption.weight(.medium))
                        .foregroundColor(AppColor.textSecondary)
                        ForEach(viewModel.tasks) { t in
                            VStack(alignment: .leading, spacing: 6) {
                                HStack(alignment: .top) {
                                    Text(t.label)
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundColor(AppColor.textPrimary)
                                        .lineLimit(2)
                                        .minimumScaleFactor(0.7)
                                    Spacer()
                                    Text(quadrantTitle(t.currentQuadrant))
                                        .font(.caption2.weight(.semibold))
                                        .padding(.vertical, 4)
                                        .padding(.horizontal, 8)
                                        .background(
                                            Capsule().fill(AppColor.primary.opacity(0.25))
                                        )
                                        .foregroundColor(AppColor.textPrimary)
                                }
                                Button {
                                    Haptics.lightImpact()
                                    viewModel.cycleQuadrant(for: t.id)
                                } label: {
                                    Text("Cycle quadrant")
                                        .font(.caption)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.7)
                                }
                                .buttonStyle(PlainToggleActionStyle())
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(10)
                            .appCardChrome(cornerRadius: 10, style: .compact)
                        }
                    }

                    Button {
                        Haptics.lightImpact()
                        let before = app.totalStars
                        viewModel.complete()
                        app.recordSession(
                            activity: .priority,
                            level: levelIndex,
                            stars: viewModel.stars,
                            detail: viewModel.resultDetail
                        )
                        let after = app.totalStars
                        milestoneBanner = after > 0 && after / 5 > before / 5
                        recordedStars = viewModel.stars
                        recordedDetail = viewModel.resultDetail
                        resultOpen = true
                    } label: {
                        Text("Lock map and score")
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
                title: "Priority map",
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
        .navigationTitle("Priority Mapper")
    }

    private func quadrantTitle(_ q: Int) -> String {
        switch q {
        case 0: return "Urgent, important"
        case 1: return "Planned, important"
        case 2: return "Urgent, light"
        default: return "Trim or hold"
        }
    }
}

private struct PlainToggleActionStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(AppColor.accent)
            .padding(.vertical, 4)
    }
}
