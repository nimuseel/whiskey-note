import Foundation

// MARK: - Cabinet Grouping

/// 이름 기준으로 노트를 그룹핑한다.
/// - representative: 그룹 내 가장 최신 노트 (병 외관 결정)
/// - notes: 그룹 내 노트 목록, createdAt 내림차순 정렬 (최신이 [0])
/// - 선반 정렬: 그룹 내 가장 오래된 노트의 createdAt 오름차순 (원래 스펙 유지)
func groupWhiskeysByName(
    _ notes: [WhiskeyNote]
) -> [(representative: WhiskeyNote, notes: [WhiskeyNote])] {
    let groups = Dictionary(grouping: notes) { $0.name }
    return groups.values
        .map { group -> (representative: WhiskeyNote, notes: [WhiskeyNote]) in
            let sorted = group.sorted { $0.createdAt > $1.createdAt }
            return (representative: sorted[0], notes: sorted)
        }
        .sorted {
            // notes는 이미 내림차순 정렬 → last가 가장 오래된 노트
            ($0.notes.last?.createdAt ?? .distantPast) < ($1.notes.last?.createdAt ?? .distantPast)
        }
}

/// 이름별 가장 최신 노트의 카테고리 rawValue를 반환한다.
/// - Key: note.name, Value: WhiskeyCategory rawValue (예: "Single Malt")
func buildCategoryDict(_ notes: [WhiskeyNote]) -> [String: String] {
    var latest: [String: (category: String, date: Date)] = [:]
    for note in notes {
        if let prev = latest[note.name] {
            if note.createdAt > prev.date {
                latest[note.name] = (note.category, note.createdAt)
            }
        } else {
            latest[note.name] = (note.category, note.createdAt)
        }
    }
    return latest.mapValues { $0.category }
}
