'use strict';

const admin = require('firebase-admin');
const { PRIMARY_LANGUAGE } = require('./config');
const { getChallengeMonthRange, getTargetMonthIndex } = require('./dates');
const { generateGoal } = require('./goal');
const { generateChallengeCopy } = require('./llm');
const { pickRegister } = require('./registers');
const {
  initFirestore,
  getRecentChallenges,
  getExerciseCatalog,
  writeChallenge
} = require('./firestore');

const PLACEHOLDER_CREATOR_ID = 'system-generated';

// How many recent challenges' registers to exclude, so consecutive copy never
// reuses the same voice.
const REGISTER_HISTORY_DEPTH = 2;

// Challenge titles are localized maps keyed by language code; older challenges may still
// be plain strings. Resolve to readable text for logging either way.
function titleText(title) {
  return title && title[PRIMARY_LANGUAGE.code] ? title[PRIMARY_LANGUAGE.code] : title;
}

// Only exercise ids are stored: clients resolve names from the exercise catalog so they
// follow the reader's language.
function toGoalDB(goal) {
  return {
    type: goal.type,
    exerciseIds: goal.exercises.map((exercise) => exercise.id),
    unit: goal.unit
  };
}

async function run() {
  const now = new Date();
  const db = initFirestore();

  const recent = await getRecentChallenges(db, REGISTER_HISTORY_DEPTH);
  const latest = recent[0];
  if (latest && latest.end.toDate() > now) {
    console.log(
      `Active challenge "${titleText(latest.title)}" has not ended yet (ends ${latest.end.toDate().toISOString()}). Skipping.`
    );
    return;
  }

  const { start, end } = getChallengeMonthRange(now);
  const targetMonthIndex = getTargetMonthIndex(now);
  const exercises = await getExerciseCatalog(db);
  const goal = generateGoal(targetMonthIndex, exercises);

  const recentRegisterIds = recent.map((challenge) => challenge.register).filter(Boolean);
  const register = pickRegister(recentRegisterIds);
  const copy = await generateChallengeCopy(goal, process.env.GEMINI_API_KEY, register);

  const challengeDoc = {
    creatorId: PLACEHOLDER_CREATOR_ID,
    title: copy.title,
    description: copy.description,
    prize: copy.prize,
    register: register.id,
    start: admin.firestore.Timestamp.fromDate(start),
    end: admin.firestore.Timestamp.fromDate(end),
    goal: toGoalDB(goal),
    createdAt: admin.firestore.Timestamp.fromDate(now)
  };

  const id = await writeChallenge(db, challengeDoc);
  console.log(`Created challenge ${id}: "${titleText(challengeDoc.title)}" (register: ${register.id})`);
}

run().catch((error) => {
  console.error('Challenge generation failed:', error);
  process.exit(1);
});

module.exports = { run, toGoalDB };
