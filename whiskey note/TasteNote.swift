import Foundation
import SwiftData

@Model
final class TasteNote {
    var whiskey: Whiskey!
    var aroma: Set<Taste>
    var taste: Set<Taste>
    var mouthfeel: Set<Taste>
    var finish: Set<Taste>
    var dish: String
    
    init(whiskey: Whiskey!, aroma: Set<Taste>, taste: Set<Taste>, mouthfeel: Set<Taste>, finish: Set<Taste>, dish: String) {
        self.whiskey = whiskey
        self.aroma = aroma
        self.taste = taste
        self.mouthfeel = mouthfeel
        self.finish = finish
        self.dish = dish
    }
}

