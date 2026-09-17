// One-time database seeder — run with: node seed.js
// Use Firestore REST directly via fetch since we have open rules
const PROJECT_ID = "robowars-2k26";
const BASE_URL = `https://firestore.googleapis.com/v1/projects/${PROJECT_ID}/databases/(default)/documents`;

async function firestorePost(collectionPath, data) {
  const url = `${BASE_URL}/${collectionPath}`;
  const response = await fetch(url, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ fields: toFirestoreFields(data) }),
  });
  const result = await response.json();
  if (!response.ok) {
    throw new Error(`Firestore error: ${JSON.stringify(result)}`);
  }
  return result.name.split('/').pop(); // return document ID
}

async function firestorePatch(docPath, data) {
  const url = `${BASE_URL}/${docPath}`;
  const response = await fetch(url, {
    method: 'PATCH',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ fields: toFirestoreFields(data) }),
  });
  const result = await response.json();
  if (!response.ok) {
    throw new Error(`Firestore error: ${JSON.stringify(result)}`);
  }
  return result;
}

function toFirestoreFields(obj) {
  const fields = {};
  for (const [key, value] of Object.entries(obj)) {
    if (typeof value === 'string') {
      fields[key] = { stringValue: value };
    } else if (typeof value === 'number') {
      fields[key] = { integerValue: value.toString() };
    } else if (typeof value === 'boolean') {
      fields[key] = { booleanValue: value };
    } else if (value === null || value === undefined) {
      fields[key] = { nullValue: null };
    } else if (Array.isArray(value)) {
      fields[key] = {
        arrayValue: {
          values: value.map(v => typeof v === 'string' ? { stringValue: v } : { integerValue: v.toString() })
        }
      };
    }
  }
  return fields;
}

async function seed() {
  console.log('🌱 Seeding Robowars 2026 database...\n');

  // ── TEAM: ORCUS ──────────────────────────────────────────────
  console.log('Creating team: Orcus...');
  const teamId = await firestorePost('teams', {
    name: 'Orcus',
    college: 'VIT Vellore',
    description: 'Team Orcus — competing in all 3 weight categories.',
    logoUrl: '',
    wins: 0,
    losses: 0,
    pts: 0,
  });
  console.log(`  ✅ Team created with ID: ${teamId}`);

  // ── BOTS for ORCUS ───────────────────────────────────────────
  console.log('Creating bots for Orcus...');
  await firestorePost(`teams/${teamId}/bots`, {
    name: 'Raven',
    category: '60kg',
    imageUrl: '',
  });
  console.log('  ✅ Bot: Raven (60kg)');

  await firestorePost(`teams/${teamId}/bots`, {
    name: 'Vulcan',
    category: '15kg',
    imageUrl: '',
  });
  console.log('  ✅ Bot: Vulcan (15kg)');

  await firestorePost(`teams/${teamId}/bots`, {
    name: 'Nyx',
    category: '8kg',
    imageUrl: '',
  });
  console.log('  ✅ Bot: Nyx (8kg)');

  // ── PARTICIPANT: ARITRA GHOSH ─────────────────────────────────
  console.log('Creating participant: Aritra Ghosh...');
  const participantId = await firestorePost('participants', {
    uid: '',
    fullName: 'Aritra Ghosh',
    phone: '+919123852103',
    email: 'aritraghosh.ag2005@gmail.com',
    teamId: teamId,
    teamRole: 'Captain',
  });
  console.log(`  ✅ Participant created with ID: ${participantId}`);

  // ── LEADERBOARD ENTRY ─────────────────────────────────────────
  console.log('Creating leaderboard entry for Orcus...');
  await firestorePost('leaderboard', {
    teamId: teamId,
    teamName: 'Orcus',
    logoUrl: '',
    wins: 0,
    losses: 0,
    points: 0,
    rank: 1,
  });
  console.log('  ✅ Leaderboard entry created');

  // ── APP CONFIG: MOOD MESSAGE ──────────────────────────────────
  console.log('Setting initial mood message...');
  await firestorePatch('app_config/mood_message', {
    text: 'Let the battles begin! ⚡',
    updatedBy: 'system',
  });
  console.log('  ✅ Mood message set');

  console.log('\n🎉 Database seeded successfully!');
  console.log(`\n📋 Summary:`);
  console.log(`   Team ID: ${teamId}`);
  console.log(`   Participant: Aritra Ghosh (+919123852103)`);
  console.log(`   Bots: Raven (60kg), Vulcan (15kg), Nyx (8kg)`);
}

seed().catch(console.error);
