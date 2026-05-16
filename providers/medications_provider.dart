import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/medication_model.dart';
import '../models/dose_log_model.dart';

class TodayDose {
  final MedicationModel medication;
  final String time;
  final bool taken;
  final bool special;
  final String? doseLogId;

  const TodayDose({
    required this.medication,
    required this.time,
    required this.taken,
    required this.special,
    this.doseLogId,
  });
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
  String? _userEmail;
  List<MedicationModel> _medications = [];
  List<DoseLogModel> _doseLogs = [];
  List<CustomReminder> _customReminders = [];

  List<MedicationModel> get medications => _medications;
  List<DoseLogModel> get doseLogs => _doseLogs;
  List<CustomReminder> get customReminders => _customReminders;

  static final List<MedicationModel> _sample = [
    const MedicationModel(
        id: '1',
        name: 'Aspirin',
        dosage: '81mg',
        frequency: 'daily',
        times: ['09:00'],
        pillCount: 1,
        color: '#E91E8C'),
    const MedicationModel(
        id: '2',
        name: 'Vitamin C',
        dosage: '500mg',
        frequency: 'daily',
        times: ['13:00'],
        pillCount: 1,
        color: '#AB47BC'),
    const MedicationModel(
        id: '3',
        name: 'Magnesium',
        dosage: '250mg',
        frequency: 'daily',
        times: ['18:00'],
        pillCount: 1,
        color: '#7B1FA2'),
  ];

  String get _medsKey => '@medications_$_userEmail';
  String get _logsKey => '@doseLogs_$_userEmail';
  String get _remindersKey => '@customReminders_$_userEmail';

  String _dateStr(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String get _today => _dateStr(DateTime.now());

  Future<void> updateUser(String? email) async {
    if (_userEmail == email) return;
    _userEmail = email;
    if (email != null) {
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
      final prefs = await SharedPreferences.getInstance();
      final medsStr = prefs.getString(_medsKey);
      final logsStr = prefs.getString(_logsKey);

      if (medsStr != null) {
        final list = jsonDecode(medsStr) as List;
        _medications = list
            .map((e) => MedicationModel.fromMap(e as Map<String, dynamic>))
            .toList();
      } else {
        _medications = _sample;
        await prefs.setString(
            _medsKey, jsonEncode(_medications.map((m) => m.toMap()).toList()));
      }

      if (logsStr != null) {
        final list = jsonDecode(logsStr) as List;
        _doseLogs = list
            .map((e) => DoseLogModel.fromMap(e as Map<String, dynamic>))
            .toList();
      } else {
        _doseLogs = [];
      }

      final remindersStr = prefs.getString(_remindersKey);
      if (remindersStr != null) {
        final list = jsonDecode(remindersStr) as List;
        _customReminders = list
            .map((e) => CustomReminder.fromMap(e as Map<String, dynamic>))
            .toList();
      } else {
        _customReminders = [];
      }
    } catch (_) {
      _medications = _sample;
      _doseLogs = [];
      _customReminders = [];
    }
    notifyListeners();
  }

  Future<void> _saveMedications() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _medsKey, jsonEncode(_medications.map((m) => m.toMap()).toList()));
  }

  Future<void> _saveLogs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _logsKey, jsonEncode(_doseLogs.map((l) => l.toMap()).toList()));
  }

  Future<void> _saveReminders() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_remindersKey,
        jsonEncode(_customReminders.map((r) => r.toMap()).toList()));
  }

  Future<void> addMedication(MedicationModel med) async {
    _medications = [..._medications, med];
    await _saveMedications();
    notifyListeners();
  }

  Future<void> updateMedication(MedicationModel med) async {
    _medications = _medications
        .map((existing) => existing.id == med.id ? med : existing)
        .toList();
    await _saveMedications();
    notifyListeners();
  }

  Future<void> removeMedication(String id) async {
    _medications = _medications.where((m) => m.id != id).toList();
    await _saveMedications();
    notifyListeners();
  }

  Future<void> addDoseLog(DoseLogModel log) async {
    _doseLogs = [..._doseLogs, log];
    await _saveLogs();
    notifyListeners();
  }

  Future<void> markDoseTaken(String medId, String date, String time) async {
    final idx = _doseLogs.indexWhere(
        (l) => l.medicationId == medId && l.date == date && l.time == time);

    if (idx >= 0) {
      final updated = _doseLogs[idx].copyWith(taken: !_doseLogs[idx].taken);
      _doseLogs = [
        ..._doseLogs.sublist(0, idx),
        updated,
        ..._doseLogs.sublist(idx + 1)
      ];
    } else {
      _doseLogs = [
        ..._doseLogs,
        DoseLogModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          medicationId: medId,
          date: date,
          time: time,
          taken: true,
          takenAt: DateTime.now().toIso8601String(),
        ),
      ];
    }
    await _saveLogs();
    notifyListeners();
  }

  Future<void> removeDoseLog(String id) async {
    _doseLogs = _doseLogs.where((log) => log.id != id).toList();
    await _saveLogs();
    notifyListeners();
  }

  Future<void> addCustomReminder(CustomReminder reminder) async {
    _customReminders = [..._customReminders, reminder];
    await _saveReminders();
    notifyListeners();
  }

  Future<void> removeCustomReminder(String id) async {
    _customReminders =
        _customReminders.where((reminder) => reminder.id != id).toList();
    await _saveReminders();
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
              entry.time == t) {
            log = entry;
            break;
          }
        }
        final key = '${med.id}|$t';
        addedKeys.add(key);
        doses.add(TodayDose(
            medication: med,
            time: t,
            taken: log?.taken ?? false,
            special: false,
            doseLogId: log?.id));
      }
    }

    for (final log in _doseLogs.where((l) => l.date == date)) {
      final key = '${log.medicationId}|${log.time}';
      if (addedKeys.contains(key)) continue;
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
          time: log.time,
          taken: log.taken,
          special: true,
          doseLogId: log.id));
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
