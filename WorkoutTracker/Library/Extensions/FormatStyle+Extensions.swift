//
//  FormatStyle+Extensions.swift
//  WorkoutTracker
//
//  Created by Eva Chlpikova on 08.04.2026.
//

import Foundation

extension FormatStyle where Self == FloatingPointFormatStyle<Double> {
    static var compactDecimal: FloatingPointFormatStyle<Double> {
        .number.precision(.fractionLength(0...3))
    }
}
