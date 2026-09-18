#!/usr/bin/env node
// Seeds/updates the Firestore `admins` collection from admin_emails.txt.
//
// Usage (from the functions/ directory, after `npm install`):
//   GOOGLE_APPLICATION_CREDENTIALS=/path/to/service-account.json node scripts/seed_admins.js
// or, if you have gcloud installed and have run
//   gcloud auth application-default login
// once, just:
//   node scripts/seed_admins.js
//
// To add a new admin later: append their lowercase email as a new line
// in admin_emails.txt and re-run this script. No rules redeploy needed
// -- firestore.rules reads this collection at request time.
//
// Each admin doc is keyed by the lowercased email itself (not an
// auto-generated id): firestore.rules looks it up with get() by exact
// path, matching the query in
// lib/features/auth/repositories/firebase_auth_repository.dart's
// _resolveRoleFromFirestore (which also lowercases the email first).

const fs = require('fs');
const path = require('path');
const admin = require('firebase-admin');

const firebaserc = JSON.parse(
  fs.readFileSync(path.join(__dirname, '..', '..', '.firebaserc'), 'utf8'),
);
const projectId = firebaserc.projects.default;

admin.initializeApp({
  credential: admin.credential.applicationDefault(),
  projectId,
});

const db = admin.firestore();

async function main() {
  const emailsPath = path.join(__dirname, 'admin_emails.txt');
  const emails = fs
    .readFileSync(emailsPath, 'utf8')
    .split('\n')
    .map((line) => line.trim().toLowerCase())
    .filter(Boolean);

  const batch = db.batch();
  for (const email of emails) {
    const ref = db.collection('admins').doc(email);
    batch.set(
      ref,
      {
        email,
        active: true,
        addedAt: admin.firestore.FieldValue.serverTimestamp(),
      },
      { merge: true },
    );
  }
  await batch.commit();

  console.log(`Seeded ${emails.length} admin(s) into project ${projectId}:`);
  emails.forEach((e) => console.log(`  - ${e}`));
}

main().catch((err) => {
  console.error('Seeding failed:', err);
  process.exit(1);
});
