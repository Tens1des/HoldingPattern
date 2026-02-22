//
//  AppAnimations.swift
//  HoldingPattern
//

import SwiftUI

enum AppAnimations {
    static let springSnappy = Animation.spring(response: 0.4, dampingFraction: 0.75)
    static let springBouncy = Animation.spring(response: 0.5, dampingFraction: 0.65)
    static let springSmooth = Animation.spring(response: 0.55, dampingFraction: 0.82)
    static let easeOutMedium = Animation.easeOut(duration: 0.35)
    static let easeOutSlow = Animation.easeOut(duration: 0.5)
}

struct ScaleButtonStyle: ButtonStyle {
    var minScale: CGFloat = 0.94
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? minScale : 1)
            .animation(AppAnimations.springSnappy, value: configuration.isPressed)
    }
}

struct ScaleOnTapStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}
