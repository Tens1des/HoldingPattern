//
//  AvatarPickerView.swift
//  HoldingPattern
//

import SwiftUI

enum SystemAvatar: String, CaseIterable, Identifiable {
    case personCircle = "person.crop.circle.fill"
    case person = "person.fill"
    case face = "face.smiling.fill"
    case star = "star.circle.fill"
    case heart = "heart.circle.fill"
    case flame = "flame.circle.fill"
    case bolt = "bolt.circle.fill"
    case drop = "drop.circle.fill"
    case leaf = "leaf.circle.fill"
    case moon = "moon.circle.fill"
    case sun = "sun.max.circle.fill"
    case brain = "brain.head.profile"
    case crown = "crown.fill"
    case clock = "clock.fill"
    case sparkles = "sparkles"

    var id: String { rawValue }
}

struct AvatarPickerView: View {
    @Binding var selectedAvatar: String
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            AppTheme.gradientBackground.ignoresSafeArea()
            VStack(spacing: 24) {
                Text("Avatar", bundle: .main)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(AppTheme.textPrimary)
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 4), spacing: 16) {
                    ForEach(SystemAvatar.allCases) { avatar in
                        Button {
                            selectedAvatar = avatar.rawValue
                            dismiss()
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(selectedAvatar == avatar.rawValue ? AppTheme.accentPrimary.opacity(0.3) : AppTheme.backgroundCard)
                                    .frame(width: 56, height: 56)
                                Circle()
                                    .stroke(selectedAvatar == avatar.rawValue ? AppTheme.accentPrimary : Color.clear, lineWidth: 3)
                                    .frame(width: 56, height: 56)
                                Image(systemName: avatar.rawValue)
                                    .font(.system(size: 26))
                                    .foregroundStyle(selectedAvatar == avatar.rawValue ? AppTheme.accentPrimary : AppTheme.textSecondary)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 20)
                Spacer()
            }
            .padding(.top, 32)
        }
        .presentationDetents([.medium, .large])
    }
}
