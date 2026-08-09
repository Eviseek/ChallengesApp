'use strict';

const { GoogleGenAI } = require('@google/genai');
const {
  GEMINI_MODEL,
  LANGUAGES,
  PRIMARY_LANGUAGE,
  AUDIENCE,
  VOICE_PERSONA,
  CULTURE_NOTES,
  INSIDE_JOKES,
  REGISTERS
} = require('./config');
const { pickRandom } = require('./goal');

// Everything group-specific in this prompt arrives through a {{PLACEHOLDER}} fed from
// config.js, so the template itself stays reusable for any team or app.
const SYSTEM_PROMPT_TEMPLATE = `You write the copy for a monthly fitness challenge shown inside a workout-tracking
app. The app is used mainly by {{AUDIENCE}}. Each month users see a new challenge with
three pieces of copy: a title, a short description of the goal, and a playful "prize".
The goal itself is given to you as the user message.

VOICE
Write like {{VOICE_LIKE}}, not {{VOICE_NOT_LIKE}}. The house voice is warm, a little
cheeky, and self-aware - it treats a workout challenge with the same mock-seriousness
you'd use to hype up an office leaderboard. Friendly banter, never a drill sergeant.
No hustle-culture, no guilt-tripping, nothing that shames beginners.
- Address the reader informally (use the familiar form in languages that have one).
- Land ONE clear joke or image, not five. Punchy beats crammed.
- Frame the copy in the register assigned for this challenge (see REGISTER below) and
  commit to it fully - don't dilute it into a generic hype tone.
- Be genuinely funny, not safe-funny. Lean into dry, dark, sarcastic, self-roasting
  humor - roast the grind, Monday mornings, the person who skips leg day. A little
  mean-to-be-nice lands well (e.g. a prize framed as the right to look down on everyone
  who skipped this month).
- Still ship-safe: off-limits are slurs, punching down at people or groups, sexual
  content, and anything you couldn't say out loud at a company all-hands. Edgy and
  irreverent, yes; cruel or exclusionary, no.
- Emoji: zero to two, and only if they earn their place. Not decoration.
{{CULTURE_LINE}}{{INSIDE_JOKES_LINE}}
REGISTER FOR THIS CHALLENGE
Frame this month's copy as {{REGISTER}}. Lean into it hard - it's what keeps consecutive
challenges from sounding the same.

VARIETY
Within your assigned register, still land a fresh joke or image - don't reach for stock
phrasing. The register sets the frame; your wit fills it.

THE PRIZE
The prize is always just for fun - never a real-world reward. Invent something
lighthearted: bragging rights, a made-up trophy, a silly nickname or title, eternal
glory on the leaderboard, and so on.

LANGUAGE - produce {{LANGUAGE_COUNT}} version(s) of every field
{{LANGUAGE_LINES}}

LENGTH (apply per language)
- title: under 8 words
- description: under 40 words
- prize: under 12 words

Call submit_challenge_copy exactly once with all fields filled in.`;

const LANGUAGE_COUNT_WORDS = ['zero', 'ONE', 'TWO', 'THREE', 'FOUR', 'FIVE'];

function languageCountWord(count) {
  return LANGUAGE_COUNT_WORDS[count] || String(count);
}

// The primary language is written natively; the rest are rewritten from it rather than
// translated, which is what keeps a joke funny instead of merely accurate.
function languageLines() {
  return LANGUAGES.map((language, index) => {
    if (index === 0) {
      return `- ${language.name} ("${language.code}") is the primary version. Write it natively and
  idiomatically so it's genuinely funny in ${language.name}, not translated-sounding. Use
  ${language.name} sentence case (not Title Case) and prefer a natural
  ${language.name} word over a foreign one where a good equivalent exists.`;
    }

    return `- ${language.name} ("${language.code}") is secondary. Keep the meaning and the vibe, but do
  NOT translate word-for-word - rewrite the same joke as a bilingual copywriter would for
  ${language.name}. Wording may differ; intent and tone must carry over.`;
  }).join('\n');
}

function buildSystemPrompt(framing) {
  const chosenFraming = framing || pickRandom(REGISTERS).framing;
  const cultureLine = CULTURE_NOTES.length
    ? `- Shared culture you can use as flavor on top of the register: ${CULTURE_NOTES.join('; ')}.\n`
    : '';
  const jokesLine = INSIDE_JOKES.length
    ? `- You may occasionally sprinkle in a shared in-joke from this list, but no more\n  than one, and never force it: ${INSIDE_JOKES.join('; ')}.\n`
    : '';

  return SYSTEM_PROMPT_TEMPLATE
    .replace('{{AUDIENCE}}', AUDIENCE)
    .replace('{{VOICE_LIKE}}', VOICE_PERSONA.like)
    .replace('{{VOICE_NOT_LIKE}}', VOICE_PERSONA.notLike)
    .replace('{{CULTURE_LINE}}', cultureLine)
    .replace('{{INSIDE_JOKES_LINE}}', jokesLine)
    .replace('{{REGISTER}}', chosenFraming)
    .replace('{{LANGUAGE_COUNT}}', languageCountWord(LANGUAGES.length))
    .replace('{{LANGUAGE_LINES}}', languageLines());
}

// Catalog exercise names are localized maps keyed by language code; older documents may
// still be plain strings. The prompt is written in the primary language, so prefer it.
function exerciseName(name) {
  return name && name[PRIMARY_LANGUAGE.code] ? name[PRIMARY_LANGUAGE.code] : name;
}

function describeGoal(goal) {
  if (goal.exercises.length === 0) {
    return goal.type === 'workout_count'
      ? 'Goal: most total workouts logged this month.'
      : 'Goal: most total workout time logged this month.';
  }

  const exerciseNames = goal.exercises.map((exercise) => exerciseName(exercise.name)).join(', ');
  const goalLabel = goal.type === 'total_volume' ? 'total weight lifted' : 'total time';
  return `Goal: highest ${goalLabel} on these exercises: ${exerciseNames}.`;
}

// A localized copy field: one string per configured language, all required so a
// challenge can never ship half-translated. Mirrors the LocalizedString map shape used
// by the exercise catalog.
const localizedField = {
  type: 'OBJECT',
  properties: Object.fromEntries(LANGUAGES.map((language) => [language.code, { type: 'STRING' }])),
  required: LANGUAGES.map((language) => language.code)
};

function isLocalized(value) {
  return Boolean(value) && LANGUAGES.every((language) => Boolean(value[language.code]));
}

async function generateChallengeCopy(goal, apiKey, register) {
  const client = new GoogleGenAI({ apiKey });
  const languageList = LANGUAGES.map((language) => language.name).join(' and ');

  const response = await client.models.generateContent({
    model: GEMINI_MODEL,
    contents: describeGoal(goal),
    config: {
      systemInstruction: buildSystemPrompt(register.framing),
      tools: [
        {
          functionDeclarations: [
            {
              name: 'submit_challenge_copy',
              description: `Submit the generated challenge title, description, and prize, each in ${languageList}.`,
              parameters: {
                type: 'OBJECT',
                properties: {
                  title: localizedField,
                  description: localizedField,
                  prize: localizedField
                },
                required: ['title', 'description', 'prize']
              }
            }
          ]
        }
      ],
      toolConfig: {
        functionCallingConfig: {
          mode: 'ANY',
          allowedFunctionNames: ['submit_challenge_copy']
        }
      }
    }
  });

  const functionCall = response.functionCalls && response.functionCalls[0];
  if (!functionCall) {
    throw new Error('Gemini response did not include the expected function call');
  }

  const { title, description, prize } = functionCall.args;
  if (!isLocalized(title) || !isLocalized(description) || !isLocalized(prize)) {
    const codes = LANGUAGES.map((language) => language.code).join('/');
    throw new Error(`Gemini response is missing required localized copy fields (${codes})`);
  }

  return { title, description, prize };
}

module.exports = { generateChallengeCopy, describeGoal, buildSystemPrompt };
