import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/dose_log_model.dart';
import '../services/firestore_service.dart';

class DoseLogRepository {
  final FirestoreService _firestoreService = FirestoreService();

  // Log dose
  Future<String> logDose({
    required String userId,
    required String medicationId,
    required DateTime loggedAt,
    required bool taken,
    String? notes,
  }) async {
    try {
      final doseLog = DoseLogModel(
        id: '',
        medicationId: medicationId,
        loggedAt: loggedAt,
        taken: taken,
        notes: notes,
      );

      return await _firestoreService.logDose(
        userId: userId,
        doseLog: doseLog,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Update dose log
  Future<void> updateDoseLog({
    required String userId,
    required String doseLogId,
    bool? taken,
    DateTime? loggedAt,
    String? notes,
    String? date,
    String? time,
    bool? isRescheduled,
    String? originalTime,
  }) async {
    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('doseLogs')
          .doc(doseLogId)
          .get();

      if (!docSnapshot.exists) throw Exception('Dose log not found');

      final data = Map<String, dynamic>.from(docSnapshot.data()!);
      data.remove('id');
      final doseLog = DoseLogModel.fromMap({
        'id': docSnapshot.id,
        ...data,
      });

      final updatedDoseLog = doseLog.copyWith(
        taken: taken ?? doseLog.taken,
        loggedAt: loggedAt ?? doseLog.loggedAt,
        notes: notes ?? doseLog.notes,
        date: date ?? doseLog.date,
        time: time ?? doseLog.time,
        isRescheduled: isRescheduled ?? doseLog.isRescheduled,
        originalTime: originalTime ?? doseLog.originalTime,
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('doseLogs')
          .doc(doseLogId)
          .update(updatedDoseLog.toMap());
    } catch (e) {
      rethrow;
    }
  }

  // Delete dose log
  Future<void> deleteDoseLog({
    required String userId,
    required String doseLogId,
  }) async {
    try {
      await _firestoreService.deleteDoseLog(
        userId: userId,
        doseLogId: doseLogId,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<List<DoseLogModel>> getDoseLogs(String userId) async {
    try {
      return await _firestoreService.getDoseLogs(userId);
    } catch (e) {
      rethrow;
    }
  }

  // Get dose logs for medication
  Future<List<DoseLogModel>> getDoseLogsForMedication({
    required String userId,
    required String medicationId,
  }) async {
    try {
      return await _firestoreService.getDoseLogsForMedication(
        userId: userId,
        medicationId: medicationId,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Get dose logs for date
  Future<List<DoseLogModel>> getDoseLogsForDate({
    required String userId,
    required DateTime date,
  }) async {
    try {
      return await _firestoreService.getDoseLogsForDate(
        userId: userId,
        date: date,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Stream dose logs for date
  Stream<List<DoseLogModel>> streamDoseLogsForDate({
    required String userId,
    required DateTime date,
  }) {
    return _firestoreService.streamDoseLogsForDate(
      userId: userId,
      date: date,
    );
  }

  // Get today's dose logs
  Future<List<DoseLogModel>> getTodayDoseLogs(String userId) async {
    try {
      return await _firestoreService.getDoseLogsForDate(
        userId: userId,
        date: DateTime.now(),
      );
    } catch (e) {
      rethrow;
    }
  }

  // Stream today's dose logs
  Stream<List<DoseLogModel>> streamTodayDoseLogs(String userId) {
    return _firestoreService.streamDoseLogsForDate(
      userId: userId,
      date: DateTime.now(),
    );
  }

  // Get dose logs for date range
  Future<List<DoseLogModel>> getDoseLogsForDateRange({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final List<DoseLogModel> allLogs = [];
      var currentDate = DateTime(startDate.year, startDate.month, startDate.day);
      final end = DateTime(endDate.year, endDate.month, endDate.day);

      while (currentDate.isBefore(end) || currentDate.isAtSameMomentAs(end)) {
        final logs = await _firestoreService.getDoseLogsForDate(
          userId: userId,
          date: currentDate,
        );
        allLogs.addAll(logs);
        currentDate = currentDate.add(const Duration(days: 1));
      }

      return allLogs;
    } catch (e) {
      rethrow;
    }
  }

  // Get today's adherence (taken / total)
  Future<double> getTodayAdherence({
    required String userId,
    required List<String> medicationIds,
  }) async {
    try {
      final todayLogs = await getTodayDoseLogs(userId);

      if (todayLogs.isEmpty) return 0.0;

      final takenCount =
          todayLogs.where((log) => log.taken).length;
      final totalCount = todayLogs.length;

      return (takenCount / totalCount * 100).clamp(0.0, 100.0);
    } catch (e) {
      rethrow;
    }
  }

  // Get adherence for a period
  Future<double> getAdherenceForPeriod({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final logs = await getDoseLogsForDateRange(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
      );

      if (logs.isEmpty) return 100.0;

      final takenCount = logs.where((log) => log.taken).length;
      final totalCount = logs.length;

      return (takenCount / totalCount * 100).clamp(0.0, 100.0);
    } catch (e) {
      rethrow;
    }
  }

  // Check if dose was taken for medication on date
  Future<bool> isMedicationTaken({
    required String userId,
    required String medicationId,
    required DateTime date,
  }) async {
    try {
      final logs = await getDoseLogsForDate(userId: userId, date: date);
      return logs.any((log) =>
          log.medicationId == medicationId && log.taken);
    } catch (e) {
      rethrow;
    }
  }

  // Get statistics for a medication
  Future<Map<String, dynamic>> getMedicationStats({
    required String userId,
    required String medicationId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final logs = await getDoseLogsForMedication(
        userId: userId,
        medicationId: medicationId,
      );

      final logsInRange = logs
          .where((log) =>
              log.loggedAt.isAfter(startDate) &&
              log.loggedAt.isBefore(endDate))
          .toList();

      final takenCount =
          logsInRange.where((log) => log.taken).length;
      final missedCount =
          logsInRange.where((log) => !log.taken).length;

      return {
        'total': logsInRange.length,
        'taken': takenCount,
        'missed': missedCount,
        'adherence':
            logsInRange.isNotEmpty
                ? (takenCount / logsInRange.length * 100).clamp(0.0, 100.0)
                : 0.0,
      };
    } catch (e) {
      rethrow;
    }
  }
}
