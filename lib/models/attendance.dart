class Attendance {
  final int? id;
  final int memberId;
  final String checkIn;
  final String? checkOut;

  Attendance({
    this.id,
    required this.memberId,
    required this.checkIn,
    this.checkOut,
  });

  factory Attendance.fromMap(Map<String, dynamic> map) {
    return Attendance(
      id: map['id'],
      memberId: map['member_id'],
      checkIn: map['check_in'],
      checkOut: map['check_out'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'member_id': memberId,
      'check_in': checkIn,
      'check_out': checkOut,
    };
  }
}
