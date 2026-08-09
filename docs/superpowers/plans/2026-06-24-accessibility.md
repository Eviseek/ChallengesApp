# App-wide Accessibility Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Bring the whole iOS app to a full VoiceOver quality bar (labels, hints, values, traits, grouping, decorative-hiding, adjustable actions), with localized strings (en + cs) and a Dynamic Type / touch-target audit.

**Architecture:** Distributed/inline accessibility (mirroring the `slovak-telekom-young-kmp` reference), expressed in this codebase's idioms. Recurring patterns live in a small `View+Accessibility.swift` helper set and in the 26 reusable `Library/Views/` components, so most of the app is covered by fixing the shared layer once. Screens then add only screen-specific semantics.

**Tech Stack:** Swift 6, SwiftUI, Xcode String Catalogs (`Localizable.xcstrings`, en + cs).

## Global Constraints

- **No tests** unless explicitly requested (user default). Verification = build + SwiftLint + VoiceOver spot-check.
- **No force ops** (`!`, `try!`, `as!`); use `guard let`/`if let`. SwiftLint `force_unwrapping` enforced.
- **Implicit returns** for single-expression properties/funcs; `sorted_imports`; access modifiers on members not `extension`; `modifier_order`.
- **Design tokens only** — `Metrics.*` for dimensions, asset-catalog color tokens, `AppTextStyle` for text. No magic numbers / hex / raw fonts.
- **Strings**: inline literals (so the String Catalog extracts them); add cs translations to `Localizable.xcstrings`.
- **No UI-test `.accessibilityIdentifier()`**, no central identifier enum.
- **Liquid Glass toolbar rule**: toolbar items stay bare `Button` + bare `Image`/`Text`; add accessibility via `.accessibilityLabel` only — never add `.frame`/`.padding`/`.appTextStyle`.
- **Custom modifier rule**: a reusable modifier is a `private struct: ViewModifier` exposed via a `View` extension.
- **Comment style**: at most one comment above a declaration; no inline body comments.
- Run `swiftlint lint` on changed files before each commit; `xcodebuild` must succeed per batch.

## Build & lint commands

```bash
# Build (adjust scheme/destination if needed; scheme is WorkoutTracker)
xcodebuild -scheme WorkoutTracker -destination 'platform=iOS Simulator,name=iPhone 16' build

# Lint
cd iosApp 2>/dev/null; swiftlint lint
```
> The Xcode project lives under the repo; if the `xcodebuild` invocation above fails to find the scheme, locate the `.xcodeproj`/`.xcworkspace` first (`find . -name '*.xcworkspace' -maxdepth 3`) and pass `-workspace`/`-project` accordingly. The shared `WorkoutTracker` scheme exists (recent commit).

---

## File Structure

- **Create:** `WorkoutTracker/Library/ViewModifiers/View+Accessibility.swift` — the reusable accessibility modifiers.
- **Modify:** 26 files in `WorkoutTracker/Library/Views/` (and feature-local component folders) — bake in defaults.
- **Modify:** 11 screen `*Component.swift` files in `WorkoutTracker/Scenes/*/`.
- **Modify:** `Localizable.xcstrings` — cs translations for new strings (Xcode auto-extracts en keys on build; cs filled by hand).

Reading rule for every component/screen step: **open the file first, then add modifiers** — accessibility edits are additive, so match the archetype that fits each element.

---

## Task 1: Shared accessibility helpers

**Files:**
- Create: `WorkoutTracker/Library/ViewModifiers/View+Accessibility.swift`

**Interfaces — Produces** (later tasks rely on these exact names):
- `View.accessibleHeader() -> some View` — adds `.isHeader` trait.
- `View.decorative() -> some View` — hides element from assistive tech.
- `View.accessibleCombined(_ label: LocalizedStringKey) -> some View` — combines children into one element with `label`.
- `View.accessibleCombined(label: String) -> some View` — same, for runtime-built strings.

- [ ] **Step 1: Create the helper file**

```swift
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
```

- [ ] **Step 2: Lint the new file**

Run: `swiftlint lint --path WorkoutTracker/Library/ViewModifiers/View+Accessibility.swift`
Expected: no violations.

- [ ] **Step 3: Build**

Run the build command above.
Expected: BUILD SUCCEEDED.

- [ ] **Step 4: Commit**

```bash
git add WorkoutTracker/Library/ViewModifiers/View+Accessibility.swift
git commit -m "feat(a11y): add reusable accessibility view modifiers

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

## Task 2: Reusable components (`Library/Views/` + feature-local components)

**Files (open and edit each):**
- `Library/Views/AchievementTileView.swift`
- `Library/Views/BottomAccessoryView.swift`
- `Library/Views/CachedAsyncImage.swift`
- `Library/Views/CapsuleGlassButton.swift`
- `Library/Views/GoogleSignInButton.swift`
- `Library/Views/HorizontalPickableItem.swift`
- `Library/Views/HorizontalTappableItem.swift`
- `Library/Views/TimerView.swift`
- `Library/Views/UserAvatarPlaceholderView.swift`
- `Library/Views/WorkoutHeader.swift`
- `Library/Views/ChallengeItem.swift`
- `Library/Views/ChallengeStakesCard.swift`
- `Scenes/ChallengeOverview/OthersRowView.swift`, `ParticipantAvatarView.swift`, `PodiumSlotView.swift`, `PointsBadgeView.swift`, `YouBadgeView.swift`
- `Scenes/Challenges/ActiveChallengeHero.swift`, `ChallengeCard.swift`, `LeaderboardRow.swift`
- `Scenes/WorkoutDetail/DurationSetView.swift`, `ExerciseItemView.swift`, `RepsSetView.swift`, `SetDisplayField.swift`, `SetFloatingTextField.swift`, `SetRowView.swift`

**Interfaces — Consumes:** `accessibleHeader()`, `decorative()`, `accessibleCombined(_:)` / `accessibleCombined(label:)` from Task 1.

Apply the archetype that fits each element. Archetypes (use the real values from each file — these show the shape):

**Archetype A — decorative image/icon:**
```swift
Image(.someIcon)
    .resizable()
    .scaledToFit()
    .decorative()
```

**Archetype B — icon-only button needs a label** (keep existing haptics/action):
```swift
Button {
    action()
} label: {
    Image(systemName: "xmark")
}
.accessibilityLabel("Close")
```

**Archetype C — multi-part row/card → one spoken unit** (e.g. `LeaderboardRow`, `OthersRowView`, `ExerciseItemView`, `AchievementTileView`, `ChallengeItem`/`ChallengeCard`). Build the combined label from the same data the row shows:
```swift
// LeaderboardRow: rank + name + score
rowContent
    .accessibleCombined(label: "Rank \(rank), \(name), \(score) points")

// AchievementTileView: stat value + title
tileContent
    .accessibleCombined(label: "\(value) \(title)")
```

**Archetype D — value-adjusting set input** (`RepsSetView`, `DurationSetView`, `SetFloatingTextField`): label the field and expose its value. Text fields already announce their content; ensure the field has a clear label and the surrounding control isn't split awkwardly:
```swift
SetFloatingTextField(text: $reps, placeholder: "Reps")
    .accessibilityLabel("Reps")
    .accessibilityValue(reps.isEmpty ? "Empty" : reps)
```
If a stepper-style increment exists, add:
```swift
.accessibilityAdjustableAction { direction in
    switch direction {
    case .increment: model.increment()
    case .decrement: model.decrement()
    default: break
    }
}
```

**Archetype E — `TimerView`:** announce as a single timer with its live value:
```swift
timerContent
    .accessibilityElement(children: .ignore)
    .accessibilityLabel("Workout duration")
    .accessibilityValue(formattedTime)
```

**Archetype F — avatar/placeholder** (`UserAvatarPlaceholderView`, `ParticipantAvatarView`, `CachedAsyncImage` when ornamental): `.decorative()` by default. Where the avatar identifies a person and no adjacent name is read, add `.accessibilityLabel(name)` at the call site instead.

**Archetype G — selectable item** (`HorizontalPickableItem`): add selection state:
```swift
itemContent
    .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
```

**Dynamic Type / touch-target checks (per file, ride along):**
- Replace any `.font(.system/.custom(size:))` that bypasses `AppTextStyle` with the right `AppTextStyle` case (unless a non-scaling label is intended — document why).
- Fixed-size icons/elements: ensure `@ScaledMetric` scaling per `ui-patterns.md`.
- Interactive containers with empty whitespace: add `.contentShape(.rect)`; ensure tap target ≥ 44pt (`Metrics.buttonHeight`).
- Note (don't silently reshape) any layout that can't scale without redesign.

- [ ] **Step 1: Edit each file** applying the matching archetype(s) above and the Dynamic Type/touch-target checks. Open the file, identify each image/button/row/input/header, apply the modifier.

- [ ] **Step 2: Lint changed files**

Run: `swiftlint lint` (or scope to changed paths).
Expected: no violations.

- [ ] **Step 3: Build**

Expected: BUILD SUCCEEDED.

- [ ] **Step 4: Commit**

```bash
git add WorkoutTracker/Library/Views WorkoutTracker/Scenes/ChallengeOverview WorkoutTracker/Scenes/Challenges WorkoutTracker/Scenes/WorkoutDetail
git commit -m "feat(a11y): add VoiceOver semantics to reusable components

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

## Task 3: Auth & Profile screens

**Files:**
- `Scenes/Login/LoginComponent.swift`
- `Scenes/Profile/ProfileComponent.swift`

**Interfaces — Consumes:** Task 1 helpers; components from Task 2 (`GoogleSignInButton`, `AchievementTileView`).

Per-screen pass (read file first):
- Section titles (e.g. Profile "YOUR STATS") → `.accessibleHeader()`.
- Stats grid → each `AchievementTileView` already combined (Task 2); ensure no duplicate reading.
- Toolbar/nav buttons → `.accessibilityLabel` (bare `Button` rule).
- Decorative background/hero images → `.decorative()`.
- Login: ensure the Google button label is meaningful ("Sign in with Google") and any decorative logo is hidden.
- Empty/loading/error states → a readable label.
- Dynamic Type / touch-target checks as in Task 2.

- [ ] **Step 1: Edit `LoginComponent.swift`** applying the above.
- [ ] **Step 2: Edit `ProfileComponent.swift`** applying the above.
- [ ] **Step 3: Lint** — no violations.
- [ ] **Step 4: Build** — BUILD SUCCEEDED.
- [ ] **Step 5: VoiceOver spot-check** the Profile screen in the simulator (a11y-tree dump). Confirm reading order: header → each stat as one unit → nav buttons labelled.
- [ ] **Step 6: Commit**

```bash
git add WorkoutTracker/Scenes/Login WorkoutTracker/Scenes/Profile
git commit -m "feat(a11y): VoiceOver semantics for Login and Profile

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

## Task 4: Workout flow screens

**Files:**
- `Scenes/WorkoutList/WorkoutListComponent.swift`
- `Scenes/WorkoutDetail/WorkoutDetailComponent.swift`
- `Scenes/WorkoutSummary/WorkoutSummaryComponent.swift`

**Interfaces — Consumes:** Task 1 helpers; Task 2 components (`TimerView`, `ExerciseItemView`, set views, `WorkoutHeader`).

Per-screen pass:
- WorkoutList: "No workouts yet" empty state readable; "Start Workout" button labelled; each workout row combined; section headers → `.accessibleHeader()`.
- WorkoutDetail: timer announced (Task 2 `TimerView`); add-exercise / add-set buttons labelled; the existing "Save changes"/"Edit workout" label (already present) kept; `WorkoutHeader` name field labelled ("Workout name").
- WorkoutSummary: keep existing "Repeat workout" label; podium/summary stats combined; nav buttons labelled.
- Dynamic Type / touch-target checks as in Task 2.

- [ ] **Step 1: Edit `WorkoutListComponent.swift`.**
- [ ] **Step 2: Edit `WorkoutDetailComponent.swift`.**
- [ ] **Step 3: Edit `WorkoutSummaryComponent.swift`.**
- [ ] **Step 4: Lint** — no violations.
- [ ] **Step 5: Build** — BUILD SUCCEEDED.
- [ ] **Step 6: VoiceOver spot-check** WorkoutDetail (timer reads as live value; set inputs labelled).
- [ ] **Step 7: Commit**

```bash
git add WorkoutTracker/Scenes/WorkoutList WorkoutTracker/Scenes/WorkoutDetail WorkoutTracker/Scenes/WorkoutSummary
git commit -m "feat(a11y): VoiceOver semantics for workout flow

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

## Task 5: Exercise screens

**Files:**
- `Scenes/ExerciseList/ExerciseListComponent.swift`
- `Scenes/ExerciseDetail/ExerciseDetailComponent.swift`
- `Scenes/CategoryList/CategoryListComponent.swift`

**Interfaces — Consumes:** Task 1 helpers; Task 2 components.

Per-screen pass:
- ExerciseList: search field labelled ("Search exercises"); each exercise row combined; section headers → `.accessibleHeader()`; empty state readable.
- ExerciseDetail: title → `.accessibleHeader()`; description readable; muscle-group chips combined or individually labelled; hero image `.decorative()` unless it conveys info (then label it).
- CategoryList: each category cell combined with its name; decorative imagery hidden.
- Dynamic Type / touch-target checks as in Task 2.

- [ ] **Step 1: Edit `ExerciseListComponent.swift`.**
- [ ] **Step 2: Edit `ExerciseDetailComponent.swift`.**
- [ ] **Step 3: Edit `CategoryListComponent.swift`.**
- [ ] **Step 4: Lint** — no violations.
- [ ] **Step 5: Build** — BUILD SUCCEEDED.
- [ ] **Step 6: VoiceOver spot-check** ExerciseList (search labelled; rows read as units).
- [ ] **Step 7: Commit**

```bash
git add WorkoutTracker/Scenes/ExerciseList WorkoutTracker/Scenes/ExerciseDetail WorkoutTracker/Scenes/CategoryList
git commit -m "feat(a11y): VoiceOver semantics for exercise screens

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

## Task 6: Challenge screens

**Files:**
- `Scenes/Challenges/ChallengesComponent.swift`
- `Scenes/ChallengeDetail/ChallengeDetailComponent.swift`
- `Scenes/ChallengeOverview/ChallengeOverviewComponent.swift`

**Interfaces — Consumes:** Task 1 helpers; Task 2 components (`LeaderboardRow`, `ActiveChallengeHero`, `ChallengeCard`, `OthersRowView`, `PodiumSlotView`, `ParticipantAvatarView`, badges, `ChallengeEndedBanner`).

Per-screen pass:
- Challenges: keep existing "Dismiss" (banner) and "N people joined" (hero) labels; "Leaderboard"/"No active challenge" headers → `.accessibleHeader()`; leaderboard rows combined (Task 2); active/past filter selection → `.isSelected` trait.
- ChallengeDetail: title header; full leaderboard rows combined; stakes card combined; participant avatars labelled with names where no adjacent name is read.
- ChallengeOverview: podium slots combined ("1st place, Eva, 340 points"); "You" badge conveyed in the row label; decorative confetti/imagery hidden.
- Dynamic Type / touch-target checks as in Task 2.

- [ ] **Step 1: Edit `ChallengesComponent.swift`.**
- [ ] **Step 2: Edit `ChallengeDetailComponent.swift`.**
- [ ] **Step 3: Edit `ChallengeOverviewComponent.swift`.**
- [ ] **Step 4: Lint** — no violations.
- [ ] **Step 5: Build** — BUILD SUCCEEDED.
- [ ] **Step 6: VoiceOver spot-check** ChallengeOverview (podium reads as ranked units).
- [ ] **Step 7: Commit**

```bash
git add WorkoutTracker/Scenes/Challenges WorkoutTracker/Scenes/ChallengeDetail WorkoutTracker/Scenes/ChallengeOverview
git commit -m "feat(a11y): VoiceOver semantics for challenge screens

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

## Task 7: Czech localization for new accessibility strings

**Files:**
- Modify: `Localizable.xcstrings`

After Tasks 2–6, Xcode has auto-extracted the new English accessibility literals into the catalog (on build). Fill in cs translations so Czech VoiceOver isn't English.

- [ ] **Step 1: Build** to ensure all new literals are extracted into `Localizable.xcstrings`.
- [ ] **Step 2: Open `Localizable.xcstrings`** (Xcode String Catalog editor, or edit the JSON). Find every new accessibility key with a missing/blank `cs` value.
- [ ] **Step 3: Add the cs translation** for each (e.g. "Close" → "Zavřít", "Reps" → "Opakování", "Workout duration" → "Délka tréninku", "Sign in with Google" → "Přihlásit se přes Google"). Match terminology already used in the catalog's existing cs strings.
- [ ] **Step 4: Build** — BUILD SUCCEEDED; confirm no "missing translation" warnings for the new keys.
- [ ] **Step 5: Commit**

```bash
git add WorkoutTracker/Localizable.xcstrings
git commit -m "feat(a11y): add Czech translations for accessibility strings

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

## Task 8: Final verification pass

- [ ] **Step 1: Full build** — BUILD SUCCEEDED.
- [ ] **Step 2: Full lint** — `swiftlint lint` and `swiftlint analyze`: no violations.
- [ ] **Step 3: VoiceOver sweep** — run each screen once in the simulator with the a11y-tree dump; confirm: every interactive element has a label, no element reads raw asset names, rows/cards read as single units, headers are navigable, decorative images are silent.
- [ ] **Step 4: Dynamic Type sweep** — set the simulator to the largest accessibility text size; confirm no clipped text on representative screens; note any unresolved layout limitations.
- [ ] **Step 5: Report** findings (anything noted-but-not-fixed) to the user.

---

## Self-Review (completed)

- **Spec coverage:** conventions (Tasks 2–6 archetypes), shared helpers (Task 1), reusable-component layer (Task 2), 5 feature batches (Tasks 2–6 grouped as specified), cs localization (Task 7), Dynamic Type/touch-target audit (ride-along in each task + Task 8 sweep), verification (per-task + Task 8). All spec sections map to a task.
- **Placeholder scan:** archetype code blocks are concrete shapes; per-file exact code is produced at edit time after reading each file (additive modifiers) — no "TODO/TBD" left.
- **Type consistency:** helper signatures in Task 1 (`accessibleHeader`, `decorative`, `accessibleCombined(_:)`, `accessibleCombined(label:)`) are used verbatim in Tasks 2–6.
