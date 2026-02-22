//
//  AchievementsView.swift
//  HoldingPattern
//

import SwiftUI
import SwiftData

struct AchievementsView: View {
    @Query(sort: \WaitEvent.endDate, order: .reverse) private var events: [WaitEvent]

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.gradientBackground.ignoresSafeArea()
                let progressList = AchievementEngine.evaluate(events: events)
                ScrollView {
                    VStack(spacing: 20) {
                        summaryHeader(unlocked: progressList.filter(\.isUnlocked).count)
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            ForEach(Array(progressList.enumerated()), id: \.element.id) { index, p in
                                AchievementCard(progress: p, staggerDelay: Double(index) * 0.05)
                            }
                        }
                        .padding(.horizontal, 12)
                    }
                    .padding(.vertical, 20)
                    .padding(.bottom, 32)
                }
                .scrollIndicators(.hidden)
            }
            .navigationTitle(String(localized: "Achievements"))
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(AppTheme.backgroundMid, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }

    private func summaryHeader(unlocked: Int) -> some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .stroke(AppTheme.backgroundCard, lineWidth: 6)
                    .frame(width: 64, height: 64)
                Circle()
                    .trim(from: 0, to: CGFloat(unlocked) / 10)
                    .stroke(
                        AngularGradient(
                            colors: [AppTheme.accentPrimary, AppTheme.accentLight, AppTheme.accentPrimary],
                            center: .center
                        ),
                        style: StrokeStyle(lineWidth: 6, lineCap: .round)
                    )
                    .frame(width: 64, height: 64)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeOut(duration: 0.9), value: unlocked)
                Text("\(unlocked)/10")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(AppTheme.textPrimary)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(String(localized: "ach_progress"))
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.textSecondary)
                Text(unlocked == 10 ? String(localized: "ach_all_done") : String(localized: "ach_keep_going"))
                    .font(.caption)
                    .foregroundStyle(AppTheme.textMuted)
            }
            Spacer()
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(AppTheme.backgroundCard.opacity(0.8))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(AppTheme.accentPrimary.opacity(0.3), lineWidth: 1)
                )
        )
        .padding(.horizontal, 16)
    }
}

struct AchievementCard: View {
    let progress: AchievementProgress
    var staggerDelay: Double = 0
    @State private var appeared = false

    var body: some View {
        let unlocked = progress.isUnlocked
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .stroke(AppTheme.backgroundMid, lineWidth: 4)
                    .frame(width: 52, height: 52)
                Circle()
                    .trim(from: 0, to: progress.target > 0 ? min(1, CGFloat(progress.current) / CGFloat(progress.target)) : 0)
                    .stroke(unlocked ? AppTheme.positive : AppTheme.accentPrimary.opacity(0.7), style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .frame(width: 52, height: 52)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeOut(duration: 0.7), value: progress.current)
                Image(systemName: progress.id.icon)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(unlocked ? AppTheme.positive : AppTheme.textMuted)
            }
            .scaleEffect(appeared ? 1 : 0.5)
            .opacity(appeared ? 1 : 0)

            Text(String(localized: String.LocalizationValue(progress.id.titleKey)))
                .font(.caption.weight(.semibold))
                .foregroundStyle(unlocked ? AppTheme.textPrimary : AppTheme.textMuted)
                .multilineTextAlignment(.center)
                .lineLimit(2)

            if progress.target > 1 {
                Text("\(progress.current)/\(progress.target)")
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                    .foregroundStyle(AppTheme.textMuted)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .padding(.horizontal, 8)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(AppTheme.backgroundCard)
                RoundedRectangle(cornerRadius: 20)
                    .stroke(unlocked ? AppTheme.positive.opacity(0.4) : AppTheme.textMuted.opacity(0.2), lineWidth: 1)
            }
        )
        .onAppear {
            withAnimation(AppAnimations.springBouncy.delay(staggerDelay)) {
                appeared = true
            }
        }
    }
}
