import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:gym/models/member.dart';
import 'package:gym/models/trainer.dart';
import 'package:gym/models/training_session.dart';
import 'package:gym/repositories/member_repository.dart';
import 'package:gym/repositories/trainer_repository.dart';
import 'package:gym/repositories/training_session_repository.dart';
import 'package:gym/screens/training_sessions/training_session_form_screen.dart';
import 'package:gym/utils/date_formatter.dart';

class TrainingSessionListScreen extends StatefulWidget {
  final int? trainerId;
  final int? memberId;

  const TrainingSessionListScreen({
    super.key,
    this.trainerId,
    this.memberId,
  });

  @override
  State<TrainingSessionListScreen> createState() => _TrainingSessionListScreenState();
}

class _TrainingSessionListScreenState extends State<TrainingSessionListScreen> with SingleTickerProviderStateMixin {
  final TrainingSessionRepository _sessionRepository = TrainingSessionRepository();
  final TrainerRepository _trainerRepository = TrainerRepository();
  final MemberRepository _memberRepository = MemberRepository();
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  List<TrainingSession> _sessions = [];
  Map<int, Trainer> _trainers = {};
  Map<int, Member> _members = {};
  
  bool _isLoading = true;
  DateTime _selectedDate = DateTime.now();

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
      List<TrainingSession> sessions;
      
      // Filter sessions based on parameters
      if (widget.trainerId != null) {
        sessions = await _sessionRepository.getTrainingSessionsByTrainerId(widget.trainerId!);
      } else if (widget.memberId != null) {
        sessions = await _sessionRepository.getTrainingSessionsByMemberId(widget.memberId!);
      } else {
        // Filter by selected date
        final formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);
        sessions = await _sessionRepository.getTrainingSessionsByDate(formattedDate);
      }
      
      // Get all related trainers and members
      final trainerIds = sessions.map((s) => s.trainerId).toSet().toList();
      final memberIds = sessions.map((s) => s.memberId).toSet().toList();
      
      final trainerMap = <int, Trainer>{};
      final memberMap = <int, Member>{};
      
      for (var id in trainerIds) {
        final trainer = await _trainerRepository.getTrainerById(id);
        if (trainer != null) {
          trainerMap[id] = trainer;
        }
      }
      
      for (var id in memberIds) {
        final member = await _memberRepository.getMemberById(id);
        if (member != null) {
          memberMap[id] = member;
        }
      }
      
      setState(() {
        _sessions = sessions;
        _trainers = trainerMap;
        _members = memberMap;
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

  Future<void> _deleteSession(int id) async {
    try {
      await _sessionRepository.deleteTrainingSession(id);
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sesi pelatihan berhasil dihapus'),
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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _loadData();
    }
  }

  Color _getStatusColor(TrainingSession session) {
    if (session.endTime != null) {
      return Colors.green;
    }
    
    final sessionDateTime = DateTime.parse('${session.sessionDate} ${session.startTime}');
    final now = DateTime.now();
    
    if (sessionDateTime.isAfter(now)) {
      return Colors.blue; // Upcoming
    } else {
      return Colors.orange; // In Progress
    }
  }

  String _getStatusText(TrainingSession session) {
    if (session.endTime != null) {
      return 'Selesai';
    }
    
    final sessionDateTime = DateTime.parse('${session.sessionDate} ${session.startTime}');
    final now = DateTime.now();
    
    if (sessionDateTime.isAfter(now)) {
      return 'Akan Datang';
    } else {
      return 'Berlangsung';
    }
  }

  IconData _getStatusIcon(TrainingSession session) {
    if (session.endTime != null) {
      return Icons.check_circle_outline;
    }
    
    final sessionDateTime = DateTime.parse('${session.sessionDate} ${session.startTime}');
    final now = DateTime.now();
    
    if (sessionDateTime.isAfter(now)) {
      return Icons.schedule;
    } else {
      return Icons.fitness_center;
    }
  }

  @override
  Widget build(BuildContext context) {
    String title = 'Sesi Pelatihan';
    if (widget.trainerId != null && _trainers.containsKey(widget.trainerId)) {
      title = 'Sesi Pelatih: ${_trainers[widget.trainerId!]!.name}';
    } else if (widget.memberId != null && _members.containsKey(widget.memberId)) {
      title = 'Sesi Anggota: ${_members[widget.memberId!]!.name}';
    }

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
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        elevation: 0,
        actions: [
          if (widget.trainerId == null && widget.memberId == null)
            IconButton(
              icon: const Icon(
                Icons.calendar_today,
                color: Colors.white,
              ),
              onPressed: () => _selectDate(context),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                if (widget.trainerId == null && widget.memberId == null)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          DateFormat('dd MMMM yyyy').format(_selectedDate),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: _sessions.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.fitness_center,
                                size: 80,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Tidak ada sesi pelatihan',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: () async {
                                  final result = await Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => TrainingSessionFormScreen(
                                        trainerId: widget.trainerId,
                                        memberId: widget.memberId,
                                        initialDate: _selectedDate,
                                      ),
                                    ),
                                  );
                                  if (result == true) {
                                    _loadData();
                                  }
                                },
                                icon: const Icon(Icons.add),
                                label: const Text('Tambah Sesi Pelatihan'),
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
                          child: ListView.builder(
                            padding: const EdgeInsets.only(top: 8, bottom: 80),
                            itemCount: _sessions.length,
                            itemBuilder: (context, index) {
                              final session = _sessions[index];
                              final trainer = _trainers[session.trainerId];
                              final member = _members[session.memberId];
                              
                              if (trainer == null || member == null) {
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
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      DateFormatter.formatDate(session.sessionDate),
                                                      style: const TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 18,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      'Waktu: ${DateFormatter.formatTime(session.startTime)} - ${session.endTime != null ? DateFormatter.formatTime(session.endTime) : 'Belum selesai'}',
                                                      style: TextStyle(
                                                        color: Colors.grey[600],
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                  vertical: 6,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: _getStatusColor(session).withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(20),
                                                  border: Border.all(
                                                    color: _getStatusColor(session).withOpacity(0.5),
                                                  ),
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      _getStatusIcon(session),
                                                      size: 16,
                                                      color: _getStatusColor(session),
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      _getStatusText(session),
                                                      style: TextStyle(
                                                        color: _getStatusColor(session),
                                                        fontWeight: FontWeight.w500,
                                                        fontSize: 12,
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
                                              color: Colors.grey[50],
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                if (widget.trainerId == null)
                                                  Row(
                                                    children: [
                                                      Icon(
                                                        Icons.person,
                                                        size: 16,
                                                        color: Colors.grey[600],
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Text(
                                                        'Pelatih: ${trainer.name}',
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          color: Colors.grey[800],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                if (widget.trainerId == null && widget.memberId == null)
                                                  const SizedBox(height: 8),
                                                if (widget.memberId == null)
                                                  Row(
                                                    children: [
                                                      Icon(
                                                        Icons.fitness_center,
                                                        size: 16,
                                                        color: Colors.grey[600],
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Text(
                                                        'Anggota: ${member.name}',
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          color: Colors.grey[800],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                              ],
                                            ),
                                          ),
                                          if (session.notes != null && session.notes!.isNotEmpty) ...[
                                            const SizedBox(height: 12),
                                            Container(
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: Colors.blue[50],
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.note,
                                                    size: 16,
                                                    color: Colors.blue[700],
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: Text(
                                                      session.notes!,
                                                      style: TextStyle(
                                                        fontStyle: FontStyle.italic,
                                                        color: Colors.blue[700],
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
                                              if (session.endTime == null)
                                                TextButton.icon(
                                                  onPressed: () async {
                                                    final now = DateTime.now();
                                                    final endTime = DateFormat('HH:mm:ss').format(now);
                                                    
                                                    final updatedSession = TrainingSession(
                                                      id: session.id,
                                                      trainerId: session.trainerId,
                                                      memberId: session.memberId,
                                                      sessionDate: session.sessionDate,
                                                      startTime: session.startTime,
                                                      endTime: endTime,
                                                      notes: session.notes,
                                                    );
                                                    
                                                    await _sessionRepository.updateTrainingSession(updatedSession);
                                                    _loadData();
                                                  },
                                                  icon: const Icon(Icons.check_circle_outline),
                                                  label: const Text('Selesai'),
                                                  style: TextButton.styleFrom(
                                                    foregroundColor: Colors.green,
                                                  ),
                                                ),
                                              const SizedBox(width: 8),
                                              TextButton.icon(
                                                onPressed: () async {
                                                  final result = await Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                      builder: (_) => TrainingSessionFormScreen(
                                                        session: session,
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
                                                          'Apakah Anda yakin ingin menghapus sesi pelatihan ini?'),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () => Navigator.of(context).pop(),
                                                          child: const Text('Batal'),
                                                        ),
                                                        TextButton(
                                                          onPressed: () {
                                                            Navigator.of(context).pop();
                                                            _deleteSession(session.id!);
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
                          ),
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => TrainingSessionFormScreen(
                trainerId: widget.trainerId,
                memberId: widget.memberId,
                initialDate: _selectedDate,
              ),
            ),
          );
          if (result == true) {
            _loadData();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Tambah Sesi'),
      ),
    );
  }
}
