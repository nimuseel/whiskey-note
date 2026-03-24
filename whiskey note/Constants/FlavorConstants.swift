import Foundation

enum WhiskeyCategory: String, CaseIterable, Codable {
    case singleMalt = "Single Malt"
    case blended    = "Blended"
    case bourbon    = "Bourbon"
    case irish      = "Irish"
    case japanese   = "Japanese"
    case other      = "Other"

    var localizedName: String {
        switch self {
        case .singleMalt: String(localized: "싱글 몰트")
        case .blended:    String(localized: "블렌디드")
        case .bourbon:    String(localized: "버번")
        case .irish:      String(localized: "아이리시")
        case .japanese:   String(localized: "재패니즈")
        case .other:      String(localized: "기타")
        }
    }
}

enum FlavorType: String, CaseIterable, Codable {
    case aroma     = "aroma"
    case taste     = "taste"
    case mouthfeel = "mouthfeel"
    case finish    = "finish"
}

struct FlavorItem {
    let name: String
    let emoji: String
    let type: FlavorType
}

enum FlavorConstants {
    static let all: [FlavorItem] = [
        // Aroma (9)
        FlavorItem(name: "과일",    emoji: "🍎", type: .aroma),
        FlavorItem(name: "꽃",      emoji: "🌸", type: .aroma),
        FlavorItem(name: "곡물",    emoji: "🌾", type: .aroma),
        FlavorItem(name: "견과류",  emoji: "🌰", type: .aroma),
        FlavorItem(name: "스파이시", emoji: "🌶️", type: .aroma),
        FlavorItem(name: "우디",    emoji: "🪵", type: .aroma),
        FlavorItem(name: "피트",    emoji: "🔥", type: .aroma),
        FlavorItem(name: "와인",    emoji: "🍷", type: .aroma),
        FlavorItem(name: "페인티",  emoji: "🍯", type: .aroma),
        // Taste (5)
        FlavorItem(name: "단맛",    emoji: "🍬", type: .taste),
        FlavorItem(name: "짠맛",    emoji: "🧂", type: .taste),
        FlavorItem(name: "신맛",    emoji: "🍋", type: .taste),
        FlavorItem(name: "쓴맛",    emoji: "☕", type: .taste),
        FlavorItem(name: "감칠맛",  emoji: "🫒", type: .taste),
        // Mouthfeel (7)
        FlavorItem(name: "가벼움",  emoji: "🪶",  type: .mouthfeel),
        FlavorItem(name: "중간",    emoji: "⚖️",  type: .mouthfeel),
        FlavorItem(name: "무거움",  emoji: "🏋️", type: .mouthfeel),
        FlavorItem(name: "부드러움", emoji: "🧈", type: .mouthfeel),
        FlavorItem(name: "거침",    emoji: "🪨",  type: .mouthfeel),
        FlavorItem(name: "오일",    emoji: "💧",  type: .mouthfeel),
        FlavorItem(name: "드라이",  emoji: "🏜️", type: .mouthfeel),
        // Finish (6)
        FlavorItem(name: "짧은",    emoji: "⚡",  type: .finish),
        FlavorItem(name: "중간",    emoji: "⏳",  type: .finish),
        FlavorItem(name: "긴",      emoji: "🌊",  type: .finish),
        FlavorItem(name: "따뜻한",  emoji: "🔆",  type: .finish),
        FlavorItem(name: "스파이시", emoji: "🌶️", type: .finish),
        FlavorItem(name: "드라이",  emoji: "🏜️", type: .finish),
    ]

    static func items(for type: FlavorType) -> [FlavorItem] {
        all.filter { $0.type == type }
    }
}
