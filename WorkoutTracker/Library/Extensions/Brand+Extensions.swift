//
//  Color+Brand.swift
//  WorkoutTracker
//
//  Created by Eva Chlpikova on 10.06.2026.
//

import SwiftUI

extension Color {
    enum Brand {

        // MARK: - Brand palette

        /// Primary brand accent — adaptive: deep electric green #008035 light / neon #26F97F dark.
        ///
        /// The two stops are not decorative. Green carries a lot of perceived luminance, so a
        /// single neon value would drop to ~1.5:1 against a white background — invisible. The
        /// light stop is darkened until it clears 4.5:1 against the *card* surface (the tighter
        /// constraint — cards are darker than the page), which also makes white text on an
        /// electric-green fill pass AA, since contrast is symmetric. The dark stop can then go
        /// fully neon because it sits on near-black.
        static let electricGreen = Color("BrandElectricGreen")
        /// Text/icons on an `electricGreen` fill — adaptive: white light / processBlack dark.
        ///
        /// Must be adaptive: the neon dark stop is so bright that white-on-green falls to 1.4:1,
        /// while near-black-on-green reaches 11.3:1.
        static let onElectricGreen = Color("BrandOnElectricGreen")
        static let processBlack = Color("BrandProcessBlack")
        static let futuristicGrey = Color("BrandFuturisticGrey")
        /// Subtle electric-green fill for highlighted surfaces (current-user rows, badges, chips).
        /// Adaptive alpha: 12% light / 18% dark — a 12% neon wash is nearly invisible on near-black,
        /// so the dark stop is strengthened rather than reused. Centralized so the tint stays
        /// consistent instead of drifting per call site.
        static let electricGreenTint = Color("BrandElectricGreenTint")
        /// Text/icons on an `electricGreenTint` surface — adaptive: #006B31 light / neon dark.
        ///
        /// `electricGreen` itself only reaches ~3.5:1 on the pale light tint, so tinted chips and
        /// badges use this deeper stop to clear AA. In dark mode the neon already contrasts against
        /// the tint, so that stop is unchanged.
        static let onElectricGreenTint = Color("BrandOnElectricGreenTint")

        // MARK: - Fixed colors
        /// Destructive red — #FF3B30 light / #FF453A dark
        static let destructive = Color("BrandDestructive")

        // MARK: - Semantic (adaptive light/dark)

        /// Primary text — #000000 light / #FFFFFF dark
        static let label = Color("SemanticLabel")
        /// Secondary text — #3C3C43 at 60% light / #EBEBF5 at 60% dark
        static let labelSecondary = Color("SemanticLabelSecondary")
        /// Card surface — #F2F2F7 light / #1C1C1E dark
        static let cardBackground = Color("SemanticCardBackground")
        /// Elevated card surface — #FFFFFF light / #2C2C2E dark
        static let cardBackgroundTertiary = Color("SemanticCardBackgroundTertiary")
        /// Divider / border — #3C3C43 at 29% light / #545458 at 65% dark
        static let separator = Color("SemanticSeparator")
        /// System gray 4 — #D1D1D6 light / #3A3A3C dark
        static let grayBorder = Color("SemanticGray4")
        /// Fully transparent
        static let clear = Color("SemanticClear")
    }
}
