import SwiftUI

extension Color {
    static let appPrimary       = Color(hex: "00875A")
    static let appPrimaryLight  = Color(hex: "E6F5EF")
    static let appPrimaryMid    = Color(hex: "B3E0CF")
    static let appPrimaryDark   = Color(hex: "00A870")
    static let appBackground    = Color(hex: "FFFBF5")
    static let appCanvas        = Color(hex: "F5F0E8")
    static let appCard          = Color.white
    static let appBorder        = Color(hex: "EDE8DF")
    static let appTextPrimary   = Color(hex: "1C1917")
    static let appTextSecondary = Color(hex: "78716C")
    static let appTextTertiary  = Color(hex: "A8A29E")
    static let appSuccess       = Color(hex: "00875A")
    static let appSuccessLight  = Color(hex: "E6F5EF")
    static let appError         = Color(hex: "E53935")
    static let appErrorLight    = Color(hex: "FDEDED")
    static let appWarning       = Color(hex: "F59E0B")
    static let appWarningLight  = Color(hex: "FFF8E7")
    static let appInfo          = Color(hex: "3B7DD8")
    static let appInfoLight     = Color(hex: "EBF2FF")
    static let appAccent        = Color(hex: "FF6B35")
    static let appAccentLight   = Color(hex: "FFF0EA")

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
        self.init(.sRGB,
            red:     Double(r) / 255,
            green:   Double(g) / 255,
            blue:    Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

@MainActor
extension LinearGradient {
    static var appPrimary: LinearGradient {
        LinearGradient(
            colors: [Color(hex: "00875A"), Color(hex: "00A870")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    static var appHero: LinearGradient {
        LinearGradient(
            colors: [Color(hex: "004D33"), Color(hex: "00875A")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
