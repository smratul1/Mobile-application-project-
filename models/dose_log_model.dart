class DoseLogModel {
  final String id;
  final String medicationId;
  final String date;
  final String time;
  final bool taken;
  final String? takenAt;

  const DoseLogModel({
    required this.id,
    required this.medicationId,
    required this.date,
    required this.time,
    required this.taken,
    this.takenAt,
  });

  DoseLogModel copyWith({bool? taken, String? takenAt}) => DoseLogModel(
        id: id,
        medicationId: medicationId,
        date: date,
        time: time,
        taken: taken ?? this.taken,
        takenAt: takenAt ?? this.takenAt,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'medicationId': medicationId,
        'date': date,
        'time': time,
        'taken': taken,
        'takenAt': takenAt,
      };

  factory DoseLogModel.fromMap(Map<String, dynamic> map) => DoseLogModel(
        id: map['id'] as String,
        medicationId: map['medicationId'] as String,
        date: map['date'] as String,
        time: map['time'] as String,
        taken: map['taken'] as bool,
        takenAt: map['takenAt'] as String?,
      );
}
