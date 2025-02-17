import Foundation
import SwiftData

@Model
final class TasteNote {
    @Relationship var whiskey: Whiskey!
    var aroma: [Aroma]
    var taste: [Taste]
    var mouthfeel: [Mouthfeel]
    var finish: [Finish]
    var dish: String
    
    init(whiskey: Whiskey!, aroma: [Aroma], taste: [Taste], mouthfeel: [Mouthfeel], finish: [Finish], dish: String) {
        self.whiskey = whiskey
        self.aroma = aroma
        self.taste = taste
        self.mouthfeel = mouthfeel
        self.finish = finish
        self.dish = dish
    }
}

