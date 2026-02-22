//
//  HistoryView.swift
//  HoldingPattern
//

import SwiftUI
import SwiftData

struct HistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \WaitEvent.endDate, order: .reverse) private var events: [WaitEvent]
    @Query private var categories: [WaitCategoryModel]
    @State private var listAppeared = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.gradientBackground.ignoresSafeArea()
                if events.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 48))
                            .foregroundStyle(AppTheme.textMuted)
                            .scaleEffect(listAppeared ? 1 : 0.8)
                        Text("No waits recorded yet")
                            .font(.headline)
                            .foregroundStyle(AppTheme.textSecondary)
                        Text("Tap Start Hold on the main screen to log waiting time.")
                            .font(.subheadline)
                            .foregroundStyle(AppTheme.textMuted)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .opacity(listAppeared ? 1 : 0)
                } else {
                    List {
                        ForEach(Array(groupedByDate(events).enumerated()), id: \.element.0) { index, item in
                            let (date, dayEvents) = item
                            Section {
                                ForEach(dayEvents) { event in
                                    HistoryRowView(event: event, categoryName: categoryName(for: event.categoryId))
                                }
                                .listRowBackground(AppTheme.backgroundCard)
                                .listRowSeparatorTint(AppTheme.textMuted.opacity(0.25))
                                .listRowInsets(EdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16))
                            } header: {
                                Text(formatSectionDate(date))
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(AppTheme.accentPrimary)
                            }
                            .opacity(listAppeared ? 1 : 0)
                            .offset(x: listAppeared ? 0 : -20)
                            .animation(AppAnimations.springSmooth.delay(Double(index) * 0.04), value: listAppeared)
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .listSectionSpacing(12)
                }
            }
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(AppTheme.backgroundMid, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .onAppear {
                withAnimation(AppAnimations.springSmooth.delay(0.1)) {
                    listAppeared = true
                }
            }
        }
    }

    private func groupedByDate(_ events: [WaitEvent]) -> [(Date, [WaitEvent])] {
        let grouped = Dictionary(grouping: events) { Calendar.current.startOfDay(for: $0.endDate) }
        return grouped.sorted { $0.key > $1.key }.map { ($0.key, $0.value) }
    }

    private func formatSectionDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    private func categoryName(for id: String) -> String {
        if let cat = categories.first(where: { $0.id == id }) {
            return cat.kind == .custom ? cat.name : String(localized: String.LocalizationValue(cat.name))
        }
        return id
    }
}

struct HistoryRowView: View {
    let event: WaitEvent
    let categoryName: String

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(categoryName)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(AppTheme.textPrimary)
                Text(formatTime(event.endDate))
                    .font(.caption)
                    .foregroundStyle(AppTheme.textMuted)
            }
            Spacer()
            Text(formatDuration(event.durationSeconds))
                .font(.subheadline.monospacedDigit().weight(.medium))
                .foregroundStyle(AppTheme.accentPrimary)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(AppTheme.accentPrimary.opacity(0.2))
                .clipShape(Capsule())
        }
        .padding(.vertical, 6)
    }

    private func formatTime(_ date: Date) -> String {
        let f = DateFormatter()
        f.timeStyle = .short
        return f.string(from: date)
    }

    private func formatDuration(_ sec: TimeInterval) -> String {
        let total = Int(sec)
        let m = total / 60
        let s = total % 60
        if m >= 60 {
            let h = m / 60
            return String(format: "%dh %02dm", h, m % 60)
        }
        if total < 60 {
            return String(format: "%d sec", total)
        }
        return String(format: "%d:%02d", m, s)
    }
}
