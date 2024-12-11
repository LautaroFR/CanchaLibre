import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/database_service.dart';

class ScheduleScreen extends StatefulWidget {
  final String clubId;
  const ScheduleScreen({super.key, required this.clubId});

  @override
  _ScheduleScreenState createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  final Map<String, Map<String, TimeOfDay>> _schedule = {};
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

  // Helper para convertir cadena de texto a TimeOfDay
  TimeOfDay? _parseTimeString(String? time) {
    if (time == null || time.isEmpty) return null;
    try {
      final format = RegExp(r'(\d+):(\d+)\s*(AM|PM)', caseSensitive: false);
      final match = format.firstMatch(time);
      if (match != null) {
        int hour = int.parse(match.group(1)!);
        int minute = int.parse(match.group(2)!);
        String period = match.group(3)!.toUpperCase();

        if (period == "PM" && hour < 12) {
          hour += 12;
        } else if (period == "AM" && hour == 12) {
          hour = 0;
        }
        return TimeOfDay(hour: hour, minute: minute);
      }
      return null;
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
      // Obtén el horario desde Firebase
      final schedule = await _databaseService.getClubSchedule(widget.clubId);
      print("Datos obtenidos de Firebase: $schedule");

      if (schedule != null) {
        setState(() {
          _schedule.clear();

          // Mantén el orden de los días
          for (String day in _daysOrder) {
            if (schedule[day] != null) {
              print("Procesando $day: ${schedule[day]}");
              _schedule[day] = {
                'open': _parseTimeString(schedule[day]['open']) ?? const TimeOfDay(hour: 8, minute: 0),
                'close': _parseTimeString(schedule[day]['close']) ?? const TimeOfDay(hour: 20, minute: 0),
              };
            } else {
              print("$day no tiene datos en Firebase.");
              _schedule[day] = {
                'open': const TimeOfDay(hour: 8, minute: 0),
                'close': const TimeOfDay(hour: 20, minute: 0),
              };
            }
          }
          _loading = false;
        });
      } else {
        print("No se encontró el horario en Firebase.");
        setState(() {
          _loading = false;
        });
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

  Future<void> _saveSchedule() async {
    try {
      await _databaseService.updateClubSchedule(widget.clubId, _schedule, context);
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
            'open': const TimeOfDay(hour: 8, minute: 0),
            'close': const TimeOfDay(hour: 20, minute: 0),
          };

          return Column(
            children: [
              Text(day, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () async {
                      TimeOfDay? selectedTime = await _selectTime(context, daySchedule['open']!);
                      if (selectedTime != null) {
                        setState(() {
                          _schedule[day]!['open'] = selectedTime;
                        });
                      }
                    },
                    child: Text('Apertura: ${daySchedule['open']!.format(context)}'),
                  ),
                  TextButton(
                    onPressed: () async {
                      TimeOfDay? selectedTime = await _selectTime(context, daySchedule['close']!);
                      if (selectedTime != null) {
                        setState(() {
                          _schedule[day]!['close'] = selectedTime;
                        });
                      }
                    },
                    child: Text('Cierre: ${daySchedule['close']!.format(context)}'),
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
