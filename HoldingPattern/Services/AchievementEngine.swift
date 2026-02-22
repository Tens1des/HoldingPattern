//
//  AchievementEngine.swift
//  HoldingPattern
//

import Foundation

enum AchievementEngine {
    private static let calendar = Calendar.current

    static func evaluate(events: [WaitEvent]) -> [AchievementProgress] {
        AchievementId.allCases.map { id in
            progress(for: id, events: events)
        }
    }

    private static func progress(for id: AchievementId, events: [WaitEvent]) -> AchievementProgress {
        switch id {
        case .firstStep:
            let n = events.count
            return AchievementProgress(id: id, current: n, target: 1, isUnlocked: n >= 1, unlockedAt: nil)
        case .gettingStarted:
            let n = events.count
            return AchievementProgress(id: id, current: min(n, 10), target: 10, isUnlocked: n >= 10, unlockedAt: nil)
        case .centurion:
            let n = events.count
            return AchievementProgress(id: id, current: min(n, 100), target: 100, isUnlocked: n >= 100, unlockedAt: nil)
        case .marathon:
            let hasMarathon = events.contains { $0.durationSeconds >= 60 * 60 }
            return AchievementProgress(id: id, current: hasMarathon ? 1 : 0, target: 1, isUnlocked: hasMarathon, unlockedAt: nil)
        case .speedster:
            let hasShort = events.contains { $0.durationSeconds < 10 && $0.durationSeconds > 0 }
            return AchievementProgress(id: id, current: hasShort ? 1 : 0, target: 1, isUnlocked: hasShort, unlockedAt: nil)
        case .weekWarrior:
            let uniqueDays = Set(events.map { calendar.startOfDay(for: $0.endDate) })
            let target = 7
            return AchievementProgress(id: id, current: min(uniqueDays.count, target), target: target, isUnlocked: uniqueDays.count >= target, unlockedAt: nil)
        case .allRounder:
            let systemIds = ["physical", "digital", "social", "decision", "passive_idle"]
            let used = Set(events.map(\.categoryId)).intersection(Set(systemIds))
            return AchievementProgress(id: id, current: used.count, target: 5, isUnlocked: used.count >= 5, unlockedAt: nil)
        case .timeSaver:
            let (thisWeek, lastWeek) = weekTotals(events: events)
            let saved = lastWeek > 0 && thisWeek < lastWeek
            return AchievementProgress(id: id, current: saved ? 1 : 0, target: 1, isUnlocked: saved, unlockedAt: nil)
        case .nightOwl:
            let hasNight = events.contains { e in
                let h = calendar.component(.hour, from: e.endDate)
                return h >= 22 || h < 6
            }
            return AchievementProgress(id: id, current: hasNight ? 1 : 0, target: 1, isUnlocked: hasNight, unlockedAt: nil)
        case .earlyBird:
            let hasEarly = events.contains { e in
                let h = calendar.component(.hour, from: e.endDate)
                return h >= 5 && h < 8
            }
            return AchievementProgress(id: id, current: hasEarly ? 1 : 0, target: 1, isUnlocked: hasEarly, unlockedAt: nil)
        }
    }

    private static func weekTotals(events: [WaitEvent]) -> (TimeInterval, TimeInterval) {
        let now = Date()
        let thisWeekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))!
        let lastWeekStart = calendar.date(byAdding: .weekOfYear, value: -1, to: thisWeekStart)!
        let thisWeek = events.filter { $0.endDate >= thisWeekStart }.reduce(0.0) { $0 + $1.durationSeconds }
        let lastWeek = events.filter { $0.endDate >= lastWeekStart && $0.endDate < thisWeekStart }.reduce(0.0) { $0 + $1.durationSeconds }
        return (thisWeek, lastWeek)
    }
}
