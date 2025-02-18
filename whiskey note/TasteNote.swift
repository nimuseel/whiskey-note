import Foundation
import SwiftData

@Model
final class TasteNote {
    @Attribute(.unique)
    var id: UUID = UUID()
    @Relationship var whiskey: Whiskey!
    var aroma: [Aroma]
    var taste: [Taste]
    var mouthfeel: [Mouthfeel]
    var finish: [Finish]
    var dish: String
    var createdAt: Date
    
    init(whiskey: Whiskey!, aroma: [Aroma], taste: [Taste], mouthfeel: [Mouthfeel], finish: [Finish], dish: String, createdAt: Date) {
        self.whiskey = whiskey
        self.aroma = aroma
        self.taste = taste
        self.mouthfeel = mouthfeel
        self.finish = finish
        self.dish = dish
        self.createdAt = createdAt
    }
}

