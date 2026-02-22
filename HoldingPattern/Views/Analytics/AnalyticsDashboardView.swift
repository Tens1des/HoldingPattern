//
//  AnalyticsDashboardView.swift
//  HoldingPattern
//

import SwiftUI
import SwiftData

struct AnalyticsDashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \WaitEvent.endDate, order: .reverse) private var events: [WaitEvent]
    @Query private var categories: [WaitCategoryModel]
    @State private var cardsAppeared = false

    var body: some View {
        let snapshot = AnalyticsEngine.snapshot(events: events, categories: categories)
        ScrollView {
            VStack(spacing: 20) {
                lifeLeakageCard(snapshot.lifeLeakage)
                    .analyticsCardAppear(show: cardsAppeared, delay: 0)
                fragmentationDriftCard(snapshot)
                    .analyticsCardAppear(show: cardsAppeared, delay: 1)
                expensiveWaitsCard(snapshot.expensiveWaits)
                    .analyticsCardAppear(show: cardsAppeared, delay: 2)
                peakHoursCard(snapshot.peakHours)
                    .analyticsCardAppear(show: cardsAppeared, delay: 3)
                reclaimableCard(snapshot.reclaimableTimeSeconds)
                    .analyticsCardAppear(show: cardsAppeared, delay: 4)
                recurringClustersCard(snapshot.recurringClusters)
                    .analyticsCardAppear(show: cardsAppeared, delay: 5)
                edgeCasesCard(snapshot.edgeCases)
                    .analyticsCardAppear(show: cardsAppeared, delay: 6)
                comparativeCard(snapshot.comparative)
                    .analyticsCardAppear(show: cardsAppeared, delay: 7)
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 32)
        }
        .scrollIndicators(.hidden)
        .background(AppTheme.gradientBackground)
        .navigationTitle(String(localized: "Analytics"))
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(AppTheme.backgroundMid, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .onAppear {
            withAnimation(AppAnimations.springSmooth.delay(0.08)) {
                cardsAppeared = true
            }
        }
    }

    private func lifeLeakageCard(_ r: LifeLeakageResult) -> some View {
        Card(title: String(localized: "Life Leakage"), icon: "drop.fill", accentColor: AppTheme.accentPrimary) {
            VStack(alignment: .leading, spacing: 12) {
                row(String(localized: "Total Waiting Time"), value: formatDuration(r.totalWaitingTimeSeconds))
                row(String(localized: "Time Lost This Month"), value: formatDuration(r.timeLostThisMonthSeconds))
                row(String(localized: "Today %"), value: String(format: "%.1f%%", r.percentOfDay))
                row(String(localized: "This Week %"), value: String(format: "%.1f%%", r.percentOfWeek))
            }
        }
    }

    private func fragmentationDriftCard(_ s: AnalyticsSnapshot) -> some View {
        Card(title: String(localized: "Patterns"), icon: "waveform.path.ecg", accentColor: AppTheme.warning) {
            VStack(alignment: .leading, spacing: 12) {
                row(String(localized: "Fragmentation Index"), value: String(format: "%.1f", s.fragmentationIndex))
                row(String(localized: "Life in Holding %"), value: String(format: "%.1f%%", s.driftIndex))
                if let h = s.peakDelayHour {
                    row(String(localized: "Peak Delay Hour"), value: "\(h):00")
                }
            }
        }
    }

    private func expensiveWaitsCard(_ list: [ExpensiveWaitItem]) -> some View {
        Card(title: String(localized: "Expensive Waits"), icon: "flame.fill", accentColor: AppTheme.warning) {
            if list.isEmpty {
                Text("No data yet", bundle: .main)
                    .foregroundStyle(AppTheme.textMuted)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                ForEach(list.prefix(5)) { item in
                    HStack {
                        Text(item.categoryName)
                            .foregroundStyle(AppTheme.textPrimary)
                        Spacer()
                        Text("\(item.frequency)× • \(formatDuration(item.totalDurationSeconds))")
                            .font(.caption)
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                }
            }
        }
    }

    private func peakHoursCard(_ slots: [PeakHourSlot]) -> some View {
        Card(title: String(localized: "Peak Hours"), icon: "chart.bar.fill", accentColor: AppTheme.accentPrimary) {
            VStack(alignment: .leading, spacing: 8) {
                let maxSec = slots.map(\.totalSeconds).max() ?? 1
                ForEach(slots) { slot in
                    HStack {
                        Text(periodName(slot.period))
                            .foregroundStyle(AppTheme.textPrimary)
                            .frame(width: 80, alignment: .leading)
                        GeometryReader { geo in
                            RoundedRectangle(cornerRadius: 6)
                                .fill(
                                    LinearGradient(
                                        colors: [AppTheme.accentPrimary, AppTheme.accentLight.opacity(0.8)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: max(6, geo.size.width * CGFloat(slot.totalSeconds / maxSec)))
                        }
                        .frame(height: 20)
                        Text(formatDuration(slot.totalSeconds))
                            .font(.caption)
                            .foregroundStyle(AppTheme.textSecondary)
                            .frame(width: 50, alignment: .trailing)
                    }
                }
            }
        }
    }

    private func reclaimableCard(_ sec: TimeInterval) -> some View {
        Card(title: String(localized: "Reclaimable Time"), icon: "arrow.uturn.backward", accentColor: AppTheme.positive) {
            Text("Waits ≥5 min total: \(formatDuration(sec))")
                .foregroundStyle(AppTheme.textSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func recurringClustersCard(_ list: [RecurringDelayCluster]) -> some View {
        Card(title: String(localized: "Recurring Delays"), icon: "repeat", accentColor: AppTheme.accentLight) {
            if list.isEmpty {
                Text("No recurring patterns yet", bundle: .main)
                    .foregroundStyle(AppTheme.textMuted)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                ForEach(list.prefix(5)) { c in
                    HStack {
                        Text(c.categoryName)
                            .foregroundStyle(AppTheme.textPrimary)
                        Spacer()
                        Text("\(c.frequency)× • avg \(formatDuration(c.avgDurationSeconds))")
                            .font(.caption)
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                }
            }
        }
    }

    private func edgeCasesCard(_ e: EdgeCaseMetrics) -> some View {
        Card(title: String(localized: "Edge Cases"), icon: "exclamationmark.triangle", accentColor: AppTheme.warning) {
            VStack(alignment: .leading, spacing: 8) {
                row(String(localized: "Ultra Short (<10 sec)"), value: "\(e.ultraShortCount)")
                row(String(localized: "Marathon (>60 min)"), value: "\(e.marathonCount)")
                row(String(localized: "Chain Waiting"), value: "\(e.chainCount)")
            }
        }
    }

    private func comparativeCard(_ c: ComparativeResult?) -> some View {
        Card(title: String(localized: "Comparison"), icon: "arrow.left.arrow.right", accentColor: AppTheme.accentPrimary) {
            VStack(alignment: .leading, spacing: 8) {
                if let growth = c?.weekOverWeekGrowthRate {
                    row(String(localized: "Week vs Week"), value: String(format: "%+.1f%%", growth))
                }
                if let name = c?.mostImprovedCategoryName, !name.isEmpty {
                    row(String(localized: "Most Improved"), value: localizedCategoryName(name))
                }
                if let ratio = c?.morningVsEveningRatio {
                    row(String(localized: "Morning / Evening"), value: String(format: "%.2f", ratio))
                }
                if let list = c?.categoryGrowth, !list.isEmpty {
                    Text(String(localized: "Category vs Category"))
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(AppTheme.textSecondary)
                        .padding(.top, 4)
                    ForEach(list.prefix(5)) { item in
                        HStack {
                            Text(localizedCategoryName(item.categoryName))
                                .foregroundStyle(AppTheme.textPrimary)
                            Spacer()
                            Text(String(format: "%+.0f%%", item.growthRatePercent))
                                .font(.caption)
                                .foregroundStyle(item.growthRatePercent <= 0 ? AppTheme.accentLight : AppTheme.textSecondary)
                        }
                    }
                }
                if c == nil || (c?.weekOverWeekGrowthRate == nil && c?.morningVsEveningRatio == nil && (c?.categoryGrowth.isEmpty ?? true)) {
                    Text("Not enough data", bundle: .main)
                        .foregroundStyle(AppTheme.textMuted)
                }
            }
        }
    }

    private func localizedCategoryName(_ name: String) -> String {
        if name.hasPrefix("category_") {
            return String(localized: String.LocalizationValue(name))
        }
        return name
    }

    private func periodName(_ p: DayPeriod) -> String {
        switch p {
        case .morning: return String(localized: "Morning")
        case .day: return String(localized: "Day")
        case .evening: return String(localized: "Evening")
        case .night: return String(localized: "Night")
        }
    }

    private func row(_ label: String, value: String) -> some View {
        HStack {
            Text(label)
                .foregroundStyle(AppTheme.textSecondary)
            Spacer()
            Text(value)
                .foregroundStyle(AppTheme.textPrimary)
        }
    }

    private func formatDuration(_ sec: TimeInterval) -> String {
        let totalSec = Int(sec)
        let h = totalSec / 3600
        let m = (totalSec % 3600) / 60
        if h > 0 {
            return String(format: "%dh %02dm", h, m)
        }
        if totalSec < 60 {
            return String(format: "%d sec", totalSec)
        }
        return String(format: "%d min", m)
    }
}

struct Card<Content: View>: View {
    let title: String
    var icon: String? = nil
    var accentColor: Color = AppTheme.accentPrimary
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(accentColor)
                }
                Text(title)
                    .font(.headline)
                    .foregroundStyle(AppTheme.textPrimary)
            }
            content
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 16)
                    .fill(AppTheme.backgroundCard)
                RoundedRectangle(cornerRadius: 16)
                    .fill(AppTheme.gradientCardGlow)
                RoundedRectangle(cornerRadius: 16)
                    .stroke(accentColor.opacity(0.2), lineWidth: 1)
            }
        )
    }
}

private extension View {
    func analyticsCardAppear(show: Bool, delay: Int) -> some View {
        opacity(show ? 1 : 0)
            .offset(y: show ? 0 : 18)
            .animation(AppAnimations.springSmooth.delay(Double(delay) * 0.05), value: show)
    }
}
