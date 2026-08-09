'use strict';

// Every value in this file is data, not logic: the generator reads it and builds the
// prompt from it. Reusing the script for another app or another team should mean
// editing this file only.

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

const GEMINI_MODEL = 'gemini-2.5-flash';

// Languages the copy is generated in. The first entry is the primary one: it is written
// natively and the rest are rewritten from it, not translated word for word. The `code`
// values become the keys of every localized field written to Firestore, so they must
// match the keys the app's LocalizedString expects.
const LANGUAGES = [
  { code: 'cs', name: 'Czech' },
  { code: 'en', name: 'English' }
];

// Who the app is for. Inserted into the prompt after "The app is used mainly by", so
// phrase it as a noun phrase. Keep it short - it only sets who the copy is talking to.
const AUDIENCE = 'a single group of colleagues who all know each other';

// The persona the copy imitates. The counter-example matters as much as the example:
// it is what keeps the model away from generic marketing voice.
const VOICE_PERSONA = { like: 'a witty colleague', notLike: 'a corporate fitness brand' };

// Shared-culture cues the copy may riff on, e.g. ['office coffee runs', 'Friday deploys'].
// Leave empty for copy that assumes nothing about the group beyond AUDIENCE.
const CULTURE_NOTES = [];

// Shared in-jokes the copy may lean on (at most one per challenge). Write them in the
// primary language. Grow this over time; an empty array is fine and simply omits them.
// e.g. ['páteční nasazování do produkce', 'kolega, co pošle jeden PR s 5000+ změnami']
const INSIDE_JOKES = [];

// Framing registers the copy rotates through so consecutive challenges never sound
// alike. registers.js picks one per challenge, excluding the ids used by the two most
// recent challenges. The `id` is written to Firestore as the challenge's `register`
// field, so ids are stable data - renaming one orphans that register's history.
// Swap in registers that fit your group; only the shape (id + framing) is required.
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

module.exports = {
  DESIGNATED_MONTH_GOALS,
  OPPOSITE_MUSCLE_GROUP_PAIRS,
  GEMINI_MODEL,
  LANGUAGES,
  PRIMARY_LANGUAGE: LANGUAGES[0],
  AUDIENCE,
  VOICE_PERSONA,
  CULTURE_NOTES,
  INSIDE_JOKES,
  REGISTERS
};
