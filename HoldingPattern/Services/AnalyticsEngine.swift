//
//  AnalyticsEngine.swift
//  HoldingPattern
//

import Foundation
import SwiftData

struct LifeLeakageResult {
    var totalWaitingTimeSeconds: TimeInterval
    var percentOfDay: Double
    var percentOfWeek: Double
    var timeLostThisMonthSeconds: TimeInterval
}

struct ExpensiveWaitItem: Identifiable {
    let id: String
    let categoryId: String
    let categoryName: String
    let totalDurationSeconds: TimeInterval
    let frequency: Int
    let waitCost: Double // duration * frequency
}

struct PeakHourSlot: Identifiable {
    let id: String
    let period: DayPeriod
    let totalSeconds: TimeInterval
    let eventCount: Int
}

enum DayPeriod: String, CaseIterable, Identifiable {
    case morning
    case day
    case evening
    case night
    var id: String { rawValue }
}

struct AnalyticsSnapshot {
    var lifeLeakage: LifeLeakageResult
    var expensiveWaits: [ExpensiveWaitItem]
    var peakHours: [PeakHourSlot]
    var fragmentationIndex: Double
    var driftIndex: Double
    var reclaimableTimeSeconds: TimeInterval
    var peakDelayHour: Int?
    var recurringClusters: [RecurringDelayCluster]
    var comparative: ComparativeResult?
    var edgeCases: EdgeCaseMetrics
}

struct RecurringDelayCluster: Identifiable {
    let id: String
    let categoryId: String
    let categoryName: String
    let avgDurationSeconds: TimeInterval
    let frequency: Int
    let lastOccurrence: Date
}

struct CategoryGrowthItem: Identifiable {
    let id: String
    let categoryId: String
    let categoryName: String
    let growthRatePercent: Double
}

struct ComparativeResult {
    var weekOverWeekGrowthRate: Double?
    var mostImprovedCategoryId: String?
    var mostImprovedCategoryName: String?
    var morningVsEveningRatio: Double?
    var categoryGrowth: [CategoryGrowthItem]
}

struct EdgeCaseMetrics {
    var ultraShortCount: Int      // <10 sec
    var marathonCount: Int        // >60 min
    var chainCount: Int           // consecutive waits, gap < 5 min
}

enum AnalyticsEngine {
    private static let calendar = Calendar.current

    static func snapshot(events: [WaitEvent], categories: [WaitCategoryModel], range: DateInterval? = nil) -> AnalyticsSnapshot {
        let range = range ?? DateInterval(start: Self.calendar.date(byAdding: .day, value: -30, to: Date())!, end: Date())
        let filtered = events.filter { range.contains($0.endDate) }
        return AnalyticsSnapshot(
            lifeLeakage: lifeLeakage(events: filtered),
            expensiveWaits: expensiveWaits(events: filtered, categories: categories),
            peakHours: peakHourMapping(events: filtered),
            fragmentationIndex: fragmentationIndex(events: filtered),
            driftIndex: driftIndex(events: filtered),
            reclaimableTimeSeconds: opportunityWindow(events: filtered),
            peakDelayHour: peakDelayHour(events: filtered),
            recurringClusters: delayPatternRecognition(events: filtered, categories: categories),
            comparative: comparative(events: events, categories: categories),
            edgeCases: edgeCases(events: filtered)
        )
    }

    // MARK: - Life Leakage Counter
    static func lifeLeakage(events: [WaitEvent]) -> LifeLeakageResult {
        let total = events.reduce(0.0) { $0 + $1.durationSeconds }
        let now = Date()
        let startOfDay = Self.calendar.startOfDay(for: now)
        let daySeconds = now.timeIntervalSince(startOfDay)
        let dayTotal = events
            .filter { $0.endDate >= startOfDay }
            .reduce(0.0) { $0 + $1.durationSeconds }
        let percentOfDay = daySeconds > 0 ? (dayTotal / daySeconds) * 100 : 0
        let startOfWeek = Self.calendar.date(from: Self.calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))!
        let weekSeconds = now.timeIntervalSince(startOfWeek)
        let weekTotal = events
            .filter { $0.endDate >= startOfWeek }
            .reduce(0.0) { $0 + $1.durationSeconds }
        let percentOfWeek = weekSeconds > 0 ? (weekTotal / weekSeconds) * 100 : 0
        let startOfMonth = Self.calendar.date(from: Self.calendar.dateComponents([.year, .month], from: now))!
        let monthTotal = events
            .filter { $0.endDate >= startOfMonth }
            .reduce(0.0) { $0 + $1.durationSeconds }
        return LifeLeakageResult(
            totalWaitingTimeSeconds: total,
            percentOfDay: percentOfDay,
            percentOfWeek: percentOfWeek,
            timeLostThisMonthSeconds: monthTotal
        )
    }

    // MARK: - Expensive Wait Detector (Duration × Frequency)
    static func expensiveWaits(events: [WaitEvent], categories: [WaitCategoryModel]) -> [ExpensiveWaitItem] {
        let byCategory = Dictionary(grouping: events, by: { $0.categoryId })
        let categoryNames = Dictionary(uniqueKeysWithValues: categories.map { ($0.id, $0.name) })
        return byCategory.map { categoryId, evs in
            let total = evs.reduce(0.0) { $0 + $1.durationSeconds }
            let cost = total * Double(evs.count)
            return ExpensiveWaitItem(
                id: categoryId,
                categoryId: categoryId,
                categoryName: categoryNames[categoryId] ?? categoryId,
                totalDurationSeconds: total,
                frequency: evs.count,
                waitCost: cost
            )
        }
        .sorted { $0.waitCost > $1.waitCost }
    }

    // MARK: - Peak Hour Mapping (Morning / Day / Evening / Night)
    static func peakHourMapping(events: [WaitEvent]) -> [PeakHourSlot] {
        func period(for date: Date) -> DayPeriod {
            let h = Self.calendar.component(.hour, from: date)
            switch h {
            case 5..<12: return .morning
            case 12..<17: return .day
            case 17..<21: return .evening
            default: return .night
            }
        }
        let byPeriod = Dictionary(grouping: events, by: { period(for: $0.endDate) })
        return DayPeriod.allCases.map { period in
            let evs = byPeriod[period] ?? []
            let total = evs.reduce(0.0) { $0 + $1.durationSeconds }
            return PeakHourSlot(id: period.rawValue, period: period, totalSeconds: total, eventCount: evs.count)
        }
    }

    // MARK: - Fragmentation Index (how many times day was interrupted)
    static func fragmentationIndex(events: [WaitEvent]) -> Double {
        let startOfDay = Self.calendar.startOfDay(for: Date())
        let todayEvents = events.filter { $0.endDate >= startOfDay }
        if todayEvents.isEmpty { return 0 }
        let count = todayEvents.count
        let shortPauses = todayEvents.filter { $0.durationSeconds < 60 }.count
        let base = Double(count)
        let compounded = base + Double(shortPauses) * 0.5
        return min(100, compounded * 2.5)
    }

    // MARK: - Psychological Drift ("Life in Holding Pattern %")
    static func driftIndex(events: [WaitEvent]) -> Double {
        let last7 = Self.calendar.date(byAdding: .day, value: -7, to: Date())!
        let recent = events.filter { $0.endDate >= last7 }
        let total = recent.reduce(0.0) { $0 + $1.durationSeconds }
        let weekSeconds: TimeInterval = 7 * 24 * 3600
        let percent = weekSeconds > 0 ? (total / weekSeconds) * 100 : 0
        return min(100, percent)
    }

    // MARK: - Opportunity Window (>5 min = reclaimable)
    static func opportunityWindow(events: [WaitEvent]) -> TimeInterval {
        let threshold: TimeInterval = 5 * 60
        return events
            .filter { $0.durationSeconds >= threshold }
            .reduce(0.0) { $0 + $1.durationSeconds }
    }

    static func peakDelayHour(events: [WaitEvent]) -> Int? {
        let byHour = Dictionary(grouping: events, by: { Self.calendar.component(.hour, from: $0.endDate) })
        return byHour.max(by: { a, b in
            a.value.reduce(0.0) { $0 + $1.durationSeconds } < b.value.reduce(0.0) { $0 + $1.durationSeconds }
        })?.key
    }

    // MARK: - Recurring Delay Clusters
    static func delayPatternRecognition(events: [WaitEvent], categories: [WaitCategoryModel]) -> [RecurringDelayCluster] {
        let byCategory = Dictionary(grouping: events, by: { $0.categoryId })
        let categoryNames = Dictionary(uniqueKeysWithValues: categories.map { ($0.id, $0.name) })
        return byCategory.compactMap { categoryId, evs in
            guard evs.count >= 2 else { return nil }
            let total = evs.reduce(0.0) { $0 + $1.durationSeconds }
            let last = evs.map(\.endDate).max()!
            return RecurringDelayCluster(
                id: categoryId,
                categoryId: categoryId,
                categoryName: categoryNames[categoryId] ?? categoryId,
                avgDurationSeconds: total / Double(evs.count),
                frequency: evs.count,
                lastOccurrence: last
            )
        }
        .sorted { $0.frequency > $1.frequency }
    }

    // MARK: - Comparative (week vs week, category vs category, morning vs evening)
    static func comparative(events: [WaitEvent], categories: [WaitCategoryModel]) -> ComparativeResult? {
        let now = Date()
        let thisWeekStart = Self.calendar.date(from: Self.calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))!
        let lastWeekStart = Self.calendar.date(byAdding: .weekOfYear, value: -1, to: thisWeekStart)!
        let thisWeekEvents = events.filter { $0.endDate >= thisWeekStart }
        let lastWeekEvents = events.filter { $0.endDate >= lastWeekStart && $0.endDate < thisWeekStart }
        let thisWeek = thisWeekEvents.reduce(0.0) { $0 + $1.durationSeconds }
        let lastWeek = lastWeekEvents.reduce(0.0) { $0 + $1.durationSeconds }
        var growth: Double? = nil
        if lastWeek > 0 {
            growth = ((thisWeek - lastWeek) / lastWeek) * 100
        }
        let morning = events.filter { e in
            let h = Self.calendar.component(.hour, from: e.endDate)
            return h >= 5 && h < 12
        }.reduce(0.0) { $0 + $1.durationSeconds }
        let evening = events.filter { e in
            let h = Self.calendar.component(.hour, from: e.endDate)
            return h >= 17 && h < 21
        }.reduce(0.0) { $0 + $1.durationSeconds }
        let ratio = evening > 0 ? morning / evening : nil
        let categoryNames = Dictionary(uniqueKeysWithValues: categories.map { ($0.id, $0.name) })
        var categoryGrowth: [CategoryGrowthItem] = []
        var bestReduction: (categoryId: String, reduction: TimeInterval)? = nil
        let allCategoryIds = Set(thisWeekEvents.map(\.categoryId)).union(lastWeekEvents.map(\.categoryId))
        for categoryId in allCategoryIds {
            let thisCat = thisWeekEvents.filter { $0.categoryId == categoryId }.reduce(0.0) { $0 + $1.durationSeconds }
            let lastCat = lastWeekEvents.filter { $0.categoryId == categoryId }.reduce(0.0) { $0 + $1.durationSeconds }
            let growthPct = lastCat > 0 ? ((thisCat - lastCat) / lastCat) * 100 : (thisCat > 0 ? 100 : 0)
            categoryGrowth.append(CategoryGrowthItem(
                id: categoryId,
                categoryId: categoryId,
                categoryName: categoryNames[categoryId] ?? categoryId,
                growthRatePercent: growthPct
            ))
            let reduction = lastCat - thisCat
            if reduction > 0, bestReduction == nil || reduction > bestReduction!.reduction {
                bestReduction = (categoryId, reduction)
            }
        }
        categoryGrowth.sort { abs($0.growthRatePercent) > abs($1.growthRatePercent) }
        return ComparativeResult(
            weekOverWeekGrowthRate: growth,
            mostImprovedCategoryId: bestReduction?.categoryId,
            mostImprovedCategoryName: bestReduction.map { categoryNames[$0.categoryId] ?? $0.categoryId },
            morningVsEveningRatio: ratio,
            categoryGrowth: categoryGrowth
        )
    }

    // MARK: - Edge Cases (Ultra Short <10s, Marathon >60min, Chain Waiting)
    static func edgeCases(events: [WaitEvent]) -> EdgeCaseMetrics {
        let ultraShort = events.filter { $0.durationSeconds < 10 }.count
        let marathon = events.filter { $0.durationSeconds > 60 * 60 }.count
        let sorted = events.sorted { $0.endDate < $1.endDate }
        var chains = 0
        let gapThreshold: TimeInterval = 5 * 60
        var i = 0
        while i < sorted.count {
            var run = 1
            while i + run < sorted.count {
                let gap = sorted[i + run].startDate.timeIntervalSince(sorted[i + run - 1].endDate)
                if gap <= gapThreshold, gap >= 0 {
                    run += 1
                } else {
                    break
                }
            }
            if run >= 2 { chains += 1 }
            i += run
        }
        return EdgeCaseMetrics(ultraShortCount: ultraShort, marathonCount: marathon, chainCount: chains)
    }
}
