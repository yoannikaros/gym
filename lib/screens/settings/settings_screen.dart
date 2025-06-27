import 'package:flutter/material.dart';
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

  void _showDeleteAccountConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Akun'),
        content: const Text('Apakah Anda yakin ingin menghapus akun ini? Tindakan ini tidak dapat dibatalkan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              // Implement delete account functionality
              Navigator.pop(context);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required String title,
    required IconData icon,
    VoidCallback? onTap,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: Colors.black54),
          title: Text(title),
          trailing: const Icon(Icons.chevron_right),
          onTap: onTap,
        ),
        if (showDivider)
          const Divider(height: 1),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.red[400],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Profile',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.red[400],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.grey[300],
                              child: const Icon(Icons.person, size: 40, color: Colors.grey),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _currentUser?.username ?? '',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    _currentUser?.role ?? '',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Account Section
                  _buildSectionTitle('Account'),
                  _buildSettingItem(
                    title: 'Change Username',
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
                    title: 'Change Password',
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
                  _buildSettingItem(
                    title: 'Delete Account',
                    icon: Icons.delete_outline,
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
                    title: 'Logout',
                    icon: Icons.logout,
                    onTap: _handleLogout,
                    showDivider: false,
                  ),

                  // General Section
                  _buildSectionTitle('General'),
                  _buildSettingItem(
                    title: 'Pengaturan Gym',
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
                  _buildSettingItem(
                    title: 'Rate Us',
                    icon: Icons.star_border,
                    onTap: () {
                      // Implement rate us
                    },
                    showDivider: false,
                  ),

                  // Support Section
                  _buildSectionTitle('Support'),
                  _buildSettingItem(
                    title: 'Terms of Service',
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
                    title: 'Privacy Policy',
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
                    title: 'Contact Us',
                    icon: Icons.info_outline,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ContactUsScreen(),
                        ),
                      );
                    },
                    showDivider: false,
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }
}
