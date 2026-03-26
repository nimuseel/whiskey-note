import Foundation

/// SwiftData store 파일을 백업하고, 마이그레이션 실패 시 복구한다.
///
/// 백업 시점 두 가지:
/// 1. 앱이 백그라운드 진입 시 (쿨다운 1시간)
/// 2. 앱 버전이 바뀐 첫 실행 시 — ModelContainer 초기화 직전 (마이그레이션 방어)
enum StoreBackupManager {

    // MARK: - 상수

    private static let storeFileName      = "default.store"
    private static let backupDirName      = "StoreBackups"
    private static let maxBackupCount     = 3
    private static let lastVersionKey     = "StoreBackup_lastVersion"

    // MARK: - 경로

    private static var appSupportURL: URL {
        FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
    }

    static var storeURL: URL {
        appSupportURL.appendingPathComponent(storeFileName)
    }

    private static var backupDirURL: URL {
        appSupportURL.appendingPathComponent(backupDirName)
    }

    // MARK: - 트리거 1: 백그라운드 진입 시

    static func backupOnBackground() {
        guard FileManager.default.fileExists(atPath: storeURL.path) else { return }
        if createBackup() {
            pruneOldBackups()
        }
    }

    // MARK: - 트리거 2: 마이그레이션 직전 (버전 변경 시)

    static func backupBeforeMigration() {
        let current = currentVersionString()
        let last    = UserDefaults.standard.string(forKey: lastVersionKey) ?? ""
        guard current != last else { return }

        guard FileManager.default.fileExists(atPath: storeURL.path) else {
            UserDefaults.standard.set(current, forKey: lastVersionKey)
            return
        }

        if createBackup() {
            UserDefaults.standard.set(current, forKey: lastVersionKey)
            pruneOldBackups()
        }
    }

    // MARK: - 복구

    /// 마이그레이션 실패 시 최신 백업으로 store를 덮어씌운다. 성공 여부 반환.
    static func restoreLatestBackup() -> Bool {
        let fm = FileManager.default
        guard let timestamp = latestBackupTimestamp() else { return false }

        for suffix in ["", "-wal", "-shm"] {
            let src = backupDirURL.appendingPathComponent("backup-\(timestamp).store\(suffix)")
            let dst = appSupportURL.appendingPathComponent(storeFileName + suffix)
            try? fm.removeItem(at: dst)
            guard fm.fileExists(atPath: src.path) else { continue }
            do { try fm.copyItem(at: src, to: dst) } catch { return false }
        }
        return true
    }

    // MARK: - 내부 구현

    @discardableResult
    private static func createBackup() -> Bool {
        let fm        = FileManager.default
        let timestamp = Int(Date().timeIntervalSince1970)

        do { try fm.createDirectory(at: backupDirURL, withIntermediateDirectories: true) }
        catch { return false }

        // iCloud 백업에서 제외 — 메인 store가 이미 iCloud 백업에 포함되므로 중복 방지
        var resourceValues = URLResourceValues()
        resourceValues.isExcludedFromBackup = true
        var mutableURL = backupDirURL
        try? mutableURL.setResourceValues(resourceValues)

        for suffix in ["", "-wal", "-shm"] {
            let src = appSupportURL.appendingPathComponent(storeFileName + suffix)
            let dst = backupDirURL.appendingPathComponent("backup-\(timestamp).store\(suffix)")
            guard fm.fileExists(atPath: src.path) else { continue }
            do { try fm.copyItem(at: src, to: dst) }
            catch { return suffix.isEmpty ? false : true }   // 메인 파일 실패만 중단
        }
        return true
    }

    private static func latestBackupTimestamp() -> Int? {
        guard let files = try? FileManager.default.contentsOfDirectory(atPath: backupDirURL.path)
        else { return nil }

        return files
            .filter  { $0.hasPrefix("backup-") && $0.hasSuffix(".store") }
            .compactMap { name -> Int? in
                Int(name
                    .replacingOccurrences(of: "backup-", with: "")
                    .replacingOccurrences(of: ".store", with: ""))
            }
            .max()
    }

    private static func pruneOldBackups() {
        let fm = FileManager.default
        guard let files = try? fm.contentsOfDirectory(atPath: backupDirURL.path) else { return }

        let sorted = files
            .filter  { $0.hasPrefix("backup-") && $0.hasSuffix(".store") }
            .compactMap { name -> Int? in
                Int(name
                    .replacingOccurrences(of: "backup-", with: "")
                    .replacingOccurrences(of: ".store", with: ""))
            }
            .sorted(by: >)

        for timestamp in sorted.dropFirst(maxBackupCount) {
            for suffix in ["", "-wal", "-shm"] {
                let file = backupDirURL.appendingPathComponent("backup-\(timestamp).store\(suffix)")
                try? fm.removeItem(at: file)
            }
        }
    }

    private static func currentVersionString() -> String {
        let info    = Bundle.main.infoDictionary
        let version = info?["CFBundleShortVersionString"] as? String ?? "0"
        let build   = info?["CFBundleVersion"] as? String ?? "0"
        return "\(version).\(build)"
    }
}
