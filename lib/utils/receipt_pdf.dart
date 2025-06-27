import 'dart:io';
import 'dart:typed_data';

import 'package:esc_pos_utils_updated/esc_pos_utils_updated.dart';
import 'package:flutter/services.dart';
import 'package:gym/models/receipt.dart';
import 'package:gym/utils/currency_formatter.dart';
import 'package:gym/utils/date_formatter.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:google_fonts/google_fonts.dart';

class ReceiptPDF {
  // Singleton instance
  static final ReceiptPDF _instance = ReceiptPDF._internal();
  factory ReceiptPDF() => _instance;
  ReceiptPDF._internal();

  // Generate PDF from receipt
  Future<Uint8List> generatePDF(Receipt receipt) async {
    // Load fonts
    final fontData = await _loadFontData();
    
    // Create PDF document
    final pdf = pw.Document();
    
    // Add page
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat(80 * PdfPageFormat.mm, double.infinity),
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(10),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                pw.Center(
                  child: pw.Column(
                    children: [
                      pw.Text(
                        receipt.setting.gymName ?? 'Gym Management System',
                        style: pw.TextStyle(
                          font: fontData.bold,
                          fontSize: 14,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'STRUK PEMBAYARAN',
                        style: pw.TextStyle(
                          font: fontData.bold,
                          fontSize: 12,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Divider(thickness: 1),
                    ],
                  ),
                ),
                
                // Receipt Info
                pw.SizedBox(height: 10),
                _buildInfoRow('No. Struk', receipt.receiptNumber, fontData),
                _buildInfoRow(
                  'Tanggal', 
                  DateFormat('dd MMMM yyyy, HH:mm').format(receipt.receiptDate),
                  fontData
                ),
                pw.Divider(),
                
                // Member Info
                pw.SizedBox(height: 8),
                pw.Text(
                  'INFORMASI ANGGOTA',
                  style: pw.TextStyle(
                    font: fontData.bold,
                    fontSize: 10,
                  ),
                ),
                pw.SizedBox(height: 5),
                _buildInfoRow('Nama', receipt.member.name, fontData),
                if (receipt.member.phone != null)
                  _buildInfoRow('Telepon', receipt.member.phone!, fontData),
                pw.Divider(),
                
                // Subscription Info
                pw.SizedBox(height: 8),
                pw.Text(
                  'INFORMASI LANGGANAN',
                  style: pw.TextStyle(
                    font: fontData.bold,
                    fontSize: 10,
                  ),
                ),
                pw.SizedBox(height: 5),
                _buildInfoRow('Paket', receipt.package.name, fontData),
                _buildInfoRow('Durasi', '${receipt.package.durationDays} hari', fontData),
                _buildInfoRow('Mulai', DateFormatter.formatDate(receipt.subscription.startDate), fontData),
                _buildInfoRow('Berakhir', DateFormatter.formatDate(receipt.subscription.endDate), fontData),
                pw.Divider(),
                
                // Payment Info
                pw.SizedBox(height: 8),
                pw.Text(
                  'INFORMASI PEMBAYARAN',
                  style: pw.TextStyle(
                    font: fontData.bold,
                    fontSize: 10,
                  ),
                ),
                pw.SizedBox(height: 5),
                _buildInfoRow('Metode', _getPaymentMethodName(receipt.payment.paymentMethod), fontData),
                _buildInfoRow('Tanggal', DateFormatter.formatDate(receipt.payment.paymentDate), fontData),
                if (receipt.payment.note != null && receipt.payment.note!.isNotEmpty)
                  _buildInfoRow('Catatan', receipt.payment.note!, fontData),
                pw.SizedBox(height: 10),
                
                // Total
                pw.Container(
                  padding: const pw.EdgeInsets.all(8),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey200,
                    borderRadius: pw.BorderRadius.circular(4),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'TOTAL',
                        style: pw.TextStyle(
                          font: fontData.bold,
                          fontSize: 12,
                        ),
                      ),
                      pw.Text(
                        CurrencyFormatter.format(receipt.payment.amount),
                        style: pw.TextStyle(
                          font: fontData.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Footer
                pw.SizedBox(height: 20),
                if (receipt.setting.noteHeader != null)
                  pw.Center(
                    child: pw.Text(
                      receipt.setting.noteHeader!,
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
                        font: fontData.italic,
                        fontSize: 9,
                      ),
                    ),
                  ),
                if (receipt.setting.noteFooter != null)
                  pw.Center(
                    child: pw.Text(
                      receipt.setting.noteFooter!,
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
                        font: fontData.italic,
                        fontSize: 9,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
    
    // Return PDF as bytes
    return pdf.save();
  }

  // Build info row
  pw.Widget _buildInfoRow(String label, String value, _FontData fontData) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 80,
            child: pw.Text(
              label,
              style: pw.TextStyle(
                font: fontData.semiBold,
                fontSize: 9,
              ),
            ),
          ),
          pw.Text(
            ': ',
            style: pw.TextStyle(
              font: fontData.regular,
              fontSize: 9,
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: pw.TextStyle(
                font: fontData.regular,
                fontSize: 9,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Print PDF
  Future<void> printPDF(Receipt receipt) async {
    final pdfBytes = await generatePDF(receipt);
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
      name: 'Struk_${receipt.receiptNumber}.pdf',
    );
  }

  // Save PDF to file and share
  Future<void> sharePDF(Receipt receipt) async {
    final pdfBytes = await generatePDF(receipt);
    
    // Save to temporary file
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/Struk_${receipt.receiptNumber}.pdf');
    await file.writeAsBytes(pdfBytes);
    
    // Share file
    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'Struk Pembayaran ${receipt.setting.gymName ?? "Gym"}',
    );
  }

  // View PDF
  Future<File> savePDFTemp(Receipt receipt) async {
    final pdfBytes = await generatePDF(receipt);
    
    // Save to temporary file
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/Struk_${receipt.receiptNumber}.pdf');
    await file.writeAsBytes(pdfBytes);
    
    return file;
  }

  // Load font data
  Future<_FontData> _loadFontData() async {
    final regular = await PdfGoogleFonts.nunitoRegular();
    final bold = await PdfGoogleFonts.nunitoBold();
    final italic = await PdfGoogleFonts.nunitoItalic();
    final semiBold = await PdfGoogleFonts.nunitoSemiBold();
    
    return _FontData(
      regular: regular,
      bold: bold,
      italic: italic,
      semiBold: semiBold,
    );
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

class _FontData {
  final pw.Font regular;
  final pw.Font bold;
  final pw.Font italic;
  final pw.Font semiBold;
  
  _FontData({
    required this.regular,
    required this.bold,
    required this.italic,
    required this.semiBold,
  });
}
