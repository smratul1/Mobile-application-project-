class MedicationModel {
  final String id;
  final String name;
  final String dosage;
  final String frequency;
  final List<String> times;
  final int pillCount;
  final String color;
  final String? notes;

  const MedicationModel({
    required this.id,
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.times,
    required this.pillCount,
    required this.color,
    this.notes,
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
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'dosage': dosage,
        'frequency': frequency,
        'times': times,
        'pillCount': pillCount,
        'color': color,
        'notes': notes,
      };

  factory MedicationModel.fromMap(Map<String, dynamic> map) => MedicationModel(
        id: map['id'] as String,
        name: map['name'] as String,
        dosage: map['dosage'] as String,
        frequency: map['frequency'] as String,
        times: List<String>.from(map['times'] as List),
        pillCount: map['pillCount'] as int,
        color: map['color'] as String,
        notes: map['notes'] as String?,
      );
}
