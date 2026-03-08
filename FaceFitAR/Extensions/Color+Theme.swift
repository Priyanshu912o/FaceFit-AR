import SwiftUI

extension Color {
    static let theme = ColorTheme()
}

struct ColorTheme {
    let accent = Color(hex: "7C3AED")
    let accentLight = Color(hex: "A78BFA")
    let background = Color(hex: "0F0B1E")
    let cardBg = Color(hex: "1A1333")
    let surface = Color(hex: "251D3D")
    let textPrimary = Color.white
    let textSecondary = Color(hex: "9CA3AF")
    let error = Color(hex: "EF4444")
    let success = Color(hex: "10B981")
    let gradient = LinearGradient(
        colors: [Color(hex: "7C3AED"), Color(hex: "EC4899")],
        startPoint: .leading,
        endPoint: .trailing
    )
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
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
