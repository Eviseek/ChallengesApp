//
//  Font+Archivo.swift
//  WorkoutTracker
//
//  Created by Eva Chlpikova on 17.06.2026.
//

import SwiftUI
import UIKit

extension Font {
    /// Archivo Black — a heavy geometric display typeface.
    ///
    /// Use **only** for titles and large hero numbers; never for body text or long
    /// strings (the single weight is very heavy and reads poorly at small sizes).
    /// All cases scale with Dynamic Type through `relativeTo:`.
    enum Archivo {
        /// Login / splash hero headline.
        static let hero = Font.custom(PostScriptName.black, size: 30, relativeTo: .largeTitle)
        /// Prominent screen or card title (e.g. challenge name, workout name).
        static let title = Font.custom(PostScriptName.black, size: 22, relativeTo: .title2)
        /// Large hero number / stat value.
        static let stat = Font.custom(PostScriptName.black, size: 20, relativeTo: .title3)
    }
}

extension UIFont {
    /// Archivo Black accessors for UIKit contexts (e.g. `UINavigationBarAppearance`).
    enum Archivo {
        /// Inline navigation-bar title. Falls back to the system bold font.
        static var navInlineTitle: UIFont {
            UIFont(name: PostScriptName.black, size: 17) ?? .systemFont(ofSize: 17, weight: .bold)
        }

        /// Large navigation-bar title. Falls back to the system bold font.
        static var navLargeTitle: UIFont {
            UIFont(name: PostScriptName.black, size: 28) ?? .systemFont(ofSize: 28, weight: .bold)
        }
    }
}

/// PostScript name of the bundled Archivo Black font file (see `UIAppFonts` in Info.plist).
///
/// Archivo Black ships a single weight (900), so every display style shares it —
/// unlike the multi-weight body typeface in `Font+Manrope.swift`.
private enum PostScriptName {
    static let black = "ArchivoBlack-Regular"
}
