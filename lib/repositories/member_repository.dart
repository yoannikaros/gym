import 'package:gym/database/database_helper.dart';
import 'package:gym/models/member.dart';

class MemberRepository {
  final dbHelper = DatabaseHelper();

  Future<List<Member>> getAllMembers() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('members');
    return List.generate(maps.length, (i) {
      return Member.fromMap(maps[i]);
    });
  }

  Future<Member?> getMemberById(int id) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'members',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Member.fromMap(maps.first);
    }
    return null;
  }

  Future<int> insertMember(Member member) async {
    final db = await dbHelper.database;
    return await db.insert('members', member.toMap());
  }

  Future<int> updateMember(Member member) async {
    final db = await dbHelper.database;
    return await db.update(
      'members',
      member.toMap(),
      where: 'id = ?',
      whereArgs: [member.id],
    );
  }

  Future<int> deleteMember(int id) async {
    final db = await dbHelper.database;
    return await db.delete(
      'members',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Member>> searchMembers(String query) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'members',
      where: 'name LIKE ? OR phone LIKE ? OR email LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
    );
    return List.generate(maps.length, (i) {
      return Member.fromMap(maps[i]);
    });
  }
}
