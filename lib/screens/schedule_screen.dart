import 'package:flutter/material.dart';
import '../services/database_service.dart';

class ScheduleScreen extends StatefulWidget {
  final String clubId;
  const ScheduleScreen({super.key, required this.clubId});

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

  // Helper para convertir TimeOfDay a cadena de texto en formato 24 horas
  String _formatTimeOfDay(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  // Helper para convertir cadena de texto en formato 24 horas a TimeOfDay
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
      print("Datos obtenidos de Firebase: $schedule");

      if (schedule != null) {
        setState(() {
          _schedule.clear();

          for (String day in _daysOrder) {
            if (schedule[day] != null) {
              print("Procesando $day: ${schedule[day]}");
              _schedule[day] = {
                'open': schedule[day]['open'] ?? '08:00',
                'close': schedule[day]['close'] ?? '20:00',
              };
            } else {
              print("$day no tiene datos en Firebase.");
              _schedule[day] = {
                'open': '08:00',
                'close': '20:00',
              };
            }
          }
          _loading = false;
        });
      } else {
        print("No se encontró el horario en Firebase. Creando horarios por defecto...");
        _createDefaultSchedule();
        _saveSchedule(); // Guardar los horarios por defecto en Firebase
      }
    } catch (e) {
      print("Error al cargar los horarios: $e");
      setState(() {
        _loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar los horarios: $e')),
      );
    }
  }

  void _createDefaultSchedule() {
    setState(() {
      _schedule.clear();

      for (String day in _daysOrder) {
        _schedule[day] = {
          'open': '08:00',
          'close': '20:00',
        };
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
    return showTimePicker(
      context: context,
      initialTime: initialTime,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configurar Horarios')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.all(16.0),
        children: _daysOrder.map((day) {
          final daySchedule = _schedule[day] ?? {
            'open': '08:00',
            'close': '20:00',
          };

          return Column(
            children: [
              Text(day, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () async {
                      final openTime = _parseTimeString(daySchedule['open']);
                      if (openTime != null) {
                        TimeOfDay? selectedTime = await _selectTime(context, openTime);
                        if (selectedTime != null) {
                          setState(() {
                            _schedule[day]!['open'] = _formatTimeOfDay(selectedTime);
                          });
                        }
                      }
                    },
                    child: Text('Apertura: ${daySchedule['open']}'),
                  ),
                  TextButton(
                    onPressed: () async {
                      final closeTime = _parseTimeString(daySchedule['close']);
                      if (closeTime != null) {
                        TimeOfDay? selectedTime = await _selectTime(context, closeTime);
                        if (selectedTime != null) {
                          setState(() {
                            _schedule[day]!['close'] = _formatTimeOfDay(selectedTime);
                          });
                        }
                      }
                    },
                    child: Text('Cierre: ${daySchedule['close']}'),
                  ),
                ],
              ),
              const Divider(),
            ],
          );
        }).toList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _saveSchedule,
        child: const Icon(Icons.save),
      ),
    );
  }
}
