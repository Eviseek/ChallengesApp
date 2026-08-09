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
