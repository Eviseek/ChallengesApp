# Challenge Register History Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Stop the monthly challenge generator from reusing the copy "register" (voice/tone) used by either of the two most recent challenges.

**Architecture:** Each register gains a short stable `id`. The generator reads the two most recent challenge documents from Firestore, collects their stored `register` ids, excludes those ids from the candidate pool, picks randomly from the rest, and writes the chosen id onto the new document. All changes are confined to `scripts/generate-challenge/`; the iOS app is untouched.

**Tech Stack:** Node.js 20 (CommonJS), `firebase-admin` 12, `@google/genai` 2, Firestore. Runs in GitHub Actions via `.github/workflows/generate-challenge.yml`.

**Spec:** `docs/superpowers/specs/2026-08-04-challenge-register-history-design.md`

## Global Constraints

- **No tests.** The user explicitly chose no automated tests for this change. `scripts/generate-challenge/` has no test framework and none is to be added. Verification is via `node --check` and small `node -e` smoke commands (given verbatim in each task) plus a final manual `workflow_dispatch` run.
- **CommonJS only.** Use `require`/`module.exports`. No ESM, no TypeScript, no new dependencies.
- **`'use strict';`** is the first line of every file in this folder. New files must have it.
- **Comment style:** one comment above a function declaration only. No inline comments inside function bodies.
- **Register ids are persisted data.** Once written to Firestore an id identifies history; renaming one orphans that register's past. Ids are snake_case.
- **Exclusion window is 2** — the two most recent challenges.
- **No iOS changes.** `ChallengeDB` is plain `Codable` and Firestore's decoder ignores undeclared keys, so the new `register` field must not be added to any Swift type.
- **Cannot run `node index.js` locally.** It requires `FIREBASE_SERVICE_ACCOUNT_JSON` and `GEMINI_API_KEY`. Never attempt a full local run as a verification step.

---

### Task 1: Reshape `REGISTERS` and add the register picker

Turns each register into an `{ id, framing }` pair, adds the history-aware picker, and updates the one existing consumer of the old shape. After this task the generator behaves exactly as before (still an unconditional random pick) — it is wiring only, which is why it is a separate reviewable unit from Task 2.

**Files:**
- Modify: `scripts/generate-challenge/config.js:28-38` (the `REGISTERS` const and its comment)
- Create: `scripts/generate-challenge/registers.js`
- Modify: `scripts/generate-challenge/llm.js:62-70` (`buildSystemPrompt`)

**Interfaces:**
- Consumes: `pickRandom(array)` from `scripts/generate-challenge/goal.js` (already exported there; picks one element uniformly at random).
- Produces:
  - `REGISTERS: Array<{ id: string, framing: string }>` from `config.js`.
  - `pickRegister(recentIds: string[] | undefined): { id: string, framing: string }` from `registers.js`. Never returns `undefined`.
  - `buildSystemPrompt(framing: string | undefined): string` from `llm.js` — now takes the framing **prose string**, not a register object.

- [ ] **Step 1: Reshape `REGISTERS` in `config.js`**

Replace lines 28-38 of `scripts/generate-challenge/config.js` (the comment block and the `REGISTERS` array) with:

```js
// Framing registers the copy rotates through so consecutive challenges never sound
// alike. registers.js picks one per challenge, excluding the ids used by the two most
// recent challenges. The `id` is written to Firestore as the challenge's `register`
// field, so ids are stable data - renaming one orphans that register's history.
const REGISTERS = [
  {
    id: 'dev_speak',
    framing: 'playful dev/agile/PM speak (sprints, standups, PRs, deploys, QA, stakeholders, tickets)'
  },
  { id: 'scientific_report', framing: 'a mock scientific report' },
  { id: 'weather_warning', framing: 'a dramatic weather warning' },
  { id: 'movie_trailer', framing: 'an over-the-top movie-trailer voice-over' },
  { id: 'office_bulletin', framing: 'a deadpan bureaucratic office bulletin' },
  { id: 'sports_commentary', framing: 'breathless sports commentary' }
];
```

The `framing` strings are copied verbatim from the current array — do not reword them. Leave `module.exports` at the bottom of the file unchanged; it already exports `REGISTERS`.

- [ ] **Step 2: Create `registers.js`**

Create `scripts/generate-challenge/registers.js` with exactly:

```js
'use strict';

const { REGISTERS } = require('./config');
const { pickRandom } = require('./goal');

// Picks the framing register for a new challenge, avoiding those used by the most
// recent challenges. Falls back to the full list when there is no usable history,
// or if the exclusions would leave nothing to choose from.
function pickRegister(recentIds) {
  if (!recentIds || recentIds.length === 0) {
    return pickRandom(REGISTERS);
  }

  const candidates = REGISTERS.filter((register) => !recentIds.includes(register.id));
  return candidates.length > 0 ? pickRandom(candidates) : pickRandom(REGISTERS);
}

module.exports = { pickRegister };
```

- [ ] **Step 3: Update `buildSystemPrompt` in `llm.js` for the new shape**

`buildSystemPrompt` interpolates prose into the prompt, so it needs a `framing` string. Its fallback currently uses `pickRandom(REGISTERS)`, which would now yield an object and put `[object Object]` into the system prompt.

Replace lines 62-70 of `scripts/generate-challenge/llm.js`:

```js
function buildSystemPrompt(register) {
  const chosenRegister = register || pickRandom(REGISTERS);
```

with:

```js
function buildSystemPrompt(framing) {
  const chosenFraming = framing || pickRandom(REGISTERS).framing;
```

and in the same function change the final replace call from:

```js
    .replace('{{REGISTER}}', chosenRegister);
```

to:

```js
    .replace('{{REGISTER}}', chosenFraming);
```

Leave the rest of the function (the `jokesLine` block and the `{{INSIDE_JOKES_LINE}}` replace) unchanged.

- [ ] **Step 4: Verify the files parse**

Run:

```bash
cd "scripts/generate-challenge" && node --check config.js && node --check registers.js && node --check llm.js && echo OK
```

Expected: `OK` with no other output.

- [ ] **Step 5: Verify the register shape and the picker's exclusion logic**

Run:

```bash
cd "scripts/generate-challenge" && node -e "
const { REGISTERS } = require('./config');
const { pickRegister } = require('./registers');
const assert = require('assert');

assert.strictEqual(REGISTERS.length, 6, 'expected 6 registers');
REGISTERS.forEach((r) => {
  assert.ok(typeof r.id === 'string' && r.id.length > 0, 'register missing id');
  assert.ok(typeof r.framing === 'string' && r.framing.length > 0, 'register missing framing');
});
assert.strictEqual(new Set(REGISTERS.map((r) => r.id)).size, 6, 'register ids not unique');

const excluded = [REGISTERS[0].id, REGISTERS[1].id];
for (let i = 0; i < 200; i += 1) {
  assert.ok(!excluded.includes(pickRegister(excluded).id), 'picked an excluded register');
}

assert.ok(pickRegister([]).id, 'empty history must still return a register');
assert.ok(pickRegister(undefined).id, 'undefined history must still return a register');
assert.ok(pickRegister(REGISTERS.map((r) => r.id)).id, 'fully-excluded pool must still return a register');
console.log('OK');
"
```

Expected: `OK`. Any assertion message printed instead means that specific step above was implemented wrong — fix it before continuing.

- [ ] **Step 6: Verify the system prompt still renders prose, not an object**

Run:

```bash
cd "scripts/generate-challenge" && node -e "
const { buildSystemPrompt } = require('./llm');
const assert = require('assert');

const withFraming = buildSystemPrompt('a dramatic weather warning');
assert.ok(withFraming.includes('Frame this month\'s copy as a dramatic weather warning.'), 'framing not interpolated');

const fallback = buildSystemPrompt();
assert.ok(!fallback.includes('[object Object]'), 'fallback leaked an object into the prompt');
assert.ok(!fallback.includes('{{REGISTER}}'), 'placeholder left unreplaced');
console.log('OK');
"
```

Expected: `OK`.

- [ ] **Step 7: Commit**

```bash
git add scripts/generate-challenge/config.js scripts/generate-challenge/registers.js scripts/generate-challenge/llm.js
git commit -m "$(cat <<'EOF'
refactor(challenges): give copy registers stable ids

Reshape REGISTERS into { id, framing } pairs and add registers.js with a
history-aware pickRegister. The id is what will be persisted per challenge
so future runs can exclude recently used voices.

Behavior is unchanged for now: nothing supplies history yet.

Co-Authored-By: Claude Opus 5 <noreply@anthropic.com>
EOF
)"
```

---

### Task 2: Read register history and persist the chosen register

Wires the picker to real history: reads two challenges instead of one, excludes their registers, and stores the chosen id on the new document. This is the task that changes behavior.

**Files:**
- Modify: `scripts/generate-challenge/firestore.js:13-20,32` (replace `getLatestChallenge` with `getRecentChallenges`)
- Modify: `scripts/generate-challenge/llm.js:99,106` (`generateChallengeCopy` signature and its `buildSystemPrompt` call)
- Modify: `scripts/generate-challenge/index.js:4-12,31-62` (imports, history read, register pick, document field, log line)

**Interfaces:**
- Consumes:
  - `pickRegister(recentIds)` from `registers.js` (Task 1) — returns `{ id, framing }`.
  - `buildSystemPrompt(framing)` from `llm.js` (Task 1) — takes the prose string.
- Produces:
  - `getRecentChallenges(db, limit): Promise<Array<{ id: string, ...challengeFields }>>` from `firestore.js`, ordered by `end` descending. Returns `[]` when the collection is empty.
  - `generateChallengeCopy(goal, apiKey, register): Promise<{ title, description, prize }>` from `llm.js` — third parameter is a register **object**, not a string.
  - A new `register: string` field on documents written to the `challenges` collection.

- [ ] **Step 1: Replace `getLatestChallenge` with `getRecentChallenges` in `firestore.js`**

Replace lines 13-20 of `scripts/generate-challenge/firestore.js`:

```js
async function getLatestChallenge(db) {
  const snapshot = await db.collection('challenges').orderBy('end', 'desc').limit(1).get();
  if (snapshot.empty) {
    return null;
  }
  const doc = snapshot.docs[0];
  return { id: doc.id, ...doc.data() };
}
```

with:

```js
// Most recently ending challenges first. The caller reads element 0 as the latest
// challenge and uses the rest for register history.
async function getRecentChallenges(db, limit) {
  const snapshot = await db.collection('challenges').orderBy('end', 'desc').limit(limit).get();
  return snapshot.docs.map((doc) => ({ id: doc.id, ...doc.data() }));
}
```

Then update the exports line (line 32) from:

```js
module.exports = { initFirestore, getLatestChallenge, getExerciseCatalog, writeChallenge };
```

to:

```js
module.exports = { initFirestore, getRecentChallenges, getExerciseCatalog, writeChallenge };
```

`getLatestChallenge` had exactly one consumer (`index.js`, updated in Step 3), so it is removed rather than kept as a wrapper.

- [ ] **Step 2: Accept a register in `generateChallengeCopy` in `llm.js`**

Change line 99 of `scripts/generate-challenge/llm.js` from:

```js
async function generateChallengeCopy(goal, apiKey) {
```

to:

```js
async function generateChallengeCopy(goal, apiKey, register) {
```

and change line 106 from:

```js
      systemInstruction: buildSystemPrompt(),
```

to:

```js
      systemInstruction: buildSystemPrompt(register.framing),
```

- [ ] **Step 3: Wire history and persistence in `index.js`**

Change the `firestore.js` import block (lines 7-12) from:

```js
const {
  initFirestore,
  getLatestChallenge,
  getExerciseCatalog,
  writeChallenge
} = require('./firestore');
```

to:

```js
const {
  initFirestore,
  getRecentChallenges,
  getExerciseCatalog,
  writeChallenge
} = require('./firestore');
```

Add this import directly below the `generateChallengeCopy` import on line 6:

```js
const { pickRegister } = require('./registers');
```

Add this constant directly below `PLACEHOLDER_CREATOR_ID` (line 14):

```js
// How many recent challenges' registers to exclude, so consecutive copy never
// reuses the same voice.
const REGISTER_HISTORY_DEPTH = 2;
```

In `run()`, replace:

```js
  const latest = await getLatestChallenge(db);
  if (latest && latest.end.toDate() > now) {
```

with:

```js
  const recent = await getRecentChallenges(db, REGISTER_HISTORY_DEPTH);
  const latest = recent[0];
  if (latest && latest.end.toDate() > now) {
```

Then replace the `generateChallengeCopy` call line:

```js
  const copy = await generateChallengeCopy(goal, process.env.GEMINI_API_KEY);
```

with:

```js
  const recentRegisterIds = recent.map((challenge) => challenge.register).filter(Boolean);
  const register = pickRegister(recentRegisterIds);
  const copy = await generateChallengeCopy(goal, process.env.GEMINI_API_KEY, register);
```

In `challengeDoc`, add the `register` field directly after `prize`:

```js
    prize: copy.prize,
    register: register.id,
```

Finally, change the success log so the chosen register is visible in the Actions log:

```js
  console.log(`Created challenge ${id}: "${titleText(challengeDoc.title)}" (register: ${register.id})`);
```

- [ ] **Step 4: Verify the files parse and no stale reference remains**

Run:

```bash
cd "scripts/generate-challenge" && node --check firestore.js && node --check llm.js && node --check index.js && ! grep -rn "getLatestChallenge" *.js && echo OK
```

Expected: `OK`. If the `grep` prints a match, a reference to the removed function is still there — remove it.

- [ ] **Step 5: Verify the history read, exclusion, and written field with a fake Firestore**

This exercises `run()` end to end without real credentials or a real Gemini call, by stubbing both modules in `require.cache`.

Run:

```bash
cd "scripts/generate-challenge" && node -e "
const assert = require('assert');
const path = require('path');

const previousRegisters = ['weather_warning', 'movie_trailer'];
let requestedLimit = null;
let written = null;

const firestorePath = require.resolve('./firestore');
require.cache[firestorePath] = { id: firestorePath, filename: firestorePath, loaded: true, exports: {
  initFirestore: () => ({}),
  getRecentChallenges: (db, limit) => {
    requestedLimit = limit;
    return Promise.resolve(previousRegisters.map((register, index) => ({
      id: 'past-' + index,
      register,
      end: { toDate: () => new Date('2020-01-01T00:00:00Z') }
    })));
  },
  getExerciseCatalog: () => Promise.resolve([
    { id: 'squat', name: 'Squat', type: 'Reps', muscleGroup: 'Legs' },
    { id: 'plank', name: 'Plank', type: 'Duration', muscleGroup: 'Core' }
  ]),
  writeChallenge: (db, doc) => { written = doc; return Promise.resolve('new-id'); }
} };

const llmPath = require.resolve('./llm');
const realLlm = require('./llm');
require.cache[llmPath] = { id: llmPath, filename: llmPath, loaded: true, exports: {
  describeGoal: realLlm.describeGoal,
  buildSystemPrompt: realLlm.buildSystemPrompt,
  generateChallengeCopy: (goal, apiKey, register) => {
    assert.ok(register && register.id && register.framing, 'register object not passed to the LLM');
    const field = { cs: 'cs', en: 'en' };
    return Promise.resolve({ title: field, description: field, prize: field });
  }
} };

const { run } = require('./index');

run().then(() => {
  assert.strictEqual(requestedLimit, 2, 'expected a history read of 2, got ' + requestedLimit);
  assert.ok(written, 'no challenge was written');
  assert.ok(written.register, 'written document has no register field');
  assert.ok(!previousRegisters.includes(written.register), 'reused a recent register: ' + written.register);
  console.log('OK - picked ' + written.register);
}).catch((error) => { console.error('FAIL', error); process.exit(1); });
"
```

Expected: `OK - picked <some id>`, where the id is none of `weather_warning` / `movie_trailer`. Re-run it a few times; it must never print one of those two.

Expect the `Created challenge new-id: ...` line to appear **twice**. `index.js` calls `run()` at module scope (line 65) as well as exporting it, so requiring the module runs it once and the script's explicit `run()` call runs it again. Both runs use the stubs and behave identically, so this is noise, not a failure.

- [ ] **Step 6: Commit**

```bash
git add scripts/generate-challenge/firestore.js scripts/generate-challenge/llm.js scripts/generate-challenge/index.js
git commit -m "$(cat <<'EOF'
feat(challenges): avoid reusing recent challenge copy registers

Read the two most recent challenges, exclude their registers from the
pick, and persist the chosen register id on the new challenge document.
Also fixes generateChallengeCopy never passing a register through to
buildSystemPrompt, which made the argument dead code.

Co-Authored-By: Claude Opus 5 <noreply@anthropic.com>
EOF
)"
```

- [ ] **Step 7: Hand off the manual verification**

The generator cannot run locally (it needs `FIREBASE_SERVICE_ACCOUNT_JSON` and `GEMINI_API_KEY`). Tell the user that the remaining verification is theirs: trigger **Generate Monthly Challenge** via `workflow_dispatch` in GitHub Actions, confirm the log line ends with `(register: <id>)`, and confirm the new Firestore document has a `register` field.

Note the expected no-op: if the current challenge has not ended yet, the run will log `Active challenge ... has not ended yet` and exit without writing — that is the pre-existing guard, not a regression.

Also note that the very first generated challenge after this change has no stored history to exclude (existing documents have no `register` field), so its register is an unconstrained random pick. Exclusion starts applying from the following month.
