import Foundation
import SwiftData

@Model
final class Taste {
    @Attribute(.unique)
    var name: String
    var value: Int
    
    init(name: String, value: Int) {
        self.name = name
        self.value = value
    }
}
