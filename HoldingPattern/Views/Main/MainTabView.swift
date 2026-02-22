//
//  MainTabView.swift
//  HoldingPattern
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            MainHoldView(selectedTab: $selectedTab)
                .tabItem {
                    Label("Hold", systemImage: "play.circle.fill")
                }
                .tag(0)
            NavigationStack {
                AnalyticsDashboardView()
            }
            .tabItem {
                Label("Analytics", systemImage: "chart.bar.doc.horizontal")
            }
            .tag(1)
            HistoryView()
                .tabItem {
                    Label("History", systemImage: "clock.arrow.circlepath")
                }
            .tag(2)
            AchievementsView()
                .tabItem {
                    Label("Achievements", systemImage: "trophy.fill")
                }
            .tag(3)
            CategoriesView()
                .tabItem {
                    Label("Categories", systemImage: "folder.fill")
                }
            .tag(4)
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
            .tag(5)
        }
        .tint(AppTheme.accentPrimary)
        .onAppear {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor(AppTheme.backgroundMid)
            appearance.stackedLayoutAppearance.normal.iconColor = UIColor(AppTheme.textMuted)
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor(AppTheme.textMuted)]
            appearance.stackedLayoutAppearance.selected.iconColor = UIColor(AppTheme.accentPrimary)
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor(AppTheme.accentPrimary)]
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}
