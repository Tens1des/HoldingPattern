//
//  ContentView.swift
//  HoldingPattern
//

import SwiftData
import SwiftUI

struct ContentView: View {
    @AppStorage("didCompleteOnboarding") private var didCompleteOnboarding = false
    @AppStorage("appLanguage") private var appLanguage = "en"

    var body: some View {
        Group {
            if didCompleteOnboarding {
                MainTabView()
            } else {
                OnboardingView(didCompleteOnboarding: $didCompleteOnboarding)
            }
        }
        .environment(\.locale, Locale(identifier: appLanguage))
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [WaitEvent.self, WaitCategoryModel.self], inMemory: true)
}
