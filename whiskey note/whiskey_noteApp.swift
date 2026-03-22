import SwiftUI
import SwiftData

@main
struct whiskey_noteApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [WhiskeyNote.self, FlavorIntensity.self])
    }
}
