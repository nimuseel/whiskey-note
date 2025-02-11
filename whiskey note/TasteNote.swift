import Foundation
import SwiftData

@Model
final class TasteNote {
    var whiskey: Whiskey!
    var aroma: [Taste] = []
    var taste: [Taste] = []
    var mouthfeel: [Taste] = []
    var finish: [Taste] = []
    var dish: String
    
    init(whiskey: Whiskey!, aroma: [Taste], taste: [Taste], mouthfeel: [Taste], finish: [Taste], dish: String) {
        self.whiskey = whiskey
        self.aroma = aroma
        self.taste = taste
        self.mouthfeel = mouthfeel
        self.finish = finish
        self.dish = dish
    }
}

