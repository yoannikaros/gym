import 'package:gym/database/database_helper.dart';
import 'package:gym/models/payment.dart';

class PaymentRepository {
  final dbHelper = DatabaseHelper();

  Future<List<Payment>> getAllPayments() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'payments',
      orderBy: 'payment_date DESC',
    );
    return List.generate(maps.length, (i) {
      return Payment.fromMap(maps[i]);
    });
  }

  Future<List<Payment>> getPaymentsBySubscriptionId(int subscriptionId) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'payments',
      where: 'subscription_id = ?',
      whereArgs: [subscriptionId],
      orderBy: 'payment_date DESC',
    );
    return List.generate(maps.length, (i) {
      return Payment.fromMap(maps[i]);
    });
  }

  Future<Payment?> getPaymentById(int id) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'payments',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Payment.fromMap(maps.first);
    }
    return null;
  }

  Future<int> insertPayment(Payment payment) async {
    final db = await dbHelper.database;
    return await db.insert('payments', payment.toMap());
  }

  Future<int> updatePayment(Payment payment) async {
    final db = await dbHelper.database;
    return await db.update(
      'payments',
      payment.toMap(),
      where: 'id = ?',
      whereArgs: [payment.id],
    );
  }

  Future<int> deletePayment(int id) async {
    final db = await dbHelper.database;
    return await db.delete(
      'payments',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<double> getTotalPaymentsBySubscriptionId(int subscriptionId) async {
    final db = await dbHelper.database;
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM payments WHERE subscription_id = ?',
      [subscriptionId],
    );
    return result.first['total'] as double? ?? 0.0;
  }
}
