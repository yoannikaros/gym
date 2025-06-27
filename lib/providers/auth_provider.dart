import 'package:flutter/material.dart';
import 'package:gym/database/database_helper.dart';
import 'package:gym/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null;

  void updateCurrentUser(User user) {
    _currentUser = user;
    notifyListeners();
  }

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final db = await DatabaseHelper().database;
      final result = await db.query(
        'users',
        where: 'username = ? AND password = ?',
        whereArgs: [username, password],
      );

      if (result.isNotEmpty) {
        _currentUser = User.fromMap(result.first);
        
        // Simpan status login
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('user_id', _currentUser!.id!);
        
        _isLoading = false;
        notifyListeners();
        return true;
      }
      
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    
    // Hapus status login
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
    
    notifyListeners();
  }

  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');
    
    if (userId != null) {
      final db = await DatabaseHelper().database;
      final result = await db.query(
        'users',
        where: 'id = ?',
        whereArgs: [userId],
      );
      
      if (result.isNotEmpty) {
        _currentUser = User.fromMap(result.first);
      }
    }
    
    notifyListeners();
  }

  Future<bool> register(User user) async {
    _isLoading = true;
    notifyListeners();

    try {
      final db = await DatabaseHelper().database;
      
      // Cek apakah username atau email sudah ada
      final existingUser = await db.query(
        'users',
        where: 'username = ? OR email = ?',
        whereArgs: [user.username, user.email],
      );
      
      if (existingUser.isNotEmpty) {
        _isLoading = false;
        notifyListeners();
        return false;
      }
      
      // Tambahkan user baru
      await db.insert('users', user.toMap());
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
