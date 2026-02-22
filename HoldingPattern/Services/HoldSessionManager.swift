//
//  HoldSessionManager.swift
//  HoldingPattern
//

import Combine
import Foundation
import SwiftUI

@MainActor
final class HoldSessionManager: ObservableObject {
    @Published var isHolding = false
    @Published var sessionStartDate: Date?
    @Published var currentDuration: TimeInterval = 0
    private var timer: Timer?

    func startHold() {
        guard !isHolding else { return }
        sessionStartDate = Date()
        isHolding = true
        currentDuration = 0
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self else { return }
            self.tick()
        }
        RunLoop.current.add(timer!, forMode: .common)
    }

    private func tick() {
        guard let start = sessionStartDate else { return }
        currentDuration = Date().timeIntervalSince(start)
    }

    func endSession() {
        timer?.invalidate()
        timer = nil
        isHolding = false
        sessionStartDate = nil
        currentDuration = 0
    }

    func cancelHold() {
        timer?.invalidate()
        timer = nil
        isHolding = false
        sessionStartDate = nil
        currentDuration = 0
    }
}
