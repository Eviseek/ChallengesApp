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
