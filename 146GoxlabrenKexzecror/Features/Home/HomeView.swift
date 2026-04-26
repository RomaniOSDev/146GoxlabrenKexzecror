//
//  HomeView.swift
//  146GoxlabrenKexzecror
//  Main home: hero + widget grid + flows (replaces the old list hub).
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var app: AppData
    var onAddTask: () -> Void
    @State private var dayCloseRitualOpen = false
    @State private var contractAreaTag: String = "any"

    private var weekContract: (done: Int, target: Int, isActive: Bool) {
        app.weeklyContractProgress()
    }

    private let widgetColumns: [GridItem] = [
        GridItem(.flexible(), spacing: 12, alignment: .top),
        GridItem(.flexible(), spacing: 12, alignment: .top)
    ]

    var body: some View {
        ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    headerRow
                    heroBlock

                    LazyVGrid(columns: widgetColumns, spacing: 12) {
                        homeWidget {
                            VStack(alignment: .leading, spacing: 10) {
                                Label("Score", systemImage: "chart.line.uptrend.xyaxis")
                                    .font(.caption.weight(.semibold))
                                    .foregroundColor(AppColor.textSecondary)
                                ZStack {
                                    ProgressRingView(
                                        progress: min(1, app.progressScore / 100.0),
                                        lineWidth: 10
                                    )
                                    .frame(width: 84, height: 84)
                                    Text("\(Int(min(100, app.progressScore.rounded(.towardZero))))%")
                                        .font(.title2.weight(.bold).monospacedDigit())
                                        .foregroundColor(AppColor.textPrimary)
                                }
                                .frame(maxWidth: .infinity)
                            }
                        }

                        homeWidget {
                            VStack(alignment: .leading, spacing: 8) {
                                Label("Streak", systemImage: "flame.fill")
                                    .font(.caption.weight(.semibold))
                                    .foregroundColor(AppColor.textSecondary)
                                Text("\(app.currentStreak)")
                                    .font(.system(size: 40, weight: .bold, design: .rounded))
                                    .foregroundColor(AppColor.accent)
                                Text("days in a row")
                                    .font(.caption)
                                    .foregroundColor(AppColor.textSecondary)
                            }
                        }

                        homeWidget {
                            VStack(alignment: .leading, spacing: 10) {
                                HStack(spacing: 8) {
                                    Image(systemName: "bolt.fill")
                                        .font(.title2)
                                        .foregroundStyle(
                                            LinearGradient(
                                                colors: [AppColor.accent, AppColor.primary],
                                                startPoint: .top,
                                                endPoint: .bottom
                                            )
                                        )
                                    Text("Energy")
                                        .font(.caption.weight(.semibold))
                                        .foregroundColor(AppColor.textSecondary)
                                }
                                HStack {
                                    Text("1")
                                        .font(.caption2.weight(.bold))
                                    Slider(
                                        value: Binding(
                                            get: { Double(app.energyForToday()) },
                                            set: { app.setEnergyForToday(Int($0.rounded())) }
                                        ),
                                        in: 1...5,
                                        step: 1
                                    )
                                    .tint(AppColor.accent)
                                    Text("5")
                                        .font(.caption2.weight(.bold))
                                }
                                .foregroundColor(AppColor.textSecondary)
                                Text("\(app.energyForToday()) / 5")
                                    .font(.title2.weight(.bold).monospacedDigit())
                                    .foregroundStyle(
                                        AppVisual.primaryButtonFill
                                    )
                            }
                        }

                        homeWidget {
                            VStack(alignment: .leading, spacing: 8) {
                                Label("Quick focus", systemImage: "play.circle.fill")
                                    .font(.caption.weight(.semibold))
                                    .foregroundColor(AppColor.textSecondary)
                                ForEach([25, 50, 90], id: \.self) { m in
                                    Button {
                                        Haptics.lightImpact()
                                        app.requestFocusFromShortcut(
                                            levelIndex: 0,
                                            minutes: Double(m)
                                        )
                                    } label: {
                                        HStack {
                                            ZStack {
                                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                                    .fill(
                                                        AppVisual.primaryButtonFill.opacity(0.35)
                                                    )
                                                    .frame(width: 36, height: 32)
                                                Image(systemName: "play.fill")
                                                    .font(.subheadline.weight(.bold))
                                            }
                                            Text("\(m) min")
                                                .font(.subheadline.weight(.semibold))
                                            Spacer()
                                            Image(systemName: "arrow.right.circle.fill")
                                        }
                                        .foregroundColor(AppColor.textPrimary)
                                        .padding(.vertical, 10)
                                        .padding(.horizontal, 10)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                                .fill(
                                                    LinearGradient(
                                                        colors: [Color.white.opacity(0.06), AppColor.background],
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    )
                                                )
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                                .stroke(AppColor.textSecondary.opacity(0.2), lineWidth: 0.75)
                                        )
                                        .shadow(color: Color.black.opacity(0.2), radius: 4, y: 1)
                                    }
                                }
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        AppScreenSectionHeader(
                            systemImage: "sun.max.fill",
                            title: "Day mode",
                            subtitle: "One pick — shapes today’s nudge."
                        )
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(DayMode.allCases, id: \.self) { m in
                                    let on = app.dayModeForToday().map { $0 == m } ?? false
                                    Button {
                                        Haptics.lightImpact()
                                        app.setDayModeForToday(m)
                                    } label: {
                                        VStack(spacing: 8) {
                                            ZStack {
                                                Circle()
                                                    .fill(
                                                        on
                                                            ? AppColor.background.opacity(0.22)
                                                            : AppColor.background.opacity(0.08)
                                                    )
                                                    .frame(width: 44, height: 44)
                                                Image(systemName: m.systemImage)
                                                    .font(.system(size: 20, weight: .semibold))
                                            }
                                            Text(m.title)
                                                .font(.caption.weight(.semibold))
                                            Text(m.hint)
                                                .font(.system(size: 9))
                                                .lineLimit(2)
                                                .minimumScaleFactor(0.6)
                                                .multilineTextAlignment(.center)
                                        }
                                        .foregroundColor(on ? AppColor.background : AppColor.textPrimary)
                                        .padding(10)
                                        .frame(width: 120, height: 118, alignment: .top)
                                        .background(
                                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                                .fill(
                                                    on
                                                        ? AppVisual.primaryButtonFill
                                                        : LinearGradient(
                                                            colors: [
                                                                Color.white.opacity(0.08),
                                                                AppColor.background.opacity(0.45)
                                                            ],
                                                            startPoint: .top,
                                                            endPoint: .bottom
                                                        )
                                                )
                                        )
                                        .overlay {
                                            Group {
                                                if on {
                                                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                                                        .stroke(Color.clear, lineWidth: 1)
                                                } else {
                                                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                                                        .stroke(AppVisual.cardBorderGradient(strong: false), lineWidth: 1)
                                                }
                                            }
                                        }
                                        .shadow(
                                            color: (on ? AppColor.primary : Color.black).opacity(on ? 0.35 : 0.2),
                                            radius: on ? 10 : 4,
                                            y: 3
                                        )
                                    }
                                }
                            }
                        }
                        if let m = app.dayModeForToday() {
                            HStack(spacing: 6) {
                                Image(systemName: m.suggestedFocus.systemImage)
                                    .font(.caption.weight(.semibold))
                                Text("Tag: \(m.suggestedFocus.title)")
                                    .font(.caption2.weight(.medium))
                            }
                            .foregroundColor(AppColor.accent)
                        }
                    }
                    .homeWidgetFrame()

                    contractCard

                    Button {
                        dayCloseRitualOpen = true
                    } label: {
                        HStack(spacing: 14) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(
                                        LinearGradient(
                                            colors: [AppColor.primary.opacity(0.45), AppColor.accent.opacity(0.2)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 48, height: 48)
                                    .shadow(color: AppColor.primary.opacity(0.25), radius: 8, y: 2)
                                Image(systemName: "moon.stars.fill")
                                    .font(.title2.weight(.semibold))
                            }
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Close the day")
                                    .font(.subheadline.weight(.semibold))
                                Text("~30s")
                                    .font(.caption2)
                                    .foregroundColor(AppColor.textSecondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.subheadline.weight(.semibold))
                        }
                        .foregroundColor(AppColor.textPrimary)
                        .homeWidgetFrameShowcase()
                    }

                    SessionWeekBarChart(values: app.sessionCountsLast7Days())
                        .homeWidgetFrame()

                    AppScreenSectionHeader(
                        systemImage: "waveform.path.ecg",
                        title: "Pace",
                        subtitle: "Flow feel for your runs."
                    )
                    Picker("Pace", selection: $app.selectedDifficulty) {
                        ForEach(Difficulty.allCases) { d in
                            Text(d.title).tag(d)
                        }
                    }
                    .pickerStyle(.segmented)

                    topTasksCard

                    AppScreenSectionHeader(
                        systemImage: "gamecontroller.fill",
                        title: "Play",
                        subtitle: "Stars clear the path forward.",
                        titleStyle: .largeHero
                    )

                    ForEach(ActivityKind.allCases) { k in
                        activityCard(kind: k)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 4)
                .padding(.bottom, 32)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Home")
                    .font(.headline.weight(.semibold))
                    .foregroundColor(AppColor.textPrimary)
            }
        }
        .sheet(isPresented: $dayCloseRitualOpen) {
            DayCloseRitualView()
                .environmentObject(app)
                .presentationBackground(AppColor.background)
        }
        .onAppear { syncContractArea() }
    }

    private var headerRow: some View {
        HStack(alignment: .firstTextBaseline) {
            Spacer()
            Button {
                onAddTask()
            } label: {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(AppColor.primary, AppColor.textPrimary)
            }
        }
    }

    private var heroBlock: some View {
        ZStack(alignment: .center) {
            AppFloatingOrbs()
            HStack(alignment: .center, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(greeting)
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.white, AppColor.textPrimary],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    Text(longDate)
                        .font(.caption.weight(.semibold))
                        .foregroundColor(AppColor.textSecondary)
                }
                Spacer(minLength: 0)
                AppGradientIconBubble(systemName: heroTimeSymbol, size: 38, bubbleSize: 80)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 4)
    }

    private var heroTimeSymbol: String {
        let h = Calendar.current.component(.hour, from: Date())
        switch h {
        case 5..<12: return "sun.horizon.fill"
        case 12..<18: return "sun.max.fill"
        default: return "moon.stars.fill"
        }
    }

    private var longDate: String {
        let f = DateFormatter()
        f.setLocalizedDateFormatFromTemplate("EEEEMMMd")
        return f.string(from: Date())
    }

    private var greeting: String {
        let h = Calendar.current.component(.hour, from: Date())
        switch h {
        case 5..<12: return "Good morning"
        case 12..<18: return "Good afternoon"
        default: return "Good evening"
        }
    }

    @ViewBuilder
    private func homeWidget<Content: View>(@ViewBuilder _ c: () -> Content) -> some View {
        c()
            .homeWidgetFrame()
    }

    private var topTasksCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            AppScreenSectionHeader(
                systemImage: "list.number",
                title: "Top 3",
                subtitle: "Today’s list"
            )
            if app.userTasks.isEmpty {
                HStack(spacing: 14) {
                    Image(systemName: "tray")
                        .font(.system(size: 36, weight: .light))
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [AppColor.accent, AppColor.primary],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    Text("Tap + to add your first task.")
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(AppColor.textSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(app.topTodayTasks) { t in
                        HStack(alignment: .top, spacing: 10) {
                            Button {
                                app.toggleTask(t)
                            } label: {
                                Image(systemName: t.isDone ? "checkmark.circle.fill" : "circle")
                                    .font(.title3)
                                    .foregroundColor(t.isDone ? AppColor.primary : AppColor.textSecondary)
                            }
                            .buttonStyle(.plain)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(t.title)
                                    .font(.subheadline.weight(.semibold))
                                    .strikethrough(t.isDone)
                                if !t.notes.isEmpty {
                                    Text(t.notes)
                                        .font(.caption)
                                        .foregroundColor(AppColor.textSecondary)
                                }
                            }
                        }
                    }
                }
                if app.userTasks.count > 3 {
                    Text("+\(app.userTasks.count - 3) more in your list")
                        .font(.caption2)
                        .foregroundColor(AppColor.textSecondary)
                }
            }
        }
        .homeWidgetFrame()
    }

    private var contractCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            AppScreenSectionHeader(
                systemImage: "hand.raised.fill",
                title: "Weekly promise",
                subtitle: "This week only — you vs. the plan."
            )
            TextField("Your promise in one line", text: $app.weeklyContractText)
                .textFieldStyle(.plain)
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(AppColor.background)
                )
                .foregroundColor(AppColor.textPrimary)
            HStack {
                Text("Target")
                Spacer()
                Stepper("\(app.weeklyContractTarget) sessions", value: $app.weeklyContractTarget, in: 0...20)
            }
            Picker("Tag", selection: $contractAreaTag) {
                Text("Any focus").tag("any")
                ForEach(FocusArea.allCases) { a in
                    Text(a.title).tag(a.rawValue)
                }
            }
            .tint(AppColor.primary)
            Button {
                Haptics.lightImpact()
                let a: FocusArea? = (contractAreaTag == "any") ? nil : FocusArea(rawValue: contractAreaTag)
                app.saveWeeklyContract(
                    text: app.weeklyContractText,
                    target: app.weeklyContractTarget,
                    area: a
                )
            } label: {
                Text("Save for this week")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(AppColor.background)
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 44)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(AppColor.primary)
                    )
            }
            if weekContract.isActive, weekContract.target > 0 {
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("Progress")
                        Spacer()
                        Text("\(weekContract.done) / \(weekContract.target)")
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(AppColor.accent)
                    }
                    ProgressView(
                        value: min(1, Double(weekContract.done) / Double(max(1, weekContract.target)))
                    )
                    .tint(AppColor.primary)
                }
            } else if !app.weeklyContractText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty, app.weeklyContractTarget == 0 {
                Label("Set target + save to track", systemImage: "arrow.right.circle")
                    .font(.caption)
                    .foregroundColor(AppColor.textSecondary)
            }
        }
        .homeWidgetFrame()
    }

    private func syncContractArea() {
        contractAreaTag = app.weeklyContractAreaRaw ?? "any"
    }

    private func activityCard(kind: ActivityKind) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .center, spacing: 12) {
                AppGradientIconBubble(
                    systemName: kind.artSymbol,
                    size: 26,
                    bubbleSize: 56,
                    strong: false
                )
                VStack(alignment: .leading, spacing: 2) {
                    Text(kind.shortTitle)
                        .font(.headline)
                    Text("Stars unlock the next level.")
                        .font(.caption2)
                        .foregroundColor(AppColor.textSecondary)
                }
                Spacer()
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(0..<GameLevels.count, id: \.self) { idx in
                        let unlocked = app.unlockedLevel(for: kind) > idx
                        if unlocked {
                            NavigationLink {
                                switch kind {
                                case .routine: RoutineEnhancerView(levelIndex: idx)
                                case .focus: FocusPulseView(levelIndex: idx, initialMinutes: nil)
                                case .priority: PriorityMapperView(levelIndex: idx)
                                }
                            } label: {
                                levelPill(
                                    level: idx + 1,
                                    best: app.bestStars(activity: kind, level: idx),
                                    locked: false
                                )
                            }
                        } else {
                            levelPill(
                                level: idx + 1,
                                best: 0,
                                locked: true
                            )
                        }
                    }
                }
            }
        }
        .homeWidgetFrame()
    }

    @ViewBuilder
    private func levelPill(level: Int, best: Int, locked: Bool) -> some View {
        VStack(spacing: 6) {
            Text("L\(level)")
                .font(.caption2.weight(.bold))
            HStack(spacing: 1) {
                ForEach(0..<3, id: \.self) { s in
                    Text("★")
                        .font(.system(size: 9))
                        .foregroundColor(
                            s < (locked ? 0 : min(3, best)) ? AppColor.primary : AppColor.textSecondary
                        )
                }
            }
            if locked { Text("Lock").font(.system(size: 8)) }
        }
        .lineLimit(1)
        .minimumScaleFactor(0.7)
        .padding(.vertical, 10)
        .frame(minWidth: 64, minHeight: 50)
        .frame(maxWidth: .infinity)
        .background {
            Group {
                if locked {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(AppColor.background.opacity(0.35))
                } else {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(AppVisual.cardBodyGradient(for: .compact))
                }
            }
        }
        .shadow(color: Color.black.opacity(locked ? 0.08 : 0.22), radius: locked ? 0 : 5, y: 1)
        .overlay {
            Group {
                if locked {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(AppColor.textSecondary.opacity(0.35), lineWidth: 1.25)
                } else {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(AppVisual.cardBorderGradient(strong: false), lineWidth: 1.25)
                }
            }
        }
        .disabled(locked)
    }
}

// MARK: - Styling

private struct HomeWidgetFrame: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .appCardChrome(cornerRadius: 20, style: .hero)
    }
}

private extension View {
    func homeWidgetFrame() -> some View {
        modifier(HomeWidgetFrame())
    }

    func homeWidgetFramePlain() -> some View {
        appCardChrome(cornerRadius: 20, style: .standard)
    }

    func homeWidgetFrameShowcase() -> some View {
        modifier(HomeWidgetShowcaseFrame())
    }
}

private struct HomeWidgetShowcaseFrame: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .appCardChrome(cornerRadius: 20, style: .showcase)
    }
}

// MARK: - Week chart (home)

private struct SessionWeekBarChart: View {
    var values: [Int]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: "chart.bar.xaxis")
                    .font(.title2.weight(.semibold))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [AppColor.accent, AppColor.primary],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                VStack(alignment: .leading, spacing: 2) {
                    Text("Sessions")
                        .font(.headline)
                    Text("7 days — today is right")
                        .font(.caption2)
                        .foregroundColor(AppColor.textSecondary)
                }
            }
            VStack(alignment: .leading, spacing: 6) {
                Canvas { context, size in
                    let pad: CGFloat = 0
                    let v7: [Int] = {
                        var a = values
                        while a.count < 7 { a.append(0) }
                        return Array(a.prefix(7))
                    }()
                    let maxC = max(1, v7.max() ?? 1)
                    let n = 7.0
                    let gap: CGFloat = 3
                    let w = (size.width - (n - 1) * gap - pad * 2) / n
                    let chartH = size.height
                    for i in 0..<7 {
                        let v = v7[i]
                        let frac = CGFloat(v) / CGFloat(maxC)
                        let barH = (chartH - 2) * frac
                        let x = pad + (w + gap) * CGFloat(i)
                        let y = chartH - barH
                        let p = Path(
                            roundedRect: CGRect(x: x, y: y, width: w, height: max(barH, 0)),
                            cornerSize: CGSize(width: 3, height: 3)
                        )
                        let em = min(1, v == (v7.max() ?? 0) && v > 0 ? 1.0 : 0.45)
                        context.fill(
                            p,
                            with: .linearGradient(
                                Gradient(
                                    colors: [AppColor.accent.opacity(0.55 + 0.2 * em), AppColor.primary]
                                ),
                                startPoint: CGPoint(x: x, y: y + barH),
                                endPoint: CGPoint(x: x, y: y)
                            )
                        )
                    }
                }
                .frame(height: 88)
                HStack(alignment: .top, spacing: 3) {
                    ForEach(0..<7, id: \.self) { i in
                        Text(weekdayLetter(offsetFromOldest: i))
                            .font(.system(size: 9, weight: .semibold, design: .rounded))
                            .foregroundColor(AppColor.textSecondary)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
        }
    }

    private func weekdayLetter(offsetFromOldest: Int) -> String {
        let cal = Calendar.current
        guard let d = cal.date(
            byAdding: .day,
            value: -6 + offsetFromOldest,
            to: cal.startOfDay(for: Date())
        ) else { return "—" }
        return String(cal.shortWeekdaySymbols[cal.component(.weekday, from: d) - 1].prefix(1))
    }
}

#Preview {
    NavigationStack {
        HomeView(onAddTask: { })
    }
    .environmentObject(AppData())
}
