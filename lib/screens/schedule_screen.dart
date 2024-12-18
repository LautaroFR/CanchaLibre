import 'package:flutter/material.dart';
import '../services/database_service.dart';

class ScheduleScreen extends StatefulWidget {
  final String clubId;
  final bool isGuest; // Nueva variable para controlar si es invitado

  const ScheduleScreen({super.key, required this.clubId, this.isGuest = false});

  @override
  _ScheduleScreenState createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  final Map<String, Map<String, String>> _schedule = {};
  final List<String> _daysOrder = [
    'Lunes',
    'Martes',
    'Miércoles',
    'Jueves',
    'Viernes',
    'Sábado',
    'Domingo'
  ];
  final DatabaseService _databaseService = DatabaseService();
  bool _loading = true;

  String _formatTimeOfDay(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  TimeOfDay? _parseTimeString(String? time) {
    if (time == null || time.isEmpty) return null;
    try {
      final parts = time.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      return TimeOfDay(hour: hour, minute: minute);
    } catch (e) {
      print("Error al analizar la hora '$time': $e");
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadSchedule();
  }

  Future<void> _loadSchedule() async {
    try {
      final schedule = await _databaseService.getClubSchedule(widget.clubId);
      if (schedule != null) {
        setState(() {
          _schedule.clear();
          for (String day in _daysOrder) {
            if (schedule[day] != null) {
              _schedule[day] = {
                'open': schedule[day]['open'] ?? '08:00',
                'close': schedule[day]['close'] ?? '20:00',
              };
            } else {
              _schedule[day] = {'open': '08:00', 'close': '20:00'};
            }
          }
          _loading = false;
        });
      } else {
        _createDefaultSchedule();
        if (!widget.isGuest) _saveSchedule(); // Solo guarda si no es invitado
      }
    } catch (e) {
      print("Error al cargar los horarios: $e");
      setState(() => _loading = false);
    }
  }

  void _createDefaultSchedule() {
    setState(() {
      _schedule.clear();
      for (String day in _daysOrder) {
        _schedule[day] = {'open': '08:00', 'close': '20:00'};
      }
      _loading = false;
    });
  }

  Future<void> _saveSchedule() async {
    try {
      await _databaseService.updateClubSchedule(widget.clubId, _schedule);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Horarios actualizados correctamente')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar los horarios: $e')),
      );
    }
  }

  Future<TimeOfDay?> _selectTime(BuildContext context, TimeOfDay initialTime) async {
    return showTimePicker(context: context, initialTime: initialTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.isGuest ? 'Horarios' : 'Configurar Horarios'),
      ),      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.all(16.0),
        children: _daysOrder.map((day) {
          final daySchedule = _schedule[day] ?? {'open': '08:00', 'close': '20:00'};
          return Column(
            children: [
              Text(day,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Botones de edición condicionados
                  TextButton(
                    onPressed: widget.isGuest
                        ? null
                        : () async {
                      final openTime =
                      _parseTimeString(daySchedule['open']);
                      if (openTime != null) {
                        TimeOfDay? selectedTime =
                        await _selectTime(context, openTime);
                        if (selectedTime != null) {
                          setState(() {
                            _schedule[day]!['open'] =
                                _formatTimeOfDay(selectedTime);
                          });
                        }
                      }
                    },
                    child: Text('Apertura: ${daySchedule['open']}',
                        style: TextStyle(
                            color: widget.isGuest
                                ? Colors.black
                                : Colors.blue)),
                  ),
                  TextButton(
                    onPressed: widget.isGuest
                        ? null
                        : () async {
                      final closeTime =
                      _parseTimeString(daySchedule['close']);
                      if (closeTime != null) {
                        TimeOfDay? selectedTime =
                        await _selectTime(context, closeTime);
                        if (selectedTime != null) {
                          setState(() {
                            _schedule[day]!['close'] =
                                _formatTimeOfDay(selectedTime);
                          });
                        }
                      }
                    },
                    child: Text('Cierre: ${daySchedule['close']}',
                        style: TextStyle(
                            color: widget.isGuest
                                ? Colors.black
                                : Colors.blue)),
                  ),
                ],
              ),
              const Divider(),
            ],
          );
        }).toList(),
      ),
      // Botón guardar: solo visible si no es invitado
      floatingActionButton: widget.isGuest
          ? null
          : FloatingActionButton(
        onPressed: _saveSchedule,
        child: const Icon(Icons.save),
      ),
    );
  }
}
