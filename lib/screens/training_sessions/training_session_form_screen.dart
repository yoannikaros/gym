import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:gym/models/member.dart';
import 'package:gym/models/trainer.dart';
import 'package:gym/models/training_session.dart';
import 'package:gym/repositories/member_repository.dart';
import 'package:gym/repositories/trainer_repository.dart';
import 'package:gym/repositories/training_session_repository.dart';

class TrainingSessionFormScreen extends StatefulWidget {
  final TrainingSession? session;
  final int? trainerId;
  final int? memberId;
  final DateTime? initialDate;

  const TrainingSessionFormScreen({
    super.key,
    this.session,
    this.trainerId,
    this.memberId,
    this.initialDate,
  });

  @override
  State<TrainingSessionFormScreen> createState() => _TrainingSessionFormScreenState();
}

class _TrainingSessionFormScreenState extends State<TrainingSessionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  
  int? _selectedTrainerId;
  int? _selectedMemberId;
  DateTime _sessionDate = DateTime.now();
  TimeOfDay _startTime = TimeOfDay.now();
  TimeOfDay? _endTime;
  
  final TrainingSessionRepository _sessionRepository = TrainingSessionRepository();
  final TrainerRepository _trainerRepository = TrainerRepository();
  final MemberRepository _memberRepository = MemberRepository();
  
  bool _isLoading = true;
  List<Trainer> _trainers = [];
  List<Member> _members = [];

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
      // Load trainers and members
      final trainers = await _trainerRepository.getAllTrainers();
      final members = await _memberRepository.getAllMembers();
      
      setState(() {
        _trainers = trainers;
        _members = members;
        
        // Set initial values if editing
        if (widget.session != null) {
          _selectedTrainerId = widget.session!.trainerId;
          _selectedMemberId = widget.session!.memberId;
          _sessionDate = DateTime.parse(widget.session!.sessionDate);
          
          // Parse start time
          final startTimeParts = widget.session!.startTime.split(':');
          _startTime = TimeOfDay(
            hour: int.parse(startTimeParts[0]),
            minute: int.parse(startTimeParts[1]),
          );
          
          // Parse end time if available
          if (widget.session!.endTime != null) {
            final endTimeParts = widget.session!.endTime!.split(':');
            _endTime = TimeOfDay(
              hour: int.parse(endTimeParts[0]),
              minute: int.parse(endTimeParts[1]),
            );
          }
          
          _notesController.text = widget.session!.notes ?? '';
        } 
        // Set initial values from parameters
        else {
          if (widget.trainerId != null) {
            _selectedTrainerId = widget.trainerId;
          }
          
          if (widget.memberId != null) {
            _selectedMemberId = widget.memberId;
          }
          
          if (widget.initialDate != null) {
            _sessionDate = widget.initialDate!;
          }
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

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _sessionDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    
    if (picked != null && picked != _sessionDate) {
      setState(() {
        _sessionDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime ? _startTime : (_endTime ?? TimeOfDay.now()),
    );
    
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  Future<void> _saveSession() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedTrainerId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pilih pelatih terlebih dahulu'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      
      if (_selectedMemberId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pilih anggota terlebih dahulu'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        // Format times
        final startTimeStr = '${_startTime.hour.toString().padLeft(2, '0')}:${_startTime.minute.toString().padLeft(2, '0')}:00';
        String? endTimeStr;
        
        if (_endTime != null) {
          endTimeStr = '${_endTime!.hour.toString().padLeft(2, '0')}:${_endTime!.minute.toString().padLeft(2, '0')}:00';
        }
        
        final session = TrainingSession(
          id: widget.session?.id,
          trainerId: _selectedTrainerId!,
          memberId: _selectedMemberId!,
          sessionDate: DateFormat('yyyy-MM-dd').format(_sessionDate),
          startTime: startTimeStr,
          endTime: endTimeStr,
          notes: _notesController.text.trim(),
        );

        if (widget.session == null) {
          await _sessionRepository.insertTrainingSession(session);
        } else {
          await _sessionRepository.updateTrainingSession(session);
        }

        setState(() {
          _isLoading = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sesi pelatihan berhasil disimpan'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(true);
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
        title: Text(widget.session == null ? 'Tambah Sesi Pelatihan' : 'Edit Sesi Pelatihan'),
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
                      value: _selectedTrainerId,
                      decoration: const InputDecoration(
                        labelText: 'Pelatih',
                        border: OutlineInputBorder(),
                      ),
                      items: _trainers.map((trainer) {
                        return DropdownMenuItem<int>(
                          value: trainer.id,
                          child: Text(trainer.name),
                        );
                      }).toList(),
                      onChanged: widget.trainerId != null ? null : (value) {
                        setState(() {
                          _selectedTrainerId = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Pilih pelatih';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
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
                      onChanged: widget.memberId != null ? null : (value) {
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
                    InkWell(
                      onTap: () => _selectDate(context),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Tanggal Sesi',
                          border: OutlineInputBorder(),
                        ),
                        child: Text(
                          DateFormat('dd/MM/yyyy').format(_sessionDate),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => _selectTime(context, true),
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Waktu Mulai',
                                border: OutlineInputBorder(),
                              ),
                              child: Text(
                                '${_startTime.hour.toString().padLeft(2, '0')}:${_startTime.minute.toString().padLeft(2, '0')}',
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: InkWell(
                            onTap: () => _selectTime(context, false),
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Waktu Selesai (Opsional)',
                                border: OutlineInputBorder(),
                              ),
                              child: Text(
                                _endTime == null
                                    ? 'Belum selesai'
                                    : '${_endTime!.hour.toString().padLeft(2, '0')}:${_endTime!.minute.toString().padLeft(2, '0')}',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _notesController,
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
                        onPressed: _saveSession,
                        child: Text(
                          widget.session == null ? 'Simpan' : 'Update',
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
