import 'package:gym/database/database_helper.dart';
import 'package:gym/models/trainer.dart';

class TrainerRepository {
  final dbHelper = DatabaseHelper();

  Future<List<Trainer>> getAllTrainers() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('trainers');
    return List.generate(maps.length, (i) {
      return Trainer.fromMap(maps[i]);
    });
  }

  Future<Trainer?> getTrainerById(int id) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'trainers',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Trainer.fromMap(maps.first);
    }
    return null;
  }

  Future<int> insertTrainer(Trainer trainer) async {
    final db = await dbHelper.database;
    return await db.insert('trainers', trainer.toMap());
  }

  Future<int> updateTrainer(Trainer trainer) async {
    final db = await dbHelper.database;
    return await db.update(
      'trainers',
      trainer.toMap(),
      where: 'id = ?',
      whereArgs: [trainer.id],
    );
  }

  Future<int> deleteTrainer(int id) async {
    final db = await dbHelper.database;
    return await db.delete(
      'trainers',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
