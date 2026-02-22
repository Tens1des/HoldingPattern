//
//  HoldButtonView.swift
//  HoldingPattern
//

import SwiftUI

struct HoldButtonView: View {
    let isHolding: Bool
    let currentDuration: TimeInterval
    let onStart: () -> Void
    let onEnd: () -> Void

    @State private var pulseScale: CGFloat = 1
    @State private var glowOpacity: Double = 0.4
    @State private var idleBreath: CGFloat = 1

    var body: some View {
        VStack(spacing: 28) {
            ZStack {
                if isHolding {
                    pulseRings
                }
                mainCircle
                .scaleEffect(isHolding ? 1 : idleBreath)
            }
            .frame(width: 220, height: 220)

            Text(isHolding ? "END HOLD" : "START HOLD")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .tracking(2.4)
                .foregroundStyle(isHolding ? AppTheme.accentLight : AppTheme.accentPrimary)
                .animation(AppAnimations.springSnappy, value: isHolding)

            if isHolding {
                Text(formatDuration(currentDuration))
                    .font(.system(size: 22, weight: .medium, design: .monospaced))
                    .foregroundStyle(AppTheme.textSecondary)
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.8).combined(with: .opacity),
                        removal: .scale(scale: 0.8).combined(with: .opacity)
                    ))
            }
        }
        .frame(maxWidth: .infinity)
        .animation(AppAnimations.springSnappy, value: isHolding)
        .onChange(of: isHolding) { _, holding in
            if holding {
                startPulse()
                stopIdleBreath()
            } else {
                stopPulse()
                startIdleBreath()
            }
        }
        .onAppear {
            if isHolding {
                startPulse()
            } else {
                startIdleBreath()
            }
        }
    }

    private func startIdleBreath() {
        withAnimation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true)) {
            idleBreath = 1.02
        }
    }

    private func stopIdleBreath() {
        withAnimation(.easeOut(duration: 0.3)) {
            idleBreath = 1
        }
    }

    private var pulseRings: some View {
        ForEach(0..<3, id: \.self) { i in
            Circle()
                .stroke(AppTheme.accentPrimary.opacity(0.3 - Double(i) * 0.08), lineWidth: 2)
                .scaleEffect(pulseScale + CGFloat(i) * 0.15)
        }
        .animation(.easeOut(duration: 2).repeatForever(autoreverses: false), value: pulseScale)
    }

    private var mainCircle: some View {
        Button {
            if isHolding {
                onEnd()
            } else {
                onStart()
            }
        } label: {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                AppTheme.accentPrimary.opacity(glowOpacity * 0.9),
                                AppTheme.accentPrimary.opacity(glowOpacity * 0.35),
                                AppTheme.backgroundCard,
                                AppTheme.backgroundMid
                            ],
                            center: .center,
                            startRadius: 8,
                            endRadius: 95
                        )
                    )
                    .frame(width: 190, height: 190)
                    .scaleEffect(isHolding ? 1.03 : 1)
                    .shadow(color: AppTheme.accentPrimary.opacity(isHolding ? 0.4 : 0.18), radius: isHolding ? 28 : 16, x: 0, y: 4)
                    .shadow(color: AppTheme.accentPrimary.opacity(0.08), radius: 40, x: 0, y: 12)
                Circle()
                    .fill(AppTheme.backgroundCard)
                    .frame(width: 164, height: 164)
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [
                                AppTheme.accentLight.opacity(0.5),
                                AppTheme.accentPrimary.opacity(0.35),
                                AppTheme.accentPrimary.opacity(0.15)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
                    .frame(width: 164, height: 164)
                Image(systemName: isHolding ? "stop.fill" : "play.fill")
                    .font(.system(size: 42, weight: .medium))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [AppTheme.accentLight, AppTheme.accentPrimary],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
        }
        .buttonStyle(ScaleButtonStyle(minScale: 0.92))
    }

    private func startPulse() {
        pulseScale = 1.2
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            glowOpacity = 0.7
        }
    }

    private func stopPulse() {
        pulseScale = 1
        glowOpacity = 0.4
    }

    private func formatDuration(_ sec: TimeInterval) -> String {
        let m = Int(sec) / 60
        let s = Int(sec) % 60
        return String(format: "%d:%02d", m, s)
    }
}
