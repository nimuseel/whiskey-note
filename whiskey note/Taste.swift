import Foundation

enum Taste: String, Codable, Identifiable, CaseIterable {
    case Sweet = "단맛"
    case Salty = "짠맛"
    case Sour = "신맛"
    case Bitter = "쓴맛"
    case Umami = "감칠맛"
    
    var id: String {
        self.rawValue
    }
}
