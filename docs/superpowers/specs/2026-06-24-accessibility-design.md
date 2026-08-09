# App-wide Accessibility — Design

**Date:** 2026-06-24
**Branch:** `feature/accessibility`
**Goal:** Bring the whole iOS app up to a full VoiceOver quality bar, with localized accessibility strings (en + cs) and a Dynamic Type / touch-target audit, mirroring the pattern used in the `slovak-telekom-young-kmp` reference project.

## Background

The reference project (`slovak-telekom-young-kmp`) uses a **distributed, component-level VoiceOver pattern**: accessibility modifiers are applied inline in each SwiftUI view (no central identifier file, no UI-test identifiers), and every accessibility string is localized through shared resources. Its toolkit: `.accessibilityLabel/Hint/Value`, `.accessibilityElement(children: .combine)`, `.accessibilityHidden(true)` for decoratives, `.accessibilityAddTraits(.isHeader/.isButton/.isSelected)`, `.accessibilityAdjustableAction`, `.accessibilityAction(.escape)`, and a `spelledOutString` helper for codes.

`workout-tracker-ios` today has only 4 ad-hoc `.accessibilityLabel` calls. It has 11 screens (Component + ComponentModel pattern) and 26 reusable components in `Library/Views/`. It localizes via Xcode String Catalogs (`Localizable.xcstrings`, en + cs) using inline `Text("literal")` — and `.accessibilityLabel("literal")` resolves through `LocalizedStringKey`, so the same mechanism localizes accessibility strings.

## Decisions (confirmed with user)

- **Depth:** Full VoiceOver pass matching the reference. **No** UI-test `.accessibilityIdentifier()`.
- **Localization:** Inline string literals, auto-extracted into `Localizable.xcstrings`; cs translations added so cs VoiceOver isn't English.
- **Scope:** VoiceOver semantics **plus** a Dynamic Type & touch-target audit.
- **Approach:** **B** — distributed/inline philosophy (like the reference) expressed in this codebase's idioms, with recurring patterns pushed into the reusable component layer and a few small `ViewModifier` helpers (per the project's "make a reusable modifier" rule). Avoids hand-editing 119 files; fixing the 26 shared components covers most of the app once.

## Conventions (the rulebook every change follows)

- **Interactive elements** get a localized `.accessibilityLabel`; add `.accessibilityHint` when purpose isn't obvious from the label.
- **Decorative images/icons** → `.accessibilityHidden(true)`. Meaningful images → a label.
- **Section titles / headers** → `.accessibilityAddTraits(.isHeader)`.
- **Selection state** (challenge filters, pickable items) → conditional `.accessibilityAddTraits(.isSelected)`; existing haptics retained.
- **Multi-part rows/cards** (leaderboard row, exercise item, achievement tile) → `.accessibilityElement(children: .combine)` with one coherent spoken label.
- **Adjustable controls** (set reps/weight, timer, sliders/pickers) → `.accessibilityValue` + `.accessibilityAdjustableAction`.
- **Dismiss/close buttons** → `.accessibilityAction(.escape)`.
- **Toolbar/nav buttons** stay bare `Button`s (Liquid Glass rule); the label is added via `.accessibilityLabel`, never via frame/padding/text-style changes.
- **Strings**: inline literals; add cs translations to `Localizable.xcstrings`.

## Shared helpers (new)

`Library/ViewModifiers/View+Accessibility.swift` — small, focused `ViewModifier`s exposed as `View` extensions:

- `.accessibleHeader()` → `.accessibilityAddTraits(.isHeader)`.
- `.accessibleCombined(_ label:)` → `.accessibilityElement(children: .combine)` + label.
- `.decorative()` → `.accessibilityHidden(true)` for ornamental images.

Defaults baked into the **26 reusable components** (high-leverage layer):

- `CachedAsyncImage` / `UserAvatarPlaceholderView` / `ParticipantAvatarView` → decorative by default; opt-in label param for meaningful images.
- `CapsuleGlassButton`, `GoogleSignInButton`, icon-only buttons → each surfaces a label.
- Row/card components (`LeaderboardRow`, `ChallengeItem`, `ChallengeCard`, `ExerciseItemView`, `AchievementTileView`, `OthersRowView`, `PodiumSlotView`, `PointsBadgeView`, `YouBadgeView`) → combined element + composed label.
- Set input components (`RepsSetView`, `DurationSetView`, `SetFloatingTextField`, `SetDisplayField`, `SetRowView`) → label + value + adjustable action where the control adjusts a value.
- `TimerView` → label + live value.

## Rollout (batched by feature → one commit per logical group)

1. **Shared layer** — `View+Accessibility.swift` + the 26 `Library/Views/` components.
2. **Auth & Profile** — Login, Profile.
3. **Workout flow** — WorkoutList, WorkoutDetail, WorkoutSummary.
4. **Exercises** — ExerciseList, ExerciseDetail, CategoryList.
5. **Challenges** — Challenges, ChallengeDetail, ChallengeOverview.

Each screen pass covers: toolbar/nav button labels, section headers, empty/loading/error states, screen-level grouping, and sensible announcement of values that change (timer, set count).

## Dynamic Type & touch-target audit (rides along per batch)

- **Dynamic Type:** flag any `.font(.custom/.system(size:))` bypassing `AppTextStyle`, fixed-size icons/elements missing `@ScaledMetric`, and hard `.frame(height:)` containers that would clip scaled text. Fix to scale per `ui-patterns.md`.
- **Touch targets:** interactive elements ≥ 44pt; `Button`/gesture containers with whitespace get `.contentShape(.rect)`.
- Findings recorded as encountered; low-risk fixes ride along in each feature commit. Risky/large layout changes are **noted, not silently reshaped**.

## Verification

- `xcodebuild` build per batch.
- `swiftlint lint` on changed files (new modifiers + edits must pass; no force ops, implicit returns, sorted imports, etc.).
- Spot-check VoiceOver reading order on representative screens in the simulator (a11y-tree dump via the simulator skill). No "VoiceOver works" claim without that evidence.
- No automated tests added unless requested.

## Non-goals

- No UI-test accessibility identifiers.
- No central accessibility identifier enum.
- No unrelated refactoring; layout redesigns beyond what Dynamic Type/touch-target fixes require are out of scope (noted instead).
