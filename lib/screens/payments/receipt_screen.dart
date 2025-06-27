import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gym/models/member.dart';
import 'package:gym/models/membership_package.dart';
import 'package:gym/models/payment.dart';
import 'package:gym/models/receipt.dart';
import 'package:gym/models/setting.dart';
import 'package:gym/models/subscription.dart';
import 'package:gym/repositories/setting_repository.dart';
import 'package:gym/utils/currency_formatter.dart';
import 'package:gym/utils/date_formatter.dart';
import 'package:gym/utils/receipt_pdf.dart';
import 'package:share_plus/share_plus.dart';

class ReceiptScreen extends StatefulWidget {
  final Payment payment;
  final Subscription subscription;
  final Member member;
  final MembershipPackage package;

  const ReceiptScreen({
    super.key,
    required this.payment,
    required this.subscription,
    required this.member,
    required this.package,
  });

  @override
  State<ReceiptScreen> createState() => _ReceiptScreenState();
}

class _ReceiptScreenState extends State<ReceiptScreen> {
  final GlobalKey _receiptKey = GlobalKey();
  final SettingRepository _settingRepository = SettingRepository();
  final ReceiptPDF _receiptPDF = ReceiptPDF();

  bool _isLoading = true;
  bool _isPdfViewVisible = false;
  Receipt? _receipt;
  File? _pdfFile;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final setting = await _settingRepository.getSettings();

      if (setting != null) {
        // Generate receipt number
        final now = DateTime.now();
        final receiptNumber = 'INV/${DateFormat('yyyyMMdd').format(now)}/${widget.payment.id}';

        setState(() {
          _receipt = Receipt(
            payment: widget.payment,
            subscription: widget.subscription,
            member: widget.member,
            package: widget.package,
            setting: setting,
            receiptNumber: receiptNumber,
            receiptDate: now,
          );
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _captureAndShareReceipt() async {
    try {
      // Capture receipt as image
      final RenderRepaintBoundary boundary = _receiptKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData != null) {
        final Uint8List pngBytes = byteData.buffer.asUint8List();

        // Save image to temporary file
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/receipt.png');
        await file.writeAsBytes(pngBytes);

        // Share image
        await Share.shareXFiles(
          [XFile(file.path)],
          text: 'Struk Pembayaran ${_receipt?.setting.gymName ?? "Gym"}',
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _generateAndViewPDF() async {
    if (_receipt == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final file = await _receiptPDF.savePDFTemp(_receipt!);

      setState(() {
        _pdfFile = file;
        _isPdfViewVisible = true;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _sharePDF() async {
    if (_receipt == null) return;

    try {
      await _receiptPDF.sharePDF(_receipt!);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isPdfViewVisible && _pdfFile != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('PDF Struk'),
          actions: [
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: _sharePDF,
              tooltip: 'Bagikan PDF',
            ),
          ],
        ),
        body: PDFView(
          filePath: _pdfFile!.path,
          enableSwipe: true,
          swipeHorizontal: false,
          autoSpacing: true,
          pageFling: true,
          pageSnap: true,
          fitPolicy: FitPolicy.BOTH,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            setState(() {
              _isPdfViewVisible = false;
            });
          },
          child: const Icon(Icons.arrow_back),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Struk Pembayaran'),
        actions: [
          if (!_isLoading && _receipt != null)
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'share_image':
                    _captureAndShareReceipt();
                    break;
                  case 'view_pdf':
                    _generateAndViewPDF();
                    break;
                  case 'share_pdf':
                    _sharePDF();
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'share_image',
                  child: Row(
                    children: [
                      Icon(Icons.image),
                      SizedBox(width: 8),
                      Text('Bagikan Gambar'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'view_pdf',
                  child: Row(
                    children: [
                      Icon(Icons.picture_as_pdf),
                      SizedBox(width: 8),
                      Text('Lihat PDF'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'share_pdf',
                  child: Row(
                    children: [
                      Icon(Icons.share),
                      SizedBox(width: 8),
                      Text('Bagikan PDF'),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _receipt == null
          ? const Center(child: Text('Data tidak ditemukan'))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            RepaintBoundary(
              key: _receiptKey,
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Center(
                      child: Column(
                        children: [
                          Text(
                            _receipt!.setting.gymName ?? 'Gym Management System',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'STRUK PEMBAYARAN',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Divider(thickness: 2),
                        ],
                      ),
                    ),

                    // Receipt Info
                    const SizedBox(height: 16),
                    _buildInfoRow('No. Struk', _receipt!.receiptNumber),
                    _buildInfoRow('Tanggal', DateFormat('dd MMMM yyyy, HH:mm').format(_receipt!.receiptDate)),
                    const Divider(),

                    // Member Info
                    const SizedBox(height: 8),
                    Text(
                      'INFORMASI ANGGOTA',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow('Nama', _receipt!.member.name),
                    if (_receipt!.member.phone != null)
                      _buildInfoRow('Telepon', _receipt!.member.phone!),
                    const Divider(),

                    // Subscription Info
                    const SizedBox(height: 8),
                    Text(
                      'INFORMASI LANGGANAN',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow('Paket', _receipt!.package.name),
                    _buildInfoRow('Durasi', '${_receipt!.package.durationDays} hari'),
                    _buildInfoRow('Mulai', DateFormatter.formatDate(_receipt!.subscription.startDate)),
                    _buildInfoRow('Berakhir', DateFormatter.formatDate(_receipt!.subscription.endDate)),
                    const Divider(),

                    // Payment Info
                    const SizedBox(height: 8),
                    Text(
                      'INFORMASI PEMBAYARAN',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow('Metode', _getPaymentMethodName(_receipt!.payment.paymentMethod)),
                    _buildInfoRow('Tanggal', DateFormatter.formatDate(_receipt!.payment.paymentDate)),
                    if (_receipt!.payment.note != null && _receipt!.payment.note!.isNotEmpty)
                      _buildInfoRow('Catatan', _receipt!.payment.note!),
                    const SizedBox(height: 16),

                    // Total
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'TOTAL',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            CurrencyFormatter.format(_receipt!.payment.amount),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Footer
                    const SizedBox(height: 24),
                    if (_receipt!.setting.noteHeader != null)
                      Center(
                        child: Text(
                          _receipt!.setting.noteHeader!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    if (_receipt!.setting.noteFooter != null)
                      Center(
                        child: Text(
                          _receipt!.setting.noteFooter!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _generateAndViewPDF,
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('Lihat PDF'),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: _sharePDF,
                  icon: const Icon(Icons.share),
                  label: const Text('Bagikan PDF'),
                ),
                const SizedBox(width: 16),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  icon: const Icon(Icons.check),
                  label: const Text('Selesai'),
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Text(': '),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

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
