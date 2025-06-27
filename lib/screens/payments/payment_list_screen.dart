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
import 'package:gym/screens/payments/payment_form_screen.dart';
import 'package:gym/screens/payments/receipt_screen.dart';
import 'package:gym/utils/currency_formatter.dart';
import 'package:gym/utils/date_formatter.dart';

class PaymentListScreen extends StatefulWidget {
  final int? memberId;
  final int? subscriptionId;

  const PaymentListScreen({
    super.key,
    this.memberId,
    this.subscriptionId,
  });

  @override
  State<PaymentListScreen> createState() => _PaymentListScreenState();
}

class _PaymentListScreenState extends State<PaymentListScreen> with SingleTickerProviderStateMixin {
  final PaymentRepository _paymentRepository = PaymentRepository();
  final SubscriptionRepository _subscriptionRepository = SubscriptionRepository();
  final MemberRepository _memberRepository = MemberRepository();
  final MembershipPackageRepository _packageRepository = MembershipPackageRepository();
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  List<Payment> _payments = [];
  Map<int, Subscription> _subscriptions = {};
  Map<int, Member> _members = {};
  Map<int, MembershipPackage> _packages = {};
  double _totalPayments = 0;
  
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _loadData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<Payment> payments;
      
      // Filter payments if needed
      if (widget.subscriptionId != null) {
        payments = await _paymentRepository.getPaymentsBySubscriptionId(widget.subscriptionId!);
      } else if (widget.memberId != null) {
        // Get all subscriptions for this member
        final memberSubscriptions = await _subscriptionRepository.getSubscriptionsByMemberId(widget.memberId!);
        
        // Get payments for all these subscriptions
        payments = [];
        for (var subscription in memberSubscriptions) {
          final subscriptionPayments = await _paymentRepository.getPaymentsBySubscriptionId(subscription.id!);
          payments.addAll(subscriptionPayments);
        }
      } else {
        payments = await _paymentRepository.getAllPayments();
      }
      
      // Get all related subscriptions
      final subscriptionIds = payments.map((p) => p.subscriptionId).toSet().toList();
      final subscriptionMap = <int, Subscription>{};
      
      for (var id in subscriptionIds) {
        final subscription = await _subscriptionRepository.getSubscriptionById(id);
        if (subscription != null) {
          subscriptionMap[id] = subscription;
        }
      }
      
      // Get all related members and packages
      final memberIds = subscriptionMap.values.map((s) => s.memberId).toSet().toList();
      final packageIds = subscriptionMap.values.map((s) => s.packageId).toSet().toList();
      
      final memberMap = <int, Member>{};
      final packageMap = <int, MembershipPackage>{};
      
      for (var id in memberIds) {
        final member = await _memberRepository.getMemberById(id);
        if (member != null) {
          memberMap[id] = member;
        }
      }
      
      for (var id in packageIds) {
        final package = await _packageRepository.getPackageById(id);
        if (package != null) {
          packageMap[id] = package;
        }
      }

      // Calculate total payments
      double total = 0;
      for (var payment in payments) {
        total += payment.amount;
      }
      
      setState(() {
        _payments = payments;
        _subscriptions = subscriptionMap;
        _members = memberMap;
        _packages = packageMap;
        _totalPayments = total;
        _isLoading = false;
      });
      
      _animationController.reset();
      _animationController.forward();
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

  Future<void> _deletePayment(int id) async {
    try {
      await _paymentRepository.deletePayment(id);
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pembayaran berhasil dihapus'),
            backgroundColor: Colors.green,
          ),
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

  Color _getPaymentMethodColor(String? method) {
    switch (method) {
      case 'cash':
        return Colors.green;
      case 'transfer':
        return Colors.blue;
      case 'qris':
        return Colors.purple;
      case 'other':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getPaymentMethodIcon(String? method) {
    switch (method) {
      case 'cash':
        return '💵';
      case 'transfer':
        return '🏦';
      case 'qris':
        return '📱';
      case 'other':
        return '💳';
      default:
        return '💰';
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColor.withOpacity(0.8),
              ],
            ),
          ),
        ),
        title: const Text(
          'Daftar Pembayaran',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _payments.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.payment_outlined,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Tidak ada data pembayaran',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (widget.subscriptionId != null)
                        ElevatedButton.icon(
                          onPressed: () async {
                            final result = await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => PaymentFormScreen(
                                  subscriptionId: widget.subscriptionId,
                                ),
                              ),
                            );
                            if (result == true) {
                              _loadData();
                            }
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Tambah Pembayaran'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Theme.of(context).primaryColor.withOpacity(0.8),
                                    Theme.of(context).primaryColor,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Total Pembayaran',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white70,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    CurrencyFormatter.format(_totalPayments),
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${_payments.length} transaksi',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final payment = _payments[index];
                            final subscription = _subscriptions[payment.subscriptionId];
                            
                            if (subscription == null) {
                              return const SizedBox.shrink();
                            }
                            
                            final member = _members[subscription.memberId];
                            final package = _packages[subscription.packageId];
                            
                            if (member == null || package == null) {
                              return const SizedBox.shrink();
                            }
                            
                            return FadeTransition(
                              opacity: _fadeAnimation,
                              child: Card(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                member.name,
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 6,
                                              ),
                                              decoration: BoxDecoration(
                                                color: _getPaymentMethodColor(payment.paymentMethod).withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    _getPaymentMethodIcon(payment.paymentMethod),
                                                    style: const TextStyle(fontSize: 16),
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    _getPaymentMethodName(payment.paymentMethod),
                                                    style: TextStyle(
                                                      color: _getPaymentMethodColor(payment.paymentMethod),
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Paket: ${package.name}',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.grey[700],
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  DateFormatter.formatDate(payment.paymentDate),
                                                  style: TextStyle(
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Text(
                                              CurrencyFormatter.format(payment.amount),
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Theme.of(context).primaryColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (payment.note != null && payment.note!.isNotEmpty) ...[
                                          const SizedBox(height: 8),
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: Colors.grey[100],
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.note,
                                                  size: 16,
                                                  color: Colors.grey[600],
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    payment.note!,
                                                    style: TextStyle(
                                                      fontStyle: FontStyle.italic,
                                                      color: Colors.grey[600],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                        const SizedBox(height: 16),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            TextButton.icon(
                                              onPressed: () {
                                                Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                    builder: (_) => ReceiptScreen(
                                                      payment: payment,
                                                      subscription: subscription,
                                                      member: member,
                                                      package: package,
                                                    ),
                                                  ),
                                                );
                                              },
                                              icon: const Icon(Icons.receipt_outlined),
                                              label: const Text('Struk'),
                                              style: TextButton.styleFrom(
                                                foregroundColor: Colors.blue,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            TextButton.icon(
                                              onPressed: () async {
                                                final result = await Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                    builder: (_) => PaymentFormScreen(
                                                      payment: payment,
                                                    ),
                                                  ),
                                                );
                                                if (result == true) {
                                                  _loadData();
                                                }
                                              },
                                              icon: const Icon(Icons.edit_outlined),
                                              label: const Text('Edit'),
                                              style: TextButton.styleFrom(
                                                foregroundColor: Colors.orange,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            TextButton.icon(
                                              onPressed: () {
                                                showDialog(
                                                  context: context,
                                                  builder: (context) => AlertDialog(
                                                    title: const Text('Konfirmasi'),
                                                    content: const Text(
                                                        'Apakah Anda yakin ingin menghapus pembayaran ini?'),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () => Navigator.of(context).pop(),
                                                        child: const Text('Batal'),
                                                      ),
                                                      TextButton(
                                                        onPressed: () {
                                                          Navigator.of(context).pop();
                                                          _deletePayment(payment.id!);
                                                        },
                                                        child: const Text(
                                                          'Hapus',
                                                          style: TextStyle(color: Colors.red),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                              icon: const Icon(Icons.delete_outline),
                                              label: const Text('Hapus'),
                                              style: TextButton.styleFrom(
                                                foregroundColor: Colors.red,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                          childCount: _payments.length,
                        ),
                      ),
                    ],
                  ),
                ),
      floatingActionButton: widget.subscriptionId != null
          ? FloatingActionButton.extended(
              onPressed: () async {
                final result = await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => PaymentFormScreen(
                      subscriptionId: widget.subscriptionId,
                    ),
                  ),
                );
                if (result == true) {
                  _loadData();
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Tambah Pembayaran'),
            )
          : null,
    );
  }
}
