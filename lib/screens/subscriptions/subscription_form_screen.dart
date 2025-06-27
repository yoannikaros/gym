import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:gym/models/member.dart';
import 'package:gym/models/membership_package.dart';
import 'package:gym/models/subscription.dart';
import 'package:gym/repositories/member_repository.dart';
import 'package:gym/repositories/membership_package_repository.dart';
import 'package:gym/repositories/subscription_repository.dart';
import 'package:gym/screens/payments/payment_form_screen.dart';
import 'package:gym/utils/currency_formatter.dart';

class SubscriptionFormScreen extends StatefulWidget {
  final int? memberId;
  final Subscription? subscription;

  const SubscriptionFormScreen({
    super.key,
    this.memberId,
    this.subscription,
  });

  @override
  State<SubscriptionFormScreen> createState() => _SubscriptionFormScreenState();
}

class _SubscriptionFormScreenState extends State<SubscriptionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  int? _selectedMemberId;
  int? _selectedPackageId;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));
  String _status = 'active';
  
  final MemberRepository _memberRepository = MemberRepository();
  final MembershipPackageRepository _packageRepository = MembershipPackageRepository();
  final SubscriptionRepository _subscriptionRepository = SubscriptionRepository();
  
  bool _isLoading = true;
  List<Member> _members = [];
  List<MembershipPackage> _packages = [];

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
      // Load members and packages
      final members = await _memberRepository.getAllMembers();
      final packages = await _packageRepository.getAllPackages();
      
      setState(() {
        _members = members;
        _packages = packages;
        
        // Set initial values if editing
        if (widget.subscription != null) {
          _selectedMemberId = widget.subscription!.memberId;
          _selectedPackageId = widget.subscription!.packageId;
          _startDate = DateTime.parse(widget.subscription!.startDate);
          _endDate = DateTime.parse(widget.subscription!.endDate);
          _status = widget.subscription!.status;
        } 
        // Set initial member if provided
        else if (widget.memberId != null) {
          _selectedMemberId = widget.memberId;
        }
        
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

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime initialDate = isStartDate ? _startDate : _endDate;
    final DateTime firstDate = isStartDate ? DateTime(2000) : _startDate;
    
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: DateTime(2100),
    );
    
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          // Recalculate end date based on package duration
          if (_selectedPackageId != null) {
            final package = _packages.firstWhere((p) => p.id == _selectedPackageId);
            _endDate = picked.add(Duration(days: package.durationDays));
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _updateEndDate() {
    if (_selectedPackageId != null) {
      final package = _packages.firstWhere((p) => p.id == _selectedPackageId);
      setState(() {
        _endDate = _startDate.add(Duration(days: package.durationDays));
      });
    }
  }

  Future<void> _saveSubscription() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedMemberId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pilih anggota terlebih dahulu'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      
      if (_selectedPackageId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pilih paket terlebih dahulu'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        final subscription = Subscription(
          id: widget.subscription?.id,
          memberId: _selectedMemberId!,
          packageId: _selectedPackageId!,
          startDate: DateFormat('yyyy-MM-dd').format(_startDate),
          endDate: DateFormat('yyyy-MM-dd').format(_endDate),
          status: _status,
        );

        int subscriptionId;
        if (widget.subscription == null) {
          subscriptionId = await _subscriptionRepository.insertSubscription(subscription);
        } else {
          await _subscriptionRepository.updateSubscription(subscription);
          subscriptionId = widget.subscription!.id!;
        }

        setState(() {
          _isLoading = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Langganan berhasil disimpan'),
              backgroundColor: Colors.green,
            ),
          );
          
          // Tanya apakah ingin langsung membuat pembayaran
          if (widget.subscription == null) {
            _showPaymentPrompt(subscriptionId);
          } else {
            Navigator.of(context).pop(true);
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

  void _showPaymentPrompt(int subscriptionId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Buat Pembayaran'),
        content: const Text('Apakah Anda ingin membuat pembayaran untuk langganan ini sekarang?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(true);
            },
            child: const Text('Nanti Saja'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => PaymentFormScreen(subscriptionId: subscriptionId),
                ),
              );
            },
            child: const Text('Ya, Buat Pembayaran'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.subscription == null ? 'Tambah Langganan' : 'Edit Langganan'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<int>(
                      value: _selectedMemberId,
                      decoration: const InputDecoration(
                        labelText: 'Anggota',
                        border: OutlineInputBorder(),
                      ),
                      items: _members.map((member) {
                        return DropdownMenuItem<int>(
                          value: member.id,
                          child: Text(member.name),
                        );
                      }).toList(),
                      onChanged: widget.subscription != null ? null : (value) {
                        setState(() {
                          _selectedMemberId = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Pilih anggota';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      value: _selectedPackageId,
                      decoration: const InputDecoration(
                        labelText: 'Paket Membership',
                        border: OutlineInputBorder(),
                      ),
                      items: _packages.map((package) {
                        return DropdownMenuItem<int>(
                          value: package.id,
                          child: Text('${package.name} - ${CurrencyFormatter.format(package.price)} (${package.durationDays} hari)'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedPackageId = value;
                          _updateEndDate();
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Pilih paket membership';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () => _selectDate(context, true),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Tanggal Mulai',
                          border: OutlineInputBorder(),
                        ),
                        child: Text(
                          DateFormat('dd/MM/yyyy').format(_startDate),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () => _selectDate(context, false),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Tanggal Berakhir',
                          border: OutlineInputBorder(),
                        ),
                        child: Text(
                          DateFormat('dd/MM/yyyy').format(_endDate),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _status,
                      decoration: const InputDecoration(
                        labelText: 'Status',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'active',
                          child: Text('Aktif'),
                        ),
                        DropdownMenuItem(
                          value: 'inactive',
                          child: Text('Tidak Aktif'),
                        ),
                        DropdownMenuItem(
                          value: 'expired',
                          child: Text('Kadaluarsa'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _status = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _saveSubscription,
                        child: Text(
                          widget.subscription == null ? 'Simpan' : 'Update',
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
}
