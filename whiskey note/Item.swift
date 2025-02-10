import Foundation
import SwiftData

@Model
final class Item {
    @Attribute(.unique)
    var id: UUID = UUID()
    var whiskey: Whiskey
    var createdAt: Date
    
    init(whiskey: Whiskey, createdAt: Date) {
        self.whiskey = whiskey
        self.createdAt = createdAt
    }
}
