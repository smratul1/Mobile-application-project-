import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// One-time migration to fix documents that were saved without
/// a `createdAt` field. Firestore's `orderBy('createdAt')` query
/// silently excludes any document missing that field, which is
/// why old medications/doseLogs disappeared after logout/login.
///
/// This walks every document under the current user's
/// `medications` and `doseLogs` sub-collections and backfills
/// `createdAt` (using `updatedAt`, `loggedAt`, or now() as a
/// fallback, in that priority order) wherever it's missing.
class MigrationService {
  static const _prefsKey = 'migration_createdAt_backfill_done_v1';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Call this once, e.g. right after a successful login/init,
  /// with the current user's uid. Safe to call every app start —
  /// it no-ops after the first successful run (per device).
  Future<void> runCreatedAtBackfillIfNeeded(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final alreadyDone = prefs.getBool(_prefsKey) ?? false;
    if (alreadyDone) {
      print('[MIGRATION] Skipped — already completed on this device.');
      return;
    }

    print('[MIGRATION] Starting createdAt backfill for user=$userId');

    try {
      await _backfillCollection(
        userId: userId,
        collectionName: 'medications',
      );

      await _backfillCollection(
        userId: userId,
        collectionName: 'doseLogs',
        // doseLogs already store loggedAt as a Timestamp; prefer
        // that over "now" so ordering stays historically accurate.
        fallbackTimestampField: 'loggedAt',
      );

      await prefs.setBool(_prefsKey, true);
      print('[MIGRATION] Completed successfully.');
    } catch (e) {
      // Don't set the flag on failure — we want to retry next launch.
      print('[MIGRATION] FAILED => $e');
    }
  }

  Future<void> _backfillCollection({
    required String userId,
    required String collectionName,
    String? fallbackTimestampField,
  }) async {
    final collectionRef = _firestore
        .collection('users')
        .doc(userId)
        .collection(collectionName);

    final snapshot = await collectionRef.get();

    print('[MIGRATION] $collectionName: found ${snapshot.docs.length} docs');

    if (snapshot.docs.isEmpty) return;

    final batch = _firestore.batch();
    int fixedCount = 0;

    for (final doc in snapshot.docs) {
      final data = doc.data();

      final hasCreatedAt =
          data.containsKey('createdAt') && data['createdAt'] != null;

      if (hasCreatedAt) continue;

      // Prefer an existing timestamp field on the doc so ordering
      // reflects reality; fall back to updatedAt, then now().
      Timestamp backfillValue;

      final fallbackField = fallbackTimestampField;
      if (fallbackField != null &&
          data[fallbackField] is Timestamp) {
        backfillValue = data[fallbackField] as Timestamp;
      } else if (data['updatedAt'] is Timestamp) {
        backfillValue = data['updatedAt'] as Timestamp;
      } else {
        backfillValue = Timestamp.now();
      }

      batch.update(doc.reference, {'createdAt': backfillValue});
      fixedCount++;
    }

    if (fixedCount > 0) {
      await batch.commit();
      print('[MIGRATION] $collectionName: fixed $fixedCount doc(s)');
    } else {
      print('[MIGRATION] $collectionName: nothing to fix');
    }
  }

  /// Optional helper: call this if you ever need to force the
  /// migration to run again (e.g. while testing).
  Future<void> resetMigrationFlag() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);
  }
}
