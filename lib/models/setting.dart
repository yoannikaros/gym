class Setting {
  final int? id;
  final String? gymName;
  final String? noteHeader;
  final String? noteFooter;
  final String? updatedAt;

  Setting({
    this.id,
    this.gymName,
    this.noteHeader,
    this.noteFooter,
    this.updatedAt,
  });

  factory Setting.fromMap(Map<String, dynamic> map) {
    return Setting(
      id: map['id'],
      gymName: map['gym_name'],
      noteHeader: map['note_header'],
      noteFooter: map['note_footer'],
      updatedAt: map['updated_at'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'gym_name': gymName,
      'note_header': noteHeader,
      'note_footer': noteFooter,
      'updated_at': updatedAt,
    };
  }
}
