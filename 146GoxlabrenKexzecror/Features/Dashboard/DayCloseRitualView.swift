//
//  DayCloseRitualView.swift
//  146GoxlabrenKexzecror
//  ~30s offline close-the-day ritual; stored locally in AppData.
//

import SwiftUI

struct DayCloseRitualView: View {
    @EnvironmentObject private var app: AppData
    @Environment(\.dismiss) private var dismiss
    @State private var didMain = false
    @State private var deferred = ""
    @State private var secondsLeft = 30
    @State private var timer: Timer?

    var body: some View {
        NavigationStack {
            ZStack {
                AppColor.background
                    .ignoresSafeArea()
                AppFloatingOrbs()
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack(spacing: 12) {
                            AppGradientIconBubble(systemName: "moon.haze.fill", size: 28, bubbleSize: 64, strong: false)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Evening")
                                    .font(.title2.weight(.bold))
                                Text("~30s · quiet close")
                                    .font(.caption)
                                    .foregroundColor(AppColor.textSecondary)
                            }
                        }
                        .padding(.bottom, 4)

                        ZStack {
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(AppVisual.cardBodyGradient(for: .showcase))
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(AppVisual.cardBorderGradient(strong: false), lineWidth: 1)
                            Group {
                                if secondsLeft == 0 {
                                    Text("\(secondsLeft)s")
                                        .font(.system(size: 36, weight: .semibold, design: .monospaced))
                                        .foregroundStyle(AppVisual.primaryButtonFill)
                                } else {
                                    Text("\(secondsLeft)s")
                                        .font(.system(size: 36, weight: .semibold, design: .monospaced))
                                        .foregroundColor(AppColor.textPrimary)
                                }
                            }
                            .padding(.vertical, 16)
                        }
                        .frame(maxWidth: .infinity)
                        .shadow(color: Color.black.opacity(0.35), radius: 14, y: 5)
                        .onAppear { startTimer() }
                        .onDisappear { stopTimer() }

                        Toggle("I moved my main thing forward", isOn: $didMain)
                            .tint(AppColor.primary)
                            .foregroundColor(AppColor.textPrimary)

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Carry to next (optional)")
                                .font(.caption.weight(.semibold))
                                .foregroundColor(AppColor.textPrimary)
                            TextField("One line", text: $deferred, axis: .vertical)
                                .lineLimit(1...3)
                                .textFieldStyle(.plain)
                                .padding(10)
                                .appCardChrome(cornerRadius: 12, style: .standard)
                                .foregroundColor(AppColor.textPrimary)
                        }

                        Button {
                            Haptics.success()
                            app.appendDayClose(didMain: didMain, deferred: deferred)
                            dismiss()
                        } label: {
                            Text("Save to journal & done")
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                                .foregroundColor(AppColor.background)
                                .frame(maxWidth: .infinity)
                                .frame(minHeight: 48)
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
                    .padding(20)
                }
                .appScreenBackground()
            }
            .navigationTitle("Evening check-in")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Skip") { dismiss() }
                }
            }
        }
    }

    private func startTimer() {
        stopTimer()
        secondsLeft = 30
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if secondsLeft > 0 {
                secondsLeft -= 1
            } else {
                stopTimer()
            }
        }
        if let t = timer {
            RunLoop.main.add(t, forMode: .common)
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

#Preview {
    DayCloseRitualView()
        .environmentObject(AppData())
}
