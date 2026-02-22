//
//  Achievement.swift
//  HoldingPattern
//

import Foundation
import SwiftUI

enum AchievementId: String, CaseIterable, Identifiable {
    case firstStep
    case gettingStarted
    case centurion
    case marathon
    case speedster
    case weekWarrior
    case allRounder
    case timeSaver
    case nightOwl
    case earlyBird

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .firstStep: return "star.fill"
        case .gettingStarted: return "flame.fill"
        case .centurion: return "crown.fill"
        case .marathon: return "figure.run"
        case .speedster: return "bolt.fill"
        case .weekWarrior: return "calendar.badge.clock"
        case .allRounder: return "square.grid.3x3.fill"
        case .timeSaver: return "arrow.down.circle.fill"
        case .nightOwl: return "moon.stars.fill"
        case .earlyBird: return "sunrise.fill"
        }
    }

    var titleKey: String {
        switch self {
        case .firstStep: return "ach_first_step"
        case .gettingStarted: return "ach_getting_started"
        case .centurion: return "ach_centurion"
        case .marathon: return "ach_marathon"
        case .speedster: return "ach_speedster"
        case .weekWarrior: return "ach_week_warrior"
        case .allRounder: return "ach_all_rounder"
        case .timeSaver: return "ach_time_saver"
        case .nightOwl: return "ach_night_owl"
        case .earlyBird: return "ach_early_bird"
        }
    }

    var descriptionKey: String {
        rawValue + "_desc"
    }

    var targetValue: Int {
        switch self {
        case .firstStep: return 1
        case .gettingStarted: return 10
        case .centurion: return 100
        default: return 1
        }
    }
}

struct AchievementProgress: Identifiable {
    let id: AchievementId
    let current: Int
    let target: Int
    let isUnlocked: Bool
    let unlockedAt: Date?
}
