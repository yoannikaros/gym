import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gym/providers/auth_provider.dart';
import 'package:gym/screens/auth/login_screen.dart';
import 'package:gym/screens/members/member_list_screen.dart';
import 'package:gym/screens/packages/package_list_screen.dart';
import 'package:gym/screens/trainers/trainer_list_screen.dart';
import 'package:gym/screens/attendance/attendance_screen.dart';
import 'package:gym/screens/finance/transaction_list_screen.dart';
import 'package:gym/screens/settings/settings_screen.dart';
import 'package:gym/screens/subscriptions/subscription_list_screen.dart';
import 'package:gym/screens/payments/payment_list_screen.dart';
import 'package:gym/screens/training_sessions/training_session_list_screen.dart';
import 'package:gym/screens/finance/savings_list_screen.dart';
import 'package:gym/screens/reports/financial_report_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;
    final isAdmin = user?.role == 'admin';

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Modern App bar with blur effect
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Halo, ${user?.username ?? "Pengguna"}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Selamat datang di Gym Manager',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    PopupMenuButton(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.green.shade100,
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          Icons.person,
                          color: Colors.green.shade700,
                          size: 24,
                        ),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          child: Row(
                            children: [
                              Icon(
                                Icons.settings,
                                color: Colors.grey.shade700,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Pengaturan',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          onTap: () {
                            Future.delayed(
                              const Duration(seconds: 0),
                                  () => Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const SettingsScreen()),
                              ),
                            );
                          },
                        ),
                        PopupMenuItem(
                          child: Row(
                            children: [
                              Icon(
                                Icons.logout,
                                color: Colors.grey.shade700,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Logout',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          onTap: () async {
                            await authProvider.logout();
                            if (context.mounted) {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(builder: (_) => const LoginScreen()),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Dashboard content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      
                      // Modern Stats cards with gradient
                      SizedBox(
                        height: 140,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            _buildStatCard(
                              context,
                              title: 'Anggota Aktif',
                              value: '120',
                              icon: Icons.people,
                              gradient: const LinearGradient(
                                colors: [Color(0xFF1E88E5), Color(0xFF42A5F5)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            _buildStatCard(
                              context,
                              title: 'Pendapatan Bulan Ini',
                              value: 'Rp 5.000.000',
                              icon: Icons.attach_money,
                              gradient: const LinearGradient(
                                colors: [Color(0xFF43A047), Color(0xFF66BB6A)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            _buildStatCard(
                              context,
                              title: 'Sesi Pelatihan',
                              value: '45',
                              icon: Icons.fitness_center,
                              gradient: const LinearGradient(
                                colors: [Color(0xFF8E24AA), Color(0xFFAB47BC)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Quick actions with modern design
                      const Text(
                        'Aksi Cepat',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildQuickAction(
                            context,
                            icon: Icons.person_add,
                            label: 'Tambah\nAnggota',
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const MemberListScreen()),
                              );
                            },
                          ),
                          _buildQuickAction(
                            context,
                            icon: Icons.payment,
                            label: 'Catat\nPembayaran',
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const PaymentListScreen()),
                              );
                            },
                          ),
                          _buildQuickAction(
                            context,
                            icon: Icons.calendar_today,
                            label: 'Absensi\nAnggota',
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const AttendanceScreen()),
                              );
                            },
                          ),
                          _buildQuickAction(
                            context,
                            icon: Icons.bar_chart,
                            label: 'Lihat\nLaporan',
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const FinancialReportScreen()),
                              );
                            },
                          ),
                        ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Menu section with modern cards
                      const Text(
                        'Menu Utama',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.4,
                        children: [
                          _buildMenuCard(
                            context,
                            'Anggota',
                            Icons.people,
                            const LinearGradient(
                              colors: [Color(0xFF1E88E5), Color(0xFF42A5F5)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                                () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const MemberListScreen()),
                              );
                            },
                          ),
                          _buildMenuCard(
                            context,
                            'Membership',
                            Icons.card_membership,
                            const LinearGradient(
                              colors: [Color(0xFFF57C00), Color(0xFFFFB74D)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                                () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const PackageListScreen()),
                              );
                            },
                          ),
                          _buildMenuCard(
                            context,
                            'Langganan',
                            Icons.subscriptions,
                            const LinearGradient(
                              colors: [Color(0xFF8E24AA), Color(0xFFAB47BC)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                                () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const SubscriptionListScreen()),
                              );
                            },
                          ),
                          _buildMenuCard(
                            context,
                            'Pembayaran',
                            Icons.payment,
                            const LinearGradient(
                              colors: [Color(0xFF43A047), Color(0xFF66BB6A)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                                () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const PaymentListScreen()),
                              );
                            },
                          ),
                          _buildMenuCard(
                            context,
                            'Pelatih',
                            Icons.sports,
                            const LinearGradient(
                              colors: [Color(0xFF3949AB), Color(0xFF5C6BC0)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                                () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const TrainerListScreen()),
                              );
                            },
                          ),
                          _buildMenuCard(
                            context,
                            'Sesi Pelatihan',
                            Icons.fitness_center,
                            const LinearGradient(
                              colors: [Color(0xFF6A1B9A), Color(0xFF8E24AA)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                                () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const TrainingSessionListScreen()),
                              );
                            },
                          ),
                          _buildMenuCard(
                            context,
                            'Absensi',
                            Icons.calendar_today,
                            const LinearGradient(
                              colors: [Color(0xFF00897B), Color(0xFF26A69A)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                                () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const AttendanceScreen()),
                              );
                            },
                          ),
                          if (isAdmin)
                            _buildMenuCard(
                              context,
                              'Keuangan',
                              Icons.attach_money,
                              const LinearGradient(
                                colors: [Color(0xFF2E7D32), Color(0xFF43A047)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                                  () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const TransactionListScreen()),
                                );
                              },
                            ),
                          if (isAdmin)
                            _buildMenuCard(
                              context,
                              'Tabungan',
                              Icons.savings,
                              const LinearGradient(
                                colors: [Color(0xFFFFA000), Color(0xFFFFCA28)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                                  () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const SavingsListScreen()),
                                );
                              },
                            ),
                          if (isAdmin)
                            _buildMenuCard(
                              context,
                              'Laporan',
                              Icons.bar_chart,
                              const LinearGradient(
                                colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                                  () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const FinancialReportScreen()),
                                );
                              },
                            ),
                          if (isAdmin)
                            _buildMenuCard(
                              context,
                              'Pengaturan',
                              Icons.settings,
                              const LinearGradient(
                                colors: [Color(0xFF757575), Color(0xFF9E9E9E)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                                  () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                                );
                              },
                            ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
      BuildContext context, {
        required String title,
        required String value,
        required IconData icon,
        required Gradient gradient,
      }) {
    return Container(
      width: 220,
      height: 150,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
            ),
            const Spacer(),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction(
      BuildContext context, {
        required IconData icon,
        required String label,
        required VoidCallback onTap,
      }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.green.shade100,
                width: 1,
                ),
            ),
            child: Icon(
              icon,
              color: Colors.green.shade700,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(
      BuildContext context,
      String title,
      IconData icon,
    Gradient gradient,
      VoidCallback onTap,
      ) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(24),
          ),
        child: Padding(
            padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                  padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 24,
                    color: Colors.white,
                ),
              ),
              const Spacer(),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                    color: Colors.white,
                ),
              ),
             // const SizedBox(height: 4),
            
            ],
            ),
          ),
        ),
      ),
    );
  }
}
