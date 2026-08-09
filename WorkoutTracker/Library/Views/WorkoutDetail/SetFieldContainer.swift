//
//  SetFieldContainer.swift
//  WorkoutTracker
//
//  Created by Eva Chlpikova on 17.07.2026.
//

import SwiftUI

/// Shared layout shell for the set-row fields: a caption title above the content,
/// with the content width measured from the (hidden) title so columns line up.
struct SetFieldContainer<Content: View>: View {
    let title: LocalizedStringKey
    var calculateWidth: Bool = true
    @ViewBuilder let content: Content

    @State private var calcWidth: CGFloat = 0

    var body: some View {
        VStack(alignment: .leading, spacing: .zero) {
            Text(title)
                .fixedSize(horizontal: true, vertical: false)
                .font(.app(.caption2))
                .foregroundStyle(Color.Brand.labelSecondary)
            content
                .padding(.trailing, Metrics.mini)
                .padding(.top, Metrics.mini)
                .padding(.bottom, Metrics.extraSmall)
                .frame(width: calculateWidth ? calcWidth : nil, alignment: .leading)
                .frame(maxWidth: calculateWidth ? nil : .infinity, alignment: .leading)
                .lineLimit(1)
        }
        .background {
            Text(title)
                .hidden()
                .readSize { calcWidth = $0.width + Self.measuredWidthPadding }
        }
    }

    // Breathing room added to the measured title width so a value slightly wider than
    // its label isn't clipped.
    private static var measuredWidthPadding: CGFloat { 15 }
}
