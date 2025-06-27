import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:gym/models/attendance.dart';
import 'package:gym/models/member.dart';
import 'package:gym/repositories/member_repository.dart';
import 'package:gym/repositories/attendance_repository.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> with SingleTickerProviderStateMixin {
  final MemberRepository _memberRepository = MemberRepository();
  final AttendanceRepository _attendanceRepository = AttendanceRepository();
  
  List<Member> _members = [];
  List<Member> _filteredMembers = [];
  List<Attendance> _todayAttendance = [];
  
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
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
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final members = await _memberRepository.getAllMembers();
      final formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);
      final attendance = await _attendanceRepository.getAttendanceByDate(formattedDate);
      
      setState(() {
        _members = members;
        _filteredMembers = members;
        _todayAttendance = attendance;
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

  void _filterMembers(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredMembers = _members;
      });
    } else {
      setState(() {
        _filteredMembers = _members
            .where((member) =>
                member.name.toLowerCase().contains(query.toLowerCase()) ||
                (member.phone != null &&
                    member.phone!.toLowerCase().contains(query.toLowerCase())))
            .toList();
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.green.shade600,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _loadData();
    }
  }

  Future<void> _recordAttendance(Member member) async {
    try {
      final now = DateTime.now();
      final formattedDateTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
      
      final existingAttendance = _todayAttendance
          .where((a) => a.memberId == member.id)
          .toList();
      
      if (existingAttendance.isEmpty) {
        final attendance = Attendance(
          memberId: member.id!,
          checkIn: formattedDateTime,
        );
        
        await _attendanceRepository.insertAttendance(attendance);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle_outline, color: Colors.green.shade100),
                  const SizedBox(width: 8),
                  Text('${member.name} berhasil check in'),
                ],
              ),
              backgroundColor: Colors.green.shade600,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.all(12),
            ),
          );
        }
      } else {
        final attendance = existingAttendance.first;
        final updatedAttendance = Attendance(
          id: attendance.id,
          memberId: attendance.memberId,
          checkIn: attendance.checkIn,
          checkOut: formattedDateTime,
        );
        
        await _attendanceRepository.updateAttendance(updatedAttendance);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle_outline, color: Colors.orange.shade100),
                  const SizedBox(width: 8),
                  Text('${member.name} berhasil check out'),
                ],
              ),
              backgroundColor: Colors.orange.shade600,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.all(12),
            ),
          );
        }
      }
      
      _loadData();
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
                                'Absensi Anggota',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const Spacer(),
                              IconButton(
                                icon: Icon(
                                  Icons.calendar_today,
                                  color: Colors.green.shade600,
                                ),
                                onPressed: () => _selectDate(context),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.event,
                                  color: Colors.green.shade600,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  DateFormat('dd MMMM yyyy').format(_selectedDate),
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.green.shade700,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Cari Anggota...',
                              hintStyle: TextStyle(color: Colors.grey.shade600),
                              prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
                              filled: true,
                              fillColor: Colors.grey.shade100,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                        ),
                        onChanged: _filterMembers,
                      ),
                    ],
                  ),
                ),
                    
                    // Content
                Expanded(
                  child: _filteredMembers.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.people_outline,
                                    size: 64,
                                    color: Colors.grey.shade400,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Tidak ada anggota',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : FadeTransition(
                              opacity: _fadeAnimation,
                              child: ListView.builder(
                                padding: const EdgeInsets.all(16),
                          itemCount: _filteredMembers.length,
                          itemBuilder: (context, index) {
                            final member = _filteredMembers[index];
                            final attendance = _todayAttendance
                                .where((a) => a.memberId == member.id)
                                .toList();
                            
                            final hasCheckedIn = attendance.isNotEmpty;
                            final hasCheckedOut = hasCheckedIn && 
                                attendance.first.checkOut != null;
                            
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
                                        child: Row(
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
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    member.phone ?? 'Tidak ada nomor telepon',
                                                    style: TextStyle(
                                                      color: Colors.grey.shade600,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                  if (hasCheckedIn) ...[
                                                    const SizedBox(height: 8),
                                                    Row(
                                                      children: [
                                                        Icon(
                                                          Icons.access_time,
                                                          size: 16,
                                                          color: Colors.green.shade600,
                                                        ),
                                                        const SizedBox(width: 4),
                                                        Text(
                                                          'Check in: ${DateFormat('HH:mm').format(DateTime.parse(attendance.first.checkIn))}',
                                                          style: TextStyle(
                                                            color: Colors.green.shade600,
                                                            fontSize: 12,
                                                          ),
                                                        ),
                                                        if (hasCheckedOut) ...[
                                                          const SizedBox(width: 12),
                                                          Icon(
                                                            Icons.logout,
                                                            size: 16,
                                                            color: Colors.orange.shade600,
                                                          ),
                                                          const SizedBox(width: 4),
                                                          Text(
                                                            'Check out: ${DateFormat('HH:mm').format(DateTime.parse(attendance.first.checkOut!))}',
                                                            style: TextStyle(
                                                              color: Colors.orange.shade600,
                                                              fontSize: 12,
                                                            ),
                                                          ),
                                                        ],
                                                      ],
                                                    ),
                                                  ],
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            ElevatedButton(
                                              onPressed: hasCheckedOut ? null : () => _recordAttendance(member),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: hasCheckedIn
                                        ? hasCheckedOut
                                                        ? Colors.grey.shade300
                                                        : Colors.orange.shade600
                                                    : Colors.green.shade600,
                                                foregroundColor: Colors.white,
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 16,
                                                  vertical: 12,
                                                ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                elevation: hasCheckedOut ? 0 : 2,
                                  ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    hasCheckedIn
                                                        ? hasCheckedOut
                                                            ? Icons.check_circle
                                                            : Icons.logout
                                                        : Icons.login,
                                                    size: 18,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                    hasCheckedIn
                                        ? hasCheckedOut
                                            ? 'Selesai'
                                            : 'Check Out'
                                        : 'Check In',
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
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
              ],
                ),
        ),
            ),
    );
  }
}
