# Monthly Challenge Generation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

> **Post-implementation update (2026-07-09):** After all 7 tasks below were implemented and reviewed as written (using Claude/`@anthropic-ai/sdk`), the LLM provider was swapped to Gemini (`@google/genai`, forced function-calling instead of forced tool-use) since the team already had a Gemini key available. Task 5 and Task 6's code blocks below still show the original Claude-based implementation that was actually reviewed at the time — they're accurate history, not the current code. See `scripts/generate-challenge/llm.js` and `index.js` for the current Gemini-based implementation.

**Goal:** A GitHub Actions workflow that runs monthly, randomly generates a new workout `Challenge` (goal + LLM-written copy), and writes it to Firestore.

**Architecture:** A standalone Node.js CLI script (`scripts/generate-challenge/`) run by a scheduled GitHub Actions workflow. The script authenticates to Firebase via the Admin SDK, guards against double-generation, picks a goal algorithmically, asks Claude for title/description/prize copy via forced tool-use, and writes a `ChallengeDB`-shaped document to Firestore.

**Tech Stack:** Node.js (CommonJS), `firebase-admin`, `@anthropic-ai/sdk`, GitHub Actions (`schedule` + `workflow_dispatch` triggers).

## Global Constraints

- No automated tests are written for this feature (per explicit user instruction) — verification steps below are one-off manual sanity checks, not a persisted test suite.
- Firestore field names/types must exactly match the Swift `Codable` models: `ChallengeDB` (`WorkoutTracker/Model/DB/ChallengeDB.swift`), `GoalDB` (`WorkoutTracker/Model/DB/GoalDB.swift`), `ExerciseDB` (`WorkoutTracker/Model/DB/ExerciseDB.swift`).
- `GoalType` raw values: `total_volume`, `total_duration`, `workout_count` (`WorkoutTracker/Model/Enums/GoalType.swift`).
- `GoalUnit` raw values: `kg`, `lbs`, `seconds`, `count` (`WorkoutTracker/Model/Enums/GoalUnit.swift`).
- `MuscleGroup` raw values: `Chest`, `Back`, `Legs`, `Shoulders`, `Arms`, `Core`, `Cardio`, `Other` (`WorkoutTracker/Model/Enums/MuscleGroup.swift`).
- `ExerciseType` raw values: `Reps`, `Duration` (`WorkoutTracker/Model/Enums/ExerciseType.swift`).
- `creatorId` is a placeholder constant for now (`"system-generated"`) — no functional effect currently, per spec.
- `prize` is flavor text only, no real-world fulfillment.
- Spec reference: `docs/superpowers/specs/2026-07-09-monthly-challenge-generation-design.md`.

---

### Task 1: Project scaffolding and config

**Files:**
- Create: `scripts/generate-challenge/package.json`
- Create: `scripts/generate-challenge/config.js`

**Interfaces:**
- Produces: `config.js` exports `DESIGNATED_MONTH_GOALS` (object, keys are 0-indexed UTC month numbers, values are `'workout_count'` or `'total_duration_overall'`), `OPPOSITE_MUSCLE_GROUP_PAIRS` (array of 2-element arrays of `MuscleGroup` raw-value strings), `CLAUDE_MODEL` (string).

- [ ] **Step 1: Create the package.json**

```json
{
  "name": "generate-challenge",
  "version": "1.0.0",
  "private": true,
  "main": "index.js",
  "dependencies": {
    "firebase-admin": "^12.0.0",
    "@anthropic-ai/sdk": "^0.32.0"
  }
}
```

- [ ] **Step 2: Create config.js**

```javascript
'use strict';

// Keys are 0-indexed UTC month numbers (0 = January, 11 = December).
// These goal types aren't tied to specific exercises, so restricting them
// to one designated month per year avoids them feeling repetitive.
const DESIGNATED_MONTH_GOALS = {
  11: 'workout_count', // December
  5: 'total_duration_overall' // June
};

const OPPOSITE_MUSCLE_GROUP_PAIRS = [
  ['Chest', 'Back'],
  ['Legs', 'Arms'],
  ['Shoulders', 'Core']
];

const CLAUDE_MODEL = 'claude-sonnet-5';

module.exports = { DESIGNATED_MONTH_GOALS, OPPOSITE_MUSCLE_GROUP_PAIRS, CLAUDE_MODEL };
```

- [ ] **Step 3: Install dependencies**

Run: `cd scripts/generate-challenge && npm install`
Expected: `node_modules/` created, `package-lock.json` created, no errors.

- [ ] **Step 4: Commit**

```bash
git add scripts/generate-challenge/package.json scripts/generate-challenge/package-lock.json scripts/generate-challenge/config.js
git commit -m "chore: scaffold generate-challenge script and config"
```

---

### Task 2: Date helpers

**Files:**
- Create: `scripts/generate-challenge/dates.js`

**Interfaces:**
- Consumes: nothing (pure function, takes a `Date` as input).
- Produces: `getChallengeMonthRange(now: Date): { start: Date, end: Date }` — UTC midnight on the 1st, and 23:59:59 UTC on the last day of `now`'s month. `getTargetMonthIndex(now: Date): number` — 0-indexed UTC month of `now`.

- [ ] **Step 1: Create dates.js**

```javascript
'use strict';

function getChallengeMonthRange(now) {
  const year = now.getUTCFullYear();
  const month = now.getUTCMonth();
  const start = new Date(Date.UTC(year, month, 1, 0, 0, 0));
  const end = new Date(Date.UTC(year, month + 1, 0, 23, 59, 59));
  return { start, end };
}

function getTargetMonthIndex(now) {
  return now.getUTCMonth();
}

module.exports = { getChallengeMonthRange, getTargetMonthIndex };
```

- [ ] **Step 2: Manually verify**

Run:
```bash
cd scripts/generate-challenge
node -e "
const { getChallengeMonthRange, getTargetMonthIndex } = require('./dates');
const now = new Date('2026-03-15T12:00:00Z');
console.log(getChallengeMonthRange(now));
console.log(getTargetMonthIndex(now));
"
```
Expected output: `start` is `2026-03-01T00:00:00.000Z`, `end` is `2026-03-31T23:59:59.000Z`, and the second line prints `2`.

- [ ] **Step 3: Commit**

```bash
git add scripts/generate-challenge/dates.js
git commit -m "feat: add month-range date helpers for challenge generation"
```

---

### Task 3: Firestore client

**Files:**
- Create: `scripts/generate-challenge/firestore.js`

**Interfaces:**
- Consumes: `process.env.FIREBASE_SERVICE_ACCOUNT_JSON` (JSON string of a service-account key).
- Produces: `initFirestore(): Firestore`, `getLatestChallenge(db): Promise<{id: string, ...ChallengeDB fields} | null>`, `getExerciseCatalog(db): Promise<Array<{id: string, ...ExerciseDB fields}>>`, `writeChallenge(db, challengeDoc): Promise<string>` (returns new document id).

- [ ] **Step 1: Create firestore.js**

```javascript
'use strict';

const admin = require('firebase-admin');

function initFirestore() {
  if (!admin.apps.length) {
    const serviceAccount = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT_JSON);
    admin.initializeApp({ credential: admin.credential.cert(serviceAccount) });
  }
  return admin.firestore();
}

async function getLatestChallenge(db) {
  const snapshot = await db.collection('challenges').orderBy('end', 'desc').limit(1).get();
  if (snapshot.empty) {
    return null;
  }
  const doc = snapshot.docs[0];
  return { id: doc.id, ...doc.data() };
}

async function getExerciseCatalog(db) {
  const snapshot = await db.collection('exercises').get();
  return snapshot.docs.map((doc) => ({ id: doc.id, ...doc.data() }));
}

async function writeChallenge(db, challengeDoc) {
  const ref = await db.collection('challenges').add(challengeDoc);
  return ref.id;
}

module.exports = { initFirestore, getLatestChallenge, getExerciseCatalog, writeChallenge };
```

- [ ] **Step 2: Manually verify against a real/staging Firebase project (when credentials are available)**

This module needs live Firestore credentials, so it can't be sanity-checked with a one-liner the way `dates.js` was. Once a service-account key exists (see Task 7's setup note), verify manually with:

```bash
cd scripts/generate-challenge
FIREBASE_SERVICE_ACCOUNT_JSON="$(cat /path/to/service-account.json)" node -e "
const { initFirestore, getLatestChallenge, getExerciseCatalog } = require('./firestore');
(async () => {
  const db = initFirestore();
  console.log(await getLatestChallenge(db));
  console.log((await getExerciseCatalog(db)).length, 'exercises found');
})();
"
```
Expected: no thrown errors; prints either `null` or the latest challenge's fields, and a positive exercise count. If this step can't be run yet (no key provisioned), note that and move on — it will be exercised for real in Task 7's `workflow_dispatch` dry run.

- [ ] **Step 3: Commit**

```bash
git add scripts/generate-challenge/firestore.js
git commit -m "feat: add Firestore client for challenge generation script"
```

---

### Task 4: Goal generation logic

**Files:**
- Create: `scripts/generate-challenge/goal.js`

**Interfaces:**
- Consumes: `config.js`'s `DESIGNATED_MONTH_GOALS`, `OPPOSITE_MUSCLE_GROUP_PAIRS`. Takes `targetMonthIndex: number` and `exerciseCatalog: Array<{id, name, muscleGroup, type, description}>` (shape from `getExerciseCatalog`).
- Produces: `generateGoal(targetMonthIndex, exerciseCatalog): { type: 'total_volume'|'total_duration'|'workout_count', unit: 'kg'|'seconds'|'count', exercises: Array<exercise> }` — consumed by `index.js` (Task 6) to build the `GoalDB` document.

- [ ] **Step 1: Create goal.js**

```javascript
'use strict';

const { DESIGNATED_MONTH_GOALS, OPPOSITE_MUSCLE_GROUP_PAIRS } = require('./config');

function pickRandom(array) {
  return array[Math.floor(Math.random() * array.length)];
}

function pickN(array, n) {
  const pool = [...array];
  const picked = [];
  while (picked.length < n && pool.length > 0) {
    const index = Math.floor(Math.random() * pool.length);
    picked.push(pool.splice(index, 1)[0]);
  }
  return picked;
}

function generateGoal(targetMonthIndex, exerciseCatalog) {
  const designated = DESIGNATED_MONTH_GOALS[targetMonthIndex];

  if (designated === 'workout_count') {
    return { type: 'workout_count', unit: 'count', exercises: [] };
  }

  if (designated === 'total_duration_overall') {
    return { type: 'total_duration', unit: 'seconds', exercises: [] };
  }

  const goalType = pickRandom(['total_volume', 'total_duration']);
  const exerciseType = goalType === 'total_volume' ? 'Reps' : 'Duration';
  const matching = exerciseCatalog.filter((exercise) => exercise.type === exerciseType);

  const exerciseCount = Math.floor(Math.random() * 3) + 1; // 1-3
  const focusMode = pickRandom(['same', 'opposite']);

  let selected = [];

  if (focusMode === 'same') {
    const groups = [...new Set(matching.map((exercise) => exercise.muscleGroup))];
    const group = pickRandom(groups);
    const groupPool = matching.filter((exercise) => exercise.muscleGroup === group);
    selected = pickN(groupPool, exerciseCount);
  } else {
    const pair = pickRandom(OPPOSITE_MUSCLE_GROUP_PAIRS);
    const pairPool = matching.filter((exercise) => pair.includes(exercise.muscleGroup));
    selected = pickN(pairPool, exerciseCount);
  }

  if (selected.length === 0) {
    // Fallback if the chosen focus mode had no eligible exercises in the catalog.
    selected = pickN(matching, exerciseCount);
  }

  return {
    type: goalType,
    unit: goalType === 'total_volume' ? 'kg' : 'seconds',
    exercises: selected
  };
}

module.exports = { generateGoal, pickRandom, pickN };
```

- [ ] **Step 2: Manually verify**

Run:
```bash
cd scripts/generate-challenge
node -e "
const { generateGoal } = require('./goal');
const catalog = [
  { id: 'a', name: 'Bench Press', muscleGroup: 'Chest', type: 'Reps' },
  { id: 'b', name: 'Squat', muscleGroup: 'Legs', type: 'Reps' },
  { id: 'c', name: 'Plank', muscleGroup: 'Core', type: 'Duration' },
  { id: 'd', name: 'Treadmill', muscleGroup: 'Cardio', type: 'Duration' }
];
console.log('December (designated):', generateGoal(11, catalog));
console.log('June (designated):', generateGoal(5, catalog));
for (let i = 0; i < 5; i++) {
  console.log('January (random):', generateGoal(0, catalog));
}
"
```
Expected: December always prints `{ type: 'workout_count', unit: 'count', exercises: [] }`; June always prints `{ type: 'total_duration', unit: 'seconds', exercises: [] }`; the January runs print varying `type` (`total_volume` or `total_duration`) with 1-3 exercises whose `type` matches (`Reps` exercises only when `type` is `total_volume`, `Duration` exercises only when `type` is `total_duration`).

- [ ] **Step 3: Commit**

```bash
git add scripts/generate-challenge/goal.js
git commit -m "feat: add randomized goal generation logic"
```

---

### Task 5: LLM copy generation

**Files:**
- Create: `scripts/generate-challenge/llm.js`

**Interfaces:**
- Consumes: `config.js`'s `CLAUDE_MODEL`. Takes a `goal` object shaped like `generateGoal`'s return value, and an `apiKey: string`.
- Produces: `generateChallengeCopy(goal, apiKey): Promise<{ title: string, description: string, prize: string }>` — consumed by `index.js` (Task 6). Also exports `describeGoal(goal): string` for standalone verification.

- [ ] **Step 1: Create llm.js**

```javascript
'use strict';

const Anthropic = require('@anthropic-ai/sdk');
const { CLAUDE_MODEL } = require('./config');

const SYSTEM_PROMPT = `You write short, punchy copy for a monthly fitness challenge inside a workout tracker app.
Vary your tone across different challenges - sometimes competitive, sometimes casual and social,
sometimes beginner-friendly and encouraging. Do not default to the same tone every time.
The prize is always just for fun, never a real-world reward, so feel free to invent something
lighthearted (bragging rights, a silly trophy, a nickname, etc).
Keep the title under 8 words, the description under 40 words, and the prize under 12 words.`;

function describeGoal(goal) {
  if (goal.exercises.length === 0) {
    return goal.type === 'workout_count'
      ? 'Goal: most total workouts logged this month.'
      : 'Goal: most total workout time logged this month.';
  }

  const exerciseNames = goal.exercises.map((exercise) => exercise.name).join(', ');
  const goalLabel = goal.type === 'total_volume' ? 'total weight lifted' : 'total time';
  return `Goal: highest ${goalLabel} on these exercises: ${exerciseNames}.`;
}

async function generateChallengeCopy(goal, apiKey) {
  const client = new Anthropic({ apiKey });

  const response = await client.messages.create({
    model: CLAUDE_MODEL,
    max_tokens: 512,
    system: SYSTEM_PROMPT,
    messages: [{ role: 'user', content: describeGoal(goal) }],
    tools: [
      {
        name: 'submit_challenge_copy',
        description: 'Submit the generated challenge title, description, and prize.',
        input_schema: {
          type: 'object',
          properties: {
            title: { type: 'string' },
            description: { type: 'string' },
            prize: { type: 'string' }
          },
          required: ['title', 'description', 'prize']
        }
      }
    ],
    tool_choice: { type: 'tool', name: 'submit_challenge_copy' }
  });

  const toolUse = response.content.find((block) => block.type === 'tool_use');
  if (!toolUse) {
    throw new Error('Claude response did not include the expected tool_use block');
  }

  const { title, description, prize } = toolUse.input;
  if (!title || !description || !prize) {
    throw new Error('Claude response is missing required copy fields');
  }

  return { title, description, prize };
}

module.exports = { generateChallengeCopy, describeGoal };
```

- [ ] **Step 2: Manually verify describeGoal (no API key needed)**

Run:
```bash
cd scripts/generate-challenge
node -e "
const { describeGoal } = require('./llm');
console.log(describeGoal({ type: 'total_volume', unit: 'kg', exercises: [{ name: 'Bench Press' }, { name: 'Squat' }] }));
console.log(describeGoal({ type: 'workout_count', unit: 'count', exercises: [] }));
"
```
Expected: first line mentions "total weight lifted on these exercises: Bench Press, Squat."; second line mentions "most total workouts logged this month."

- [ ] **Step 3: Manually verify generateChallengeCopy against the real Claude API (when ANTHROPIC_API_KEY is available)**

```bash
cd scripts/generate-challenge
ANTHROPIC_API_KEY="sk-..." node -e "
const { generateChallengeCopy } = require('./llm');
generateChallengeCopy({ type: 'total_volume', unit: 'kg', exercises: [{ name: 'Bench Press' }] }, process.env.ANTHROPIC_API_KEY)
  .then(console.log)
  .catch(console.error);
"
```
Expected: prints an object with non-empty `title`, `description`, `prize` strings, no thrown error.

- [ ] **Step 4: Commit**

```bash
git add scripts/generate-challenge/llm.js
git commit -m "feat: add Claude-based challenge copy generation"
```

---

### Task 6: Orchestration script

**Files:**
- Create: `scripts/generate-challenge/index.js`

**Interfaces:**
- Consumes: `dates.js` (`getChallengeMonthRange`, `getTargetMonthIndex`), `goal.js` (`generateGoal`), `llm.js` (`generateChallengeCopy`), `firestore.js` (`initFirestore`, `getLatestChallenge`, `getExerciseCatalog`, `writeChallenge`). Reads `process.env.ANTHROPIC_API_KEY`.
- Produces: a runnable script (`node index.js`) that exits 0 on success (including the no-op "already active" case) and exits 1 on any error, printing the error to stderr.

- [ ] **Step 1: Create index.js**

```javascript
'use strict';

const admin = require('firebase-admin');
const { getChallengeMonthRange, getTargetMonthIndex } = require('./dates');
const { generateGoal } = require('./goal');
const { generateChallengeCopy } = require('./llm');
const {
  initFirestore,
  getLatestChallenge,
  getExerciseCatalog,
  writeChallenge
} = require('./firestore');

const PLACEHOLDER_CREATOR_ID = 'system-generated';

function toGoalDB(goal) {
  return {
    type: goal.type,
    exerciseIds: goal.exercises.map((exercise) => exercise.id),
    exerciseNames: goal.exercises.map((exercise) => exercise.name),
    unit: goal.unit
  };
}

async function run() {
  const now = new Date();
  const db = initFirestore();

  const latest = await getLatestChallenge(db);
  if (latest && latest.end.toDate() > now) {
    console.log(
      `Active challenge "${latest.title}" has not ended yet (ends ${latest.end.toDate().toISOString()}). Skipping.`
    );
    return;
  }

  const { start, end } = getChallengeMonthRange(now);
  const targetMonthIndex = getTargetMonthIndex(now);
  const exercises = await getExerciseCatalog(db);
  const goal = generateGoal(targetMonthIndex, exercises);

  const copy = await generateChallengeCopy(goal, process.env.ANTHROPIC_API_KEY);

  const challengeDoc = {
    creatorId: PLACEHOLDER_CREATOR_ID,
    title: copy.title,
    description: copy.description,
    prize: copy.prize,
    start: admin.firestore.Timestamp.fromDate(start),
    end: admin.firestore.Timestamp.fromDate(end),
    goal: toGoalDB(goal),
    createdAt: admin.firestore.Timestamp.fromDate(now)
  };

  const id = await writeChallenge(db, challengeDoc);
  console.log(`Created challenge ${id}: "${challengeDoc.title}"`);
}

run().catch((error) => {
  console.error('Challenge generation failed:', error);
  process.exit(1);
});

module.exports = { run, toGoalDB };
```

- [ ] **Step 2: Manually verify toGoalDB (no credentials needed)**

Run:
```bash
cd scripts/generate-challenge
node -e "
const { toGoalDB } = require('./index');
console.log(toGoalDB({ type: 'total_volume', unit: 'kg', exercises: [{ id: 'a', name: 'Bench Press' }] }));
"
```
Expected: `{ type: 'total_volume', exerciseIds: [ 'a' ], exerciseNames: [ 'Bench Press' ], unit: 'kg' }`.

Note: requiring `./index` also triggers the module's top-level `run()` call as a side effect (it calls `initFirestore()`, which will throw without `FIREBASE_SERVICE_ACCOUNT_JSON` set). That's expected here — the thrown/caught error and non-zero exit are fine for this manual check; the `toGoalDB` log line above still prints correctly before that happens since `run()` is async. If this ordering is confusing when you run it, set `FIREBASE_SERVICE_ACCOUNT_JSON='{}'` in the environment first so the throw happens quietly instead of looking alarming.

- [ ] **Step 3: End-to-end manual verification (when both FIREBASE_SERVICE_ACCOUNT_JSON and ANTHROPIC_API_KEY are available against a test/staging project)**

```bash
cd scripts/generate-challenge
FIREBASE_SERVICE_ACCOUNT_JSON="$(cat /path/to/service-account.json)" ANTHROPIC_API_KEY="sk-..." node index.js
```
Expected: either `Created challenge <id>: "<title>"` printed, or the "has not ended yet" skip message — and a corresponding new document visible in the Firestore console's `challenges` collection in the first case.

- [ ] **Step 4: Commit**

```bash
git add scripts/generate-challenge/index.js
git commit -m "feat: add orchestration script for monthly challenge generation"
```

---

### Task 7: GitHub Actions workflow

**Files:**
- Create: `.github/workflows/generate-challenge.yml`

**Interfaces:**
- Consumes: `scripts/generate-challenge/index.js` as the entry point. Reads GitHub secrets `CHALLENGE_GENERATOR_FIREBASE_SERVICE_ACCOUNT` and `ANTHROPIC_API_KEY`.
- Produces: a scheduled + manually-dispatchable CI job.

- [ ] **Step 1: Create the workflow file**

```yaml
name: Generate Monthly Challenge

on:
  schedule:
    - cron: '5 0 1 * *'
  workflow_dispatch: {}

jobs:
  generate-challenge:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-node@v4
        with:
          node-version: '20'

      - name: Install dependencies
        working-directory: scripts/generate-challenge
        run: npm install

      - name: Generate challenge
        working-directory: scripts/generate-challenge
        env:
          FIREBASE_SERVICE_ACCOUNT_JSON: ${{ secrets.CHALLENGE_GENERATOR_FIREBASE_SERVICE_ACCOUNT }}
          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
        run: node index.js
```

- [ ] **Step 2: Provision the two GitHub secrets (manual, one-time, in the GitHub repo settings — not a code step)**

1. In Firebase/Google Cloud Console, create a dedicated service account scoped to Firestore access only (not the default broad Firebase Admin role), generate a JSON key for it.
2. In the GitHub repo: Settings → Secrets and variables → Actions → New repository secret:
   - `CHALLENGE_GENERATOR_FIREBASE_SERVICE_ACCOUNT` = the full JSON key contents.
   - `ANTHROPIC_API_KEY` = a Claude API key.

- [ ] **Step 3: Manually verify via workflow_dispatch**

After secrets are provisioned and this file is merged, trigger the workflow manually: GitHub repo → Actions → "Generate Monthly Challenge" → "Run workflow". Expected: the run succeeds, and either a new `challenges` document appears in Firestore, or the log shows the "has not ended yet" skip message if a challenge is already active.

- [ ] **Step 4: Commit**

```bash
git add .github/workflows/generate-challenge.yml
git commit -m "ci: add scheduled workflow to generate monthly challenges"
```
