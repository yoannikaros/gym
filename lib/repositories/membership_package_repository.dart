import 'package:gym/database/database_helper.dart';
import 'package:gym/models/membership_package.dart';

class MembershipPackageRepository {
  final dbHelper = DatabaseHelper();

  Future<List<MembershipPackage>> getAllPackages() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('membership_packages');
    return List.generate(maps.length, (i) {
      return MembershipPackage.fromMap(maps[i]);
    });
  }

  Future<MembershipPackage?> getPackageById(int id) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'membership_packages',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return MembershipPackage.fromMap(maps.first);
    }
    return null;
  }

  Future<int> insertPackage(MembershipPackage package) async {
    final db = await dbHelper.database;
    return await db.insert('membership_packages', package.toMap());
  }

  Future<int> updatePackage(MembershipPackage package) async {
    final db = await dbHelper.database;
    return await db.update(
      'membership_packages',
      package.toMap(),
      where: 'id = ?',
      whereArgs: [package.id],
    );
  }

  Future<int> deletePackage(int id) async {
    final db = await dbHelper.database;
    return await db.delete(
      'membership_packages',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
