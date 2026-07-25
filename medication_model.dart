import 'package:cloud_firestore/cloud_firestore.dart';

class DoseLogModel {
  final String id;
  final String medicationId;
  final DateTime loggedAt;
  final bool taken;
  final String? notes;
  final DateTime? createdAt;
  final String? date;
  final String? time;
  final String? takenAt;
  final String? customName;
  final bool isRescheduled;
  final String? originalTime;

  const DoseLogModel({
    required this.id,
    required this.medicationId,
    required this.loggedAt,
    required this.taken,
    this.notes,
    this.createdAt,
    this.date,
    this.time,
    this.takenAt,
    this.customName,
    this.isRescheduled = false,
    this.originalTime,
  });

  DoseLogModel copyWith({
    String? id,
    String? medicationId,
    DateTime? loggedAt,
    bool? taken,
    String? notes,
    DateTime? createdAt,
    String? date,
    String? time,
    String? takenAt,
    String? customName,
    bool? isRescheduled,
    String? originalTime,
  }) =>
      DoseLogModel(
        id: id ?? this.id,
        medicationId: medicationId ?? this.medicationId,
        loggedAt: loggedAt ?? this.loggedAt,
        taken: taken ?? this.taken,
        notes: notes ?? this.notes,
        createdAt: createdAt ?? this.createdAt,
        date: date ?? this.date,
        time: time ?? this.time,
        takenAt: takenAt ?? this.takenAt,
        customName: customName ?? this.customName,
        isRescheduled: isRescheduled ?? this.isRescheduled,
        originalTime: originalTime ?? this.originalTime,
      );

  Map<String, dynamic> toMap() {
    final createdDate = createdAt != null
        ? Timestamp.fromDate(createdAt!)
        : FieldValue.serverTimestamp();
    final dateValue = date ??
        '${loggedAt.year}-${loggedAt.month.toString().padLeft(2, '0')}-${loggedAt.day.toString().padLeft(2, '0')}';
    final timeValue = time ??
        '${loggedAt.hour.toString().padLeft(2, '0')}:${loggedAt.minute.toString().padLeft(2, '0')}';

    return {
      'medicationId': medicationId,
      'loggedAt': Timestamp.fromDate(loggedAt),
      'taken': taken,
      'notes': notes,
      'createdAt': createdDate,
      'date': dateValue,
      'time': timeValue,
      'takenAt': takenAt,
      'name': customName,
      'isRescheduled': isRescheduled,
      'originalTime': originalTime,
    };
  }

  factory DoseLogModel.fromMap(Map<String, dynamic> map) {
    final Timestamp? loggedTimestamp = map['loggedAt'] as Timestamp?;
    final Timestamp? createdTimestamp = map['createdAt'] as Timestamp?;
    final dateStr = map['date'] as String?;
    final timeStr = map['time'] as String?;

    final loggedAt = loggedTimestamp?.toDate() ?? DateTime.now();
    final parsedDate = dateStr ??
        '${loggedAt.year}-${loggedAt.month.toString().padLeft(2, '0')}-${loggedAt.day.toString().padLeft(2, '0')}';
    final parsedTime = timeStr ??
        '${loggedAt.hour.toString().padLeft(2, '0')}:${loggedAt.minute.toString().padLeft(2, '0')}';

    return DoseLogModel(
      id: map['id'] as String? ?? '',
      medicationId: map['medicationId'] as String? ?? '',
      loggedAt: loggedAt,
      taken: map['taken'] as bool? ?? false,
      notes: map['notes'] as String?,
      createdAt: createdTimestamp?.toDate(),
      date: parsedDate,
      time: parsedTime,
      takenAt: map['takenAt'] as String?,
      customName: map['name'] as String?,
      isRescheduled: map['isRescheduled'] as bool? ?? false,
      originalTime: map['originalTime'] as String?,
    );
  }
}
