class Subscription {
  final int? id;
  final int memberId;
  final int packageId;
  final String startDate;
  final String endDate;
  final String status;

  Subscription({
    this.id,
    required this.memberId,
    required this.packageId,
    required this.startDate,
    required this.endDate,
    this.status = 'active',
  });

  factory Subscription.fromMap(Map<String, dynamic> map) {
    return Subscription(
      id: map['id'],
      memberId: map['member_id'],
      packageId: map['package_id'],
      startDate: map['start_date'],
      endDate: map['end_date'],
      status: map['status'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'member_id': memberId,
      'package_id': packageId,
      'start_date': startDate,
      'end_date': endDate,
      'status': status,
    };
  }
}
