import Foundation

enum Finish: String, Codable, Identifiable, CaseIterable {
    case Short = "짧은"
    case Medium = "중간"
    case Long = "긴"
    case Warm = "따뜻한"
    case Spicy = "스파이시"
    case Dry = "드라이"
    
    var id: String {
        self.rawValue
    }
}
