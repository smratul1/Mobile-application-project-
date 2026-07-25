import 'package:flutter/foundation.dart';
import '../models/medication_model.dart';
import '../models/dose_log_model.dart';
import '../repositories/medication_repository.dart';
import '../repositories/dose_log_repository.dart';
import '../services/notification_service.dart';

class TodayDose {
  final MedicationModel medication;
  final String time;
  final bool taken;
  final bool special;
  final bool isRescheduled;
  final String? doseLogId;
  final String? customName;

  const TodayDose({
    required this.medication,
    required this.time,
    required this.taken,
    required this.special,
    required this.isRescheduled,
    this.doseLogId,
    this.customName,
  });

  String get displayName => (customName?.isNotEmpty ?? false)
      ? customName!
      : medication.name;
}

class CustomReminder {
  final String id;
  final String name;
  final String time;

  const CustomReminder({
    required this.id,
    required this.name,
    required this.time,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'time': time,
      };

  factory CustomReminder.fromMap(Map<String, dynamic> map) => CustomReminder(
        id: map['id'] as String,
        name: map['name'] as String,
        time: map['time'] as String,
      );
}

class MedicationsProvider extends ChangeNotifier {
  final MedicationRepository _medicationRepo = MedicationRepository();
  final DoseLogRepository _doseLogRepo = DoseLogRepository();

  String? _userId;
  List<MedicationModel> _medications = [];
  List<DoseLogModel> _doseLogs = [];
  List<CustomReminder> _customReminders = [];

  List<MedicationModel> get medications => _medications;
  List<DoseLogModel> get doseLogs => _doseLogs;
  List<CustomReminder> get customReminders => _customReminders;

  String _dateStr(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String get _today => _dateStr(DateTime.now());

  DateTime _parseDateTime(String date, String time) {
    try {
      final dParts = date.split('-');
      final tParts = time.split(':');
      return DateTime(
        int.parse(dParts[0]),
        int.parse(dParts[1]),
        int.parse(dParts[2]),
        int.parse(tParts[0]),
        int.parse(tParts[1]),
      );
    } catch (_) {
      return DateTime.now();
    }
  }

  Future<void> updateUser(String? userId) async {
    if (_userId == userId) return;
    _userId = userId;
    if (userId != null) {
      await _load();
    } else {
      _medications = [];
      _doseLogs = [];
      _customReminders = [];
      notifyListeners();
    }
  }

  Future<void> _load() async {
    try {
      _medications = await _medicationRepo.getMedications(_userId!);
      _doseLogs = await _doseLogRepo.getDoseLogs(_userId!);
    } catch (e) {
      print('[CRITICAL] _load() failed for userId=$_userId: $e');
      _medications = [];
      _doseLogs = [];
      _customReminders = [];
    }
    _scheduleNotifications();
    notifyListeners();
  }

  void _scheduleNotifications() {
    NotificationService()
        .scheduleForMedications(_medications)
        .catchError((_) {});
  }

  Future<void> rescheduleNotifications() async => _scheduleNotifications();

  Future<void> addMedication(MedicationModel med) async {
    final newId = await _medicationRepo.addMedication(
      userId: _userId!,
      name: med.name,
      dosage: med.dosage,
      frequency: med.frequency,
      times: med.times,
      pillCount: med.pillCount,
      color: med.color,
      startDate: med.startDate,
      frequencyPerDay: med.frequencyPerDay,
      endDate: med.endDate,
      notes: med.notes,
    );
    _medications = [..._medications, med.copyWith(id: newId)];
    notifyListeners();
    _scheduleNotifications();
  }

  Future<void> updateMedication(MedicationModel med) async {
    await _medicationRepo.updateMedication(
      userId: _userId!,
      medicationId: med.id,
      name: med.name,
      dosage: med.dosage,
      frequency: med.frequency,
      times: med.times,
      pillCount: med.pillCount,
      color: med.color,
      endDate: med.endDate,
      notes: med.notes,
    );
    _medications = _medications
        .map((existing) => existing.id == med.id ? med : existing)
        .toList();
    notifyListeners();
    _scheduleNotifications();
  }

  Future<void> removeMedication(String id) async {
    await _medicationRepo.deleteMedication(
      userId: _userId!,
      medicationId: id,
    );
    _medications = _medications.where((m) => m.id != id).toList();
    notifyListeners();
    _scheduleNotifications();
  }

  Future<void> addDoseLog(String medId, String date, String time,
      {String? customName}) async {
    final docId = await _doseLogRepo.logDose(
      userId: _userId!,
      medicationId: medId,
      loggedAt: _parseDateTime(date, time),
      taken: false,
    );
    final log = DoseLogModel(
      id: docId,
      medicationId: medId,
      loggedAt: _parseDateTime(date, time),
      date: date,
      time: time,
      taken: false,
      customName: customName,
    );
    _doseLogs = [..._doseLogs, log];
    notifyListeners();
  }

  Future<void> markDoseTaken(
      String medId,
      String date,
      String time,
      ) async {
    try {
      final idx = _doseLogs.indexWhere(
        (l) =>
            l.medicationId == medId &&
            l.date == date &&
            l.time == time,
      );

      if (idx != -1) {
        final updated = _doseLogs[idx].copyWith(
          taken: true,
          takenAt: DateTime.now().toIso8601String(),
        );
        await _doseLogRepo.updateDoseLog(
          userId: _userId!,
          doseLogId: updated.id,
          taken: updated.taken,
        );
        _doseLogs[idx] = updated;
      } else {
        final now = DateTime.now();
        final docId = await _doseLogRepo.logDose(
          userId: _userId!,
          medicationId: medId,
          loggedAt: _parseDateTime(date, time),
          taken: true,
        );
        final log = DoseLogModel(
          id: docId,
          medicationId: medId,
          loggedAt: _parseDateTime(date, time),
          date: date,
          time: time,
          taken: true,
          takenAt: now.toIso8601String(),
        );
        _doseLogs = [..._doseLogs, log];
      }

      notifyListeners();
    } catch (e) {
      print('[ERROR] markDoseTaken failed: $e');
    }
  }

  Future<void> undoDoseTake(
      String medId,
      String date,
      String time,
      ) async {
    try {
      final idx = _doseLogs.indexWhere(
        (l) =>
            l.medicationId == medId &&
            l.date == date &&
            l.time == time,
      );

      if (idx != -1) {
        await _doseLogRepo.deleteDoseLog(
          userId: _userId!,
          doseLogId: _doseLogs[idx].id,
        );
        _doseLogs.removeAt(idx);
      }

      notifyListeners();
    } catch (e) {
      print('[ERROR] undoDoseTake failed: $e');
    }
  }

  Future<void> undoDoseSkip(
      String medId,
      String date,
      String time,
      ) async {
    try {
      final idx = _doseLogs.indexWhere(
        (l) =>
            l.medicationId == medId &&
            l.date == date &&
            l.time == time,
      );

      if (idx != -1) {
        await _doseLogRepo.deleteDoseLog(
          userId: _userId!,
          doseLogId: _doseLogs[idx].id,
        );
        _doseLogs.removeAt(idx);
      }

      notifyListeners();
    } catch (e) {
      print('[ERROR] undoDoseSkip failed: $e');
    }
  }

  Future<void> undoReschedule(
      String medId,
      String date,
      String currentTime,
      ) async {
    try {
      final idx = _doseLogs.indexWhere(
        (l) =>
            l.medicationId == medId &&
            l.date == date &&
            l.time == currentTime,
      );

      if (idx != -1) {
        final log = _doseLogs[idx];
        final originalTime = log.originalTime ??
            _medications.firstWhere((m) => m.id == medId).times.first;

        if (originalTime == currentTime) return;

        final updated = log.copyWith(
          time: originalTime,
          loggedAt: _parseDateTime(date, originalTime),
          isRescheduled: false,
          originalTime: null,
        );
        await _doseLogRepo.updateDoseLog(
          userId: _userId!,
          doseLogId: log.id,
          time: originalTime,
          date: date,
          isRescheduled: false,
          originalTime: null,
        );
        _doseLogs[idx] = updated;
        notifyListeners();
      }
    } catch (e) {
      print('[ERROR] undoReschedule failed: $e');
    }
  }

  Future<void> markDoseSkipped(
      String medId,
      String date,
      String time,
      ) async {
    try {
      final idx = _doseLogs.indexWhere(
        (l) =>
            l.medicationId == medId &&
            l.date == date &&
            l.time == time,
      );

      if (idx != -1) {
        final updated = _doseLogs[idx].copyWith(
          taken: false,
        );
        await _doseLogRepo.updateDoseLog(
          userId: _userId!,
          doseLogId: updated.id,
          taken: false,
        );
        _doseLogs[idx] = updated;
      } else {
        final docId = await _doseLogRepo.logDose(
          userId: _userId!,
          medicationId: medId,
          loggedAt: _parseDateTime(date, time),
          taken: false,
        );
        final log = DoseLogModel(
          id: docId,
          medicationId: medId,
          loggedAt: _parseDateTime(date, time),
          date: date,
          time: time,
          taken: false,
        );
        _doseLogs = [..._doseLogs, log];
      }

      notifyListeners();
    } catch (e) {
      print('[ERROR] markDoseSkipped failed: $e');
    }
  }

  Future<void> rescheduleDose(
      String medId,
      String date,
      String oldTime,
      String newTime,
      ) async {
    try {
      final idx = _doseLogs.indexWhere(
        (l) =>
            l.medicationId == medId &&
            l.date == date &&
            l.time == oldTime,
      );

      if (idx != -1) {
        final existingOriginalTime = _doseLogs[idx].originalTime;
        final updated = _doseLogs[idx].copyWith(
          time: newTime,
          loggedAt: _parseDateTime(date, newTime),
          isRescheduled: true,
          originalTime: existingOriginalTime ?? oldTime,
        );
        await _doseLogRepo.updateDoseLog(
          userId: _userId!,
          doseLogId: _doseLogs[idx].id,
          time: newTime,
          date: date,
          isRescheduled: true,
          originalTime: existingOriginalTime ?? oldTime,
        );
        _doseLogs[idx] = updated;
        notifyListeners();
      }
    } catch (e) {
      print('[ERROR] rescheduleDose failed: $e');
    }
  }

  Future<void> removeDoseLog(String id) async {
    await _doseLogRepo.deleteDoseLog(
      userId: _userId!,
      doseLogId: id,
    );
    _doseLogs = _doseLogs.where((log) => log.id != id).toList();
    notifyListeners();
  }

  Future<void> addCustomReminder(CustomReminder reminder) async {
    _customReminders = [..._customReminders, reminder];
    notifyListeners();
  }

  Future<void> removeCustomReminder(String id) async {
    _customReminders =
        _customReminders.where((reminder) => reminder.id != id).toList();
    notifyListeners();
  }

  List<TodayDose> _getDosesForDate(String date) {
    final doses = <TodayDose>[];
    final addedKeys = <String>{};

    for (final med in _medications) {
      for (final t in med.times) {
        DoseLogModel? log;
        for (final entry in _doseLogs) {
          if (entry.medicationId == med.id &&
              entry.date == date &&
              (entry.time == t || (entry.isRescheduled && entry.originalTime == t))) {
            log = entry;
            break;
          }
        }
        final key = '${med.id}|${log?.time ?? t}';
        if (addedKeys.contains(key)) continue;
        addedKeys.add(key);
        doses.add(TodayDose(
            medication: med,
            time: log?.time ?? t,
            taken: log?.taken ?? false,
            special: false,
            isRescheduled: log?.isRescheduled ?? false,
            doseLogId: log?.id,
            customName: log?.customName));
      }
    }

    for (final log in _doseLogs.where((l) => l.date == date)) {
      final key = '${log.medicationId}|${log.time}';
      if (addedKeys.contains(key)) continue;
      addedKeys.add(key);
      MedicationModel? med;
      for (final entry in _medications) {
        if (entry.id == log.medicationId) {
          med = entry;
          break;
        }
      }
      if (med == null) continue;
      doses.add(TodayDose(
          medication: med,
          time: log.time ?? '',
          taken: log.taken,
          special: true,
          isRescheduled: log.isRescheduled,
          doseLogId: log.id,
          customName: log.customName));
    }

    doses.sort((a, b) => a.time.compareTo(b.time));
    return doses;
  }

  List<TodayDose> getTodaysDoses() => _getDosesForDate(_today);
  List<TodayDose> getDateDoses(String date) => _getDosesForDate(date);
  int getTakenCount(String date) =>
      _getDosesForDate(date).where((d) => d.taken).length;
  int getTotalCount(String date) => _getDosesForDate(date).length;
}
