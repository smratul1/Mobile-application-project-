import 'package:cloud_firestore/cloud_firestore.dart';

class TrackerEntryModel {
  final String id;
  final String userId;
  final String type;
  final String title;
  final String? value;
  final String? unit;
  final String? notes;
  final DateTime createdAt;

  const TrackerEntryModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    this.value,
    this.unit,
    this.notes,
    required this.createdAt,
  });

  TrackerEntryModel copyWith({
    String? id,
    String? userId,
    String? type,
    String? title,
    String? value,
    String? unit,
    String? notes,
    DateTime? createdAt,
  }) =>
      TrackerEntryModel(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        type: type ?? this.type,
        title: title ?? this.title,
        value: value ?? this.value,
        unit: unit ?? this.unit,
        notes: notes ?? this.notes,
        createdAt: createdAt ?? this.createdAt,
      );

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'type': type,
        'title': title,
        'value': value,
        'unit': unit,
        'notes': notes,
        'createdAt': FieldValue.serverTimestamp(),
      };

  factory TrackerEntryModel.fromMap(Map<String, dynamic> map) {
    final createdTimestamp = map['createdAt'];
    return TrackerEntryModel(
      id: map['id'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      type: map['type'] as String? ?? 'weight',
      title: map['title'] as String? ?? '',
      value: map['value'] as String?,
      unit: map['unit'] as String?,
      notes: map['notes'] as String?,
      createdAt: createdTimestamp?.toDate() ?? DateTime.now(),
    );
  }
}
