//
//  HoldingPatternApp.swift
//  HoldingPattern
//

import SwiftUI
import SwiftData

@main
struct HoldingPatternApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([WaitEvent.self, WaitCategoryModel.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: false)
        return try! ModelContainer(for: schema, configurations: [config])
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(sharedModelContainer)
        }
    }
}
