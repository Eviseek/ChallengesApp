//
//  FullscreenErrorView.swift
//  WorkoutTracker
//
//  Created by Eva Chlpikova on 22.06.2026.
//

import SwiftUI

struct FullscreenErrorView: View {

    var icon: String = "wifi.slash"
    var title: String
    var description: String
    var action: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Image(systemName: icon)
                .font(.system(size: 48)) // Intentional fixed size — decorative error-state icon.
                .foregroundStyle(Color.Brand.electricGreen)
                .padding(.bottom, Metrics.medium)
            Text(title)
                .font(.Archivo.title)
                .foregroundStyle(Color.Brand.label)
                .multilineTextAlignment(.center)
                .padding(.bottom, Metrics.small)
            Text(description)
                .font(.app(.subheadline))
                .foregroundStyle(Color.Brand.labelSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, Metrics.extraHuge)
        .safeAreaInset(edge: .bottom) {
            retryButton
                .padding(.horizontal, Metrics.large)
                .padding(.bottom, Metrics.extraSmall)
        }
    }

    private var retryButton: some View {
        Button(action: action) {
            Text("Try Again")
                .font(.app(.subheadline, .semibold))
                .foregroundStyle(Color.Brand.onElectricGreen)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Metrics.medium)
                .background(Color.Brand.electricGreen, in: Capsule())
        }
    }
}

#if DEBUG
#Preview {
    FullscreenErrorView(
        title: "No Internet Connection",
        description: "Check your connection and try again."
    ) {}
}
#endif
