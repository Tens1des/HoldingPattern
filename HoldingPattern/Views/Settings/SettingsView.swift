//
//  SettingsView.swift
//  HoldingPattern
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("didCompleteOnboarding") private var didCompleteOnboarding = false
    @AppStorage("appLanguage") private var appLanguage = "en"
    @AppStorage("userAvatar") private var userAvatar = SystemAvatar.personCircle.rawValue
    @AppStorage("userNickname") private var userNickname = ""
    @State private var showOnboardingAgain = false
    @State private var showAvatarPicker = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.gradientBackground.ignoresSafeArea()
                List {
                    Section {
                        HStack(spacing: 20) {
                            Button {
                                showAvatarPicker = true
                            } label: {
                                ZStack {
                                    Circle()
                                        .fill(AppTheme.backgroundCard)
                                        .frame(width: 64, height: 64)
                                    Circle()
                                        .stroke(AppTheme.accentPrimary.opacity(0.5), lineWidth: 2)
                                        .frame(width: 64, height: 64)
                                    Image(systemName: userAvatar)
                                        .font(.system(size: 30))
                                        .foregroundStyle(AppTheme.accentPrimary)
                                }
                            }
                            .buttonStyle(.plain)
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Nickname", bundle: .main)
                                    .font(.caption)
                                    .foregroundStyle(AppTheme.textMuted)
                                TextField("", text: $userNickname, prompt: Text("Your name or nickname").foregroundStyle(AppTheme.textMuted))
                                    .textFieldStyle(.plain)
                                    .foregroundStyle(AppTheme.textPrimary)
                                    .font(.body.weight(.medium))
                            }
                            Spacer()
                        }
                        .padding(.vertical, 8)
                    } header: {
                        Text("Profile", bundle: .main)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                    .listRowBackground(AppTheme.backgroundCard)
                    .listRowSeparatorTint(AppTheme.textMuted.opacity(0.25))
                    .listRowInsets(EdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16))

                    Section {
                        Picker("Language", selection: $appLanguage) {
                            Text("English", bundle: .main).tag("en")
                            Text("Русский", bundle: .main).tag("ru")
                        }
                        .pickerStyle(.menu)
                        .foregroundStyle(AppTheme.textPrimary)
                    } header: {
                        Text("Language", bundle: .main)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                    .listRowBackground(AppTheme.backgroundCard)
                    .listRowSeparatorTint(AppTheme.textMuted.opacity(0.25))
                    .listRowInsets(EdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16))

                    Section {
                        Button {
                            didCompleteOnboarding = false
                            showOnboardingAgain = true
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: "arrow.clockwise.circle")
                                    .font(.system(size: 20))
                                    .foregroundStyle(AppTheme.accentPrimary)
                                Text("Replay Onboarding", bundle: .main)
                                    .foregroundStyle(AppTheme.textPrimary)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(AppTheme.textMuted)
                            }
                        }
                        .listRowBackground(AppTheme.backgroundCard)
                        .listRowSeparatorTint(AppTheme.textMuted.opacity(0.25))
                        .listRowInsets(EdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16))
                    } header: {
                        Text("Onboarding", bundle: .main)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(AppTheme.backgroundMid, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .fullScreenCover(isPresented: $showOnboardingAgain) {
                OnboardingView(didCompleteOnboarding: $didCompleteOnboarding)
                    .onDisappear {
                        if didCompleteOnboarding {
                            showOnboardingAgain = false
                        }
                    }
            }
            .onChange(of: didCompleteOnboarding) { _, completed in
                if completed && showOnboardingAgain {
                    showOnboardingAgain = false
                }
            }
            .sheet(isPresented: $showAvatarPicker) {
                AvatarPickerView(selectedAvatar: $userAvatar)
            }
        }
    }
}
