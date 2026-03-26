import SwiftData

enum AppMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [AppSchemaV1.self]
    }

    static var stages: [MigrationStage] {
        // V1이 유일한 버전 — 추후 모델 변경 시 여기에 MigrationStage 추가
        []
    }
}
