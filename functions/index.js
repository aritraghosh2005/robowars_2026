const {onDocumentUpdated, onDocumentCreated} = require("firebase-functions/v2/firestore");
const {onCall, HttpsError} = require("firebase-functions/v2/https");
const {beforeUserCreated} = require("firebase-functions/v2/identity");
const logger = require("firebase-functions/logger");
const admin = require("firebase-admin");

admin.initializeApp();
const db = admin.firestore();
const messaging = admin.messaging();

/**
 * 1. onMatchCompleted - Firestore trigger
 * Triggered when a match status changes to "completed".
 */
exports.onMatchCompleted = onDocumentUpdated("matches/{matchId}", async (event) => {
  const matchId = event.params.matchId;
  const newValue = event.data.after.data();
  const previousValue = event.data.before.data();

  // Only run if status changed to completed
  if (newValue.status === "completed" && previousValue.status !== "completed") {
    const winnerId = newValue.winnerId;
    const loserId = winnerId === newValue.team1Id ? newValue.team2Id : newValue.team1Id;
    const winnerPoints = newValue.winnerPoints || 0;
    const loserPoints = newValue.loserPoints || 0;

    if (!winnerId) {
      logger.error(`Match ${matchId} completed but no winnerId set.`);
      return;
    }

    try {
      const batch = db.batch();

      // Older clients rely on this trigger for score updates. New clients set
      // pointsApplied after updating both team totals in one transaction.
      if (newValue.pointsApplied !== true) {
        const winnerRef = db.collection("teams").doc(winnerId);
        batch.update(winnerRef, {
          wins: admin.firestore.FieldValue.increment(1),
          pts: admin.firestore.FieldValue.increment(winnerPoints),
        });

        const loserRef = db.collection("teams").doc(loserId);
        batch.update(loserRef, {
          losses: admin.firestore.FieldValue.increment(1),
          pts: admin.firestore.FieldValue.increment(loserPoints),
        });
      }

      // 2. Process Predictions
      const predictionsSnapshot = await db.collectionGroup("predictions")
          .where("matchId", "==", matchId)
          .get();

      predictionsSnapshot.forEach((doc) => {
        const prediction = doc.data();
        if (prediction.status !== "pending") return;
        if (prediction.predictedWinnerTeamId === winnerId) {
          // Correct prediction
          const pointsAwarded = Math.round(100 * (prediction.pointsMultiplier || 1.0));
          batch.update(doc.ref, {
            status: "won",
            pointsAwarded: pointsAwarded,
            isCorrect: true,
          });
          // Reward user
          const userRef = db.collection("users").doc(prediction.userId);
          batch.update(userRef, {
            predictionPoints: admin.firestore.FieldValue.increment(pointsAwarded),
          });
        } else {
          batch.update(doc.ref, {
            status: "lost",
            pointsAwarded: 0,
            isCorrect: false,
          });
        }
      });

      await batch.commit();

      // 3. Send Notification to Winning Team
      await messaging.send({
        topic: `team_${winnerId}`,
        notification: {
          title: "Match Won! 🎉",
          body: "Congratulations! Your team won the match.",
        },
        data: { matchId: matchId },
      });

      logger.info(`Successfully processed match ${matchId} completion.`);
    } catch (error) {
      logger.error("Error processing match completion", error);
    }
  }
});

/**
 * 2. onNotificationCreated - Firestore trigger
 * Triggered when a new notification is created. Broadcasts to all participants.
 */
exports.onNotificationCreated = onDocumentCreated("notifications/{notificationId}", async (event) => {
  const data = event.data.data();
  if (!data) return;

  try {
    const messageId = await messaging.send({
      topic: "participants",
      notification: {
        title: data.title,
        body: data.content,
      },
      android: {
        priority: "high",
        notification: {
          channelId: "robowars_alerts",
          sound: "default",
        },
      },
    });
    await event.data.ref.update({
      deliveryStatus: "sent",
      deliveredAt: admin.firestore.FieldValue.serverTimestamp(),
      fcmMessageId: messageId,
    });
    logger.info(`Successfully sent notification broadcast: ${data.title}`);
  } catch (error) {
    await event.data.ref.update({
      deliveryStatus: "failed",
      deliveryError: error.message || String(error),
    });
    logger.error("Error sending notification broadcast", error);
  }
});

/**
 * 3. onCallupCreated - Firestore trigger
 * Triggered when a new callup is created. Broadcasts to the specific team.
 */
exports.onCallupCreated = onDocumentCreated("callups/{callupId}", async (event) => {
  const data = event.data.data();
  if (!data || !data.isActive) return;

  try {
    const messageId = await messaging.send({
      topic: `team_${data.teamId}`,
      notification: {
        title: `URGENT CALL-UP: ${data.teamName}`,
        body: data.message,
      },
      android: {
        priority: "high",
        notification: {
          channelId: "robowars_alerts",
          sound: "default",
        },
      },
      apns: {
        payload: {
          aps: {
            contentAvailable: true,
          },
        },
      },
    });
    await event.data.ref.update({
      deliveryStatus: "sent",
      deliveredAt: admin.firestore.FieldValue.serverTimestamp(),
      fcmMessageId: messageId,
    });
    logger.info(`Successfully sent callup to team_${data.teamId}`);
  } catch (error) {
    await event.data.ref.update({
      deliveryStatus: "failed",
      deliveryError: error.message || String(error),
    });
    logger.error("Error sending callup", error);
  }
});

async function resolveRoleForEmail(email) {
  const normalizedEmail = (email || "").trim().toLowerCase();
  if (!normalizedEmail) {
    return {role: "viewer", teamId: null, participantRef: null};
  }

  const [adminSnapshot, participantSnapshot] = await Promise.all([
    db.collection("admins")
        .where("email", "==", normalizedEmail)
        .limit(1)
        .get(),
    db.collection("participants")
        .where("email", "==", normalizedEmail)
        .limit(1)
        .get(),
  ]);

  if (!adminSnapshot.empty) {
    return {role: "admin", teamId: null, participantRef: null};
  }

  if (!participantSnapshot.empty) {
    const participant = participantSnapshot.docs[0];
    if (participant.data().isActive === false) {
      return {role: "viewer", teamId: null, participantRef: null};
    }
    return {
      role: "participant",
      teamId: participant.data().teamId || null,
      participantRef: participant.ref,
    };
  }

  return {role: "viewer", teamId: null, participantRef: null};
}

/**
 * Assigns initial claims when a Firebase Auth user is first created.
 */
exports.onUserCreated = beforeUserCreated(async (event) => {
  const user = event.data;
  const resolved = await resolveRoleForEmail(user.email);

  if (resolved.participantRef) {
    await resolved.participantRef.update({uid: user.uid});
  }

  await db.collection("users").doc(user.uid).set({
    uid: user.uid,
    displayName: user.displayName || user.email || "User",
    email: user.email || "",
    phone: user.phoneNumber || "",
    avatarUrl: user.photoURL || "",
    role: resolved.role,
    teamId: resolved.teamId,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    lastLoginAt: admin.firestore.FieldValue.serverTimestamp(),
    fcmToken: "",
    onboardingCompleted: false,
    predictionPoints: 0,
  });

  return {
    customClaims: {
      role: resolved.role,
      teamId: resolved.teamId,
    },
  };
});

async function assertAdmin(request) {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Sign in first.");
  }

  let email = request.auth.token.email;
  if (!email) {
    const user = await admin.auth().getUser(request.auth.uid);
    email = user.email;
  }

  const normalizedEmail = (email || "").trim().toLowerCase();
  const adminSnapshot = await db.collection("admins")
      .where("email", "==", normalizedEmail)
      .limit(1)
      .get();
  if (adminSnapshot.empty) {
    throw new HttpsError("permission-denied", "Admin only.");
  }
}

/**
 * 5. sendCallup - HTTPS Callable (Admin only)
 */
exports.sendCallup = onCall(async (request) => {
  await assertAdmin(request);

  const { matchId, teamIds, arena, reportInMinutes } = request.data;

  // Create callup doc
  await db.collection("callups").add({
    matchId,
    teamIds,
    arena,
    reportInMinutes,
    sentAt: admin.firestore.FieldValue.serverTimestamp(),
    sentBy: request.auth.uid,
  });

  // Create updates doc
  await db.collection("updates").add({
    title: "Call Up! 🚨",
    content: `Teams requested at ${arena} in ${reportInMinutes} minutes.`,
    tag: "callup",
    priority: 1,
    targetRole: "participant",
    sentBy: request.auth.uid,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  // Send FCM
  for (const teamId of teamIds) {
    await messaging.send({
      topic: `team_${teamId}`,
      notification: {
        title: "Match Call Up 🚨",
        body: `Your team is called to ${arena} in ${reportInMinutes} minutes!`,
      },
      android: {
        priority: "high",
      },
    });
  }

  return { success: true };
});

/**
 * 6. sendBroadcastNotification - HTTPS Callable (Admin only)
 */
exports.sendBroadcastNotification = onCall(async (request) => {
  await assertAdmin(request);

  const { title, body, targetRole, priority } = request.data;
  
  let topic = "role_all";
  if (targetRole === "viewer") topic = "role_viewer";
  if (targetRole === "participant") topic = "participants";

  // Send FCM
  await messaging.send({
    topic: topic,
    notification: {
      title: title,
      body: body,
    },
  });

  // Create updates doc
  await db.collection("updates").add({
    title: title,
    content: body,
    tag: "general",
    priority: priority || 3,
    targetRole: targetRole || "all",
    sentBy: request.auth.uid,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  return { success: true };
});

/**
 * 7. computeEarlyBirdMultiplier - HTTPS Callable
 */
exports.computeEarlyBirdMultiplier = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Must be logged in.");
  }

  const { matchId } = request.data;
  const matchDoc = await db.collection("matches").doc(matchId).get();
  
  if (!matchDoc.exists) {
    throw new HttpsError("not-found", "Match not found.");
  }

  const match = matchDoc.data();
  const now = admin.firestore.Timestamp.now();
  
  // Basic implementation: if you bet more than 1 hour before, multiplier is 1.5. 
  // If less than 1 hour before, multiplier is 1.0.
  const oneHourBefore = new admin.firestore.Timestamp(
    match.scheduledAt.seconds - 3600,
    0
  );

  let multiplier = 1.0;
  if (now.toMillis() < oneHourBefore.toMillis()) {
    multiplier = 1.5;
  }

  return { multiplier: multiplier };
});
