# Monthly Automated Challenge Generation — Design

## Problem

`Challenge` documents in Firestore are currently created manually. We want a CI job that automatically generates a new challenge each month with a randomized goal and LLM-written marketing copy, so someone doesn't have to hand-author one every month.

## Goals

- Generate exactly one new challenge per month, automatically, with no manual step.
- Randomize the goal (type + exercises) in a way that stays fair/sane (no invented numeric targets — goals are "highest value wins", per `Goal`/`GoalType`).
- Generate fresh, varied title/description/prize copy each month via an LLM, with tone that shouldn't feel identical month to month.
- Avoid ever having zero or two active challenges at once.

## Non-goals

- Deciding the real `creatorId` (placeholder for now, to be supplied later).
- Real prize fulfillment — prize text is flavor/bragging-rights only, no real-world consequence.
- Filtering exercise choice by usage history — any catalog exercise is eligible.
- Building a staging/test Firebase project (assumed to already exist or be set up separately if needed for dry runs).

## Architecture

A new GitHub Actions workflow, `.github/workflows/generate-challenge.yml`:
- Trigger: monthly `schedule:` cron (1st of month, 00:05 UTC) + `workflow_dispatch:` for manual/test runs.
- Runs a standalone Node.js script under `scripts/generate-challenge/` (CI tooling, not part of the Swift app target).

Script flow:
1. Authenticate to Firebase via `firebase-admin`, using a service-account key from a GitHub Actions secret. The service account should be scoped to Firestore access only (not the default broad Firebase Admin role) — see "Auth" below.
2. Query the `challenges` collection for the most recent challenge. If it exists and hasn't ended yet (`end` is in the future), log and exit — no challenge created this run (the "guard" against double-generation).
3. Otherwise, generate a new challenge for the upcoming month and write it to Firestore.

### Auth

- Service account key stored as an encrypted GitHub Actions secret, gated behind a GitHub Environment if the repo has one configured.
- Admin SDK bypasses Firestore Security Rules entirely, so the service account should be created with the narrowest IAM role that allows Firestore reads/writes — not the default broad Firebase Admin service account.
- Workload Identity Federation (keyless GCP auth) was considered as a more modern alternative but is deferred — service-account-key is simpler to ship for a single scheduled job and matches this repo's existing CI secret-management pattern (`nightly-build.yml`'s Match/App Store Connect keys). WIF can be adopted later without changing the generation logic.

## Goal generation logic

`Goal.GoalType` has three cases: `.totalVolume(unit)`, `.totalDuration`, `.workoutCount`. `Goal.exercises` may be empty (an "overall" goal, not tied to specific exercises — already supported by `Goal.description`).

A config dict maps specific months to a designated "overall" goal type, since `.totalDuration` (overall) and `.workoutCount` aren't tied to exercises and would feel repetitive if eligible every month:

```
designatedMonths = {
  december: .workoutCount,
  june: .totalDuration (overall)
}
```

(Exact months are just config — trivially changeable, not a logic change.)

Logic per run:

```
if current target month is in designatedMonths:
    goalType = designatedMonths[month]
    exercises = []
else:
    goalType = random choice of .totalVolume or .totalDuration (50/50)
    exerciseType = .reps if totalVolume else .duration
    fetch exercise catalog from Firestore `exercises` collection
    filter to exercises matching exerciseType
    focusMode = random choice of "same muscle group" or "opposite muscle groups"
      - same: pick one MuscleGroup, pick 1-3 exercises from that group (from filtered pool)
      - opposite: pick 2 muscle groups from a fixed opposite-pairs config
                  (e.g. chest<->back, legs<->arms), pick 1-3 exercises spread across them
    if filtered pool doesn't have enough exercises for the chosen mode,
      fall back to picking from whatever's available in the filtered pool
```

Opposite-pairs and designated-months are both simple config objects at the top of the script.

## LLM copy generation

Once the goal is decided, call the Gemini API with:
- A fixed **system prompt** describing desired voice/tone, explicitly instructing the model to vary tone across calls (competitive / casual-social / beginner-friendly / etc.) so consecutive months don't sound alike.
- A **user message** with the concrete goal details (goal type, exercise names + muscle groups, or "no specific exercise" for overall-type months).
- **Structured output** via forced function-calling (`toolConfig.functionCallingConfig.mode: 'ANY'`), returning validated JSON: `{ title: string, description: string, prize: string }`. No free-text parsing.

(Originally designed against the Claude API; swapped to Gemini since the team already had a Gemini key available — same forced-structured-output approach, different provider.)

### Error handling

If the Gemini API call fails or returns invalid/unparseable output, the workflow run fails loudly — no challenge is created that month, no canned-text fallback. This is a low-frequency job; a failed run is manually re-triggered via `workflow_dispatch` after investigation.

## Assembling & writing the challenge

- `start` = first day of the upcoming month (UTC midnight), `end` = last day of that month (UTC midnight).
- `creatorId` = placeholder constant (e.g. `"system-generated"`) — to be replaced with a real value later; has no functional effect currently.
- `createdAt` = now.
- `goal` assembled into `GoalDB` shape (type + unit if `.totalVolume`, + exercise IDs; empty exercise IDs for overall-type goals).
- Written to the `challenges` Firestore collection via `firebase-admin`, matching `ChallengeDB`/`GoalDB` field names/types exactly so the app's `Codable` decoding succeeds.

## Testing

- Unit-test the goal-picking logic as a pure function (seeded random / injected exercise list) — assert same-group vs. opposite-group behavior, exercise-type filtering, designated-month override, and the small-pool fallback.
- No automated tests for the Firestore/Gemini API calls themselves (mocking external services for a once-a-month script has little payoff).
- Manual `workflow_dispatch` dry run against a test/staging Firebase project (if available) before relying on the live monthly cron.

(Per default preference, no tests are written unless explicitly requested — this section describes what testing would look like if requested.)
