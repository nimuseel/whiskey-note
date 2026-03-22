import SwiftUI

enum AppColors {
    static let background    = Color(hex: "#faf8f5")
    static let accent        = Color(hex: "#9b6a2f")
    static let tagBackground = Color(hex: "#f0e8d8")
    static let textPrimary   = Color(hex: "#2d2d2d")
    static let textSecondary = Color(hex: "#888888")
    static let star          = Color(hex: "#e8a838")
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8)  & 0xFF) / 255
        let b = Double(int         & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}
