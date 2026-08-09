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
