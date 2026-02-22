//
//  MainHoldView.swift
//  HoldingPattern
//

import SwiftUI
import SwiftData

struct MainHoldView: View {
    @Binding var selectedTab: Int
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \WaitEvent.endDate, order: .reverse) private var events: [WaitEvent]
    @Query private var categories: [WaitCategoryModel]
    @StateObject private var holdManager = HoldSessionManager()
    @State private var showCategoryPicker = false
    @State private var selectedCategoryId: String?
    @State private var mainAppeared = false

    private var todayStats: (seconds: TimeInterval, count: Int) {
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let today = events.filter { $0.endDate >= startOfDay }
        let total = today.reduce(0.0) { $0 + $1.durationSeconds }
        return (total, today.count)
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                AppTheme.gradientBackground.ignoresSafeArea()
                spotlightBehindButton(in: geo)
                VStack(spacing: 0) {
                    todayCard
                        .opacity(mainAppeared ? 1 : 0)
                        .offset(y: mainAppeared ? 0 : 12)
                    Spacer(minLength: 20)
                    HoldButtonView(
                        isHolding: holdManager.isHolding,
                        currentDuration: holdManager.currentDuration,
                        onStart: { holdManager.startHold() },
                        onEnd: { showCategoryPicker = true }
                    )
                    .frame(maxWidth: .infinity)
                    .opacity(mainAppeared ? 1 : 0)
                    .scaleEffect(mainAppeared ? 1 : 0.85)
                    if holdManager.isHolding {
                        Button {
                            holdManager.cancelHold()
                        } label: {
                            Text("Cancel", bundle: .main)
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(AppTheme.textMuted)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                        }
                        .padding(.top, 12)
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .scale(scale: 0.9)),
                            removal: .opacity.combined(with: .scale(scale: 0.9))
                        ))
                    }
                    Spacer(minLength: 28)
                    quickActionsStrip
                        .opacity(mainAppeared ? 1 : 0)
                        .offset(y: mainAppeared ? 0 : 20)
                }
                .animation(AppAnimations.springSmooth, value: holdManager.isHolding)
                .padding(.top, geo.safeAreaInsets.top + 16)
                .padding(.horizontal, 20)
                .padding(.bottom, geo.safeAreaInsets.bottom + 24)
            }
        }
        .sheet(isPresented: $showCategoryPicker) {
            categoryPickerSheet
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .onChange(of: showCategoryPicker) { _, isPresented in
            if !isPresented && holdManager.isHolding {
                holdManager.cancelHold()
            }
        }
        .onAppear {
            if categories.isEmpty {
                insertSystemCategories()
            }
            if selectedCategoryId == nil, let first = categories.first {
                selectedCategoryId = first.id
            }
            withAnimation(AppAnimations.springSmooth.delay(0.1)) {
                mainAppeared = true
            }
        }
    }

    private func spotlightBehindButton(in geo: GeometryProxy) -> some View {
        Circle()
            .fill(AppTheme.gradientSpotlight)
            .frame(width: 400, height: 400)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .offset(y: -20)
    }

    private var todayCard: some View {
        let (sec, count) = todayStats
        let min = Int(sec) / 60
        return HStack(spacing: 14) {
            Image(systemName: "clock.badge.checkmark")
                .font(.system(size: 26, weight: .medium))
                .foregroundStyle(AppTheme.accentPrimary)
                .frame(width: 40, height: 40, alignment: .center)
            VStack(alignment: .leading, spacing: 4) {
                Text("Today", bundle: .main)
                    .font(.caption)
                    .foregroundStyle(AppTheme.textMuted)
                Text("\(min) min · \(count) \(count == 1 ? String(localized: "wait_one") : String(localized: "wait_many"))")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppTheme.textPrimary)
            }
            Spacer(minLength: 0)
        }
        .padding(.leading, 20)
        .padding(.trailing, 20)
        .padding(.vertical, 16)
        .background(
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 18)
                    .fill(AppTheme.backgroundCard.opacity(0.95))
                RoundedRectangle(cornerRadius: 18)
                    .stroke(AppTheme.accentPrimary.opacity(0.18), lineWidth: 1)
                RoundedRectangle(cornerRadius: 2)
                    .fill(
                        LinearGradient(
                            colors: [AppTheme.accentPrimary, AppTheme.accentLight.opacity(0.8)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 4)
                    .padding(.leading, 12)
                    .padding(.vertical, 12)
            }
        )
        .padding(.bottom, 12)
    }

    private var quickActionsStrip: some View {
        HStack(spacing: 0) {
            QuickActionTile(icon: "chart.bar.doc.horizontal", label: String(localized: "Analytics")) {
                selectedTab = 1
            }
            QuickActionTile(icon: "clock.arrow.circlepath", label: String(localized: "History")) {
                selectedTab = 2
            }
            QuickActionTile(icon: "trophy.fill", label: String(localized: "Achievements")) {
                selectedTab = 3
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(AppTheme.backgroundCard.opacity(0.9))
                .overlay(
                    RoundedRectangle(cornerRadius: 22)
                        .stroke(AppTheme.accentPrimary.opacity(0.2), lineWidth: 1)
                )
        )
    }

    private var categoryPickerSheet: some View {
        NavigationStack {
            ZStack {
                AppTheme.gradientBackground.ignoresSafeArea()
                List {
                    ForEach(categories.sorted(by: { $0.sortOrder < $1.sortOrder })) { cat in
                        Button {
                            selectedCategoryId = cat.id
                            if let start = holdManager.sessionStartDate {
                                let event = WaitEvent(startDate: start, endDate: Date(), categoryId: cat.id)
                                modelContext.insert(event)
                                try? modelContext.save()
                            }
                            holdManager.endSession()
                            showCategoryPicker = false
                        } label: {
                            HStack {
                                Text(localizedName(for: cat))
                                    .foregroundStyle(AppTheme.textPrimary)
                                Spacer()
                                if cat.id == selectedCategoryId {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(AppTheme.accentPrimary)
                                        .transition(.scale.combined(with: .opacity))
                                }
                            }
                        }
                        .buttonStyle(ScaleOnTapStyle())
                        .listRowBackground(AppTheme.backgroundCard)
                        .listRowSeparatorTint(AppTheme.textMuted.opacity(0.3))
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Select Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(AppTheme.backgroundMid, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        holdManager.cancelHold()
                        showCategoryPicker = false
                    }
                    .foregroundStyle(AppTheme.accentPrimary)
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private func insertSystemCategories() {
        for cat in WaitCategoryModel.systemCategories() {
            modelContext.insert(cat)
        }
        try? modelContext.save()
    }

    private func localizedName(for cat: WaitCategoryModel) -> String {
        if cat.kind == .custom {
            return cat.name
        }
        return String(localized: String.LocalizationValue(cat.name))
    }
}

struct QuickActionTile: View {
    let icon: String
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(AppTheme.backgroundMid)
                        .frame(width: 48, height: 48)
                    Circle()
                        .stroke(AppTheme.accentPrimary.opacity(0.4), lineWidth: 1)
                        .frame(width: 48, height: 48)
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(AppTheme.accentPrimary)
                }
                Text(label)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(AppTheme.textSecondary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(ScaleOnTapStyle())
    }
}
