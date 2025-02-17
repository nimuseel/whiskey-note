import Foundation

enum Mouthfeel: String, Codable, Identifiable, CaseIterable {
    case Light = "가벼움"
    case Medium = "중간"
    case Full = "무거움"
    case Smooth = "부드러움"
    case Rough = "거침"
    case Oily = "오일"
    case Dry = "드라이"
    
    var id: String {
        self.rawValue
    }
}
