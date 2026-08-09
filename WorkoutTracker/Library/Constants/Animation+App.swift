//
//  Animation+App.swift
//  WorkoutTracker
//

import SwiftUI

extension Animation {
    /// State / content transitions — easeInOut, 0.30 s
    static let appStateChange = Animation.easeInOut(duration: Metrics.animationDuration)
    /// Quick interactive toggles — snappy spring
    static let appToggle = Animation.snappy
}
