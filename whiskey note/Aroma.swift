import Foundation

enum Aroma: String, Codable, Identifiable, CaseIterable {
    case Fruity = "과일"
    case Floral = "꽃"
    case Grainy = "곡물"
    case Nutty = "견과류"
    case Spicy = "스파이시"
    case Woody = "우디(캐러멜, 토피, 바닐라)"
    case Peaty = "피트"
    case Winey = "와인(초콜릿)"
    case Feinty = "페인티(꿀, 가죽, 담배, 치즈)"
    
    var id: String {
        self.rawValue
    }
}
