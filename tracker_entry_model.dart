import 'package:cloud_firestore/cloud_firestore.dart';

class MedicationModel {
  final String id;
  final String name;
  final String dosage;
  final String frequency;
  final List<String> times;
  final int pillCount;
  final String color;
  final String? notes;
  final DateTime startDate;
  final DateTime? endDate;
  final int frequencyPerDay;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const MedicationModel({
    required this.id,
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.times,
    required this.pillCount,
    required this.color,
    this.notes,
    required this.startDate,
    this.endDate,
    required this.frequencyPerDay,
    this.createdAt,
    this.updatedAt,
  });

  MedicationModel copyWith({
    String? id,
    String? name,
    String? dosage,
    String? frequency,
    List<String>? times,
    int? pillCount,
    String? color,
    String? notes,
    DateTime? startDate,
    DateTime? endDate,
    int? frequencyPerDay,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      MedicationModel(
        id: id ?? this.id,
        name: name ?? this.name,
        dosage: dosage ?? this.dosage,
        frequency: frequency ?? this.frequency,
        times: times ?? this.times,
        pillCount: pillCount ?? this.pillCount,
        color: color ?? this.color,
        notes: notes ?? this.notes,
        startDate: startDate ?? this.startDate,
        endDate: endDate ?? this.endDate,
        frequencyPerDay: frequencyPerDay ?? this.frequencyPerDay,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  Map<String, dynamic> toMap() => {
        'name': name,
        'dosage': dosage,
        'frequency': frequency,
        'times': times,
        'pillCount': pillCount,
        'color': color,
        'notes': notes,
        'startDate': Timestamp.fromDate(startDate),
        'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
        'frequencyPerDay': frequencyPerDay,
        'updatedAt': FieldValue.serverTimestamp(),
        if (createdAt == null) 'createdAt': FieldValue.serverTimestamp(),
      };

  factory MedicationModel.fromMap(Map<String, dynamic> map) {
    Timestamp? startTimestamp = map['startDate'];
    Timestamp? endTimestamp = map['endDate'];
    Timestamp? createdTimestamp = map['createdAt'];
    Timestamp? updatedTimestamp = map['updatedAt'];

    return MedicationModel(
      id: map['id'] as String? ?? '',
      name: map['name'] as String,
      dosage: map['dosage'] as String,
      frequency: map['frequency'] as String,
      times: List<String>.from(map['times'] as List? ?? []),
      pillCount: map['pillCount'] as int? ?? 0,
      color: map['color'] as String? ?? '#000000',
      notes: map['notes'] as String?,
      startDate: startTimestamp?.toDate() ?? DateTime.now(),
      endDate: endTimestamp?.toDate(),
      frequencyPerDay: map['frequencyPerDay'] as int? ?? 1,
      createdAt: createdTimestamp?.toDate(),
      updatedAt: updatedTimestamp?.toDate(),
    );
  }
}
