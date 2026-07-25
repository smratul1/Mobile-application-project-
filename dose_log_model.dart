import 'package:cloud_firestore/cloud_firestore.dart';

class AppointmentModel {
  final String id;
  final String userId;
  final String title;
  final DateTime date;
  final String? time;
  final String? doctor;
  final String? location;
  final String? notes;
  final bool reminderEnabled;
  final bool isCompleted;
  final DateTime createdAt;

  const AppointmentModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.date,
    this.time,
    this.doctor,
    this.location,
    this.notes,
    this.reminderEnabled = true,
    this.isCompleted = false,
    required this.createdAt,
  });

  AppointmentModel copyWith({
    String? id,
    String? userId,
    String? title,
    DateTime? date,
    String? time,
    String? doctor,
    String? location,
    String? notes,
    bool? reminderEnabled,
    bool? isCompleted,
    DateTime? createdAt,
  }) =>
      AppointmentModel(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        title: title ?? this.title,
        date: date ?? this.date,
        time: time ?? this.time,
        doctor: doctor ?? this.doctor,
        location: location ?? this.location,
        notes: notes ?? this.notes,
        reminderEnabled: reminderEnabled ?? this.reminderEnabled,
        isCompleted: isCompleted ?? this.isCompleted,
        createdAt: createdAt ?? this.createdAt,
      );

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'title': title,
        'date': Timestamp.fromDate(date),
        'time': time,
        'doctor': doctor,
        'location': location,
        'notes': notes,
        'reminderEnabled': reminderEnabled,
        'isCompleted': isCompleted,
        'createdAt': FieldValue.serverTimestamp(),
      };

  factory AppointmentModel.fromMap(Map<String, dynamic> map) {
    final dateTimestamp = map['date'];
    final createdTimestamp = map['createdAt'];
    return AppointmentModel(
      id: map['id'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      title: map['title'] as String? ?? '',
      date: dateTimestamp?.toDate() ?? DateTime.now(),
      time: map['time'] as String?,
      doctor: map['doctor'] as String?,
      location: map['location'] as String?,
      notes: map['notes'] as String?,
      reminderEnabled: map['reminderEnabled'] as bool? ?? true,
      isCompleted: map['isCompleted'] as bool? ?? false,
      createdAt: createdTimestamp?.toDate() ?? DateTime.now(),
    );
  }
}
