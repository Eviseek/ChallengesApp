# Challenge Register History — Design

## Problem

Monthly challenge copy is framed in one of six "registers" (voices/tones) defined in `scripts/generate-challenge/config.js`. The register is meant to keep consecutive challenges from sounding alike — the system prompt even says so explicitly ("Lean into it hard - it's what keeps consecutive challenges from sounding the same").

Two defects break that intent:

1. The register is picked at random on every run with no knowledge of history, so two consecutive months can land the same voice (a 1-in-6 chance each month).
2. `buildSystemPrompt(register)` accepts a register argument, but `generateChallengeCopy` calls `buildSystemPrompt()` with no argument (`llm.js:106`), so the parameter is dead code and the function always falls back to its internal `pickRandom(REGISTERS)`.

Nothing persists the chosen register, so nothing *could* remember it even if the pick were history-aware.

## Goals

- Never use the same register in two consecutive challenges.
- Additionally exclude the register from two challenges ago, so a near-repeat doesn't read as recycled.
- Keep the pick genuinely random within the remaining candidates — not a fixed rotation.
- Require no change to the iOS app.

## Non-goals

- Growing the `REGISTERS` list. Six is on the thin side for an exclusion window of two, but a window of two still leaves four live candidates. Adding registers is an independent, cheap follow-up.
- Remembering anything else about past challenges (jokes used, exercises chosen, goal types). Goal repetition is already handled separately by `DESIGNATED_MONTH_GOALS` in `config.js`.
- Backfilling a `register` value onto challenges already in Firestore.

## Approach

Persist a short, stable register **id** on each challenge document. The generator reads the two most recent challenges, collects their register ids, excludes those ids from the candidate pool, picks randomly from what remains, and writes the chosen id onto the new document.

### Why an id rather than the prose

The obvious cheaper variant is to store the framing prose verbatim (`"a dramatic weather warning"`) and compare by string equality. Rejected: the first time the wording of a framing is edited in `config.js`, last month's stored string matches nothing, the exclusion silently degrades back to today's unconditional random pick, and no error is raised. A silent failure in a job that runs once a month would only surface via the copy itself, potentially months later. A stable id decouples the matching key from the editable prose.

### Why not a deterministic rotation

`REGISTERS[monthIndex % REGISTERS.length]` needs no storage and makes repeats impossible. Rejected: it produces the same six framings in the same order forever, and a skipped or re-run month shifts the whole sequence. The requirement is "not the same voice twice in a row", not "a fixed carousel" — deterministic rotation gives up more variety than it buys.

## Data

One new field on documents in the `challenges` collection:

- `register: string` — the id of the framing used for this challenge's copy, e.g. `"weather_warning"`.

The field is optional by nature: challenges already in Firestore do not have it, and the generator must treat its absence as "no history available" rather than an error.

`ChallengeDB` (`WorkoutTracker/Model/DB/ChallengeDB.swift`) is plain `Codable`. Firestore's decoder only reads the keys the type declares and ignores the rest, so the new field needs no Swift-side change and cannot break decoding of existing or new documents.

## Components

All changes are confined to `scripts/generate-challenge/`.

### `config.js`

`REGISTERS` changes from an array of strings to an array of `{ id, framing }` objects. The six existing prose strings move verbatim into `framing`; each gains a short snake_case `id`. Ids are stable identifiers written to Firestore — renaming one orphans stored history for that register, so they are not to be changed casually.

### `registers.js` (new)

One export:

- `pickRegister(recentIds)` → a register object. Filters `REGISTERS` to those whose `id` is not in `recentIds`, then picks uniformly at random from the survivors.

Two guards, both returning a pick from the full list:

- `recentIds` is empty or undefined (first run ever, or all recent challenges predate the `register` field).
- Filtering leaves an empty pool (only reachable if `REGISTERS` shrinks below the window size).

This lives in its own module rather than in `goal.js` because `goal.js` decides *what the challenge measures*, not *how the copy sounds*. `pickRandom` is imported from `goal.js`, where it already exists, rather than duplicated.

### `firestore.js`

Add `getRecentChallenges(db, limit)` — the existing `orderBy('end', 'desc')` query with a parameterized limit, returning an array of `{ id, ...data }`.

`getLatestChallenge(db)` is removed. Its only consumer is `index.js`, which now calls `getRecentChallenges(db, 2)` and treats the first element as the latest — so keeping it as a wrapper would leave dead code behind.

### `index.js`

The single read of the latest challenge becomes a read of the two most recent. Flow:

1. `getRecentChallenges(db, 2)`.
2. Active-challenge guard, unchanged, applied to the first element.
3. Map the fetched challenges to their `register` values and drop any that are undefined.
4. `pickRegister(recentIds)`.
5. Pass the register to `generateChallengeCopy`.
6. Include `register: register.id` in the written document.

### `llm.js`

`generateChallengeCopy(goal, apiKey, register)` gains a third parameter and passes `register.framing` to `buildSystemPrompt`. This closes the dead-parameter defect: the register is now always supplied by the caller.

`buildSystemPrompt` keeps its existing `register || pickRandom(REGISTERS)` fallback so it stays independently usable, but must be updated for the new `REGISTERS` shape — its fallback needs `pickRandom(REGISTERS).framing`, since it interpolates prose into the prompt, not an id.

## Data flow

`index.js` owns history and the choice; `llm.js` renders whatever framing it is handed. Deliberate: the module that talks to Gemini should not also know how challenge history is queried. `registers.js` knows the candidate list and the exclusion rule but nothing about Firestore or the LLM, so it is testable with a plain array of ids.

## Error handling

No new failure modes.

- Missing `register` on older documents is expected and absorbed by the empty-`recentIds` guard.
- A failed Firestore read of two documents fails on the same existing path as today's read of one.
- `pickRegister` cannot return `undefined`; both degenerate cases fall back to the full list.

## Testing

Per project convention, no automated tests unless requested. Manual verification: the workflow has a `workflow_dispatch:` trigger, so a manual run against the target project confirms the new field is written and the chosen register differs from the two stored on the previous challenges.
