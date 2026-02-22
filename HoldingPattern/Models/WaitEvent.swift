//
//  WaitEvent.swift
//  HoldingPattern
//

import Foundation
import SwiftData

@Model
final class WaitEvent {
    var id: String
    var startDate: Date
    var endDate: Date
    var categoryId: String
    var createdAt: Date

    var durationSeconds: TimeInterval {
        max(0, endDate.timeIntervalSince(startDate))
    }

    init(id: String = UUID().uuidString, startDate: Date, endDate: Date, categoryId: String, createdAt: Date = .now) {
        self.id = id
        self.startDate = startDate
        self.endDate = endDate
        self.categoryId = categoryId
        self.createdAt = createdAt
    }
}
