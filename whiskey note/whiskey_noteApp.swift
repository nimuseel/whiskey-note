import SwiftUI
import SwiftData

@main
struct whiskey_noteApp: App {
    let container: ModelContainer = {
        let schema = Schema([WhiskeyNote.self, FlavorIntensity.self])
        return try! ModelContainer(for: schema)
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    if ProcessInfo.processInfo.arguments.contains("-SCREENSHOT_MODE") {
                        ScreenshotSeedData.seed(into: container.mainContext)
                    }
                }
        }
        .modelContainer(container)
    }
}
