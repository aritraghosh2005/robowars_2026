# Backend & Database — Robowars 2026

Full-stack implementation plan covering Firebase backend, three-role authentication, Firestore schema, real-time notifications, an admin control panel, and seamless MVVM integration into the existing Flutter app.

---

## Tech Stack Decision

| Layer | Technology | Rationale |
|---|---|---|
| **Database** | Cloud Firestore | Real-time listeners, offline support, Flutter-native SDK |
| **Auth** | Firebase Auth | OTP via Phone, Email/Password, Custom Token for Admin |
| **Push Notifications** | Firebase Cloud Messaging (FCM) + Cloud Functions | Priority-ranked delivery, topic-based subscriptions |
| **Backend Logic** | Firebase Cloud Functions (Node.js 20) | OTP validation, match-end cleanup, admin token minting, call-up trigger |
| **Storage** | Firebase Storage | Team logos, bot images, profile avatars |
| **Admin Panel** | Flutter Web (same codebase, admin-flagged routes) | Consistent UI, no extra codebase to maintain |
| **State Management** | Riverpod (already in app) | Unchanged; repositories surface `Stream<T>` and `Future<T>` |
| **Architecture** | MVVM + Repository Pattern + Use Cases | Strict separation — Data → Repository → Use Case → ViewModel → View |

---

## User Roles & Auth Strategy

### Role 1 — Viewer
- **Sign in**: Email/Password **or** Anonymous (read-only until they try to predict)
- **Trigger**: Clicking "Predict" while unauthenticated instantly opens the Auth screen
- **Access**: Read schedule, leaderboard, teams, updates. Submit/read own predictions
- **Firestore rule claim**: `role == "viewer"`

### Role 2 — Participant
- **Sign in**: Phone number → Firebase Phone Auth (OTP SMS)
- **Pre-condition**: Phone number must already exist in the `participants` Firestore collection (seeded by admin); any unrecognised number is rejected
- **Access**: All viewer capabilities + priority match notifications + personalised profile with team details
- **Firestore rule claim**: `role == "participant"`, `teamId` custom claim

### Role 3 — Admin
- **Sign in**: Developer-generated **custom token** (created via Cloud Function using a secret env variable + a hardcoded admin UID list in Firestore). Password is a one-time hash shared securely.
- **No public sign-up path** — the Admin Login screen is a hidden route (`/admin-login`)
- **Access**: Full CRUD on all collections, send notifications with priority, trigger call-ups
- **Firestore rule claim**: `role == "admin"`

---

## Firestore Database Schema

### Collection: `users`
```
users/{uid}
  ├── uid: string
  ├── displayName: string
  ├── email: string?           // viewers only
  ├── phone: string?           // participants only
  ├── role: "viewer" | "participant" | "admin"
  ├── fcmToken: string         // updated on every app launch
  ├── teamId: string?          // participants only (ref to teams/{id})
  ├── createdAt: Timestamp
  └── lastLoginAt: Timestamp
```

### Collection: `teams`
```
teams/{teamId}
  ├── name: string
  ├── college: string
  ├── description: string
  ├── logoUrl: string          // Firebase Storage URL
  ├── wins: int
  ├── losses: int
  ├── points: int
  ├── rank: int                // updated by Cloud Function post-match
  ├── createdAt: Timestamp
  └── bots: [                  // subcollection (see below)
        bots/{botId}
          ├── name: string
          ├── weight: string
          ├── category: string  // e.g. "Antweight", "Featherweight"
          └── imageUrl: string
      ]
```

### Subcollection: `teams/{teamId}/bots`
```
teams/{teamId}/bots/{botId}
  ├── name: string
  ├── weight: string
  ├── category: string
  └── imageUrl: string
```

### Collection: `participants`
```
participants/{participantId}
  ├── uid: string?             // null until they log in for the first time
  ├── fullName: string
  ├── phone: string            // E.164 format, used for OTP gate
  ├── email: string?
  ├── teamId: string           // ref → teams/{teamId}
  ├── role: string             // e.g. "Driver", "Designer", "Captain"
  └── registeredAt: Timestamp
```

### Collection: `matches`
```
matches/{matchId}
  ├── team1Id: string          // ref → teams/{teamId}
  ├── team2Id: string          // ref → teams/{teamId}
  ├── bot1Id: string           // ref → teams/{teamId}/bots/{botId}
  ├── bot2Id: string
  ├── category: string
  ├── scheduledAt: Timestamp
  ├── arena: string
  ├── status: "upcoming" | "live" | "completed" | "cancelled"
  ├── winnerId: string?        // teamId of winner (null until complete)
  ├── scoreTeam1: int
  ├── scoreTeam2: int
  ├── round: string            // e.g. "Quarterfinal", "Final"
  └── updatedAt: Timestamp
```

### Collection: `predictions`
```
predictions/{predictionId}
  ├── userId: string           // ref → users/{uid}
  ├── matchId: string          // ref → matches/{matchId}
  ├── predictedWinnerId: string// teamId they predicted
  ├── isCorrect: bool?         // null until match ends, set by Cloud Function
  ├── createdAt: Timestamp
  └── matchScheduledAt: Timestamp // denormalised for rule: must be in future
```
> **Post-match cleanup**: A Cloud Function triggered on `matches/{matchId}` write (when `status → "completed"`) marks all predictions for that match as correct/incorrect, **then deletes** all incorrect predictions. Only winning predictions remain.

### Collection: `updates`
```
updates/{updateId}
  ├── title: string
  ├── content: string
  ├── tag: "match" | "result" | "urgent" | "general" | "callup"
  ├── priority: 1 | 2 | 3      // 1=urgent, 3=low
  ├── targetRole: "all" | "viewer" | "participant" | "admin"
  ├── targetTeamId: string?    // if scoped to a specific team
  ├── sentBy: string           // uid of admin
  ├── fcmSent: bool
  ├── createdAt: Timestamp
  └── scheduledAt: Timestamp?  // null = send now
```

### Collection: `leaderboard`  *(denormalised, updated by Cloud Function)*
```
leaderboard/{teamId}
  ├── teamId: string
  ├── teamName: string
  ├── logoUrl: string
  ├── wins: int
  ├── losses: int
  ├── points: int
  └── rank: int
```

### Collection: `admins`  *(sealed by security rules — only readable by admin role)*
```
admins/{adminId}
  ├── uid: string
  ├── displayName: string
  ├── email: string
  └── grantedAt: Timestamp
```

### Collection: `callups`
```
callups/{callupId}
  ├── matchId: string
  ├── teamIds: string[]        // teams to be called
  ├── arena: string
  ├── reportIn: int            // minutes before match
  ├── sentAt: Timestamp
  └── sentBy: string           // admin uid
```

---

## Firestore Security Rules Summary

| Collection | Viewer | Participant | Admin |
|---|---|---|---|
| `users/{uid}` | Read own | Read own, write own | Read/write all |
| `teams` | Read | Read | CRUD |
| `teams/bots` | Read | Read | CRUD |
| `participants` | None | Read own | CRUD |
| `matches` | Read | Read | CRUD |
| `predictions` | Read/write own (only if match is upcoming) | Read/write own | Read all |
| `updates` | Read | Read | CRUD |
| `leaderboard` | Read | Read | Read |
| `admins` | None | None | Read |
| `callups` | None | Read (own teamId) | CRUD |

---

## Cloud Functions

### 1. `onMatchCompleted` (Firestore trigger)
- Triggered: `matches/{matchId}` `onUpdate` when `status` changes to `"completed"`
- Actions:
  - Sets `isCorrect` on all predictions for that match
  - Deletes incorrect predictions
  - Updates `teams/{winnerId}` → increment `wins` and `points`
  - Updates `teams/{loserId}` → increment `losses`
  - Recalculates and updates `leaderboard` collection
  - Sends FCM notification to the winning/losing team participants

### 2. `mintAdminToken` (HTTPS callable)
- Input: `{ password: string }`
- Validates password hash against Firestore `admins` doc
- Returns a Firebase custom token with `role: "admin"` custom claim
- Rate-limited to 5 attempts per IP per hour

### 3. `validateParticipantPhone` (HTTPS callable, pre-OTP)
- Input: `{ phone: string }`
- Checks if phone exists in `participants` collection
- Returns `{ allowed: bool }` — Flutter only calls `signInWithPhoneNumber` if `allowed: true`
- Prevents arbitrary phone numbers from registering

### 4. `onUserCreated` (Auth trigger)
- Triggered: `auth.user().onCreate`
- Reads `participants` collection for matching phone
- If found: sets custom claim `role: "participant"`, `teamId`
- Else: sets custom claim `role: "viewer"`
- Creates `users/{uid}` document

### 5. `sendCallup` (HTTPS callable, admin only)
- Input: `{ matchId, teamIds[], arena, reportIn }`
- Verifies caller has `role: "admin"` custom claim
- Sends high-priority FCM to all FCM tokens of participants in specified teams
- Writes `callups/{id}` document
- Creates an `updates` entry with tag `"callup"`

### 6. `sendBroadcastNotification` (HTTPS callable, admin only)
- Input: `{ title, content, priority, targetRole, targetTeamId? }`
- Admin-only gated
- Sends FCM to topic (e.g. `role_participant`, `team_{teamId}`)
- Writes `updates` document

---

## FCM Notification Architecture

### Topics
| Topic Name | Subscribed By |
|---|---|
| `role_all` | All users on first app open |
| `role_viewer` | All viewers |
| `role_participant` | All participants |
| `team_{teamId}` | Participants of that team |
| `match_{matchId}` | Anyone who predicted that match |

### Notification Priority Levels
| Priority | Use Case | FCM Priority |
|---|---|---|
| 1 — Urgent | Call-up, match about to start | `high`, heads-up display |
| 2 — Important | Match result, score update | `high` |
| 3 — General | Broadcast updates | `normal` |

---

## Flutter App Architecture Changes

### New Folder Structure (additions to existing)
```
lib/
├── core/
│   ├── theme/               ← existing
│   ├── firebase/
│   │   ├── firebase_options.dart      ← generated by FlutterFire CLI
│   │   └── firebase_providers.dart    ← Riverpod providers for Firebase instances
│   ├── auth/
│   │   ├── auth_repository.dart       ← abstract interface
│   │   ├── firebase_auth_repository.dart
│   │   └── auth_providers.dart
│   ├── routing/
│   │   ├── app_router.dart            ← go_router with auth guards
│   │   └── route_guard.dart
│   └── utils/
│       ├── phone_formatter.dart
│       └── error_handler.dart
│
├── features/
│   ├── auth/
│   │   ├── models/
│   │   │   └── app_user.dart           ← unified user model
│   │   ├── repositories/
│   │   │   └── auth_repository.dart
│   │   ├── viewmodels/
│   │   │   ├── auth_viewmodel.dart
│   │   │   └── otp_viewmodel.dart
│   │   └── views/
│   │       ├── auth_screen.dart        ← unified entry for viewer login
│   │       ├── otp_screen.dart         ← phone OTP screen for participants
│   │       └── admin_login_screen.dart ← hidden route
│   │
│   ├── home/             ← existing, wire to Firestore
│   ├── schedule/         ← existing, wire to Firestore
│   ├── updates/          ← existing, wire to Firestore
│   ├── teams/            ← existing, wire to Firestore
│   ├── leaderboard/      ← currently inside teams, extract to own feature
│   ├── profile/          ← existing, wire to Firestore user doc
│   ├── prediction/       ← existing, add auth gate + Firestore write
│   │
│   └── admin/            ← NEW — admin-only feature
│       ├── models/
│       ├── repositories/
│       ├── viewmodels/
│       └── views/
│           ├── admin_dashboard_screen.dart
│           ├── match_editor_screen.dart
│           ├── team_editor_screen.dart
│           ├── leaderboard_editor_screen.dart
│           ├── updates_composer_screen.dart
│           ├── notification_sender_screen.dart
│           └── callup_screen.dart
│
└── shared/
    ├── widgets/          ← existing
    ├── repositories/     ← NEW
    │   ├── base_repository.dart
    │   ├── team_repository.dart
    │   ├── match_repository.dart
    │   ├── prediction_repository.dart
    │   ├── update_repository.dart
    │   └── leaderboard_repository.dart
    └── use_cases/        ← NEW
        ├── submit_prediction_use_case.dart
        ├── resolve_predictions_use_case.dart
        └── send_callup_use_case.dart
```

---

## Implementation Phases

### Phase 1 — Firebase Setup
1. Create Firebase project (`robowars-2026`)
2. Enable Firestore, Firebase Auth (Email/Password, Phone), FCM, Firebase Storage
3. Run `flutterfire configure` to generate `firebase_options.dart`
4. Add dependencies to `pubspec.yaml`:
   - `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_messaging`, `firebase_storage`, `cloud_functions`, `go_router`, `firebase_analytics`
5. Initialize Firebase in `main.dart` with `WidgetsFlutterBinding.ensureInitialized()` and `Firebase.initializeApp()`
6. Write and deploy Firestore security rules
7. Create Firebase Storage bucket rules

### Phase 2 — Auth Layer
1. Implement `AppUser` model (wraps `firebase_auth.User` + custom claims)
2. Implement `FirebaseAuthRepository` with:
   - `signInWithEmailPassword()`
   - `signInWithPhone()` (participant gate: calls `validateParticipantPhone` Cloud Function first)
   - `verifyOtp()`
   - `signInWithCustomToken()` (admin)
   - `signOut()`
   - `Stream<AppUser?> authStateChanges`
3. Implement `AuthViewModel` (Riverpod `AsyncNotifier`)
4. Implement `OtpViewModel`
5. Build `AuthScreen`, `OtpScreen`, `AdminLoginScreen` views
6. Add `go_router` with `redirect` guards based on role
7. Add auth gate to the Prediction flow

### Phase 3 — Data Layer (Repositories + ViewModels)
1. **TeamRepository**: `Stream<List<Team>> watchTeams()`, `Stream<List<Bot>> watchBots(teamId)`, CRUD for admin
2. **MatchRepository**: `Stream<List<Match>> watchMatches({status?})`, CRUD for admin
3. **PredictionRepository**: `Future<void> submitPrediction()`, `Stream<List<Prediction>> watchMyPredictions(userId)`, delete incorrect ones via Cloud Function
4. **UpdateRepository**: `Stream<List<Update>> watchUpdates()`, `Future<void> createUpdate()` (admin)
5. **LeaderboardRepository**: `Stream<List<LeaderboardEntry>> watchLeaderboard()`
6. **ProfileRepository**: `Stream<AppUser> watchUser(uid)`, `Future<void> updateFcmToken()`
7. Wire existing ViewModels — replace all hardcoded data with repository `Stream`s
8. Replace `TabLoadingWrapper`'s 2s fake delay with Riverpod `AsyncValue` loading states from the actual streams

### Phase 4 — Cloud Functions (Node.js)
1. Init Cloud Functions project in `/functions`
2. Implement all 6 functions described above
3. Write unit tests for `onMatchCompleted` cleanup logic
4. Deploy and test in Firebase Emulator Suite first

### Phase 5 — Notifications
1. `FirebaseMessaging.instance.requestPermission()` on first app launch
2. Subscribe users to relevant FCM topics after login
3. Handle foreground messages with `flutter_local_notifications` overlay
4. Handle background/terminated launch via `getInitialMessage()` / `onMessageOpenedApp`
5. Implement notification routing (open correct screen based on notification payload)

### Phase 6 — Admin Panel
1. Build `AdminDashboardScreen` with 6 tiles (Matches, Teams, Leaderboard, Updates, Notifications, Call-ups)
2. **Match Editor**: Add/edit/delete matches; change status to `live`/`completed`; enter winner and scores
3. **Team Editor**: Add/edit/delete teams and bots; upload images to Firebase Storage
4. **Leaderboard Editor**: Manual rank override (auto-calculated by Cloud Function, but admin can override)
5. **Updates Composer**: Rich text; select priority, target role/team; schedule or send now
6. **Notification Sender**: Title, body, priority, target audience
7. **Call-up Screen**: Select upcoming match → select teams → set "report in X minutes" → send
8. Protect all admin routes with role guard

### Phase 7 — Profile Integration
1. Show participant's team name, bot names, role (Driver/Captain etc.) from `participants` doc
2. Show their correct predictions count from remaining `predictions` docs
3. Show win/loss record of their team from `teams` doc
4. Show all incoming notifications/callups targeted at their team

### Phase 8 — Polish & Security Audit
1. Full Firestore security rules review and testing with `firebase emulators:exec`
2. Error handling for network failures, auth errors, OTP timeouts
3. Offline persistence configuration for Firestore
4. Rate limiting validation on Cloud Functions
5. Admin route obfuscation (no visible link in drawer — must know the URL/deep-link)

---

## Open Questions for Review

> [!IMPORTANT]
> **OTP Login**: Participants will receive an SMS OTP via Firebase Phone Auth. This requires a real phone number in `+91XXXXXXXXXX` format in the database. Will registration data be manually seeded by you (the developer) into Firestore before the event, or does admin need a UI to add participants too?

> [!IMPORTANT]
> **Admin Password Strategy**: Admins log in using a custom token. The password(s) will be generated by you and stored as environment variables in Cloud Functions. How many admin accounts are needed and should there be a hierarchy (super-admin vs sub-admin)?

> [!IMPORTANT]
> **Prediction Points**: Should correct predictions award viewer/participant points visible in a "prediction leaderboard", or is the prediction feature purely for engagement (no scoring)?

> [!NOTE]
> **Email Auth for Viewers**: The plan uses Email/Password for viewers. Should Google Sign-In also be offered for a faster onboarding experience?

> [!NOTE]
> **Offline Support**: Firestore offline persistence is enabled by default. Should the app show a specific "you're offline" banner, or just show the last-cached data silently?
