//
//  OnboardingView.swift
//  HoldingPattern
//

import SwiftUI

struct OnboardingView: View {
    @Binding var didCompleteOnboarding: Bool
    @State private var page = 0
    @State private var iconScale: CGFloat = 0.5
    private let totalPages = 3

    var body: some View {
        ZStack {
            AppTheme.gradientBackground.ignoresSafeArea()
            VStack(spacing: 0) {
                TabView(selection: $page) {
                    page1.tag(0)
                    page2.tag(1)
                    page3.tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.35), value: page)

                pageIndicator
                    .animation(AppAnimations.springSnappy, value: page)
                primaryButton
            }
        }
    }

    private var pageIndicator: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalPages, id: \.self) { i in
                Capsule()
                    .fill(page == i ? AppTheme.accentPrimary : AppTheme.backgroundCard)
                    .frame(width: page == i ? 24 : 8, height: 8)
            }
        }
        .padding(.top, 24)
    }

    private var primaryButton: some View {
        Button {
            if page < totalPages - 1 {
                iconScale = 0.5
                withAnimation(AppAnimations.springSnappy) { page += 1 }
                withAnimation(AppAnimations.springBouncy.delay(0.2)) {
                    iconScale = 1
                }
            } else {
                didCompleteOnboarding = true
            }
        } label: {
            Text(page < totalPages - 1 ? String(localized: "Next") : String(localized: "Get Started"))
                .font(.headline.weight(.semibold))
                .foregroundStyle(AppTheme.backgroundDeep)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(AppTheme.accentPrimary)
                        .shadow(color: AppTheme.accentPrimary.opacity(0.4), radius: 12, y: 4)
                )
        }
        .buttonStyle(ScaleButtonStyle(minScale: 0.97))
        .padding(.horizontal, 24)
        .padding(.top, 24)
        .padding(.bottom, 48)
    }

    private var page1: some View {
        ScrollView {
            VStack(spacing: 24) {
                Spacer(minLength: 24)
                ZStack {
                    Circle()
                        .fill(AppTheme.backgroundCard)
                        .frame(width: 140, height: 140)
                        .overlay(Circle().stroke(AppTheme.accentPrimary.opacity(0.3), lineWidth: 2))
                    Image(systemName: "clock.badge.checkmark")
                        .font(.system(size: 56))
                        .foregroundStyle(AppTheme.accentPrimary)
                }
                .scaleEffect(page == 0 ? iconScale : 0.9)
                .opacity(page == 0 ? 1 : 0.6)
                .animation(page == 0 ? AppAnimations.springBouncy : .easeOut(duration: 0.2), value: page)
                .onAppear {
                    if page == 0 {
                        withAnimation(AppAnimations.springBouncy.delay(0.2)) { iconScale = 1 }
                    }
                }
                Text("Track Waiting Time", bundle: .main)
                    .font(.title.bold())
                    .foregroundStyle(AppTheme.textPrimary)
                    .multilineTextAlignment(.center)
                Text("Log every moment you spend waiting — for elevators, replies, loading screens, people or decisions.")
                    .font(.body)
                    .foregroundStyle(AppTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                Spacer(minLength: 24)
            }
        }
        .scrollIndicators(.hidden)
    }

    private var page2: some View {
        ScrollView {
            VStack(spacing: 24) {
                Spacer(minLength: 24)
                ZStack {
                    Circle()
                        .fill(AppTheme.backgroundCard)
                        .frame(width: 140, height: 140)
                        .overlay(Circle().stroke(AppTheme.accentLight.opacity(0.3), lineWidth: 2))
                    Image(systemName: "chart.bar.doc.horizontal")
                        .font(.system(size: 56))
                        .foregroundStyle(AppTheme.accentLight)
                }
                .scaleEffect(page == 1 ? iconScale : 0.9)
                .opacity(page == 1 ? 1 : 0.6)
                .animation(AppAnimations.springBouncy, value: iconScale)
                Text("See Patterns")
                    .font(.title.bold())
                    .foregroundStyle(AppTheme.textPrimary)
                    .multilineTextAlignment(.center)
                Text("Discover peak delay hours, fragmentation index, and which types of waiting consume the most time.")
                    .font(.body)
                    .foregroundStyle(AppTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                Spacer(minLength: 24)
            }
        }
        .scrollIndicators(.hidden)
    }

    private var page3: some View {
        ScrollView {
            VStack(spacing: 24) {
                Spacer(minLength: 24)
                ZStack {
                    Circle()
                        .fill(AppTheme.backgroundCard)
                        .frame(width: 140, height: 140)
                        .overlay(Circle().stroke(AppTheme.accentPrimary.opacity(0.3), lineWidth: 2))
                    Image(systemName: "lock.shield")
                        .font(.system(size: 56))
                        .foregroundStyle(AppTheme.accentPrimary)
                }
                .scaleEffect(page == 2 ? iconScale : 0.9)
                .opacity(page == 2 ? 1 : 0.6)
                .animation(AppAnimations.springBouncy, value: iconScale)
                Text("Fully Offline")
                    .font(.title.bold())
                    .foregroundStyle(AppTheme.textPrimary)
                    .multilineTextAlignment(.center)
                Text("No accounts. No tracking. All data stays on your device.")
                    .font(.body)
                    .foregroundStyle(AppTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                Spacer(minLength: 24)
            }
        }
        .scrollIndicators(.hidden)
    }
}
