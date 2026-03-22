import Foundation
import SwiftData

@Model final class WhiskeyNote {
    @Attribute(.unique) var id: UUID = UUID()
    var name: String = ""
    var category: String = WhiskeyCategory.singleMalt.rawValue
    var age: Int?
    var abv: Double?
    var price: Int?
    var rating: Double = 0.0
    var photoData: Data?
    var memo: String = ""
    var dish: String = ""
    var createdAt: Date = Date()

    @Relationship(deleteRule: .cascade, inverse: \FlavorIntensity.note)
    var flavorIntensities: [FlavorIntensity] = []

    init(name: String = "",
         category: String = WhiskeyCategory.singleMalt.rawValue) {
        self.name = name
        self.category = category
    }
}
