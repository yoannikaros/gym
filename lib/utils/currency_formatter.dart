import 'package:intl/intl.dart';

class CurrencyFormatter {
  static String format(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    
    return formatter.format(amount);
  }
  
  static String formatCompact(double amount) {
    final formatter = NumberFormat.compactCurrency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    
    return formatter.format(amount);
  }
  
  static double parse(String formattedAmount) {
    // Hapus simbol mata uang dan pemisah ribuan
    final cleanString = formattedAmount.replaceAll('Rp ', '').replaceAll('.', '');
    
    // Ganti koma dengan titik untuk parsing
    final normalizedString = cleanString.replaceAll(',', '.');
    
    return double.parse(normalizedString);
  }
}
