import SwiftUI
import SwiftData

@main
struct whiskey_noteApp: App {
    @State private var container: ModelContainer?

    var body: some Scene {
        WindowGroup {
            if let container {
                ContentView()
                    .onAppear {
                        if ProcessInfo.processInfo.arguments.contains("-SCREENSHOT_MODE") {
                            ScreenshotSeedData.seed(into: container.mainContext)
                        }
                    }
                    .modelContainer(container)
            } else {
                MigrationLoadingView()
                    .task {
                        container = await makeContainer()
                    }
            }
        }
    }

    private func makeContainer() async -> ModelContainer {
        await Task.detached(priority: .userInitiated) {
            do {
                // ModelConfiguration 이름을 명시하지 않아야
                // 구버전이 사용하던 default.store를 그대로 이어받음
                return try ModelContainer(
                    for: WhiskeyNote.self, FlavorIntensity.self,
                    migrationPlan: AppMigrationPlan.self
                )
            } catch {
                fatalError("SwiftData 컨테이너 초기화 실패: \(error)")
            }
        }.value
    }
}
