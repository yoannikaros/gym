import 'package:gym/database/database_helper.dart';
import 'package:gym/models/user.dart';

class UserRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<bool> updateUsername(int userId, String newUsername) async {
    try {
      // Check if username already exists
      final db = await _databaseHelper.database;
      final List<Map<String, dynamic>> existingUsers = await db.query(
        'users',
        where: 'username = ? AND id != ?',
        whereArgs: [newUsername, userId],
      );

      if (existingUsers.isNotEmpty) {
        throw Exception('Username sudah digunakan');
      }

      // Update username
      final result = await db.update(
        'users',
        {'username': newUsername},
        where: 'id = ?',
        whereArgs: [userId],
      );

      return result > 0;
    } catch (e) {
      throw Exception('Gagal mengubah username: ${e.toString()}');
    }
  }

  Future<bool> updatePassword(int userId, String currentPassword, String newPassword) async {
    try {
      final db = await _databaseHelper.database;
      
      // Verify current password
      final List<Map<String, dynamic>> user = await db.query(
        'users',
        where: 'id = ? AND password = ?',
        whereArgs: [userId, currentPassword],
      );

      if (user.isEmpty) {
        throw Exception('Password saat ini tidak sesuai');
      }

      // Update password
      final result = await db.update(
        'users',
        {'password': newPassword},
        where: 'id = ?',
        whereArgs: [userId],
      );

      return result > 0;
    } catch (e) {
      throw Exception('Gagal mengubah password: ${e.toString()}');
    }
  }

  Future<User?> getUserById(int userId) async {
    try {
      final db = await _databaseHelper.database;
      final List<Map<String, dynamic>> results = await db.query(
        'users',
        where: 'id = ?',
        whereArgs: [userId],
      );

      if (results.isEmpty) {
        return null;
      }

      return User.fromMap(results.first);
    } catch (e) {
      throw Exception('Gagal mendapatkan data user: ${e.toString()}');
    }
  }

  Future<bool> deleteAccount(int userId, String password) async {
    try {
      final db = await _databaseHelper.database;
      
      // Verify password first
      final List<Map<String, dynamic>> user = await db.query(
        'users',
        where: 'id = ? AND password = ?',
        whereArgs: [userId, password],
      );

      if (user.isEmpty) {
        throw Exception('Password tidak sesuai');
      }

      // Begin transaction to delete user and related data
      await db.transaction((txn) async {
        // Delete user's related data from other tables
        // Note: Add more tables as needed based on your database structure
        await txn.delete('subscriptions', where: 'user_id = ?', whereArgs: [userId]);
        await txn.delete('payments', where: 'user_id = ?', whereArgs: [userId]);
        await txn.delete('transactions', where: 'user_id = ?', whereArgs: [userId]);
        await txn.delete('attendance', where: 'user_id = ?', whereArgs: [userId]);
        
        // Finally delete the user
        final result = await txn.delete(
          'users',
          where: 'id = ?',
          whereArgs: [userId],
        );

        if (result <= 0) {
          throw Exception('Gagal menghapus akun');
        }
      });

      return true;
    } catch (e) {
      throw Exception('Gagal menghapus akun: ${e.toString()}');
    }
  }
} 