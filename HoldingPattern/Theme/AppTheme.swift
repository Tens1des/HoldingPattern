//
//  AppTheme.swift
//  HoldingPattern
//

import SwiftUI

enum AppTheme {
    // Backgrounds
    static let backgroundDeep = Color(hex: "0A0710")
    static let backgroundMid = Color(hex: "18152E")
    static let backgroundCard = Color(hex: "2A1F4A")
    static let backgroundCardElevated = Color(hex: "352A52")

    // Accents
    static let accentPrimary = Color(hex: "C27CFF")
    static let accentLight = Color(hex: "E0B0FF")
    static let accentDim = Color(hex: "9B5DD4")

    // Semantic
    static let positive = Color(hex: "7DD3A8")
    static let warning = Color(hex: "F5C26B")
    static let negative = Color(hex: "E88B8B")

    // Text
    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.82)
    static let textMuted = Color.white.opacity(0.52)

    // Gradients
    static let gradientBackground = LinearGradient(
        colors: [backgroundDeep, backgroundMid, Color(hex: "1A0F2E")],
        startPoint: .top,
        endPoint: .bottom
    )
    static let gradientAccent = LinearGradient(
        colors: [accentLight.opacity(0.4), accentPrimary.opacity(0.2)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    static let gradientCardGlow = LinearGradient(
        colors: [accentPrimary.opacity(0.15), .clear],
        startPoint: .leading,
        endPoint: .trailing
    )
    /// Radial “pool of light” behind main button
    static let gradientSpotlight = RadialGradient(
        colors: [
            accentPrimary.opacity(0.12),
            accentPrimary.opacity(0.04),
            .clear
        ],
        center: .center,
        startRadius: 60,
        endRadius: 200
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
