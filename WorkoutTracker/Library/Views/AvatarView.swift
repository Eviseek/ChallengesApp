//
//  AvatarView.swift
//  WorkoutTracker
//
//  Created by Eva Chlpikova on 17.07.2026.
//

import SwiftUI

struct AvatarView: View {
    let name: String
    let size: CGFloat
    var isCurrentUser: Bool = false

    var body: some View {
        ZStack {
            background
            Text(initials)
                .font(.appFixed(size: size * 0.38, weight: isCurrentUser ? .heavy : .bold))
                .foregroundStyle(isCurrentUser ? Color.Brand.onElectricGreenTint : Color.Brand.label)
                .textCase(.uppercase)
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .decorative()
    }

    private var initials: String {
        isCurrentUser ? String(name.prefix(1)) : name.abbreviatedName
    }

    @ViewBuilder private var background: some View {
        if isCurrentUser {
            Color.Brand.electricGreenTint
        } else {
            Color.Brand.cardBackground
        }
    }
}

#if DEBUG
#Preview {
    HStack(spacing: Metrics.small) {
        AvatarView(name: "Lucas Hill", size: 64)
        AvatarView(name: "Eva Chlpikova", size: 52, isCurrentUser: true)
        AvatarView(name: "X", size: Metrics.compactAvatarSize)
    }
    .padding()
}
#endif
