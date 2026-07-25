import 'package:flutter/foundation.dart';
import '../models/appointment_model.dart';
import '../services/firestore_service.dart';
import '../services/notification_service.dart';

class AppointmentsProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final NotificationService _notificationService = NotificationService();

  String? _userId;
  List<AppointmentModel> _appointments = [];

  List<AppointmentModel> get appointments => _appointments;

  Future<void> updateUser(String? userId) async {
    if (_userId == userId) return;
    _userId = userId;
    if (userId != null) {
      await _load();
    } else {
      _appointments = [];
      notifyListeners();
    }
  }

  Future<void> _load() async {
    try {
      _appointments = await _firestoreService.getAppointments(_userId!);
    } catch (e) {
      print('[APPOINTMENTS] _load failed: $e');
      _appointments = [];
      rethrow;
    }
    notifyListeners();
  }

  Future<void> addAppointment({
    required String title,
    required DateTime date,
    String? time,
    String? doctor,
    String? location,
    String? notes,
    bool reminderEnabled = true,
  }) async {
    try {
      if (_userId == null) throw Exception('User not authenticated');

      final appointment = AppointmentModel(
        id: '',
        userId: _userId!,
        title: title,
        date: date,
        time: time,
        doctor: doctor,
        location: location,
        notes: notes,
        reminderEnabled: reminderEnabled,
        isCompleted: false,
        createdAt: DateTime.now(),
      );

      final docId = await _firestoreService.addAppointment(
        userId: _userId!,
        appointment: appointment,
      );

      final created = appointment.copyWith(id: docId);
      _appointments = [..._appointments, created];
      notifyListeners();

      if (reminderEnabled && time != null) {
        await _scheduleReminder(created);
      }
    } catch (e) {
      print('[APPOINTMENTS] addAppointment failed: $e');
      rethrow;
    }
  }

  Future<void> updateAppointment(AppointmentModel appointment) async {
    try {
      if (_userId == null) return;
      await _firestoreService.updateAppointment(
        userId: _userId!,
        appointmentId: appointment.id,
        appointment: appointment,
      );
      _appointments = _appointments
          .map((a) => a.id == appointment.id ? appointment : a)
          .toList();
      notifyListeners();

      if (appointment.reminderEnabled && appointment.time != null) {
        await _scheduleReminder(appointment);
      }
    } catch (e) {
      print('[APPOINTMENTS] updateAppointment failed: $e');
      rethrow;
    }
  }

  Future<void> completeAppointment(String appointmentId) async {
    try {
      if (_userId == null) return;
      final idx = _appointments.indexWhere((a) => a.id == appointmentId);
      if (idx == -1) return;
      final updated = _appointments[idx].copyWith(isCompleted: true);
      await _firestoreService.updateAppointment(
        userId: _userId!,
        appointmentId: appointmentId,
        appointment: updated,
      );
      _appointments[idx] = updated;
      notifyListeners();
    } catch (e) {
      print('[APPOINTMENTS] completeAppointment failed: $e');
      rethrow;
    }
  }

  Future<void> removeAppointment(String appointmentId) async {
    try {
      if (_userId == null) return;
      await _firestoreService.deleteAppointment(
        userId: _userId!,
        appointmentId: appointmentId,
      );
      _appointments = _appointments.where((a) => a.id != appointmentId).toList();
      notifyListeners();
    } catch (e) {
      print('[APPOINTMENTS] removeAppointment failed: $e');
      rethrow;
    }
  }

  Future<void> _scheduleReminder(AppointmentModel appointment) async {
    try {
      await _notificationService.scheduleForAppointment(appointment);
    } catch (e) {
      print('[APPOINTMENTS] _scheduleReminder failed: $e');
    }
  }
}
