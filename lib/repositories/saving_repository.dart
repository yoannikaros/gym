import 'package:gym/database/database_helper.dart';
import 'package:gym/models/saving.dart';

class SavingRepository {
  final dbHelper = DatabaseHelper();

  Future<List<Saving>> getAllSavings() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'savings',
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) {
      return Saving.fromMap(maps[i]);
    });
  }

  Future<List<Saving>> getSavingsByType(String type) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'savings',
      where: 'type = ?',
      whereArgs: [type],
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) {
      return Saving.fromMap(maps[i]);
    });
  }

  Future<Saving?> getSavingById(int id) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'savings',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Saving.fromMap(maps.first);
    }
    return null;
  }

  Future<int> insertSaving(Saving saving) async {
    final db = await dbHelper.database;
    return await db.insert('savings', saving.toMap());
  }

  Future<int> updateSaving(Saving saving) async {
    final db = await dbHelper.database;
    return await db.update(
      'savings',
      saving.toMap(),
      where: 'id = ?',
      whereArgs: [saving.id],
    );
  }

  Future<int> deleteSaving(int id) async {
    final db = await dbHelper.database;
    return await db.delete(
      'savings',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<Map<String, double>> getSavingSummary() async {
    final db = await dbHelper.database;
    
    // Get total deposits
    final depositResult = await db.rawQuery(
      'SELECT SUM(amount) as total FROM savings WHERE type = ?',
      ['deposit'],
    );
    
    // Get total withdrawals
    final withdrawalResult = await db.rawQuery(
      'SELECT SUM(amount) as total FROM savings WHERE type = ?',
      ['withdrawal'],
    );
    
    final depositTotal = depositResult.first['total'] as double? ?? 0.0;
    final withdrawalTotal = withdrawalResult.first['total'] as double? ?? 0.0;
    
    return {
      'deposit': depositTotal,
      'withdrawal': withdrawalTotal,
      'balance': depositTotal - withdrawalTotal,
    };
  }
}
