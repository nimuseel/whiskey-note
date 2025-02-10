import Foundation
import SwiftData

@Model
final class Whiskey {
    @Attribute(.unique)
    var id: UUID = UUID()
    var name: String
    var category: String
    
    init(name: String, category: String) {
        self.name = name
        self.category = category
    }
}
