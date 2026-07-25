import '../models/medication_model.dart';
import '../services/firestore_service.dart';

class MedicationRepository {
  final FirestoreService _firestoreService = FirestoreService();

  // Add medication
  Future<String> addMedication({
    required String userId,
    required String name,
    required String dosage,
    required String frequency,
    required List<String> times,
    required int pillCount,
    required String color,
    required DateTime startDate,
    required int frequencyPerDay,
    DateTime? endDate,
    String? notes,
  }) async {
    try {
      final medication = MedicationModel(
        id: '',
        name: name,
        dosage: dosage,
        frequency: frequency,
        times: times,
        pillCount: pillCount,
        color: color,
        startDate: startDate,
        endDate: endDate,
        frequencyPerDay: frequencyPerDay,
        notes: notes,
      );

      return await _firestoreService.addMedication(
        userId: userId,
        medication: medication,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Update medication
  Future<void> updateMedication({
    required String userId,
    required String medicationId,
    String? name,
    String? dosage,
    String? frequency,
    List<String>? times,
    int? pillCount,
    String? color,
    DateTime? endDate,
    String? notes,
  }) async {
    try {
      final medications =
          await _firestoreService.getMedications(userId);
      final medication = medications.firstWhere(
        (m) => m.id == medicationId,
      );

      final updatedMedication = medication.copyWith(
        name: name ?? medication.name,
        dosage: dosage ?? medication.dosage,
        frequency: frequency ?? medication.frequency,
        times: times ?? medication.times,
        pillCount: pillCount ?? medication.pillCount,
        color: color ?? medication.color,
        endDate: endDate ?? medication.endDate,
        notes: notes ?? medication.notes,
      );

      await _firestoreService.updateMedication(
        userId: userId,
        medicationId: medicationId,
        medication: updatedMedication,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Delete medication
  Future<void> deleteMedication({
    required String userId,
    required String medicationId,
  }) async {
    try {
      await _firestoreService.deleteMedication(
        userId: userId,
        medicationId: medicationId,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Get all medications
  Future<List<MedicationModel>> getMedications(String userId) async {
    try {
      return await _firestoreService.getMedications(userId);
    } catch (e) {
      rethrow;
    }
  }

  // Stream medications
  Stream<List<MedicationModel>> streamMedications(String userId) {
    return _firestoreService.streamMedications(userId);
  }

  // Get active medications (not ended)
  Future<List<MedicationModel>> getActiveMedications(String userId) async {
    try {
      final medications = await _firestoreService.getMedications(userId);
      final now = DateTime.now();
      return medications
          .where(
            (m) =>
                m.startDate.isBefore(now) &&
                (m.endDate == null || m.endDate!.isAfter(now)),
          )
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Get medications ending soon (within 7 days)
  Future<List<MedicationModel>> getMedicationsEndingSoon(
    String userId,
  ) async {
    try {
      final medications = await _firestoreService.getMedications(userId);
      final now = DateTime.now();
      final oneWeekLater = now.add(const Duration(days: 7));

      return medications
          .where(
            (m) =>
                m.endDate != null &&
                m.endDate!.isAfter(now) &&
                m.endDate!.isBefore(oneWeekLater),
          )
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Get total pills remaining today
  Future<int> getTotalPillsToday(String userId) async {
    try {
      final medications = await getActiveMedications(userId);
      int totalPills = 0;

      for (final med in medications) {
        totalPills += med.pillCount * med.frequencyPerDay;
      }

      return totalPills;
    } catch (e) {
      rethrow;
    }
  }
}
