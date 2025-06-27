import 'package:intl/intl.dart';

class DateFormatter {
  static String formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return 'Tidak ada tanggal';
    }
    
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return 'Format tanggal tidak valid';
    }
  }

  static String formatDateTime(String? dateTimeString) {
    if (dateTimeString == null || dateTimeString.isEmpty) {
      return 'Tidak ada waktu';
    }
    
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
    } catch (e) {
      return 'Format waktu tidak valid';
    }
  }

  static String formatTime(String? timeString) {
    if (timeString == null || timeString.isEmpty) {
      return 'Tidak ada waktu';
    }
    
    try {
      // Jika format waktu hanya HH:mm:ss
      if (!timeString.contains('T') && !timeString.contains('-')) {
        final parts = timeString.split(':');
        return '${parts[0]}:${parts[1]}';
      }
      
      // Jika format waktu lengkap dengan tanggal
      final dateTime = DateTime.parse(timeString);
      return DateFormat('HH:mm').format(dateTime);
    } catch (e) {
      return 'Format waktu tidak valid';
    }
  }

  static String getRelativeTime(String? dateTimeString) {
    if (dateTimeString == null || dateTimeString.isEmpty) {
      return 'Tidak ada waktu';
    }
    
    try {
      final dateTime = DateTime.parse(dateTimeString);
      final now = DateTime.now();
      final difference = now.difference(dateTime);
      
      if (difference.inDays > 365) {
        return '${(difference.inDays / 365).floor()} tahun yang lalu';
      } else if (difference.inDays > 30) {
        return '${(difference.inDays / 30).floor()} bulan yang lalu';
      } else if (difference.inDays > 0) {
        return '${difference.inDays} hari yang lalu';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} jam yang lalu';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} menit yang lalu';
      } else {
        return 'Baru saja';
      }
    } catch (e) {
      return 'Format waktu tidak valid';
    }
  }
}
