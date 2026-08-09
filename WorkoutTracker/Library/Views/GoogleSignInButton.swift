//
//  GoogleSignInButton.swift
//  WorkoutTracker
//
//  Created by Eva Chlpikova on 19.03.2026.
//

import SwiftUI

struct GoogleSignInButton: View {
    var title: LocalizedStringKey = "Continue with Google"
    var isLoading: Bool
    var action: () -> Void

    var body: some View {
        button
            .accessibilityLabel(title)
    }

    @ViewBuilder private var button: some View {
        let base = Button {
            guard !isLoading else { return }
            action()
        } label: {
            buttonLabel
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(.background)
                .clipShape(RoundedRectangle(cornerRadius: Metrics.roundCornerRadius))
                .overlay {
                    RoundedRectangle(cornerRadius: Metrics.roundCornerRadius)
                        .strokeBorder(Color.Brand.grayBorder, lineWidth: Metrics.normalBorderWidth)
                }
        }
        .buttonStyle(.plain)
        if isLoading {
            base.accessibilityValue("Loading")
        } else {
            base
        }
    }

    private var buttonLabel: some View {
        ZStack {
            HStack(spacing: Metrics.small) {
                Image("googleLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .decorative()
                Text(title)
                    .font(.appFixed(size: 16, weight: .medium))
                    .foregroundStyle(Color.Brand.label)
            }
            .opacity(isLoading ? 0 : 1)

            if isLoading {
                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(Color.Brand.label)
            }
        }
    }
}
