'use strict';

const admin = require('firebase-admin');

function initFirestore() {
  if (!admin.apps.length) {
    const serviceAccount = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT_JSON);
    admin.initializeApp({ credential: admin.credential.cert(serviceAccount) });
  }
  return admin.firestore();
}

// Most recently ending challenges first. The caller reads element 0 as the latest
// challenge and uses the rest for register history.
async function getRecentChallenges(db, limit) {
  const snapshot = await db.collection('challenges').orderBy('end', 'desc').limit(limit).get();
  return snapshot.docs.map((doc) => ({ id: doc.id, ...doc.data() }));
}

async function getExerciseCatalog(db) {
  const snapshot = await db.collection('exercises').get();
  return snapshot.docs.map((doc) => ({ id: doc.id, ...doc.data() }));
}

async function writeChallenge(db, challengeDoc) {
  const ref = await db.collection('challenges').add(challengeDoc);
  return ref.id;
}

module.exports = { initFirestore, getRecentChallenges, getExerciseCatalog, writeChallenge };
