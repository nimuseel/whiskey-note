import SwiftUI
import SwiftData

@main
struct whiskey_noteApp: App {
    @Environment(\.scenePhase) private var scenePhase
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
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .background {
                StoreBackupManager.backupOnBackground()
            }
        }
    }

    private func makeContainer() async -> ModelContainer {
        await Task.detached(priority: .userInitiated) {
            // 앱 버전이 바뀐 경우 ModelContainer 초기화 직전에 백업 (마이그레이션 방어)
            StoreBackupManager.backupBeforeMigration()

            do {
                return try ModelContainer(
                    for: WhiskeyNote.self, FlavorIntensity.self,
                    migrationPlan: AppMigrationPlan.self
                )
            } catch {
                // 마이그레이션 실패 → 최신 백업으로 복구 후 재시도
                if StoreBackupManager.restoreLatestBackup() {
                    do {
                        return try ModelContainer(
                            for: WhiskeyNote.self, FlavorIntensity.self,
                            migrationPlan: AppMigrationPlan.self
                        )
                    } catch {
                        fatalError("SwiftData 복구 후에도 초기화 실패: \(error)")
                    }
                }
                fatalError("SwiftData 컨테이너 초기화 실패: \(error)")
            }
        }.value
    }
}
