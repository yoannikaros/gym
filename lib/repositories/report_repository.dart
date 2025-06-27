import 'package:gym/database/database_helper.dart';
import 'package:intl/intl.dart';

class ReportRepository {
  final dbHelper = DatabaseHelper();

  // Mendapatkan data pendapatan dan pengeluaran berdasarkan periode
  Future<Map<String, dynamic>> getFinancialSummary(
      DateTime startDate, DateTime endDate) async {
    final db = await dbHelper.database;
    
    final startDateStr = DateFormat('yyyy-MM-dd').format(startDate);
    final endDateStr = DateFormat('yyyy-MM-dd').format(endDate);
    
    // Mendapatkan total pendapatan dari pembayaran
    final paymentResult = await db.rawQuery('''
      SELECT SUM(p.amount) as total
      FROM payments p
      JOIN subscriptions s ON p.subscription_id = s.id
      WHERE p.payment_date BETWEEN ? AND ?
    ''', [startDateStr, endDateStr]);
    
    // Mendapatkan total pengeluaran dari transaksi
    final expenseResult = await db.rawQuery('''
      SELECT SUM(amount) as total
      FROM transactions
      WHERE type = 'expense' AND transaction_date BETWEEN ? AND ?
    ''', [startDateStr, endDateStr]);
    
    // Mendapatkan total pendapatan lain dari transaksi
    final otherIncomeResult = await db.rawQuery('''
      SELECT SUM(amount) as total
      FROM transactions
      WHERE type = 'income' AND transaction_date BETWEEN ? AND ?
    ''', [startDateStr, endDateStr]);
    
    // Mendapatkan total setoran tabungan
    final depositResult = await db.rawQuery('''
      SELECT SUM(amount) as total
      FROM savings
      WHERE type = 'deposit' AND date BETWEEN ? AND ?
    ''', [startDateStr, endDateStr]);
    
    // Mendapatkan total penarikan tabungan
    final withdrawalResult = await db.rawQuery('''
      SELECT SUM(amount) as total
      FROM savings
      WHERE type = 'withdrawal' AND date BETWEEN ? AND ?
    ''', [startDateStr, endDateStr]);
    
    final paymentTotal = paymentResult.first['total'] as double? ?? 0.0;
    final expenseTotal = expenseResult.first['total'] as double? ?? 0.0;
    final otherIncomeTotal = otherIncomeResult.first['total'] as double? ?? 0.0;
    final depositTotal = depositResult.first['total'] as double? ?? 0.0;
    final withdrawalTotal = withdrawalResult.first['total'] as double? ?? 0.0;
    
    final totalIncome = paymentTotal + otherIncomeTotal;
    final totalExpense = expenseTotal;
    final netProfit = totalIncome - totalExpense;
    
    return {
      'payment_income': paymentTotal,
      'other_income': otherIncomeTotal,
      'total_income': totalIncome,
      'total_expense': expenseTotal,
      'net_profit': netProfit,
      'deposit': depositTotal,
      'withdrawal': withdrawalTotal,
      'savings_balance': depositTotal - withdrawalTotal,
    };
  }

  // Mendapatkan data pendapatan dan pengeluaran per hari dalam rentang waktu
  Future<List<Map<String, dynamic>>> getDailyFinancialData(
      DateTime startDate, DateTime endDate) async {
    final db = await dbHelper.database;
    
    final startDateStr = DateFormat('yyyy-MM-dd').format(startDate);
    final endDateStr = DateFormat('yyyy-MM-dd').format(endDate);
    
    // Mendapatkan pendapatan harian dari pembayaran
    final paymentResult = await db.rawQuery('''
      SELECT date(p.payment_date) as date, SUM(p.amount) as total
      FROM payments p
      JOIN subscriptions s ON p.subscription_id = s.id
      WHERE p.payment_date BETWEEN ? AND ?
      GROUP BY date(p.payment_date)
      ORDER BY date(p.payment_date)
    ''', [startDateStr, endDateStr]);
    
    // Mendapatkan pengeluaran harian dari transaksi
    final expenseResult = await db.rawQuery('''
      SELECT date(transaction_date) as date, SUM(amount) as total
      FROM transactions
      WHERE type = 'expense' AND transaction_date BETWEEN ? AND ?
      GROUP BY date(transaction_date)
      ORDER BY date(transaction_date)
    ''', [startDateStr, endDateStr]);
    
    // Mendapatkan pendapatan lain harian dari transaksi
    final otherIncomeResult = await db.rawQuery('''
      SELECT date(transaction_date) as date, SUM(amount) as total
      FROM transactions
      WHERE type = 'income' AND transaction_date BETWEEN ? AND ?
      GROUP BY date(transaction_date)
      ORDER BY date(transaction_date)
    ''', [startDateStr, endDateStr]);
    
    // Mengkonversi hasil query ke format yang lebih mudah digunakan
    final Map<String, double> paymentByDate = {};
    final Map<String, double> expenseByDate = {};
    final Map<String, double> otherIncomeByDate = {};
    
    for (var row in paymentResult) {
      final date = row['date'] as String;
      final total = row['total'] as double? ?? 0.0;
      paymentByDate[date] = total;
    }
    
    for (var row in expenseResult) {
      final date = row['date'] as String;
      final total = row['total'] as double? ?? 0.0;
      expenseByDate[date] = total;
    }
    
    for (var row in otherIncomeResult) {
      final date = row['date'] as String;
      final total = row['total'] as double? ?? 0.0;
      otherIncomeByDate[date] = total;
    }
    
    // Membuat daftar tanggal dalam rentang
    final List<Map<String, dynamic>> result = [];
    final difference = endDate.difference(startDate).inDays;
    
    for (int i = 0; i <= difference; i++) {
      final date = startDate.add(Duration(days: i));
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      final formattedDate = DateFormat('dd/MM/yyyy').format(date);
      
      result.add({
        'date': dateStr,
        'formatted_date': formattedDate,
        'payment_income': paymentByDate[dateStr] ?? 0.0,
        'other_income': otherIncomeByDate[dateStr] ?? 0.0,
        'total_income': (paymentByDate[dateStr] ?? 0.0) + (otherIncomeByDate[dateStr] ?? 0.0),
        'expense': expenseByDate[dateStr] ?? 0.0,
        'profit': (paymentByDate[dateStr] ?? 0.0) + (otherIncomeByDate[dateStr] ?? 0.0) - (expenseByDate[dateStr] ?? 0.0),
      });
    }
    
    return result;
  }

  // Mendapatkan data pendapatan dan pengeluaran per bulan dalam rentang waktu
  Future<List<Map<String, dynamic>>> getMonthlyFinancialData(
      DateTime startDate, DateTime endDate) async {
    final db = await dbHelper.database;
    
    final startDateStr = DateFormat('yyyy-MM-dd').format(startDate);
    final endDateStr = DateFormat('yyyy-MM-dd').format(endDate);
    
    // Mendapatkan pendapatan bulanan dari pembayaran
    final paymentResult = await db.rawQuery('''
      SELECT strftime('%Y-%m', p.payment_date) as month, SUM(p.amount) as total
      FROM payments p
      JOIN subscriptions s ON p.subscription_id = s.id
      WHERE p.payment_date BETWEEN ? AND ?
      GROUP BY strftime('%Y-%m', p.payment_date)
      ORDER BY strftime('%Y-%m', p.payment_date)
    ''', [startDateStr, endDateStr]);
    
    // Mendapatkan pengeluaran bulanan dari transaksi
    final expenseResult = await db.rawQuery('''
      SELECT strftime('%Y-%m', transaction_date) as month, SUM(amount) as total
      FROM transactions
      WHERE type = 'expense' AND transaction_date BETWEEN ? AND ?
      GROUP BY strftime('%Y-%m', transaction_date)
      ORDER BY strftime('%Y-%m', transaction_date)
    ''', [startDateStr, endDateStr]);
    
    // Mendapatkan pendapatan lain bulanan dari transaksi
    final otherIncomeResult = await db.rawQuery('''
      SELECT strftime('%Y-%m', transaction_date) as month, SUM(amount) as total
      FROM transactions
      WHERE type = 'income' AND transaction_date BETWEEN ? AND ?
      GROUP BY strftime('%Y-%m', transaction_date)
      ORDER BY strftime('%Y-%m', transaction_date)
    ''', [startDateStr, endDateStr]);
    
    // Mengkonversi hasil query ke format yang lebih mudah digunakan
    final Map<String, double> paymentByMonth = {};
    final Map<String, double> expenseByMonth = {};
    final Map<String, double> otherIncomeByMonth = {};
    
    for (var row in paymentResult) {
      final month = row['month'] as String;
      final total = row['total'] as double? ?? 0.0;
      paymentByMonth[month] = total;
    }
    
    for (var row in expenseResult) {
      final month = row['month'] as String;
      final total = row['total'] as double? ?? 0.0;
      expenseByMonth[month] = total;
    }
    
    for (var row in otherIncomeResult) {
      final month = row['month'] as String;
      final total = row['total'] as double? ?? 0.0;
      otherIncomeByMonth[month] = total;
    }
    
    // Membuat daftar bulan dalam rentang
    final List<Map<String, dynamic>> result = [];
    
    // Mendapatkan bulan awal dan akhir
    final startMonth = startDate.month;
    final startYear = startDate.year;
    final endMonth = endDate.month;
    final endYear = endDate.year;
    
    // Menghitung jumlah bulan dalam rentang
    final totalMonths = (endYear - startYear) * 12 + (endMonth - startMonth) + 1;
    
    for (int i = 0; i < totalMonths; i++) {
      final date = DateTime(startYear, startMonth + i, 1);
      final monthStr = DateFormat('yyyy-MM').format(date);
      final formattedMonth = DateFormat('MMMM yyyy').format(date);
      
      result.add({
        'month': monthStr,
        'formatted_month': formattedMonth,
        'payment_income': paymentByMonth[monthStr] ?? 0.0,
        'other_income': otherIncomeByMonth[monthStr] ?? 0.0,
        'total_income': (paymentByMonth[monthStr] ?? 0.0) + (otherIncomeByMonth[monthStr] ?? 0.0),
        'expense': expenseByMonth[monthStr] ?? 0.0,
        'profit': (paymentByMonth[monthStr] ?? 0.0) + (otherIncomeByMonth[monthStr] ?? 0.0) - (expenseByMonth[monthStr] ?? 0.0),
      });
    }
    
    return result;
  }

  // Mendapatkan data paket membership terlaris
  Future<List<Map<String, dynamic>>> getTopMembershipPackages(
      DateTime startDate, DateTime endDate) async {
    final db = await dbHelper.database;
    
    final startDateStr = DateFormat('yyyy-MM-dd').format(startDate);
    final endDateStr = DateFormat('yyyy-MM-dd').format(endDate);
    
    final result = await db.rawQuery('''
      SELECT mp.id, mp.name, COUNT(s.id) as subscription_count, SUM(p.amount) as total_revenue
      FROM membership_packages mp
      JOIN subscriptions s ON mp.id = s.package_id
      JOIN payments p ON s.id = p.subscription_id
      WHERE s.start_date BETWEEN ? AND ? OR p.payment_date BETWEEN ? AND ?
      GROUP BY mp.id
      ORDER BY subscription_count DESC
      LIMIT 5
    ''', [startDateStr, endDateStr, startDateStr, endDateStr]);
    
    return result.map((row) {
      return {
        'id': row['id'] as int,
        'name': row['name'] as String,
        'subscription_count': row['subscription_count'] as int,
        'total_revenue': row['total_revenue'] as double? ?? 0.0,
      };
    }).toList();
  }

  // Mendapatkan data kategori pengeluaran
  Future<List<Map<String, dynamic>>> getExpenseCategories(
      DateTime startDate, DateTime endDate) async {
    final db = await dbHelper.database;
    
    final startDateStr = DateFormat('yyyy-MM-dd').format(startDate);
    final endDateStr = DateFormat('yyyy-MM-dd').format(endDate);
    
    final result = await db.rawQuery('''
      SELECT category, SUM(amount) as total
      FROM transactions
      WHERE type = 'expense' AND transaction_date BETWEEN ? AND ?
      GROUP BY category
      ORDER BY total DESC
    ''', [startDateStr, endDateStr]);
    
    return result.map((row) {
      return {
        'category': row['category'] as String? ?? 'Lainnya',
        'total': row['total'] as double? ?? 0.0,
      };
    }).toList();
  }
}
