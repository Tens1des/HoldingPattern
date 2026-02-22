//
//  WaitCategory.swift
//  HoldingPattern
//

import Foundation
import SwiftData

/// System categories + custom. Maps to WaitCategoryEngine.
enum WaitCategoryKind: String, Codable, CaseIterable, Identifiable {
    case physical = "physical"   // elevator, queue
    case digital = "digital"     // loading, reply
    case social = "social"       // person
    case decision = "decision"  // waiting for decision
    case passiveIdle = "passive_idle"
    case custom = "custom"

    var id: String { rawValue }

    var defaultLocalizationKey: String {
        switch self {
        case .physical: return "category_physical"
        case .digital: return "category_digital"
        case .social: return "category_social"
        case .decision: return "category_decision"
        case .passiveIdle: return "category_passive_idle"
        case .custom: return "category_custom"
        }
    }
}

@Model
final class WaitCategoryModel {
    var id: String
    var name: String
    var kindRaw: String
    var sortOrder: Int
    var createdAt: Date

    var kind: WaitCategoryKind {
        get { WaitCategoryKind(rawValue: kindRaw) ?? .custom }
        set { kindRaw = newValue.rawValue }
    }

    init(id: String = UUID().uuidString, name: String, kind: WaitCategoryKind, sortOrder: Int = 0, createdAt: Date = .now) {
        self.id = id
        self.name = name
        self.kindRaw = kind.rawValue
        self.sortOrder = sortOrder
        self.createdAt = createdAt
    }

    static func systemCategories() -> [WaitCategoryModel] {
        let kinds: [(WaitCategoryKind, Int)] = [
            (.physical, 0),
            (.digital, 1),
            (.social, 2),
            (.decision, 3),
            (.passiveIdle, 4)
        ]
        return kinds.map { k, order in
            WaitCategoryModel(id: k.rawValue, name: k.defaultLocalizationKey, kind: k, sortOrder: order)
        }
    }
}
