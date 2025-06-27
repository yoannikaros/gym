import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:gym/models/member.dart';
import 'package:gym/models/membership_package.dart';
import 'package:gym/models/subscription.dart';
import 'package:gym/repositories/member_repository.dart';
import 'package:gym/repositories/membership_package_repository.dart';
import 'package:gym/repositories/subscription_repository.dart';
import 'package:gym/screens/payments/payment_form_screen.dart';
import 'package:gym/screens/subscriptions/subscription_form_screen.dart';
import 'package:gym/utils/currency_formatter.dart';
import 'package:gym/utils/date_formatter.dart';

class SubscriptionListScreen extends StatefulWidget {
  const SubscriptionListScreen({super.key});

  @override
  State<SubscriptionListScreen> createState() => _SubscriptionListScreenState();
}

class _SubscriptionListScreenState extends State<SubscriptionListScreen> with SingleTickerProviderStateMixin {
  final SubscriptionRepository _subscriptionRepository = SubscriptionRepository();
  final MemberRepository _memberRepository = MemberRepository();
  final MembershipPackageRepository _packageRepository = MembershipPackageRepository();
  
  List<Subscription> _subscriptions = [];
  Map<int, Member> _members = {};
  Map<int, MembershipPackage> _packages = {};
  
  bool _isLoading = true;
  String _filter = 'all'; // all, active, inactive, expired
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
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
      // Load subscriptions based on filter
      List<Subscription> subscriptions;
      switch (_filter) {
        case 'active':
          subscriptions = await _subscriptionRepository.getActiveSubscriptions();
          break;
        case 'expired':
          subscriptions = await _subscriptionRepository.getExpiredSubscriptions();
          break;
        default:
          subscriptions = await _subscriptionRepository.getAllSubscriptions();
      }
      
      // Load all members and packages
      final members = await _memberRepository.getAllMembers();
      final packages = await _packageRepository.getAllPackages();
      
      // Create maps for quick lookup
      final memberMap = {for (var m in members) m.id!: m};
      final packageMap = {for (var p in packages) p.id!: p};
      
      setState(() {
        _subscriptions = subscriptions;
        _members = memberMap;
        _packages = packageMap;
        _isLoading = false;
      });
      _animationController.forward();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text('Error: ${e.toString()}')),
              ],
            ),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(12),
          ),
        );
      }
    }
  }

  Future<void> _deleteSubscription(int id) async {
    try {
      await _subscriptionRepository.deleteSubscription(id);
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle_outline, color: Colors.green.shade100),
                const SizedBox(width: 8),
                const Text('Langganan berhasil dihapus'),
              ],
            ),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(12),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text('Error: ${e.toString()}')),
              ],
            ),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(12),
          ),
        );
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'active':
        return Colors.green.shade600;
      case 'inactive':
        return Colors.orange.shade600;
      case 'expired':
        return Colors.red.shade600;
      default:
        return Colors.grey.shade600;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'active':
        return 'Aktif';
      case 'inactive':
        return 'Tidak Aktif';
      case 'expired':
        return 'Kadaluarsa';
      default:
        return 'Tidak Diketahui';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF4CAF50).withOpacity(0.1),
              Colors.white,
              Color(0xFF2E7D32).withOpacity(0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.green.shade600),
                  ),
                )
              : Column(
                  children: [
                    // Modern App Bar
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(24),
                          bottomRight: Radius.circular(24),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.arrow_back_ios),
                                onPressed: () => Navigator.pop(context),
                              ),
                              const Text(
                                'Daftar Langganan',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const Spacer(),
                              PopupMenuButton<String>(
                                icon: Icon(
                                  Icons.filter_list,
                                  color: Colors.green.shade600,
                                ),
                                onSelected: (value) {
                                  setState(() {
                                    _filter = value;
                                  });
                                  _loadData();
                                },
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    value: 'all',
                                    child: Row(
                                      children: [
                                        Icon(Icons.list, color: Colors.grey.shade600),
                                        const SizedBox(width: 8),
                                        const Text('Semua'),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 'active',
                                    child: Row(
                                      children: [
                                        Icon(Icons.check_circle_outline, color: Colors.green.shade600),
                                        const SizedBox(width: 8),
                                        const Text('Aktif'),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 'expired',
                                    child: Row(
                                      children: [
                                        Icon(Icons.timer_off_outlined, color: Colors.red.shade600),
                                        const SizedBox(width: 8),
                                        const Text('Kadaluarsa'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Content
                    Expanded(
                      child: _subscriptions.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.subscriptions_outlined,
                                    size: 64,
                                    color: Colors.grey.shade400,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Tidak ada data langganan',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton.icon(
                                    onPressed: () async {
                                      final result = await Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => const SubscriptionFormScreen(),
                                        ),
                                      );
                                      if (result == true) {
                                        _loadData();
                                      }
                                    },
                                    icon: const Icon(Icons.add),
                                    label: const Text('Tambah Langganan'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green.shade600,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: _loadData,
                              color: Colors.green.shade600,
                              child: FadeTransition(
                                opacity: _fadeAnimation,
                                child: ListView.builder(
                                  padding: const EdgeInsets.all(16),
                                  itemCount: _subscriptions.length,
                                  itemBuilder: (context, index) {
                                    final subscription = _subscriptions[index];
                                    final member = _members[subscription.memberId];
                                    final package = _packages[subscription.packageId];
                                    
                                    if (member == null || package == null) {
                                      return const SizedBox.shrink();
                                    }
                                    
                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 12),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.03),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Material(
                                        color: Colors.transparent,
                                        child: Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Container(
                                                    width: 50,
                                                    height: 50,
                                                    decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                        colors: [
                                                          Colors.green.shade400,
                                                          Colors.green.shade600,
                                                        ],
                                                        begin: Alignment.topLeft,
                                                        end: Alignment.bottomRight,
                                                      ),
                                                      borderRadius: BorderRadius.circular(12),
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                        member.name.substring(0, 1).toUpperCase(),
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 20,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 16),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          member.name,
                                                          style: const TextStyle(
                                                            fontSize: 18,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                        const SizedBox(height: 4),
                                                        Container(
                                                          padding: const EdgeInsets.symmetric(
                                                            horizontal: 8,
                                                            vertical: 4,
                                                          ),
                                                          decoration: BoxDecoration(
                                                            color: _getStatusColor(subscription.status).withOpacity(0.1),
                                                            borderRadius: BorderRadius.circular(6),
                                                          ),
                                                          child: Text(
                                                            _getStatusText(subscription.status),
                                                            style: TextStyle(
                                                              color: _getStatusColor(subscription.status),
                                                              fontSize: 12,
                                                              fontWeight: FontWeight.w500,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 16),
                                              Container(
                                                padding: const EdgeInsets.all(12),
                                                decoration: BoxDecoration(
                                                  color: Colors.grey.shade50,
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Icon(Icons.fitness_center, size: 16, color: Colors.grey.shade600),
                                                        const SizedBox(width: 8),
                                                        Text(
                                                          'Paket: ${package.name}',
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            color: Colors.grey.shade700,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Row(
                                                      children: [
                                                        Icon(Icons.payments_outlined, size: 16, color: Colors.grey.shade600),
                                                        const SizedBox(width: 8),
                                                        Text(
                                                          'Harga: ${CurrencyFormatter.format(package.price)}',
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            color: Colors.grey.shade700,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Row(
                                                      children: [
                                                        Icon(Icons.date_range, size: 16, color: Colors.grey.shade600),
                                                        const SizedBox(width: 8),
                                                        Expanded(
                                                          child: Text(
                                                            'Periode: ${DateFormatter.formatDate(subscription.startDate)} - ${DateFormatter.formatDate(subscription.endDate)}',
                                                            style: TextStyle(
                                                              fontSize: 14,
                                                              color: Colors.grey.shade700,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(height: 16),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.end,
                                                children: [
                                                  TextButton.icon(
                                                    onPressed: () {
                                                      Navigator.of(context).push(
                                                        MaterialPageRoute(
                                                          builder: (_) => PaymentFormScreen(
                                                            subscriptionId: subscription.id,
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                    icon: Icon(Icons.payment_outlined, color: Colors.green.shade600),
                                                    label: Text(
                                                      'Bayar',
                                                      style: TextStyle(color: Colors.green.shade600),
                                                    ),
                                                    style: TextButton.styleFrom(
                                                      backgroundColor: Colors.green.shade50,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(8),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  TextButton.icon(
                                                    onPressed: () async {
                                                      final result = await Navigator.of(context).push(
                                                        MaterialPageRoute(
                                                          builder: (_) => SubscriptionFormScreen(
                                                            subscription: subscription,
                                                          ),
                                                        ),
                                                      );
                                                      if (result == true) {
                                                        _loadData();
                                                      }
                                                    },
                                                    icon: Icon(Icons.edit_outlined, color: Colors.blue.shade600),
                                                    label: Text(
                                                      'Edit',
                                                      style: TextStyle(color: Colors.blue.shade600),
                                                    ),
                                                    style: TextButton.styleFrom(
                                                      backgroundColor: Colors.blue.shade50,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(8),
                                                      ),
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
                                                              'Apakah Anda yakin ingin menghapus langganan ini?'),
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.circular(16),
                                                          ),
                                                          actions: [
                                                            TextButton(
                                                              onPressed: () => Navigator.of(context).pop(),
                                                              child: Text(
                                                                'Batal',
                                                                style: TextStyle(color: Colors.grey.shade600),
                                                              ),
                                                            ),
                                                            TextButton(
                                                              onPressed: () {
                                                                Navigator.of(context).pop();
                                                                _deleteSubscription(subscription.id!);
                                                              },
                                                              child: Text(
                                                                'Hapus',
                                                                style: TextStyle(color: Colors.red.shade600),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    },
                                                    icon: Icon(Icons.delete_outline, color: Colors.red.shade600),
                                                    label: Text(
                                                      'Hapus',
                                                      style: TextStyle(color: Colors.red.shade600),
                                                    ),
                                                    style: TextButton.styleFrom(
                                                      backgroundColor: Colors.red.shade50,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(8),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const SubscriptionFormScreen(),
            ),
          );
          if (result == true) {
            _loadData();
          }
        },
        backgroundColor: Colors.green.shade600,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Langganan'),
      ),
    );
  }
}
