//
//  HistoryView.swift
//  146GoxlabrenKexzecror
//

import SwiftUI

private enum HistorySessionFilter: String, CaseIterable, Identifiable {
    case all
    case routine
    case focus
    case priority

    var id: String { rawValue }

    var title: String {
        switch self {
        case .all: return "All"
        case .routine: return "Routine"
        case .focus: return "Focus"
        case .priority: return "Priority"
        }
    }

    func matches(_ e: HistoryEntry) -> Bool {
        switch self {
        case .all: return true
        case .routine: return e.activityKind == .routine
        case .focus: return e.activityKind == .focus
        case .priority: return e.activityKind == .priority
        }
    }
}

struct HistoryView: View {
    @EnvironmentObject private var app: AppData
    @State private var filter: HistorySessionFilter = .all
    @State private var shareOpen = false
    @State private var selectedEntry: HistoryEntry?

    private var filtered: [HistoryEntry] {
        app.history.filter { filter.matches($0) }
    }

    private var historyStatsStrip: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [AppColor.primary.opacity(0.35), AppColor.accent.opacity(0.15)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 52, height: 52)
                Image(systemName: "square.stack.3d.up.fill")
                    .font(.title2)
                    .foregroundColor(AppColor.textPrimary)
            }
            .shadow(color: AppColor.primary.opacity(0.25), radius: 8, y: 3)
            VStack(alignment: .leading, spacing: 2) {
                Text("\(app.history.count) sessions")
                    .font(.title2.weight(.bold).monospacedDigit())
                Text("all time in your log")
                    .font(.caption)
                    .foregroundColor(AppColor.textSecondary)
            }
            Spacer(minLength: 0)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .appCardChrome(cornerRadius: 18, style: .showcase)
    }

    var body: some View {
        Group {
            if app.history.isEmpty {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        ZStack(alignment: .top) {
                            AppFloatingOrbs()
                            AppEmptyStatePanel(
                                systemName: "clock.badge.checkmark",
                                line: "Finish a run — your trail starts here."
                            )
                            .appCard(
                                cornerRadius: 20,
                                style: .showcase,
                                padding: 0
                            )
                        }
                    }
                    .padding(16)
                }
            } else {
                VStack(alignment: .leading, spacing: 0) {
                    historyStatsStrip
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                    Picker("Type", selection: $filter) {
                        ForEach(HistorySessionFilter.allCases) { f in
                            Text(f.title)
                                .tag(f)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(12)
                    .appCard(
                        cornerRadius: 16,
                        style: .compact,
                        padding: 0
                    )
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    if filtered.isEmpty {
                        Spacer()
                        HStack(spacing: 10) {
                            Image(systemName: "line.3.horizontal.decrease.circle")
                                .font(.title2)
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [AppColor.accent, AppColor.primary],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                            Text("Nothing in this filter.")
                                .font(.subheadline.weight(.medium))
                                .foregroundColor(AppColor.textSecondary)
                        }
                        .frame(maxWidth: .infinity)
                        Spacer()
                    } else {
                        List {
                            ForEach(filtered) { entry in
                                Button {
                                    Haptics.lightImpact()
                                    selectedEntry = entry
                                } label: {
                                    HistoryItemRowView(entry: entry)
                                }
                                .buttonStyle(HistoryRowButtonStyle())
                                .listRowBackground(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .fill(AppVisual.cardBodyGradient(for: .compact))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                                .stroke(
                                                    AppVisual.cardBorderGradient(strong: false),
                                                    lineWidth: 0.75
                                                )
                                        )
                                        .shadow(color: Color.black.opacity(0.3), radius: 8, y: 3)
                                )
                                .listRowSeparator(.hidden, edges: .all)
                                .listRowInsets(EdgeInsets(top: 5, leading: 16, bottom: 5, trailing: 16))
                            }
                        }
                        .listRowSpacing(12)
                        .scrollContentBackground(.hidden)
                        .listStyle(.insetGrouped)
                    }
                }
            }
        }
        .navigationTitle("History")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if !app.history.isEmpty {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        shareOpen = true
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                    }
                    .accessibilityLabel("Export sessions as CSV")
                }
            }
        }
        .sheet(isPresented: $shareOpen) {
            ActivityShareView(csvText: HistoryExport.csvString(from: filtered))
                .presentationBackground(AppColor.background)
        }
        .sheet(item: $selectedEntry) { entry in
            HistoryEntryDetailSheet(entry: entry)
                .presentationBackground(AppColor.background)
        }
    }
}

private struct HistoryItemRowView: View {
    let entry: HistoryEntry

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [AppColor.accent.opacity(0.2), AppColor.primary.opacity(0.15)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                Image(systemName: entry.activityKind.artSymbol)
                    .font(.body.weight(.semibold))
                    .foregroundColor(AppColor.textPrimary)
            }
            .frame(width: 44, height: 44)
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.title)
                    .font(.headline)
                    .foregroundColor(AppColor.textPrimary)
                Text(rowDetailLine)
                    .font(.caption)
                    .foregroundColor(AppColor.textSecondary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            VStack(alignment: .trailing, spacing: 4) {
                HStack(spacing: 0) {
                    ForEach(0..<3, id: \.self) { i in
                        Text("★")
                            .font(.caption2)
                            .foregroundColor(
                                i < min(3, entry.starsEarned) ? AppColor.primary : AppColor.textSecondary
                            )
                    }
                }
                if let t = entry.focusLog {
                    Text(t.title)
                        .font(.caption2)
                        .foregroundColor(AppColor.textSecondary)
                }
                Text(entry.date, style: .date)
                    .font(.caption2)
                    .foregroundColor(AppColor.textSecondary)
            }
            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundColor(AppColor.textSecondary.opacity(0.5))
        }
        .padding(.vertical, 6)
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
        .multilineTextAlignment(.leading)
    }

    private var rowDetailLine: String {
        var s = "Level \(entry.levelIndex + 1) · \(entry.activityKind.rawValue) · "
        s += "\(entry.difficulty.title) · " + entry.detail
        if entry.activityKind == .focus, let it = entry.focusIntention, !it.isEmpty {
            s = "“\(it)” — " + s
        }
        return s
    }
}

private struct HistoryRowButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1, anchor: .center)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

private struct HistoryEntryDetailSheet: View {
    @Environment(\.dismiss) private var dismiss
    let entry: HistoryEntry

    var body: some View {
        NavigationStack {
            ZStack {
                AppColor.background.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack(spacing: 14) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(
                                        LinearGradient(
                                            colors: [AppColor.primary.opacity(0.3), AppColor.accent.opacity(0.2)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                Image(systemName: entry.activityKind.artSymbol)
                                    .font(.title2.weight(.semibold))
                            }
                            .frame(width: 64, height: 64)
                            VStack(alignment: .leading, spacing: 4) {
                                Text(entry.title)
                                    .font(.title2.weight(.bold))
                                Text(entry.date.formatted(date: .abbreviated, time: .shortened))
                                    .font(.subheadline)
                                    .foregroundColor(AppColor.textSecondary)
                            }
                        }
                        .padding(4)

                        HStack {
                            labelChip("Level", "\(entry.levelIndex + 1)")
                            labelChip("Stars", "\(entry.starsEarned)/3")
                        }

                        if let log = entry.focusLog {
                            labelChip("Tag", log.title)
                        }
                        if entry.activityKind == .focus, let it = entry.focusIntention, !it.isEmpty {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Intention")
                                    .font(.caption.weight(.semibold))
                                    .foregroundColor(AppColor.textSecondary)
                                Text(verbatim: "“\(it)”")
                                    .font(.body)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(16)
                            .appCardChrome(cornerRadius: 16, style: .standard)
                        }
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Detail")
                                .font(.caption.weight(.semibold))
                                .foregroundColor(AppColor.textSecondary)
                            Text(entry.detail)
                                .font(.body)
                                .foregroundColor(AppColor.textPrimary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(16)
                        .appCardChrome(cornerRadius: 16, style: .standard)
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Session")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private func labelChip(_ k: String, _ v: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 6) {
            Text(k)
                .font(.caption)
                .foregroundColor(AppColor.textSecondary)
            Text(v)
                .font(.subheadline.weight(.semibold))
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .appCardChrome(cornerRadius: 12, style: .compact)
    }
}

#Preview {
    NavigationStack {
        HistoryView()
    }
    .environmentObject(AppData())
}
