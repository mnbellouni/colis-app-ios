import SwiftUI

enum AppFont {
    static let displayXL: Font = .system(size: 32, weight: .heavy)
    static let displayL:  Font = .system(size: 26, weight: .heavy)
    static let title:     Font = .system(size: 22, weight: .heavy)
    static let subtitle:  Font = .system(size: 18, weight: .bold)
    static let bodyL:     Font = .system(size: 15, weight: .medium)
    static let bodyM:     Font = .system(size: 13, weight: .regular)
    static let label:     Font = .system(size: 11, weight: .bold)
    static let price:     Font = .system(size: 28, weight: .heavy)
    static let code:      Font = .system(size: 16, weight: .bold).monospaced()
}
