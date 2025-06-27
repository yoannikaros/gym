import 'package:gym/database/database_helper.dart';
import 'package:gym/models/setting.dart';

class SettingRepository {
  final dbHelper = DatabaseHelper();

  Future<Setting?> getSettings() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('settings');

    if (maps.isNotEmpty) {
      return Setting.fromMap(maps.first);
    }
    
    // Jika tidak ada pengaturan, buat pengaturan default
    final defaultSetting = Setting(
      gymName: 'Gym Management System',
      noteHeader: 'Terima kasih telah bergabung',
      noteFooter: 'Selamat berolahraga',
    );
    
    await db.insert('settings', defaultSetting.toMap());
    return defaultSetting;
  }

  Future<int> updateSettings(Setting setting) async {
    final db = await dbHelper.database;
    
    // Cek apakah pengaturan sudah ada
    final List<Map<String, dynamic>> maps = await db.query('settings');
    
    if (maps.isEmpty) {
      // Jika belum ada, insert baru
      return await db.insert('settings', setting.toMap());
    } else {
      // Jika sudah ada, update
      return await db.update(
        'settings',
        setting.toMap(),
        where: 'id = ?',
        whereArgs: [maps.first['id']],
      );
    }
  }
}
