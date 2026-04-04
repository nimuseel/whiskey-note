import Foundation

enum ShareCardHelper {

    // MARK: - Tasting Number

    /// 전체 노트 중 현재 노트의 1-based 순번 (createdAt 오름차순, 동점 시 id 문자열 오름차순)
    static func tastingNumber(for note: WhiskeyNote, in allNotes: [WhiskeyNote]) -> Int {
        let sorted = allNotes.sorted {
            if $0.createdAt != $1.createdAt { return $0.createdAt < $1.createdAt }
            return $0.id.uuidString < $1.id.uuidString
        }
        return (sorted.firstIndex { $0.id == note.id } ?? 0) + 1
    }

    // MARK: - Top Aroma Items

    /// intensity > 0인 aroma 항목을 intensity 내림차순으로 limit개 반환.
    /// 동점이면 FlavorConstants.all 정의 순서 우선.
    static func topAromaItems(
        from note: WhiskeyNote,
        limit: Int = 3
    ) -> [(item: FlavorItem, intensity: Int)] {
        let aromaOrder = FlavorConstants.items(for: .aroma)
        let intensityMap = Dictionary(
            uniqueKeysWithValues: note.flavorIntensities
                .filter { $0.flavorType == FlavorType.aroma.rawValue && $0.intensity > 0 }
                .map { ($0.name, $0.intensity) }
        )
        return aromaOrder
            .compactMap { item -> (FlavorItem, Int)? in
                guard let v = intensityMap[item.name] else { return nil }
                return (item, v)
            }
            .sorted { $0.1 > $1.1 }
            .prefix(limit)
            .map { (item: $0.0, intensity: $0.1) }
    }

    // MARK: - Radar Axis Values

    /// 4개 FlavorType별 intensity > 0인 항목의 평균값 배열 [aroma, taste, mouthfeel, finish].
    /// 해당 타입에 intensity > 0인 항목이 없으면 0.0.
    static func radarAxisValues(from note: WhiskeyNote) -> [Double] {
        FlavorType.allCases.map { flavorType in
            let active = note.flavorIntensities.filter {
                $0.flavorType == flavorType.rawValue && $0.intensity > 0
            }
            guard !active.isEmpty else { return 0.0 }
            return Double(active.map(\.intensity).reduce(0, +)) / Double(active.count)
        }
    }

    // MARK: - Has Any Flavor

    /// intensity > 0인 FlavorIntensity 항목이 하나라도 있으면 true
    static func hasAnyFlavor(from note: WhiskeyNote) -> Bool {
        note.flavorIntensities.contains { $0.intensity > 0 }
    }
}
