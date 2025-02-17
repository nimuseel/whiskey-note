import Foundation
import SwiftData

@Model
final class Whiskey {
    @Attribute(.unique)
    var id: UUID = UUID()
    var name: String
    var category: String
    var tastingNotes: [TasteNote]
    
    init(name: String, category: String, tastingNotes: [TasteNote] = []) {
        self.name = name
        self.category = category
        self.tastingNotes = tastingNotes
    }
}
