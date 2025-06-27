import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:gym/models/member.dart';
import 'package:gym/models/membership_package.dart';
import 'package:gym/models/payment.dart';
import 'package:gym/models/subscription.dart';
import 'package:gym/repositories/member_repository.dart';
import 'package:gym/repositories/membership_package_repository.dart';
import 'package:gym/repositories/payment_repository.dart';
import 'package:gym/repositories/subscription_repository.dart';
import 'package:gym/screens/payments/receipt_screen.dart';
import 'package:gym/utils/currency_formatter.dart';

class PaymentFormScreen extends StatefulWidget {
  final int? subscriptionId;
  final Payment? payment;

  const PaymentFormScreen({
    super.key,
    this.subscriptionId,
    this.payment,
  });

  @override
  State<PaymentFormScreen> createState() => _PaymentFormScreenState();
}

class _PaymentFormScreenState extends State<PaymentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  
  String _paymentMethod = 'cash';
  DateTime _paymentDate = DateTime.now();
  
  final PaymentRepository _paymentRepository = PaymentRepository();
  final SubscriptionRepository _subscriptionRepository = SubscriptionRepository();
  final MemberRepository _memberRepository = MemberRepository();
  final MembershipPackageRepository _packageRepository = MembershipPackageRepository();
  
  bool _isLoading = true;
  Subscription? _subscription;
  Member? _member;
  MembershipPackage? _package;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Jika ini adalah edit payment
      if (widget.payment != null) {
        _amountController.text = widget.payment!.amount.toString();
        _noteController.text = widget.payment!.note ?? '';
        _paymentMethod = widget.payment!.paymentMethod ?? 'cash';
        _paymentDate = DateTime.parse(widget.payment!.paymentDate);
        
        _subscription = await _subscriptionRepository.getSubscriptionById(widget.payment!.subscriptionId);
      } 
      // Jika ini adalah payment baru dengan subscription yang sudah dipilih
      else if (widget.subscriptionId != null) {
        _subscription = await _subscriptionRepository.getSubscriptionById(widget.subscriptionId!);
      }
      
      // Load member dan package data
      if (_subscription != null) {
        _member = await _memberRepository.getMemberById(_subscription!.memberId);
        _package = await _packageRepository.getPackageById(_subscription!.packageId);
        
        // Set default amount jika ini adalah payment baru
        if (widget.payment == null && _package != null) {
          _amountController.text = _package!.price.toString();
        }
      }
      
      setState(() {
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

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _paymentDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    
    if (picked != null && picked != _paymentDate) {
      setState(() {
        _paymentDate = picked;
      });
    }
  }

  Future<void> _savePayment() async {
    if (_formKey.currentState!.validate()) {
      if (_subscription == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Langganan tidak ditemukan'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        final payment = Payment(
          id: widget.payment?.id,
          subscriptionId: _subscription!.id!,
          amount: double.parse(_amountController.text.trim()),
          paymentDate: DateFormat('yyyy-MM-dd').format(_paymentDate),
          paymentMethod: _paymentMethod,
          note: _noteController.text.trim(),
        );

        int paymentId;
        if (widget.payment == null) {
          paymentId = await _paymentRepository.insertPayment(payment);
        } else {
          await _paymentRepository.updatePayment(payment);
          paymentId = widget.payment!.id!;
        }

        // Dapatkan payment yang baru saja disimpan
        final savedPayment = await _paymentRepository.getPaymentById(paymentId);

        setState(() {
          _isLoading = false;
        });

        if (mounted && savedPayment != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pembayaran berhasil disimpan'),
              backgroundColor: Colors.green,
            ),
          );
          
          // Navigasi ke halaman struk
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => ReceiptScreen(
                  payment: savedPayment,
                  subscription: _subscription!,
                  member: _member!,
                  package: _package!,
                ),
              ),
            );
          }
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.payment == null ? 'Tambah Pembayaran' : 'Edit Pembayaran'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _subscription == null || _member == null || _package == null
              ? const Center(child: Text('Data tidak ditemukan'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Informasi Langganan',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Divider(),
                                _buildInfoRow('Anggota', _member!.name),
                                _buildInfoRow('Paket', _package!.name),
                                _buildInfoRow('Harga', CurrencyFormatter.format(_package!.price)),
                                _buildInfoRow('Periode', '${DateFormat('dd/MM/yyyy').format(DateTime.parse(_subscription!.startDate))} - ${DateFormat('dd/MM/yyyy').format(DateTime.parse(_subscription!.endDate))}'),
                                _buildInfoRow('Status', _subscription!.status == 'active' ? 'Aktif' : 'Tidak Aktif'),
                              ],
                            ),
                          ),
                        ),
                        TextFormField(
                          controller: _amountController,
                          decoration: const InputDecoration(
                            labelText: 'Jumlah Pembayaran',
                            border: OutlineInputBorder(),
                            prefixText: 'Rp ',
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Jumlah pembayaran tidak boleh kosong';
                            }
                            if (double.tryParse(value) == null || double.parse(value) <= 0) {
                              return 'Jumlah pembayaran harus berupa angka positif';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _paymentMethod,
                          decoration: const InputDecoration(
                            labelText: 'Metode Pembayaran',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'cash',
                              child: Text('Tunai'),
                            ),
                            DropdownMenuItem(
                              value: 'transfer',
                              child: Text('Transfer Bank'),
                            ),
                            DropdownMenuItem(
                              value: 'qris',
                              child: Text('QRIS'),
                            ),
                            DropdownMenuItem(
                              value: 'other',
                              child: Text('Lainnya'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _paymentMethod = value!;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        InkWell(
                          onTap: () => _selectDate(context),
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Tanggal Pembayaran',
                              border: OutlineInputBorder(),
                            ),
                            child: Text(
                              DateFormat('dd/MM/yyyy').format(_paymentDate),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _noteController,
                          decoration: const InputDecoration(
                            labelText: 'Catatan',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _savePayment,
                            child: Text(
                              widget.payment == null ? 'Simpan & Cetak Struk' : 'Update & Cetak Struk',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
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
}
