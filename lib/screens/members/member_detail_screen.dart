import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:gym/models/member.dart';
import 'package:gym/repositories/member_repository.dart';
import 'package:gym/screens/members/member_form_screen.dart';

class MemberDetailScreen extends StatefulWidget {
  final int memberId;

  const MemberDetailScreen({super.key, required this.memberId});

  @override
  State<MemberDetailScreen> createState() => _MemberDetailScreenState();
}

class _MemberDetailScreenState extends State<MemberDetailScreen> {
  final MemberRepository _memberRepository = MemberRepository();
  Member? _member;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMember();
  }

  Future<void> _loadMember() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final member = await _memberRepository.getMemberById(widget.memberId);
      setState(() {
        _member = member;
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Anggota'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              if (_member != null) {
                final result = await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => MemberFormScreen(member: _member),
                  ),
                );
                if (result == true) {
                  _loadMember();
                }
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _member == null
              ? const Center(child: Text('Anggota tidak ditemukan'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.green,
                          child: Text(
                            _member!.name.substring(0, 1).toUpperCase(),
                            style: const TextStyle(
                              fontSize: 40,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: Text(
                          _member!.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Center(
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _member!.status == 'active'
                                ? Colors.green
                                : Colors.red,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _member!.status == 'active' ? 'Aktif' : 'Tidak Aktif',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Divider(),
                      _buildInfoItem(
                        'Jenis Kelamin',
                        _member!.gender ?? 'Tidak diisi',
                        Icons.person,
                      ),
                      _buildInfoItem(
                        'Tanggal Lahir',
                        _member!.birthDate != null
                            ? DateFormat('dd/MM/yyyy').format(
                                DateTime.parse(_member!.birthDate!))
                            : 'Tidak diisi',
                        Icons.cake,
                      ),
                      _buildInfoItem(
                        'Nomor Telepon',
                        _member!.phone ?? 'Tidak diisi',
                        Icons.phone,
                      ),
                      _buildInfoItem(
                        'Email',
                        _member!.email ?? 'Tidak diisi',
                        Icons.email,
                      ),
                      _buildInfoItem(
                        'Alamat',
                        _member!.address ?? 'Tidak diisi',
                        Icons.home,
                      ),
                      _buildInfoItem(
                        'Tanggal Bergabung',
                        _member!.joinDate != null
                            ? DateFormat('dd/MM/yyyy').format(
                                DateTime.parse(_member!.joinDate!))
                            : 'Tidak diisi',
                        Icons.calendar_today,
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.green),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
