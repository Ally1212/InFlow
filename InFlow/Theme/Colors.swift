import SwiftUI

extension Color {
    // Terra 暖色系
    static let terra50 = Color(hex: "FFF8F3")
    static let terra100 = Color(hex: "F7E6CA")
    static let terra200 = Color(hex: "C9A690")
    static let terra300 = Color(hex: "E2725B")
    static let terra400 = Color(hex: "C64837")
    static let terra500 = Color(hex: "F2854B")

    // Ink 墨色系
    static let ink900 = Color(hex: "2D2520")
    static let ink600 = Color(hex: "5C4A42")
    static let ink400 = Color(hex: "8E6F5E")

    // 卡片背景
    static let cardBackground = Color(hex: "FFFDFB")

    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
