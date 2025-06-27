import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gym/models/setting.dart';
import 'package:gym/models/user.dart';
import 'package:gym/repositories/setting_repository.dart';
import 'package:gym/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:gym/screens/settings/gym_settings_screen.dart';
import 'package:gym/screens/settings/change_username_screen.dart';
import 'package:gym/screens/settings/change_password_screen.dart';
import 'package:gym/screens/settings/delete_account_screen.dart';
import 'package:gym/screens/settings/terms_of_service_screen.dart';
import 'package:gym/screens/settings/privacy_policy_screen.dart';
import 'package:gym/screens/settings/contact_us_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _gymNameController = TextEditingController();
  final _noteHeaderController = TextEditingController();
  final _noteFooterController = TextEditingController();
  
  final SettingRepository _settingRepository = SettingRepository();
  bool _isLoading = true;
  Setting? _setting;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadCurrentUser();
  }

  @override
  void dispose() {
    _gymNameController.dispose();
    _noteHeaderController.dispose();
    _noteFooterController.dispose();
    super.dispose();
  }

  void _loadCurrentUser() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    setState(() {
      _currentUser = authProvider.currentUser;
    });
  }

  Future<void> _loadSettings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final setting = await _settingRepository.getSettings();
      
      setState(() {
        _setting = setting;
        if (setting != null) {
          _gymNameController.text = setting.gymName ?? '';
          _noteHeaderController.text = setting.noteHeader ?? '';
          _noteFooterController.text = setting.noteFooter ?? '';
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

  Future<void> _handleLogout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.logout();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  Widget _buildSettingItem({
    required String title,
    required IconData icon,
    String? subtitle,
    VoidCallback? onTap,
    bool showDivider = true,
    bool isDestructive = false,
  }) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDestructive 
                    ? Colors.red.shade50 
                    : Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isDestructive 
                    ? Colors.red.shade400 
                    : Colors.blue.shade700,
                size: 22,
              ),
            ),
            title: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isDestructive 
                    ? Colors.red.shade700 
                    : Colors.grey.shade800,
              ),
            ),
            subtitle: subtitle != null
                ? Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  )
                : null,
            trailing: Icon(
              Icons.chevron_right,
              color: isDestructive 
                  ? Colors.red.shade300 
                  : Colors.blue.shade300,
            ),
            onTap: onTap,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 24, 32, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 1,
          color: Colors.blue.shade700,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Pengaturan',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Section
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.blue.shade700,
                          Colors.blue.shade500,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.shade100,
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.white,
                            child: Icon(
                              Icons.person,
                              size: 36,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _currentUser?.username ?? '',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  _currentUser?.role?.toUpperCase() ?? '',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Account Section
                  _buildSectionTitle('Akun'),
                  _buildSettingItem(
                    title: 'Ubah Username',
                    subtitle: _currentUser?.username,
                    icon: Icons.person_outline,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ChangeUsernameScreen(),
                        ),
                      );
                    },
                  ),
                  _buildSettingItem(
                    title: 'Ubah Password',
                    subtitle: '••••••••',
                    icon: Icons.lock_outline,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ChangePasswordScreen(),
                        ),
                      );
                    },
                  ),

                  // General Section
                  _buildSectionTitle('Umum'),
                  _buildSettingItem(
                    title: 'Pengaturan Gym',
                    subtitle: _setting?.gymName ?? 'Belum diatur',
                    icon: Icons.business,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const GymSettingsScreen(),
                        ),
                      );
                    },
                  ),

                  // Support Section
                  _buildSectionTitle('Bantuan'),
                  _buildSettingItem(
                    title: 'Syarat dan Ketentuan',
                    icon: Icons.description_outlined,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TermsOfServiceScreen(),
                        ),
                      );
                    },
                  ),
                  _buildSettingItem(
                    title: 'Kebijakan Privasi',
                    icon: Icons.privacy_tip_outlined,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PrivacyPolicyScreen(),
                        ),
                      );
                    },
                  ),
                  _buildSettingItem(
                    title: 'Hubungi Kami',
                    icon: Icons.headset_mic_outlined,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ContactUsScreen(),
                        ),
                      );
                    },
                  ),

                  // Danger Zone
                  _buildSectionTitle('Bahaya'),
                  _buildSettingItem(
                    title: 'Hapus Akun',
                    icon: Icons.delete_outline,
                    isDestructive: true,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DeleteAccountScreen(),
                        ),
                      );
                    },
                  ),
                  _buildSettingItem(
                    title: 'Keluar',
                    icon: Icons.logout,
                    isDestructive: true,
                    onTap: _handleLogout,
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }
}
