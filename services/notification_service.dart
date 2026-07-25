import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import '../models/medication_model.dart';
import '../models/appointment_model.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;

  static const String _channelId = 'med_reminder_channel';
  static const String _channelName = 'Medicine Reminders';
  static const String _channelDesc =
      'Reminders to take your medications on time.';

  static const String _kSound = 'notif_sound';
  static const String _kVibration = 'notif_vibration';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  SharedPreferences? _prefs;

  Future<void> init() async {
    tz_data.initializeTimeZones();
    _prefs = await SharedPreferences.getInstance();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    final androidImpl = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidImpl != null) {
      await androidImpl.createNotificationChannel(
        const AndroidNotificationChannel(
          _channelId,
          _channelName,
          description: _channelDesc,
          importance: Importance.max,
          playSound: true,
          enableVibration: true,
        ),
      );
      await androidImpl.requestNotificationsPermission();
      await androidImpl.requestExactAlarmsPermission();
    }
  }

  void _onNotificationTap(NotificationResponse response) {
    // Reserved for deep-linking into the app (e.g. open dashboard).
  }

  bool get _soundEnabled => _prefs?.getBool(_kSound) ?? true;
  bool get _vibrationEnabled => _prefs?.getBool(_kVibration) ?? true;

  Future<void> setSoundEnabled(bool value) async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.setBool(_kSound, value);
  }

  Future<void> setVibrationEnabled(bool value) async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.setBool(_kVibration, value);
  }

  Future<bool> isSoundEnabled() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!.getBool(_kSound) ?? true;
  }

  Future<bool> isVibrationEnabled() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!.getBool(_kVibration) ?? true;
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  Future<void> scheduleForMedications(List<MedicationModel> medications) async {
    await cancelAll();
    int id = 0;
    for (final med in medications) {
      for (final time in med.times) {
        final parts = time.split(':');
        if (parts.length != 2) continue;
        final hour = int.tryParse(parts[0]);
        final minute = int.tryParse(parts[1]);
        if (hour == null || minute == null) continue;

        await _plugin.zonedSchedule(
          id++,
          'Time for ${med.name}',
          '${med.dosage} • Open the app to mark it as taken',
          _nextInstanceOfTime(hour, minute),
          NotificationDetails(
            android: AndroidNotificationDetails(
              _channelId,
              _channelName,
              channelDescription: _channelDesc,
              importance: Importance.max,
              priority: Priority.high,
              playSound: _soundEnabled,
              enableVibration: _vibrationEnabled,
              styleInformation: const DefaultStyleInformation(true, true),
            ),
            iOS: DarwinNotificationDetails(
              presentSound: _soundEnabled,
              sound: _soundEnabled ? 'default' : null,
              presentAlert: true,
              presentBadge: true,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time,
          payload: med.id,
        );
      }
    }
  }

  Future<void> scheduleForAppointment(AppointmentModel appointment) async {
    if (!appointment.reminderEnabled || appointment.time == null) return;

    final dateStr = appointment.time!.trim();
    final timeParts = dateStr.split(':');
    if (timeParts.length != 2) return;
    final hour = int.tryParse(timeParts[0]);
    final minute = int.tryParse(timeParts[1]);
    if (hour == null || minute == null) return;

    var scheduled = tz.TZDateTime(
      tz.local,
      appointment.date.year,
      appointment.date.month,
      appointment.date.day,
      hour,
      minute,
    );

    await _plugin.zonedSchedule(
      appointment.id.hashCode,
      'Appointment Reminder',
      '${appointment.title} is scheduled for today at ${appointment.time}',
      scheduled,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDesc,
          importance: Importance.max,
          priority: Priority.high,
          playSound: _soundEnabled,
          enableVibration: _vibrationEnabled,
          styleInformation: const DefaultStyleInformation(true, true),
        ),
        iOS: DarwinNotificationDetails(
          presentSound: _soundEnabled,
          sound: _soundEnabled ? 'default' : null,
          presentAlert: true,
          presentBadge: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'appointment:${appointment.id}',
    );
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  Future<void> showTestNotification() async {
    await _plugin.show(
      9999,
      'Test Reminder',
      'This is how your medicine reminder will sound.',
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDesc,
          importance: Importance.max,
          priority: Priority.high,
          playSound: _soundEnabled,
          enableVibration: _vibrationEnabled,
        ),
        iOS: DarwinNotificationDetails(
          presentSound: _soundEnabled,
          sound: _soundEnabled ? 'default' : null,
          presentAlert: true,
          presentBadge: true,
        ),
      ),
    );
  }
}
