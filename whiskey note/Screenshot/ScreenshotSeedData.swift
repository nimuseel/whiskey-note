import SwiftData
import Foundation

enum ScreenshotSeedData {

    private struct NoteSpec {
        let name: String
        let category: String
        let abv: Double
        let age: Int?
        let price: Int
        let rating: Double
        let memoKo: String
        let memoEn: String
        let dishKo: String
        let dishEn: String
        let aromas: [(String, Int)]
        let tastes: [(String, Int)]
        let mouthfeels: [(String, Int)]
        let finishes: [(String, Int)]
        let daysAgo: Int
    }

    private static let specs: [NoteSpec] = [
        NoteSpec(
            name: "Laphroaig 10yr",
            category: WhiskeyCategory.singleMalt.rawValue,
            abv: 43.0, age: 10, price: 85000, rating: 5.0,
            memoKo: "강렬한 피트 향 뒤로 달콤한 바닐라가 느껴진다",
            memoEn: "Bold peat smoke with a surprisingly sweet vanilla finish",
            dishKo: "다크 초콜릿, 훈제 치즈",
            dishEn: "Dark chocolate, smoked cheese",
            aromas: [("피트", 5), ("과일", 2), ("우디", 3)],
            tastes: [("단맛", 3), ("쓴맛", 2)],
            mouthfeels: [("무거움", 4), ("오일", 3)],
            finishes: [("긴", 5), ("따뜻한", 3)],
            daysAgo: 1
        ),
        NoteSpec(
            name: "Glenfiddich 18yr",
            category: WhiskeyCategory.singleMalt.rawValue,
            abv: 40.0, age: 18, price: 120000, rating: 4.0,
            memoKo: "건과일과 오크 향이 조화롭고 여운이 길다",
            memoEn: "Dried fruit and oak in perfect harmony, long finish",
            dishKo: "호두 타르트, 블루치즈",
            dishEn: "Walnut tart, blue cheese",
            aromas: [("과일", 4), ("꽃", 3), ("견과류", 2)],
            tastes: [("단맛", 4), ("감칠맛", 2)],
            mouthfeels: [("중간", 3), ("부드러움", 4)],
            finishes: [("긴", 4), ("드라이", 2)],
            daysAgo: 5
        ),
        NoteSpec(
            name: "Yamazaki 12yr",
            category: WhiskeyCategory.japanese.rawValue,
            abv: 43.0, age: 12, price: 150000, rating: 5.0,
            memoKo: "섬세한 꽃 향과 과일 향이 인상적인 균형미",
            memoEn: "Delicate floral and fruit notes, beautifully balanced",
            dishKo: "화과자, 녹차 초콜릿",
            dishEn: "Wagashi, matcha chocolate",
            aromas: [("꽃", 5), ("과일", 3), ("와인", 2)],
            tastes: [("단맛", 3), ("신맛", 2)],
            mouthfeels: [("부드러움", 5), ("중간", 2)],
            finishes: [("긴", 3), ("따뜻한", 2)],
            daysAgo: 10
        ),
        NoteSpec(
            name: "Maker's Mark",
            category: WhiskeyCategory.bourbon.rawValue,
            abv: 45.0, age: nil, price: 65000, rating: 3.0,
            memoKo: "바닐라와 캐러멜 향이 진하고 부드럽다",
            memoEn: "Rich vanilla and caramel, smooth and approachable",
            dishKo: "바비큐, 버번 피칸",
            dishEn: "BBQ ribs, bourbon pecans",
            aromas: [("곡물", 4), ("견과류", 3), ("스파이시", 2)],
            tastes: [("단맛", 5), ("감칠맛", 2)],
            mouthfeels: [("중간", 3), ("드라이", 2)],
            finishes: [("중간", 3), ("스파이시", 2)],
            daysAgo: 15
        ),
        NoteSpec(
            name: "Jameson",
            category: WhiskeyCategory.irish.rawValue,
            abv: 40.0, age: nil, price: 45000, rating: 4.0,
            memoKo: "가볍고 달콤하며 입문용으로 완벽하다",
            memoEn: "Light, sweet, and perfectly easy-drinking",
            dishKo: "아이리시 스튜, 체다 치즈",
            dishEn: "Irish stew, cheddar cheese",
            aromas: [("과일", 3), ("꽃", 2), ("곡물", 2)],
            tastes: [("단맛", 3), ("신맛", 1)],
            mouthfeels: [("가벼움", 4), ("부드러움", 3)],
            finishes: [("짧은", 3), ("따뜻한", 2)],
            daysAgo: 20
        )
    ]

    static func seed(into context: ModelContext) {
        let isKorean = Locale.current.language.languageCode?.identifier == "ko"
        let now = Date()

        for spec in specs {
            let note = WhiskeyNote(name: spec.name, category: spec.category)
            note.abv = spec.abv
            note.age = spec.age
            note.price = spec.price
            note.rating = spec.rating
            note.memo = isKorean ? spec.memoKo : spec.memoEn
            note.dish = isKorean ? spec.dishKo : spec.dishEn
            note.createdAt = Calendar.current.date(byAdding: .day, value: -spec.daysAgo, to: now) ?? now
            context.insert(note)

            let flavors: [(FlavorType, [(String, Int)])] = [
                (.aroma, spec.aromas),
                (.taste, spec.tastes),
                (.mouthfeel, spec.mouthfeels),
                (.finish, spec.finishes)
            ]
            for (type, items) in flavors {
                for (name, intensity) in items {
                    let fi = FlavorIntensity(flavorType: type, name: name, intensity: intensity)
                    fi.note = note
                    note.flavorIntensities.append(fi)
                    context.insert(fi)
                }
            }
        }
    }
}
