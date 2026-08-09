//
//  View+Extensions.swift
//  WorkoutTracker
//
//  Created by Eva Chlpikova on 08.04.2026.
//

import SwiftUI

extension View {
    func readSize(ignoreSafeArea: Bool = false, onChange: @escaping (CGSize) -> Void) -> some View {
        background(
            GeometryReader { geometry in
                Color.Brand.clear
                    .onAppear { onChange(size(of: geometry, ignoreSafeArea: ignoreSafeArea)) }
                    .onChange(of: size(of: geometry, ignoreSafeArea: ignoreSafeArea)) { _, newValue in
                        onChange(newValue)
                    }
            }
        )
    }

    private func size(of geometry: GeometryProxy, ignoreSafeArea: Bool) -> CGSize {
        var size = geometry.size
        if ignoreSafeArea {
            size.width -= geometry.safeAreaInsets.leading + geometry.safeAreaInsets.trailing
            size.height -= geometry.safeAreaInsets.top + geometry.safeAreaInsets.bottom
        }
        return size
    }
}

extension View {
    func tabViewBottomAccessory<C: View>(
        enabled: Bool,
        @ViewBuilder content: @escaping () -> C
    ) -> some View {
        modifier(TabViewBottomAccessoryModifier(isEnabled: enabled, accessoryContent: content))
    }
}
