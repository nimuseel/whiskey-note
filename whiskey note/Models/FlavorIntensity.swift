import Foundation
import SwiftData

@Model final class FlavorIntensity {
    @Attribute(.unique) var id: UUID = UUID()
    var flavorType: String = FlavorType.aroma.rawValue
    var name: String = ""
    var intensity: Int = 0
    var note: WhiskeyNote?

    init(flavorType: FlavorType, name: String, intensity: Int) {
        self.flavorType = flavorType.rawValue
        self.name = name
        self.intensity = intensity
    }
}
