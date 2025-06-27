import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_pos_printer_platform_image_3/flutter_pos_printer_platform_image_3.dart';
import 'package:gym/models/receipt.dart';
import 'package:gym/utils/currency_formatter.dart';
import 'package:gym/utils/date_formatter.dart';
import 'package:image/image.dart' as img;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class ReceiptPrinter {
  // Singleton instance
  static final ReceiptPrinter _instance = ReceiptPrinter._internal();
  factory ReceiptPrinter() => _instance;
  ReceiptPrinter._internal();

  // Printer manager
  final PrinterManager _printerManager = PrinterManager.instance;

  // Printer connection status
  bool _isConnected = false;
  PrinterDevice? _selectedPrinter;

  // Initialize printer
  Future<void> initialize() async {
    try {
      // Request permissions
      await _requestPermissions();
    } catch (e) {
      print('Error initializing printer: $e');
    }
  }

  // Request required permissions
  Future<void> _requestPermissions() async {
    if (Platform.isAndroid) {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.bluetooth,
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.bluetoothAdvertise,
        Permission.location,
      ].request();

      print('Permission statuses: $statuses');
    }
  }

  // Discover available printers
  Future<List<PrinterDevice>> discoverPrinters() async {
    List<PrinterDevice> devices = [];

    try {
      devices = (await _printerManager.discovery(
        type: PrinterType.bluetooth,
        isBle: false,
      )) as List<PrinterDevice>;
    } catch (e) {
      print('Error discovering printers: $e');
    }

    return devices;
  }

  // Connect to printer
  Future<bool> connectPrinter(PrinterDevice printer) async {
    try {
      _isConnected = await _printerManager.connect(
        type: PrinterType.bluetooth,
        model: BluetoothPrinterInput(
          name: printer.name,
          address: printer.address!,
          isBle: false,
          autoConnect: true,
        ),
      );

      if (_isConnected) {
        _selectedPrinter = printer;
      }

      return _isConnected;
    } catch (e) {
      print('Error connecting to printer: $e');
      return false;
    }
  }

  // Disconnect from printer
  Future<bool> disconnect() async {
    try {
      _isConnected = false;
      _selectedPrinter = null;
      return await _printerManager.disconnect(type: PrinterType.bluetooth);
    } catch (e) {
      print('Error disconnecting printer: $e');
      return false;
    }
  }

  // Check if printer is connected
  bool get isConnected => _isConnected;

  // Get selected printer
  PrinterDevice? get selectedPrinter => _selectedPrinter;

  // Print receipt
  Future<bool> printReceipt(Receipt receipt) async {
    if (!_isConnected || _selectedPrinter == null) {
      return false;
    }

    try {
      // Generate receipt image
      final Uint8List imageBytes = await _generateReceiptImage(receipt);
      return true;
    } catch (e) {
      print('Error printing receipt: $e');
      return false;
    }
  }

  // Generate receipt image
  Future<Uint8List> _generateReceiptImage(Receipt receipt) async {
    // Create a new image
    final img.Image image = img.Image(width: 380, height: 800);

    // Fill with white background
    img.fill(image, color: img.ColorRgb8(255, 255, 255));

    // Draw receipt content
    int y = 10;

    // Header
    y = _drawText(image, receipt.setting.gymName ?? 'Gym Management System', y, fontSize: 14, isBold: true, alignment: TextAlignment.center);
    y = _drawText(image, 'STRUK PEMBAYARAN', y + 5, fontSize: 12, isBold: true, alignment: TextAlignment.center);
    y = _drawLine(image, y + 10);

    // Receipt Info
    y = _drawText(image, 'No. Struk: ${receipt.receiptNumber}', y + 10);
    y = _drawText(image, 'Tanggal: ${DateFormat('dd MMMM yyyy, HH:mm').format(receipt.receiptDate)}', y + 5);
    y = _drawLine(image, y + 10);

    // Member Info
    y = _drawText(image, 'INFORMASI ANGGOTA', y + 10, isBold: true);
    y = _drawText(image, 'Nama: ${receipt.member.name}', y + 5);
    if (receipt.member.phone != null) {
      y = _drawText(image, 'Telepon: ${receipt.member.phone}', y + 5);
    }
    y = _drawLine(image, y + 10);

    // Subscription Info
    y = _drawText(image, 'INFORMASI LANGGANAN', y + 10, isBold: true);
    y = _drawText(image, 'Paket: ${receipt.package.name}', y + 5);
    y = _drawText(image, 'Durasi: ${receipt.package.durationDays} hari', y + 5);
    y = _drawText(image, 'Mulai: ${DateFormatter.formatDate(receipt.subscription.startDate)}', y + 5);
    y = _drawText(image, 'Berakhir: ${DateFormatter.formatDate(receipt.subscription.endDate)}', y + 5);
    y = _drawLine(image, y + 10);

    // Payment Info
    y = _drawText(image, 'INFORMASI PEMBAYARAN', y + 10, isBold: true);
    y = _drawText(image, 'Metode: ${_getPaymentMethodName(receipt.payment.paymentMethod)}', y + 5);
    y = _drawText(image, 'Tanggal: ${DateFormatter.formatDate(receipt.payment.paymentDate)}', y + 5);
    if (receipt.payment.note != null && receipt.payment.note!.isNotEmpty) {
      y = _drawText(image, 'Catatan: ${receipt.payment.note}', y + 5);
    }

    // Total
    y = _drawLine(image, y + 10);
    y = _drawText(image, 'TOTAL: ${CurrencyFormatter.format(receipt.payment.amount)}', y + 10, isBold: true, alignment: TextAlignment.right);
    y = _drawLine(image, y + 10);

    // Footer
    if (receipt.setting.noteHeader != null) {
      y = _drawText(image, receipt.setting.noteHeader!, y + 10, alignment: TextAlignment.center);
    }
    if (receipt.setting.noteFooter != null) {
      y = _drawText(image, receipt.setting.noteFooter!, y + 5, alignment: TextAlignment.center);
    }

    // Resize image to actual content height
    final img.Image croppedImage = img.copyCrop(
        image,
        x: 0,
        y: 0,
        width: image.width,
        height: y + 20
    );

    // Convert to PNG
    return Uint8List.fromList(img.encodePng(croppedImage));
  }

  // Draw text on image
  int _drawText(img.Image image, String text, int y, {
    int fontSize = 10,
    bool isBold = false,
    TextAlignment alignment = TextAlignment.left,
  }) {
    final int x = _getAlignmentX(text, alignment, image.width);

    img.drawString(
      image,
      text,
      font: isBold ? img.arial24 : img.arial14,
      x: x,
      y: y,
      color: img.ColorRgb8(0, 0, 0),
    );

    return y + fontSize + 2;
  }

  // Get X position based on alignment
  int _getAlignmentX(String text, TextAlignment alignment, int imageWidth) {
    switch (alignment) {
      case TextAlignment.center:
        return (imageWidth - text.length * 6) ~/ 2;
      case TextAlignment.right:
        return imageWidth - text.length * 6 - 10;
      case TextAlignment.left:
      default:
        return 10;
    }
  }

  // Draw horizontal line
  int _drawLine(img.Image image, int y) {
    for (int x = 10; x < image.width - 10; x++) {
      image.setPixel(x, y, img.ColorRgb8(0, 0, 0));
    }
    return y;
  }

  // Get payment method name
  String _getPaymentMethodName(String? method) {
    switch (method) {
      case 'cash':
        return 'Tunai';
      case 'transfer':
        return 'Transfer Bank';
      case 'qris':
        return 'QRIS';
      case 'other':
        return 'Lainnya';
      default:
        return 'Tunai';
    }
  }
}

enum TextAlignment {
  left,
  center,
  right,
}
