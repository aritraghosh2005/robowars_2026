package robowars.com.robowars_app

import android.content.Context
import android.content.SharedPreferences
import androidx.work.Worker
import androidx.work.WorkerParameters
import com.google.android.gms.tasks.Tasks
import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.firestore.DocumentSnapshot
import com.google.firebase.firestore.FirebaseFirestore
import com.google.firebase.firestore.FirebaseFirestoreException
import com.google.firebase.firestore.Query
import com.google.firebase.firestore.Source
import java.util.concurrent.ExecutionException
import java.util.concurrent.TimeUnit
import java.util.concurrent.TimeoutException

class NotificationPollingWorker(
    appContext: Context,
    workerParams: WorkerParameters,
) : Worker(appContext, workerParams) {
    companion object {
        private const val PREFERENCES = "notification_polling"
        private const val KEY_INITIALIZED = "initialized"
        private const val KEY_SEEN_IDS = "seen_notification_ids"
        private const val KEY_CALLUPS_INITIALIZED = "callups_initialized"
        private const val KEY_SEEN_CALLUP_IDS = "seen_callup_ids"
        private const val QUERY_LIMIT = 100L
        private const val TIMEOUT_SECONDS = 25L
    }

    override fun doWork(): Result {
        val user = FirebaseAuth.getInstance().currentUser ?: return Result.success()
        val firestore = FirebaseFirestore.getInstance()

        return try {
            val userDocument = Tasks.await(
                firestore.collection("users").document(user.uid).get(Source.SERVER),
                TIMEOUT_SECONDS,
                TimeUnit.SECONDS,
            )
            if (userDocument.getString("role") != "participant") {
                return Result.success()
            }
            val teamId = userDocument.getString("teamId")

            val notificationSnapshot = Tasks.await(
                firestore.collection("notifications")
                    .orderBy("timestamp", Query.Direction.DESCENDING)
                    .limit(QUERY_LIMIT)
                    .get(Source.SERVER),
                TIMEOUT_SECONDS,
                TimeUnit.SECONDS,
            )
            val preferences = applicationContext.getSharedPreferences(
                PREFERENCES,
                Context.MODE_PRIVATE,
            )
            val currentIds = notificationSnapshot.documents.mapTo(linkedSetOf()) { it.id }

            if (!preferences.getBoolean(KEY_INITIALIZED, false)) {
                preferences.edit()
                    .putBoolean(KEY_INITIALIZED, true)
                    .putStringSet(KEY_SEEN_IDS, currentIds)
                    .apply()
            } else {
                val seenIds = preferences.getStringSet(KEY_SEEN_IDS, emptySet())
                    ?.toSet()
                    .orEmpty()
                notificationSnapshot.documents
                    .asReversed()
                    .filter { document ->
                        document.id !in seenIds &&
                            document.getString("deliveryStatus") != "sent"
                    }
                    .forEach { document ->
                        val title = document.getString("title") ?: "Robowars update"
                        val body = document.getString("content") ?: return@forEach
                        NotificationHelper.show(
                            applicationContext,
                            title,
                            body,
                            document.id.hashCode(),
                        )
                    }

                preferences.edit().putStringSet(KEY_SEEN_IDS, currentIds).apply()
            }

            if (!teamId.isNullOrBlank()) {
                pollTeamCallups(firestore, teamId, preferences)
            }
            Result.success()
        } catch (error: Exception) {
            val cause = if (error is ExecutionException) error.cause ?: error else error
            when {
                cause is TimeoutException -> Result.retry()
                cause is FirebaseFirestoreException -> when (cause.code) {
                    FirebaseFirestoreException.Code.ABORTED,
                    FirebaseFirestoreException.Code.DEADLINE_EXCEEDED,
                    FirebaseFirestoreException.Code.RESOURCE_EXHAUSTED,
                    FirebaseFirestoreException.Code.UNAVAILABLE,
                    -> Result.retry()

                    else -> Result.success()
                }

                else -> Result.retry()
            }
        }
    }

    private fun pollTeamCallups(
        firestore: FirebaseFirestore,
        teamId: String,
        preferences: SharedPreferences,
    ) {
        val snapshot = Tasks.await(
            firestore.collection("callups")
                .whereEqualTo("teamId", teamId)
                .limit(QUERY_LIMIT)
                .get(Source.SERVER),
            TIMEOUT_SECONDS,
            TimeUnit.SECONDS,
        )
        val currentIds = snapshot.documents.mapTo(linkedSetOf()) { it.id }
        val pendingCallups = snapshot.documents
            .filter { document ->
                document.getBoolean("isActive") != false &&
                    document.getString("deliveryStatus") != "sent"
            }
            .sortedBy { document -> document.getTimestamp("timestamp") }

        if (!preferences.getBoolean(KEY_CALLUPS_INITIALIZED, false)) {
            pendingCallups.lastOrNull()?.let(::showCallup)
            preferences.edit()
                .putBoolean(KEY_CALLUPS_INITIALIZED, true)
                .putStringSet(KEY_SEEN_CALLUP_IDS, currentIds)
                .apply()
            return
        }

        val seenIds = preferences.getStringSet(KEY_SEEN_CALLUP_IDS, emptySet())
            ?.toSet()
            .orEmpty()
        pendingCallups
            .filter { document -> document.id !in seenIds }
            .forEach(::showCallup)
        preferences.edit().putStringSet(KEY_SEEN_CALLUP_IDS, currentIds).apply()
    }

    private fun showCallup(document: DocumentSnapshot) {
        val teamName = document.getString("teamName") ?: "your team"
        val body = document.getString("message") ?: return
        NotificationHelper.show(
            applicationContext,
            "URGENT CALL-UP: $teamName",
            body,
            document.id.hashCode(),
        )
    }
}
