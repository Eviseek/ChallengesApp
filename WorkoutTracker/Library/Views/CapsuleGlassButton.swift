//
//  CapsuleGlassButton.swift
//  WorkoutTracker
//
//  Created by Eva Chlpikova on 15.04.2026.
//

import SwiftUI

struct CapsuleGlassButton: View {

    var text: String
    var foregroundColor: Color = Color.Brand.electricGreen
    var imageName: String
    var action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            HStack(spacing: Metrics.extraSmall) {
                Image(systemName: imageName)
                    .decorative()
                Text(text)
                    .font(.app(.body, .semibold))
            }
            .foregroundStyle(foregroundColor)
            .frame(maxWidth: .infinity)
            .padding(.vertical, Metrics.medium)
            .glassEffect(.regular, in: Capsule())
        }
    }
}
