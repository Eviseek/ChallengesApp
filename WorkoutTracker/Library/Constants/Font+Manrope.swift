//
//  Font+Manrope.swift
//  WorkoutTracker
//
//  Created by Eva Chlpikova on 17.06.2026.
//

import SwiftUI
import UIKit

/// Semantic text styles for the app, backed by the Manrope body typeface.
///
/// Each case mirrors a system text style — same point size and the matching
/// Dynamic Type ramp — so call sites read like the SwiftUI styles they replace:
/// `.font(.app(.subheadline, .semibold))`.
enum AppTextStyle {
    case largeTitle
    case title
    case title2
    case title3
    case headline
    case body
    case callout
    case subheadline
    case footnote
    case caption
    case caption2

    var size: CGFloat {
        switch self {
        case .largeTitle:
            34
        case .title:
            28
        case .title2:
            22
        case .title3:
            20
        case .headline, .body:
            17
        case .callout:
            16
        case .subheadline:
            15
        case .footnote:
            13
        case .caption:
            12
        case .caption2:
            11
        }
    }

    /// System text style the font scales against for Dynamic Type.
    var relativeTo: Font.TextStyle {
        switch self {
        case .largeTitle:
            .largeTitle
        case .title:
            .title
        case .title2:
            .title2
        case .title3:
            .title3
        case .headline:
            .headline
        case .body:
            .body
        case .callout:
            .callout
        case .subheadline:
            .subheadline
        case .footnote:
            .footnote
        case .caption:
            .caption
        case .caption2:
            .caption2
        }
    }

    /// Weight applied when a call site does not specify one — matches the system
    /// convention where `headline` is semibold and everything else is regular.
    var defaultWeight: AppFontWeight {
        self == .headline ? .semibold : .regular
    }
}

/// The Manrope weights bundled in the app (see `UIAppFonts` in Info.plist).
enum AppFontWeight {
    case regular
    case medium
    case semibold
    case bold
    /// Maps to Manrope ExtraBold — the heaviest bundled weight.
    case heavy

    var postScriptName: String {
        switch self {
        case .regular:
            "Manrope-Regular"
        case .medium:
            "Manrope-Medium"
        case .semibold:
            "Manrope-SemiBold"
        case .bold:
            "Manrope-Bold"
        case .heavy:
            "Manrope-ExtraBold"
        }
    }
}

extension Font {
    /// Manrope font for a semantic style, scaling with Dynamic Type.
    /// Pass an explicit weight to override the style's default.
    static func app(_ style: AppTextStyle, _ weight: AppFontWeight? = nil) -> Font {
        .custom((weight ?? style.defaultWeight).postScriptName, size: style.size, relativeTo: style.relativeTo)
    }

    /// App-wide default body font, installed on the view hierarchy root.
    static let appDefault = app(.body)

    /// Manrope at a fixed point size (non-scaling). For compact badges and avatar
    /// initials whose size is derived from their container rather than Dynamic Type.
    static func appFixed(size: CGFloat, weight: AppFontWeight = .regular) -> Font {
        .custom(weight.postScriptName, size: size)
    }
}
