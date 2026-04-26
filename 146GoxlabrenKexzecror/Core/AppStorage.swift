//
//  AppStorage.swift
//  146GoxlabrenKexzecror
//  Single source of truth for persisted app state.
//

import Combine
import Foundation
import SwiftUI

extension Notification.Name {
    static let appDataDidReset = Notification.Name("appDataDidReset")
}

/// Number of playable level slots per activity (0 ..< `count`), persisted in `starsGrid`.
enum GameLevels {
    static let count: Int = 6
}

/// One pick per calendar day. Shapes hints and the focus reminder, not gating.
enum DayMode: String, Codable, CaseIterable, Identifiable {
    case deep
    case admin
    case recovery

    var id: String { rawValue }

    var title: String {
        switch self {
        case .deep: return "Deep"
        case .admin: return "Admin"
        case .recovery: return "Recovery"
        }
    }

    var hint: String {
        switch self {
        case .deep: return "Favor one hard block and long focus."
        case .admin: return "Inbox, planning, and follow-ups first."
        case .recovery: return "Short blocks, breaks, low pressure."
        }
    }

    var focusReminderLine: String {
        switch self {
        case .deep: return "Today: protect one deep work block."
        case .admin: return "Today: one admin sweep, then your focus run."
        case .recovery: return "Today: short sprints, keep it gentle."
        }
    }

    var suggestedFocus: FocusArea {
        switch self {
        case .deep: return .deepWork
        case .admin: return .organization
        case .recovery: return .wellBeing
        }
    }

    var systemImage: String {
        switch self {
        case .deep: return "flame.fill"
        case .admin: return "tray.full.fill"
        case .recovery: return "leaf.fill"
        }
    }
}

struct DayCloseEntry: Codable, Identifiable, Equatable {
    var id: UUID
    var dayYMD: String
    var didMain: Bool
    var deferred: String
    var savedAt: Date
}

enum ActivityKind: String, Codable, CaseIterable, Identifiable {
    case routine
    case focus
    case priority

    var id: String { rawValue }

    var displayTitle: String {
        switch self {
        case .routine: return "Routine Enhancer"
        case .focus: return "Focus Pulse"
        case .priority: return "Priority Mapper"
        }
    }

    var shortTitle: String {
        switch self {
        case .routine: return "Routine"
        case .focus: return "Focus"
        case .priority: return "Map"
        }
    }

    var artSymbol: String {
        switch self {
        case .routine: return "calendar.badge.clock"
        case .focus: return "bolt.heart.fill"
        case .priority: return "square.grid.2x2.fill"
        }
    }
}

enum FocusArea: String, CaseIterable, Identifiable, Codable {
    case deepWork
    case organization
    case wellBeing
    case learning

    var id: String { rawValue }

    var title: String {
        switch self {
        case .deepWork: return "Deep Work"
        case .organization: return "Organization"
        case .wellBeing: return "Well-Being"
        case .learning: return "Learning"
        }
    }

    var systemImage: String {
        switch self {
        case .deepWork: return "brain"
        case .organization: return "archivebox.fill"
        case .wellBeing: return "heart.fill"
        case .learning: return "book.fill"
        }
    }
}

enum Difficulty: String, CaseIterable, Codable, Identifiable, Hashable {
    case calm
    case steady
    case intense

    var id: String { rawValue }

    var title: String {
        switch self {
        case .calm: return "Calm"
        case .steady: return "Steady"
        case .intense: return "Intense"
        }
    }

    /// Slot count for routine timeline.
    var routineSlots: Int {
        switch self {
        case .calm: return 4
        case .steady: return 5
        case .intense: return 6
        }
    }

    /// Focus session length scale (multiplier on base minutes).
    var focusLengthScale: Double {
        switch self {
        case .calm: return 0.75
        case .steady: return 1.0
        case .intense: return 1.35
        }
    }

    /// How many items in priority mapper.
    var priorityItemCount: Int {
        switch self {
        case .calm: return 4
        case .steady: return 5
        case .intense: return 6
        }
    }

    /// Stricter star thresholds when higher.
    var starStrictness: Double {
        switch self {
        case .calm: return 0.85
        case .steady: return 0.9
        case .intense: return 0.95
        }
    }
}

struct UserTask: Codable, Identifiable, Equatable {
    var id: UUID
    var title: String
    var notes: String
    var isDone: Bool
    var createdAt: Date
}

struct HistoryEntry: Codable, Identifiable, Equatable {
    var id: UUID
    var title: String
    var date: Date
    var activityKind: ActivityKind
    var levelIndex: Int
    var starsEarned: Int
    var detail: String
    var difficulty: Difficulty
    var focusLog: FocusArea?
    var focusIntention: String?
}

@MainActor
final class AppData: ObservableObject {
    private let defaults: UserDefaults

    @Published var hasSeenOnboarding: Bool {
        didSet { save(.hasSeenOnboarding, hasSeenOnboarding) }
    }

    @Published var tasksCompleted: Int {
        didSet { save(.tasksCompleted, tasksCompleted) }
    }

    @Published var progressScore: Double {
        didSet { save(.progressScore, progressScore) }
    }

    @Published var currentStreak: Int {
        didSet { save(.currentStreak, currentStreak) }
    }

    @Published var totalStars: Int {
        didSet { save(.totalStars, totalStars) }
    }

    @Published var lastSessionDay: String? {
        didSet { saveOptional(.lastSessionDay, lastSessionDay) }
    }

    @Published var userTasks: [UserTask] {
        didSet { saveJSON(.userTasks, userTasks) }
    }

    @Published var history: [HistoryEntry] {
        didSet { saveJSON(.history, history) }
    }

    @Published var focusTargets: [FocusArea: Double] {
        didSet { saveJSON(.focusTargets, Self.encodeFocus(focusTargets)) }
    }

    @Published var selectedDifficulty: Difficulty {
        didSet { saveRaw(.selectedDifficulty, selectedDifficulty) }
    }

    @Published var unlockedLevelRoutine: Int {
        didSet { save(.unlockedLevelRoutine, unlockedLevelRoutine) }
    }

    @Published var unlockedLevelFocus: Int {
        didSet { save(.unlockedLevelFocus, unlockedLevelFocus) }
    }

    @Published var unlockedLevelPriority: Int {
        didSet { save(.unlockedLevelPriority, unlockedLevelPriority) }
    }

    /// Per activity, per level index, best stars 0...3; length = `GameLevels.count`.
    @Published var starsGrid: [String: [Int]] {
        didSet { saveJSON(.starsGrid, starsGrid) }
    }

    /// New sessions are tagged for Goals stats; override per call of `recordSession` if needed.
    @Published var defaultLogFocus: FocusArea {
        didSet { saveRaw(.defaultLogFocus, defaultLogFocus) }
    }

    @Published var remindFocusOn: Bool {
        didSet { save(.remindFocusOn, remindFocusOn) }
    }

    /// 0...1439 minutes from midnight
    @Published var focusReminderMinuteOfDay: Int {
        didSet { save(.focusReminderMinuteOfDay, focusReminderMinuteOfDay) }
    }

    @Published var dayReviewOn: Bool {
        didSet { save(.dayReviewOn, dayReviewOn) }
    }

    @Published var dayReviewMinuteOfDay: Int {
        didSet { save(.dayReviewMinuteOfDay, dayReviewMinuteOfDay) }
    }

    /// Most recent first, minutes (e.g. 25, 50, 90), capped
    @Published var recentFocusDurations: [Int] {
        didSet { saveJSON(.recentFocusDurations, recentFocusDurations) }
    }

    @Published var focusLaunch: FocusLaunchItem?

    /// `yyyy-MM-dd` → `DayMode.rawValue`
    @Published var dayModeByYMD: [String: String] {
        didSet { saveJSON(.dayModeByYMD, dayModeByYMD) }
    }

    /// 1...5, keyed by calendar day (how you feel, not the score %)
    @Published var energyByYMD: [String: Int] {
        didSet { saveJSON(.energyByYMD, energyByYMD) }
    }

    @Published var weeklyContractSetWeekId: String? {
        didSet { saveOptional(.weeklyContractSetWeekId, weeklyContractSetWeekId) }
    }

    @Published var weeklyContractText: String {
        didSet { saveStringKey(.weeklyContractText, weeklyContractText) }
    }

    @Published var weeklyContractTarget: Int {
        didSet { save(.weeklyContractTarget, weeklyContractTarget) }
    }

    @Published var weeklyContractAreaRaw: String? {
        didSet { saveOptional(.weeklyContractAreaRaw, weeklyContractAreaRaw) }
    }

    @Published var dayCloseHistory: [DayCloseEntry] {
        didSet { saveJSON(.dayCloseHistory, dayCloseHistory) }
    }

    var streakLength: Int { currentStreak }
    var todayYMD: String { Self.dayString(Date()) }

    init(userDefaults: UserDefaults = .standard) {
        self.defaults = userDefaults
        hasSeenOnboarding = userDefaults.bool(forKey: Key.hasSeenOnboarding.rawValue)
        tasksCompleted = userDefaults.object(forKey: Key.tasksCompleted.rawValue) as? Int ?? 0
        let ps = userDefaults.object(forKey: Key.progressScore.rawValue) as? Double
        progressScore = ps ?? 0
        currentStreak = userDefaults.object(forKey: Key.currentStreak.rawValue) as? Int ?? 0
        totalStars = userDefaults.object(forKey: Key.totalStars.rawValue) as? Int ?? 0
        lastSessionDay = userDefaults.string(forKey: Key.lastSessionDay.rawValue)
        userTasks = Self.loadJSON(key: .userTasks, def: [], defaults: userDefaults)
        history = Self.loadJSON(key: .history, def: [], defaults: userDefaults)
        if let data: [String: Double] = Self.loadJSON(key: .focusTargets, def: nil, defaults: userDefaults) {
            focusTargets = Self.decodeFocus(data)
        } else {
            focusTargets = [
                .deepWork: 0.35,
                .organization: 0.25,
                .wellBeing: 0.2,
                .learning: 0.2
            ]
        }
        if let raw = userDefaults.string(forKey: Key.selectedDifficulty.rawValue),
           let d = Difficulty(rawValue: raw) {
            selectedDifficulty = d
        } else {
            selectedDifficulty = .steady
        }
        let ur = userDefaults.object(forKey: Key.unlockedLevelRoutine.rawValue) as? Int ?? 1
        let uf = userDefaults.object(forKey: Key.unlockedLevelFocus.rawValue) as? Int ?? 1
        let up = userDefaults.object(forKey: Key.unlockedLevelPriority.rawValue) as? Int ?? 1
        unlockedLevelRoutine = min(GameLevels.count, max(1, ur))
        unlockedLevelFocus = min(GameLevels.count, max(1, uf))
        unlockedLevelPriority = min(GameLevels.count, max(1, up))
        var loaded = Self.loadJSON(key: .starsGrid, def: [String: [Int]](), defaults: userDefaults)
        Self.normalizeStarsGridInPlace(&loaded)
        starsGrid = loaded
        if let raw = userDefaults.string(forKey: Key.defaultLogFocus.rawValue),
           let a = FocusArea(rawValue: raw) {
            defaultLogFocus = a
        } else {
            defaultLogFocus = .deepWork
        }
        remindFocusOn = userDefaults.bool(forKey: Key.remindFocusOn.rawValue)
        focusReminderMinuteOfDay = userDefaults.object(forKey: Key.focusReminderMinuteOfDay.rawValue) as? Int ?? 9 * 60
        dayReviewOn = userDefaults.bool(forKey: Key.dayReviewOn.rawValue)
        dayReviewMinuteOfDay = userDefaults.object(forKey: Key.dayReviewMinuteOfDay.rawValue) as? Int ?? 18 * 60
        let recent: [Int] = Self.loadJSON(key: .recentFocusDurations, def: [25, 50, 90], defaults: userDefaults)
        recentFocusDurations = recent.isEmpty ? [25, 50, 90] : recent
        dayModeByYMD = Self.loadJSON(key: .dayModeByYMD, def: [:], defaults: userDefaults)
        energyByYMD = Self.loadJSON(key: .energyByYMD, def: [:], defaults: userDefaults)
        weeklyContractSetWeekId = userDefaults.string(forKey: Key.weeklyContractSetWeekId.rawValue)
        weeklyContractText = userDefaults.string(forKey: Key.weeklyContractText.rawValue) ?? ""
        weeklyContractTarget = userDefaults.object(forKey: Key.weeklyContractTarget.rawValue) as? Int ?? 0
        weeklyContractAreaRaw = userDefaults.string(forKey: Key.weeklyContractAreaRaw.rawValue)
        dayCloseHistory = Self.loadJSON(key: .dayCloseHistory, def: [], defaults: userDefaults)
        focusLaunch = nil
    }

    func unlockedLevel(for kind: ActivityKind) -> Int {
        switch kind {
        case .routine: return unlockedLevelRoutine
        case .focus: return unlockedLevelFocus
        case .priority: return unlockedLevelPriority
        }
    }

    func setUnlockedToAtLeast(_ value: Int, for kind: ActivityKind) {
        let clamped = min(GameLevels.count, max(1, value))
        switch kind {
        case .routine: unlockedLevelRoutine = max(unlockedLevelRoutine, clamped)
        case .focus: unlockedLevelFocus = max(unlockedLevelFocus, clamped)
        case .priority: unlockedLevelPriority = max(unlockedLevelPriority, clamped)
        }
    }

    func bestStars(activity: ActivityKind, level: Int) -> Int {
        let key = activity.rawValue
        var arr = starsGrid[key] ?? Array(repeating: 0, count: GameLevels.count)
        Self.normalizeStarsArrayInPlace(&arr)
        guard level >= 0, level < GameLevels.count else { return 0 }
        return arr[level]
    }

    /// Logged `focusLog` is used for weekly Goals; defaults to `defaultLogFocus` when `nil`.
    /// `focusIntention` — "chain of intention" for `focus` sessions only; stored in history.
    func recordSession(
        activity: ActivityKind,
        level: Int,
        stars: Int,
        detail: String,
        focusLog: FocusArea? = nil,
        focusIntention: String? = nil
    ) {
        let day = Self.dayString(Date())
        let cappedStars = min(3, max(0, stars))
        if cappedStars > 0 {
            if lastSessionDay == nil {
                lastSessionDay = day
                currentStreak = 1
            } else if lastSessionDay == day {
                // same day, streak unchanged
                _ = ()
            } else if let previous = lastSessionDay,
                      Self.isConsecutiveDay(previous, day) {
                currentStreak += 1
                lastSessionDay = day
            } else {
                currentStreak = 1
                lastSessionDay = day
            }
        }

        if cappedStars > 0 {
            tasksCompleted += 1
            totalStars += cappedStars
            let key = activity.rawValue
            var arr = starsGrid[key] ?? Array(repeating: 0, count: GameLevels.count)
            Self.normalizeStarsArrayInPlace(&arr)
            if level >= 0, level < GameLevels.count {
                arr[level] = max(arr[level], cappedStars)
            }
            starsGrid[key] = arr

            if cappedStars >= 1 {
                setUnlockedToAtLeast(level + 2, for: activity)
            }
        }

        let newScore = min(100, progressScore + Double(cappedStars) * 0.6)
        progressScore = newScore

        let tag = focusLog ?? defaultLogFocus
        let intText: String? = {
            guard activity == .focus, let s = focusIntention else { return nil }
            let t = s.trimmingCharacters(in: .whitespacesAndNewlines)
            return t.isEmpty ? nil : t
        }()
        let entry = HistoryEntry(
            id: UUID(),
            title: activity.displayTitle,
            date: Date(),
            activityKind: activity,
            levelIndex: level,
            starsEarned: cappedStars,
            detail: detail,
            difficulty: selectedDifficulty,
            focusLog: tag,
            focusIntention: intText
        )
        history.insert(entry, at: 0)
    }

    func addUserTask(title: String, notes: String) {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let t = UserTask(
            id: UUID(),
            title: trimmed,
            notes: notes.trimmingCharacters(in: .whitespacesAndNewlines),
            isDone: false,
            createdAt: Date()
        )
        userTasks.insert(t, at: 0)
    }

    func toggleTask(_ task: UserTask) {
        guard let i = userTasks.firstIndex(of: task) else { return }
        userTasks[i].isDone.toggle()
    }

    func updateFocusTargets(_ map: [FocusArea: Double]) {
        var normalized = map
        let sum = FocusArea.allCases.reduce(0.0) { $0 + (normalized[$1] ?? 0) }
        if sum > 0.001 {
            for k in FocusArea.allCases {
                normalized[k, default: 0] = (normalized[k] ?? 0) / sum
            }
        }
        focusTargets = normalized
    }

    func achievementPercent(for area: FocusArea) -> Double {
        let w = focusTargets[area] ?? 0.25
        let base = progressScore / 100.0
        return min(100, max(0, (base * 0.55 + w * 0.45) * 100.0))
    }

    var topTodayTasks: [UserTask] {
        let s = userTasks.sorted { a, b in
            if a.isDone != b.isDone { return !a.isDone && b.isDone }
            return a.createdAt > b.createdAt
        }
        return Array(s.prefix(3))
    }

    /// 7 values: index 0 = 6 days ago, 6 = today. Session count per day.
    func sessionCountsLast7Days() -> [Int] {
        let cal = Calendar.current
        var out: [Int] = Array(repeating: 0, count: 7)
        let today = cal.startOfDay(for: Date())
        for i in 0..<7 {
            guard let day = cal.date(byAdding: .day, value: -6 + i, to: today) else { continue }
            for e in history {
                if cal.isDate(e.date, inSameDayAs: day) {
                    out[i] += 1
                }
            }
        }
        return out
    }

    /// Sessions in the last 7 days by kind.
    func sessionCountsByActivityLast7() -> [ActivityKind: Int] {
        var m: [ActivityKind: Int] = [.routine: 0, .focus: 0, .priority: 0]
        for e in historyInLast7Days {
            m[e.activityKind, default: 0] += 1
        }
        return m
    }

    /// `focusLog` by area, plus unlabeled.
    func sessionCountsByFocusLogLast7() -> (byArea: [FocusArea: Int], unlabeled: Int) {
        var a: [FocusArea: Int] = [:]
        for x in FocusArea.allCases { a[x] = 0 }
        var u = 0
        for e in historyInLast7Days {
            if let t = e.focusLog {
                a[t, default: 0] += 1
            } else {
                u += 1
            }
        }
        return (a, u)
    }

    private var historyInLast7Days: [HistoryEntry] {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        guard let start = cal.date(byAdding: .day, value: -6, to: today) else { return [] }
        return history.filter { $0.date >= start }
    }

    /// Remember the last 5 custom lengths (integer minutes) for the focus screen.
    func recordRecentFocusChoice(minutes: Int) {
        let c = min(90, max(1, minutes))
        var a = recentFocusDurations
        a.removeAll { $0 == c }
        a.insert(c, at: 0)
        if a.count > 5 { a = Array(a.prefix(5)) }
        recentFocusDurations = a
    }

    func requestFocusFromShortcut(levelIndex: Int, minutes: Double) {
        focusLaunch = FocusLaunchItem(levelIndex: levelIndex, minutes: minutes)
    }

    // MARK: - Day mode, energy, weekly contract, day close

    func dayModeForToday() -> DayMode? {
        dayModeByYMD[todayYMD].flatMap { DayMode(rawValue: $0) }
    }

    func setDayModeForToday(_ m: DayMode) {
        var c = dayModeByYMD
        c[todayYMD] = m.rawValue
        dayModeByYMD = c
    }

    /// 1...5, default 3 for today
    func energyForToday() -> Int {
        let n = energyByYMD[todayYMD] ?? 3
        return min(5, max(1, n))
    }

    func setEnergyForToday(_ n: Int) {
        var c = energyByYMD
        c[todayYMD] = min(5, max(1, n))
        energyByYMD = c
    }

    func currentISOWeekId() -> String {
        let c = Calendar.current
        let d = Date()
        let y = c.component(.yearForWeekOfYear, from: d)
        let w = c.component(.weekOfYear, from: d)
        return "\(y)-W\(w)"
    }

    func thisWeekDateInterval() -> DateInterval? {
        Calendar.current.dateInterval(of: .weekOfYear, for: Date())
    }

    /// Count focus sessions in the current calendar week; `nil` area = any.
    func focusSessionCountThisWeek(focus: FocusArea?) -> Int {
        guard let interval = thisWeekDateInterval() else { return 0 }
        return history.filter { e in
            guard e.date >= interval.start, e.date < interval.end, e.activityKind == .focus else { return false }
            if let f = focus, e.focusLog != f { return false }
            return true
        }.count
    }

    func saveWeeklyContract(text: String, target: Int, area: FocusArea?) {
        let t = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let tgt = min(20, max(0, target))
        weeklyContractText = t
        weeklyContractTarget = tgt
        weeklyContractAreaRaw = area?.rawValue
        if t.isEmpty || tgt <= 0 {
            weeklyContractSetWeekId = nil
        } else {
            weeklyContractSetWeekId = currentISOWeekId()
        }
    }

    func weeklyContractProgress() -> (done: Int, target: Int, isActive: Bool) {
        let t = max(0, weeklyContractTarget)
        guard
            t > 0,
            !weeklyContractText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
            let wid = weeklyContractSetWeekId,
            wid == currentISOWeekId()
        else { return (0, t, false) }
        let area = weeklyContractAreaRaw.flatMap { FocusArea(rawValue: $0) }
        return (focusSessionCountThisWeek(focus: area), t, true)
    }

    func focusReminderBody() -> String {
        let m = dayModeForToday() ?? .deep
        return "Time to start a focus session. \(m.focusReminderLine)"
    }

    func appendDayClose(didMain: Bool, deferred: String) {
        let note = deferred.trimmingCharacters(in: .whitespacesAndNewlines)
        let e = DayCloseEntry(
            id: UUID(),
            dayYMD: todayYMD,
            didMain: didMain,
            deferred: note,
            savedAt: Date()
        )
        var a = dayCloseHistory.filter { $0.dayYMD != todayYMD }
        a.insert(e, at: 0)
        if a.count > 100 { a = Array(a.prefix(100)) }
        dayCloseHistory = a
    }

    func dayCloseForToday() -> DayCloseEntry? {
        dayCloseHistory.first { $0.dayYMD == todayYMD }
    }

    func resetAllProgress() {
        for key in Key.allCases {
            defaults.removeObject(forKey: key.rawValue)
        }
        hasSeenOnboarding = true
        tasksCompleted = 0
        progressScore = 0
        currentStreak = 0
        totalStars = 0
        lastSessionDay = nil
        userTasks = []
        history = []
        focusTargets = [
            .deepWork: 0.35,
            .organization: 0.25,
            .wellBeing: 0.2,
            .learning: 0.2
        ]
        selectedDifficulty = .steady
        unlockedLevelRoutine = 1
        unlockedLevelFocus = 1
        unlockedLevelPriority = 1
        starsGrid = [:]
        defaultLogFocus = .deepWork
        remindFocusOn = false
        focusReminderMinuteOfDay = 9 * 60
        dayReviewOn = false
        dayReviewMinuteOfDay = 18 * 60
        recentFocusDurations = [25, 50, 90]
        dayModeByYMD = [:]
        energyByYMD = [:]
        weeklyContractSetWeekId = nil
        weeklyContractText = ""
        weeklyContractTarget = 0
        weeklyContractAreaRaw = nil
        dayCloseHistory = []
        focusLaunch = nil
        objectWillChange.send()
        NotificationCenter.default.post(name: .appDataDidReset, object: nil)
    }

    // MARK: - Private

    private enum Key: String, CaseIterable {
        case hasSeenOnboarding
        case tasksCompleted
        case progressScore
        case currentStreak
        case totalStars
        case lastSessionDay
        case userTasks
        case history
        case focusTargets
        case selectedDifficulty
        case unlockedLevelRoutine
        case unlockedLevelFocus
        case unlockedLevelPriority
        case starsGrid
        case defaultLogFocus
        case remindFocusOn
        case focusReminderMinuteOfDay
        case dayReviewOn
        case dayReviewMinuteOfDay
        case recentFocusDurations
        case dayModeByYMD
        case energyByYMD
        case weeklyContractSetWeekId
        case weeklyContractText
        case weeklyContractTarget
        case weeklyContractAreaRaw
        case dayCloseHistory
    }

    private func save(_ key: Key, _ value: Bool) {
        defaults.set(value, forKey: key.rawValue)
    }

    private func save(_ key: Key, _ value: Int) {
        defaults.set(value, forKey: key.rawValue)
    }

    private func save(_ key: Key, _ value: Double) {
        defaults.set(value, forKey: key.rawValue)
    }

    private func saveOptional(_ key: Key, _ value: String?) {
        if let value {
            defaults.set(value, forKey: key.rawValue)
        } else {
            defaults.removeObject(forKey: key.rawValue)
        }
    }

    private func saveRaw(_ key: Key, _ value: some RawRepresentable) {
        defaults.set(value.rawValue as? String, forKey: key.rawValue)
    }

    private func saveJSON<T: Encodable>(_ key: Key, _ value: T) {
        do {
            let d = try JSONEncoder().encode(value)
            defaults.set(d, forKey: key.rawValue)
        } catch {
            // Persistent storage best-effort; values are kept in live state if encoding fails.
        }
    }

    private func saveStringKey(_ key: Key, _ value: String) {
        defaults.set(value, forKey: key.rawValue)
    }

    private static func loadJSON<T: Decodable>(key: Key, def: T, defaults: UserDefaults) -> T {
        guard let data = defaults.data(forKey: key.rawValue) else { return def }
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            return def
        }
    }

    private static func loadJSON<T: Decodable>(key: Key, def: T?, defaults: UserDefaults) -> T? {
        guard let data = defaults.data(forKey: key.rawValue) else { return def }
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            return def
        }
    }

    private static func dayString(_ date: Date) -> String {
        let f = DateFormatter()
        f.calendar = Calendar(identifier: .gregorian)
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: date)
    }

    private static func isConsecutiveDay(_ previous: String, _ next: String) -> Bool {
        let f = DateFormatter()
        f.calendar = Calendar(identifier: .gregorian)
        f.dateFormat = "yyyy-MM-dd"
        guard let a = f.date(from: previous), let b = f.date(from: next) else { return false }
        let cal = Calendar.current
        if let t = cal.date(byAdding: .day, value: 1, to: cal.startOfDay(for: a)) {
            return cal.isDate(t, inSameDayAs: b)
        }
        return false
    }

    private static func encodeFocus(_ m: [FocusArea: Double]) -> [String: Double] {
        var d: [String: Double] = [:]
        for (k, v) in m { d[k.rawValue] = v }
        return d
    }

    private static func decodeFocus(_ m: [String: Double]) -> [FocusArea: Double] {
        var out: [FocusArea: Double] = [:]
        for a in FocusArea.allCases {
            if let v = m[a.rawValue] {
                out[a] = v
            }
        }
        if out.isEmpty {
            return [
                .deepWork: 0.35,
                .organization: 0.25,
                .wellBeing: 0.2,
                .learning: 0.2
            ]
        }
        return out
    }

    private static func normalizeStarsGridInPlace(_ g: inout [String: [Int]]) {
        for k in ActivityKind.allCases.map(\.rawValue) {
            if g[k] == nil { g[k] = Array(repeating: 0, count: GameLevels.count) }
            var row = g[k]!
            normalizeStarsArrayInPlace(&row)
            g[k] = row
        }
    }

    private static func normalizeStarsArrayInPlace(_ a: inout [Int]) {
        while a.count < GameLevels.count { a.append(0) }
        if a.count > GameLevels.count {
            a = Array(a.prefix(GameLevels.count))
        }
    }
}
