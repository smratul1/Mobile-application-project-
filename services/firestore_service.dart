import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/medication_model.dart';
import '../models/dose_log_model.dart';
import '../models/tracker_entry_model.dart';
import '../models/appointment_model.dart';

class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();

  factory FirestoreService() {
    return _instance;
  }

  FirestoreService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection references
  CollectionReference get usersCollection => _firestore.collection('users');
  CollectionReference get medicationsCollection =>
      _firestore.collection('medications');
  CollectionReference get doseLogsCollection => _firestore.collection('doseLogs');

  // ======================== USER OPERATIONS ========================

  // Create or update user document
  Future<void> setUserData({
  required String userId,
  required String email,
  required String name,
  String? photoUrl,
  String? birthDate,
}) async {

  print("FIRESTORE STEP 1");

  try {

    print("Writing User : $userId");

    await FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .set({
      "email": email,
      "name": name,
      "photoUrl": photoUrl,
      "birthDate": birthDate,
      "createdAt": FieldValue.serverTimestamp(),
      "updatedAt": FieldValue.serverTimestamp(),
    });

    print("FIRESTORE SUCCESS");

  } catch (e, s) {

    print("========================");
    print(e);
    print(s);
    print("========================");

    rethrow;
  }
}

  // Get user data
  Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      final doc = await usersCollection.doc(userId).get();
      return doc.data() as Map<String, dynamic>?;
    } catch (e) {
      throw Exception('Error fetching user data: $e');
    }
  }

  // ======================== MEDICATION OPERATIONS ========================

  // Add medication
  Future<String> addMedication({
    required String userId,
    required MedicationModel medication,
  }) async {
    try {
      final docRef = await usersCollection
          .doc(userId)
          .collection('medications')
          .add(medication.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Error adding medication: $e');
    }
  }

  // Update medication
  Future<void> updateMedication({
    required String userId,
    required String medicationId,
    required MedicationModel medication,
  }) async {
    try {
      await usersCollection
          .doc(userId)
          .collection('medications')
          .doc(medicationId)
          .update(medication.toMap());
    } catch (e) {
      throw Exception('Error updating medication: $e');
    }
  }

  // Delete medication
  Future<void> deleteMedication({
    required String userId,
    required String medicationId,
  }) async {
    try {
      await usersCollection
          .doc(userId)
          .collection('medications')
          .doc(medicationId)
          .delete();
    } catch (e) {
      throw Exception('Error deleting medication: $e');
    }
  }

  // Get all medications for user
  Future<List<MedicationModel>> getMedications(String userId) async {
    try {
      final snapshot = await usersCollection
          .doc(userId)
          .collection('medications')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => MedicationModel.fromMap({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();
    } catch (e) {
      throw Exception('Error fetching medications: $e');
    }
  }

  // Stream medications for real-time updates
  Stream<List<MedicationModel>> streamMedications(String userId) {
    try {
      return usersCollection
          .doc(userId)
          .collection('medications')
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => MedicationModel.fromMap({
                    'id': doc.id,
                    ...doc.data(),
                  }))
              .toList());
    } catch (e) {
      throw Exception('Error streaming medications: $e');
    }
  }

  // ======================== DOSE LOG OPERATIONS ========================

  // Log dose intake
  Future<String> logDose({
    required String userId,
    required DoseLogModel doseLog,
  }) async {
    try {
      final docRef =
          await usersCollection.doc(userId).collection('doseLogs').add(
            doseLog.toMap(),
          );
      return docRef.id;
    } catch (e) {
      throw Exception('Error logging dose: $e');
    }
  }

  Future<List<DoseLogModel>> getDoseLogs(String userId) async {
    try {
      final snapshot = await usersCollection
          .doc(userId)
          .collection('doseLogs')
          .orderBy('loggedAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) {
            final data = Map<String, dynamic>.from(doc.data());
            data.remove('id');
            return DoseLogModel.fromMap({
              'id': doc.id,
              ...data,
            });
          })
          .toList();
    } catch (e) {
      throw Exception('Error fetching dose logs: $e');
    }
  }

  // Get dose logs for medication
  Future<List<DoseLogModel>> getDoseLogsForMedication({
    required String userId,
    required String medicationId,
  }) async {
    try {
      final snapshot = await usersCollection
          .doc(userId)
          .collection('doseLogs')
          .where('medicationId', isEqualTo: medicationId)
          .orderBy('loggedAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) {
            final data = Map<String, dynamic>.from(doc.data());
            data.remove('id');
            return DoseLogModel.fromMap({
              'id': doc.id,
              ...data,
            });
          })
          .toList();
    } catch (e) {
      throw Exception('Error fetching dose logs: $e');
    }
  }

  // Get dose logs for a specific date
  Future<List<DoseLogModel>> getDoseLogsForDate({
    required String userId,
    required DateTime date,
  }) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final snapshot = await usersCollection
          .doc(userId)
          .collection('doseLogs')
          .where('loggedAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('loggedAt', isLessThan: Timestamp.fromDate(endOfDay))
          .orderBy('loggedAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) {
            final data = Map<String, dynamic>.from(doc.data());
            data.remove('id');
            return DoseLogModel.fromMap({
              'id': doc.id,
              ...data,
            });
          })
          .toList();
    } catch (e) {
      throw Exception('Error fetching dose logs for date: $e');
    }
  }

  // Update dose log
  Future<void> updateDoseLog({
    required String userId,
    required String doseLogId,
    required DoseLogModel doseLog,
  }) async {
    try {
      await usersCollection
          .doc(userId)
          .collection('doseLogs')
          .doc(doseLogId)
          .update(doseLog.toMap());
    } catch (e) {
      throw Exception('Error updating dose log: $e');
    }
  }

  // Delete dose log
  Future<void> deleteDoseLog({
    required String userId,
    required String doseLogId,
  }) async {
    try {
      await usersCollection
          .doc(userId)
          .collection('doseLogs')
          .doc(doseLogId)
          .delete();
    } catch (e) {
      throw Exception('Error deleting dose log: $e');
    }
  }

  // Stream dose logs for real-time updates
  Stream<List<DoseLogModel>> streamDoseLogsForDate({
    required String userId,
    required DateTime date,
  }) {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      return usersCollection
          .doc(userId)
          .collection('doseLogs')
          .where('loggedAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('loggedAt', isLessThan: Timestamp.fromDate(endOfDay))
          .orderBy('loggedAt', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) {
                final data = Map<String, dynamic>.from(doc.data());
                data.remove('id');
                return DoseLogModel.fromMap({
                  'id': doc.id,
                  ...data,
                });
              })
              .toList());
    } catch (e) {
      throw Exception('Error streaming dose logs: $e');
    }
  }

  // ======================== TRACKER OPERATIONS ========================

  Future<String> addTrackerEntry({
    required String userId,
    required String type,
    required String title,
    String? value,
    String? unit,
    String? notes,
  }) async {
    try {
      final docRef = await usersCollection
          .doc(userId)
          .collection('trackerEntries')
          .add({
        'userId': userId,
        'type': type,
        'title': title,
        'value': value,
        'unit': unit,
        'notes': notes,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      throw Exception('Error adding tracker entry: $e');
    }
  }

  Future<void> deleteTrackerEntry({
    required String userId,
    required String entryId,
  }) async {
    try {
      await usersCollection
          .doc(userId)
          .collection('trackerEntries')
          .doc(entryId)
          .delete();
    } catch (e) {
      throw Exception('Error deleting tracker entry: $e');
    }
  }

  Future<List<TrackerEntryModel>> getTrackerEntries(
    String userId, {
    String? type,
  }) async {
    try {
      Query<Map<String, dynamic>> query = usersCollection
          .doc(userId)
          .collection('trackerEntries');
      if (type != null) {
        query = query.where('type', isEqualTo: type);
      }
      final snapshot =
          await query.orderBy('createdAt', descending: true).get();
      return snapshot.docs
          .map((doc) => TrackerEntryModel.fromMap({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();
    } catch (e) {
      throw Exception('Error fetching tracker entries: $e');
    }
  }

  // ======================== APPOINTMENT OPERATIONS ========================

  Future<String> addAppointment({
    required String userId,
    required AppointmentModel appointment,
  }) async {
    try {
      final docRef = await usersCollection
          .doc(userId)
          .collection('appointments')
          .add(appointment.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Error adding appointment: $e');
    }
  }

  Future<void> updateAppointment({
    required String userId,
    required String appointmentId,
    required AppointmentModel appointment,
  }) async {
    try {
      await usersCollection
          .doc(userId)
          .collection('appointments')
          .doc(appointmentId)
          .update(appointment.toMap());
    } catch (e) {
      throw Exception('Error updating appointment: $e');
    }
  }

  Future<void> deleteAppointment({
    required String userId,
    required String appointmentId,
  }) async {
    try {
      await usersCollection
          .doc(userId)
          .collection('appointments')
          .doc(appointmentId)
          .delete();
    } catch (e) {
      throw Exception('Error deleting appointment: $e');
    }
  }

  Future<List<AppointmentModel>> getAppointments(String userId) async {
    try {
      final snapshot = await usersCollection
          .doc(userId)
          .collection('appointments')
          .orderBy('date', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => AppointmentModel.fromMap({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();
    } catch (e) {
      throw Exception('Error fetching appointments: $e');
    }
  }

  // ======================== STATISTICS OPERATIONS ========================

  // Get medication adherence for a period
  Future<double> getMedicationAdherence({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final medications = await getMedications(userId);
      if (medications.isEmpty) return 100.0;

      int totalExpected = 0;
      int totalLogged = 0;

      for (final med in medications) {
        // Calculate expected doses
        final medStartDate =
            med.startDate.isAfter(startDate) ? med.startDate : startDate;
        final medEndDate = med.endDate != null && med.endDate!.isBefore(endDate)
            ? med.endDate!
            : endDate;

        if (medStartDate.isBefore(medEndDate)) {
          final days = medEndDate.difference(medStartDate).inDays + 1;
          totalExpected += days * med.frequencyPerDay;

          // Count logged doses
          final logs = await getDoseLogsForMedication(
            userId: userId,
            medicationId: med.id,
          );

          totalLogged += logs
              .where((log) =>
                  log.loggedAt.isAfter(medStartDate) &&
                  log.loggedAt.isBefore(medEndDate))
              .length;
        }
      }

      if (totalExpected == 0) return 100.0;
      return (totalLogged / totalExpected * 100).clamp(0.0, 100.0);
    } catch (e) {
      throw Exception('Error calculating adherence: $e');
    }
  }

  // Batch write operations
  Future<void> batchUpdateMedications({
    required String userId,
    required List<MedicationModel> medications,
  }) async {
    try {
      final batch = _firestore.batch();

      for (final med in medications) {
        final docRef = usersCollection
            .doc(userId)
            .collection('medications')
            .doc(med.id);
        batch.set(docRef, med.toMap(), SetOptions(merge: true));
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Error batch updating medications: $e');
    }
  }
}
