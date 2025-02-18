//
//  whiskey_noteApp.swift
//  whiskey note
//
//  Created by 이수민 on 2/10/25.
//

import SwiftUI
import SwiftData

@main
struct whiskey_noteApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            TasteNote.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
