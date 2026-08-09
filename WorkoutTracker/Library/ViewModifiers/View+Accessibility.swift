import SwiftUI

private struct AccessibleHeaderModifier: ViewModifier {
    func body(content: Content) -> some View {
        content.accessibilityAddTraits(.isHeader)
    }
}

private struct DecorativeModifier: ViewModifier {
    func body(content: Content) -> some View {
        content.accessibilityHidden(true)
    }
}

private struct AccessibleCombinedKeyModifier: ViewModifier {
    let label: LocalizedStringKey

    func body(content: Content) -> some View {
        content
            .accessibilityElement(children: .combine)
            .accessibilityLabel(Text(label))
    }
}

private struct AccessibleCombinedStringModifier: ViewModifier {
    let label: String

    func body(content: Content) -> some View {
        content
            .accessibilityElement(children: .combine)
            .accessibilityLabel(label)
    }
}

extension View {
    /// Marks the view as a heading for assistive technologies (VoiceOver rotor navigation).
    func accessibleHeader() -> some View {
        modifier(AccessibleHeaderModifier())
    }

    /// Hides a purely decorative element from assistive technologies.
    func decorative() -> some View {
        modifier(DecorativeModifier())
    }

    /// Combines child elements into a single accessibility element with a localized label.
    func accessibleCombined(_ label: LocalizedStringKey) -> some View {
        modifier(AccessibleCombinedKeyModifier(label: label))
    }

    /// Combines child elements into a single accessibility element with a runtime-built label.
    func accessibleCombined(label: String) -> some View {
        modifier(AccessibleCombinedStringModifier(label: label))
    }
}
