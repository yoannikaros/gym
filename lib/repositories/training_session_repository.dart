import 'package:gym/database/database_helper.dart';
import 'package:gym/models/training_session.dart';

class TrainingSessionRepository {
  final dbHelper = DatabaseHelper();

  Future<List<TrainingSession>> getAllTrainingSessions() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'training_sessions',
      orderBy: 'session_date DESC, start_time ASC',
    );
    return List.generate(maps.length, (i) {
      return TrainingSession.fromMap(maps[i]);
    });
  }

  Future<List<TrainingSession>> getTrainingSessionsByTrainerId(int trainerId) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'training_sessions',
      where: 'trainer_id = ?',
      whereArgs: [trainerId],
      orderBy: 'session_date DESC, start_time ASC',
    );
    return List.generate(maps.length, (i) {
      return TrainingSession.fromMap(maps[i]);
    });
  }

  Future<List<TrainingSession>> getTrainingSessionsByMemberId(int memberId) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'training_sessions',
      where: 'member_id = ?',
      whereArgs: [memberId],
      orderBy: 'session_date DESC, start_time ASC',
    );
    return List.generate(maps.length, (i) {
      return TrainingSession.fromMap(maps[i]);
    });
  }

  Future<List<TrainingSession>> getTrainingSessionsByDate(String date) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'training_sessions',
      where: 'session_date = ?',
      whereArgs: [date],
      orderBy: 'start_time ASC',
    );
    return List.generate(maps.length, (i) {
      return TrainingSession.fromMap(maps[i]);
    });
  }

  Future<TrainingSession?> getTrainingSessionById(int id) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'training_sessions',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return TrainingSession.fromMap(maps.first);
    }
    return null;
  }

  Future<int> insertTrainingSession(TrainingSession session) async {
    final db = await dbHelper.database;
    return await db.insert('training_sessions', session.toMap());
  }

  Future<int> updateTrainingSession(TrainingSession session) async {
    final db = await dbHelper.database;
    return await db.update(
      'training_sessions',
      session.toMap(),
      where: 'id = ?',
      whereArgs: [session.id],
    );
  }

  Future<int> deleteTrainingSession(int id) async {
    final db = await dbHelper.database;
    return await db.delete(
      'training_sessions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
