import 'package:gym/database/database_helper.dart';
import 'package:gym/models/subscription.dart';

class SubscriptionRepository {
  final dbHelper = DatabaseHelper();

  Future<List<Subscription>> getAllSubscriptions() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('subscriptions');
    return List.generate(maps.length, (i) {
      return Subscription.fromMap(maps[i]);
    });
  }

  Future<List<Subscription>> getSubscriptionsByMemberId(int memberId) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'subscriptions',
      where: 'member_id = ?',
      whereArgs: [memberId],
    );
    return List.generate(maps.length, (i) {
      return Subscription.fromMap(maps[i]);
    });
  }

  Future<Subscription?> getSubscriptionById(int id) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'subscriptions',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Subscription.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Subscription>> getActiveSubscriptions() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'subscriptions',
      where: 'status = ?',
      whereArgs: ['active'],
    );
    return List.generate(maps.length, (i) {
      return Subscription.fromMap(maps[i]);
    });
  }

  Future<List<Subscription>> getExpiredSubscriptions() async {
    final db = await dbHelper.database;
    final now = DateTime.now().toIso8601String().split('T')[0];
    final List<Map<String, dynamic>> maps = await db.query(
      'subscriptions',
      where: 'end_date < ? AND status = ?',
      whereArgs: [now, 'active'],
    );
    return List.generate(maps.length, (i) {
      return Subscription.fromMap(maps[i]);
    });
  }

  Future<int> insertSubscription(Subscription subscription) async {
    final db = await dbHelper.database;
    return await db.insert('subscriptions', subscription.toMap());
  }

  Future<int> updateSubscription(Subscription subscription) async {
    final db = await dbHelper.database;
    return await db.update(
      'subscriptions',
      subscription.toMap(),
      where: 'id = ?',
      whereArgs: [subscription.id],
    );
  }

  Future<int> deleteSubscription(int id) async {
    final db = await dbHelper.database;
    return await db.delete(
      'subscriptions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
