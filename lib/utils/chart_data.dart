import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChartData {
  final String label;
  final double value;
  final Color color;

  ChartData({
    required this.label,
    required this.value,
    required this.color,
  });
}

class FinancialChartData {
  static List<ChartData> prepareIncomeExpenseData(
      List<Map<String, dynamic>> data, bool isMonthly) {
    final List<ChartData> chartData = [];
    
    for (var item in data) {
      final String label = isMonthly 
          ? item['formatted_month'] 
          : item['formatted_date'];
      
      // Data pendapatan
      chartData.add(
        ChartData(
          label: label,
          value: item['total_income'],
          color: Colors.green,
        ),
      );
      
      // Data pengeluaran
      chartData.add(
        ChartData(
          label: label,
          value: item['expense'],
          color: Colors.red,
        ),
      );
    }
    
    return chartData;
  }

  static List<ChartData> prepareProfitData(
      List<Map<String, dynamic>> data, bool isMonthly) {
    final List<ChartData> chartData = [];
    
    for (var item in data) {
      final String label = isMonthly 
          ? item['formatted_month'] 
          : item['formatted_date'];
      
      // Data keuntungan
      chartData.add(
        ChartData(
          label: label,
          value: item['profit'],
          color: item['profit'] >= 0 ? Colors.blue : Colors.red,
        ),
      );
    }
    
    return chartData;
  }

  static List<ChartData> preparePackageData(
      List<Map<String, dynamic>> data) {
    final List<ChartData> chartData = [];
    final List<Color> colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
    ];
    
    for (int i = 0; i < data.length; i++) {
      final item = data[i];
      chartData.add(
        ChartData(
          label: item['name'],
          value: item['subscription_count'].toDouble(),
          color: colors[i % colors.length],
        ),
      );
    }
    
    return chartData;
  }

  static List<ChartData> prepareExpenseCategoryData(
      List<Map<String, dynamic>> data) {
    final List<ChartData> chartData = [];
    final List<Color> colors = [
      Colors.red,
      Colors.orange,
      Colors.amber,
      Colors.brown,
      Colors.grey,
    ];
    
    for (int i = 0; i < data.length; i++) {
      final item = data[i];
      chartData.add(
        ChartData(
          label: item['category'],
          value: item['total'],
          color: colors[i % colors.length],
        ),
      );
    }
    
    return chartData;
  }
}

class CurrencyFormatter {
  static String formatCompact(double value) {
    final formatter = NumberFormat.compactCurrency(
      locale: 'id',
      symbol: 'Rp',
      decimalDigits: 0,
    );
    return formatter.format(value);
  }
}
