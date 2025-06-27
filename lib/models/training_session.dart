class TrainingSession {
  final int? id;
  final int trainerId;
  final int memberId;
  final String sessionDate;
  final String startTime;
  final String? endTime;
  final String? notes;

  TrainingSession({
    this.id,
    required this.trainerId,
    required this.memberId,
    required this.sessionDate,
    required this.startTime,
    this.endTime,
    this.notes,
  });

  factory TrainingSession.fromMap(Map<String, dynamic> map) {
    return TrainingSession(
      id: map['id'],
      trainerId: map['trainer_id'],
      memberId: map['member_id'],
      sessionDate: map['session_date'],
      startTime: map['start_time'],
      endTime: map['end_time'],
      notes: map['notes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'trainer_id': trainerId,
      'member_id': memberId,
      'session_date': sessionDate,
      'start_time': startTime,
      'end_time': endTime,
      'notes': notes,
    };
  }
}
