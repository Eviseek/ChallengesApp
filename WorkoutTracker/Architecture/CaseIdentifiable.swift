//
//  CaseIdentifiable.swift
//  WorkoutTracker
//
//  Replaces Futured's `@EnumIdentable` macro, which the flow coordinators relied on
//  transitively through FuturedKit.
//

/// Identity and equality for coordinator `Destination` enums, based on the *case* alone.
///
/// - Important: Two values of the same case are equal even when their associated values differ,
/// e.g. `.challengeDetail(a) == .challengeDetail(b)` is `true`. This is deliberate — a destination
/// describes *which* screen is shown, not which data it carries — and it matches the behaviour of
/// the `@EnumIdentable` macro this protocol replaces. Do not switch to a synthesized `Hashable`
/// conformance: that would make the associated values participate in equality and change how
/// ``NavigationStackCoordinator/pop(to:)`` and `NavigationStack` path matching behave.
///
/// - Note: Both the protocol and its extension are explicitly `nonisolated`. The target builds with
/// `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`, so without it they would be inferred as `@MainActor`
/// and the `nonisolated` `Destination` enums could not conform.
nonisolated protocol CaseIdentifiable: Identifiable, Hashable {
    /// The name of the case, ignoring any associated values.
    var id: String { get }
}

nonisolated extension CaseIdentifiable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
