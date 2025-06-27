import 'package:gym/database/database_helper.dart';
import 'package:gym/models/attendance.dart';

class AttendanceRepository {
  final dbHelper = DatabaseHelper();

  Future<List<Attendance>> getAllAttendance() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('attendance');
    return List.generate(maps.length, (i) {
      return Attendance.fromMap(maps[i]);
    });
  }

  Future<List<Attendance>> getAttendanceByDate(String date) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'attendance',
      where: "date(check_in) = ?",
      whereArgs: [date],
    );
    return List.generate(maps.length, (i) {
      return Attendance.fromMap(maps[i]);
    });
  }

  Future<List<Attendance>> getAttendanceByMemberId(int memberId) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'attendance',
      where: 'member_id = ?',
      whereArgs: [memberId],
    );
    return List.generate(maps.length, (i) {
      return Attendance.fromMap(maps[i]);
    });
  }

  Future<Attendance?> getAttendanceById(int id) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'attendance',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Attendance.fromMap(maps.first);
    }
    return null;
  }

  Future<int> insertAttendance(Attendance attendance) async {
    final db = await dbHelper.database;
    return await db.insert('attendance', attendance.toMap());
  }

  Future<int> updateAttendance(Attendance attendance) async {
    final db = await dbHelper.database;
    return await db.update(
      'attendance',
      attendance.toMap(),
      where: 'id = ?',
      whereArgs: [attendance.id],
    );
  }

  Future<int> deleteAttendance(int id) async {
    final db = await dbHelper.database;
    return await db.delete(
      'attendance',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
