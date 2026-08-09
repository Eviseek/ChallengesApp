//
//  Metrics.swift
//  WorkoutTracker
//
//  Created by Eva Chlpikova on 11.06.2026.
//

import CoreGraphics

enum Metrics {

    // MARK: - Spacing

    /// 2 pt
    static let extraMini: CGFloat = 2
    /// 4 pt
    static let mini: CGFloat = 4
    /// 8 pt
    static let extraSmall: CGFloat = 8
    /// 10 pt
    static let mediumSmall: CGFloat = 10
    /// 12 pt
    static let small: CGFloat = 12
    /// 16 pt
    static let medium: CGFloat = 16
    /// 20 pt
    static let large: CGFloat = 20
    /// 24 pt
    static let extraLarge: CGFloat = 24
    /// 32 pt
    static let extraHuge: CGFloat = 32
    /// 20 pt — standard horizontal screen padding
    static let preferredPadding: CGFloat = 20

    // MARK: - Corner Radius

    /// 6 pt
    static let sharpCornerRadius: CGFloat = 6
    /// 8 pt — inner tiles / badges
    static let tileCornerRadius: CGFloat = 8
    /// 10 pt — chips / list rows
    static let chipCornerRadius: CGFloat = 10
    /// 12 pt
    static let roundCornerRadius: CGFloat = 12
    /// 14 pt — card container
    static let cardCornerRadius: CGFloat = 14

    // MARK: - Borders

    /// 1 pt
    static let normalBorderWidth: CGFloat = 1

    // MARK: - Sizes

    /// 36 pt — compact avatar diameter (leaderboard / list rows)
    static let compactAvatarSize: CGFloat = 36
    /// 36 pt — decorative icon container (stat tiles)
    static let iconTileSize: CGFloat = 36
    /// 44 pt — minimum touch target (Apple HIG)
    static let minTouchTargetSize: CGFloat = 44

    // MARK: - Animation

    /// 0.30 s
    static let animationDuration: Double = 0.30
}
