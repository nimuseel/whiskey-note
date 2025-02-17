import Foundation
import SwiftData

struct AromaStruct: Codable {
    var aroma: Aroma
    var value: Int
    
    init(aroma: Aroma, value: Int) {
        self.aroma = aroma
        self.value = value
    }
}

struct TasteStruct: Codable {
    var taste: Taste
    var value: Int
    
    init(taste: Taste, value: Int) {
        self.taste = taste
        self.value = value
    }
}

struct MouthfeelStruct: Codable {
    var mouthfeel: Mouthfeel
    var value: Int
    
    init(mouthfeel: Mouthfeel, value: Int) {
        self.mouthfeel = mouthfeel
        self.value = value
    }
}

struct FinishStruct: Codable {
    var finish: Finish
    var value: Int
    
    init(finish: Finish, value: Int) {
        self.finish = finish
        self.value = value
    }
}

@Model
final class TasteNote {
    var whiskey: Whiskey!
    var aroma: [AromaStruct]
    var taste: [TasteStruct]
    var mouthfeel: [MouthfeelStruct]
    var finish: [FinishStruct]
    var dish: String
    
    init(whiskey: Whiskey!, aroma: [AromaStruct] = [], taste: [TasteStruct] = [], mouthfeel: [MouthfeelStruct] = [], finish: [FinishStruct] = [], dish: String) {
        self.whiskey = whiskey
        self.aroma = aroma
        self.taste = taste
        self.mouthfeel = mouthfeel
        self.finish = finish
        self.dish = dish
    }
}

