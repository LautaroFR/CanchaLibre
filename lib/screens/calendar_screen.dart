import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/database_service.dart';

class CalendarScreen extends StatefulWidget {
  final String clubId;

  const CalendarScreen({super.key, required this.clubId});

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _selectedDate = DateTime.now();
  List<int> _courts = [];
  List<String> _times = [];
  TimeOfDay? _openingTime;
  TimeOfDay? _closingTime;
  final DatabaseService _databaseService = DatabaseService();
  bool _isLoading = true;

  final ScrollController _verticalScrollController = ScrollController();
  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _fixedColumnScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchDataFromDatabase();

    // Sincronizar el scroll vertical
    _verticalScrollController.addListener(() {
      if (_fixedColumnScrollController.hasClients) {
        _fixedColumnScrollController.jumpTo(_verticalScrollController.offset);
      }
    });
  }

  @override
  void dispose() {
    _verticalScrollController.dispose();
    _horizontalScrollController.dispose();
    _fixedColumnScrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchDataFromDatabase() async {
    try {
      final clubData = await _databaseService.getClubById(widget.clubId);
      if (clubData != null) {
        final schedule = clubData['schedule'] as Map<String, dynamic>;
        String dayOfWeek = DateFormat('EEEE', 'es_ES').format(_selectedDate);
        dayOfWeek = dayOfWeek[0].toUpperCase() + dayOfWeek.substring(1).toLowerCase();

        if (schedule != null && schedule.containsKey(dayOfWeek)) {
          final daySchedule = schedule[dayOfWeek];
          _openingTime = _parseTimeString(daySchedule['open']);
          _closingTime = _parseTimeString(daySchedule['close']);

          final courtsSnapshot = await _databaseService.getCourtsByClubId(widget.clubId);
          setState(() {
            _courts = courtsSnapshot.docs.map((doc) => doc['number'] as int).toList();
            _times = _generateTimes(_openingTime!, _closingTime!);
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  TimeOfDay _parseTimeString(String time) {
    final parts = time.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    return TimeOfDay(hour: hour, minute: minute);
  }

  List<String> _generateTimes(TimeOfDay startTime, TimeOfDay endTime) {
    List<String> times = [];
    DateTime now = DateTime.now();
    DateTime startDateTime = DateTime(now.year, now.month, now.day, startTime.hour, startTime.minute);
    DateTime endDateTime = DateTime(now.year, now.month, now.day, endTime.hour, endTime.minute);

    while (startDateTime.isBefore(endDateTime)) {
      times.add(DateFormat.Hm().format(startDateTime));
      startDateTime = startDateTime.add(const Duration(minutes: 30));
    }
    return times;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _isLoading = true;
        _fetchDataFromDatabase();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('EEEE dd \'de\' MMMM yyyy', 'es_ES').format(_selectedDate);
    formattedDate = formattedDate.split(' ').map((word) {
      if (word != 'de') {
        return word[0].toUpperCase() + word.substring(1);
      }
      return word;
    }).join(' ');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendario de Canchas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _selectDate(context),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                formattedDate,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Column(
                children: [
                  // Primera fila con "Horarios" fija y cabeceras sincronizadas con el scroll horizontal
                  Row(
                    children: [
                      Container(
                        width: 100,
                        height: 50,
                        color: Colors.grey[300],
                        alignment: Alignment.center,
                        child: const Text(
                          'Horarios',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      // Fila sincronizada al scroll horizontal
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          controller: _horizontalScrollController,
                          child: Row(
                            children: _courts.map((court) {
                              return Container(
                                width: 100,
                                height: 50,
                                color: Colors.grey[300],
                                alignment: Alignment.center,
                                child: Text(
                                  'Cancha $court',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Contenido desplazable
                  Expanded(
                    child: Row(
                      children: [
                        // Columna fija (horarios)
                        SingleChildScrollView(
                          controller: _fixedColumnScrollController,
                          scrollDirection: Axis.vertical,
                          child: Column(
                            children: _times.map((time) {
                              return Container(
                                width: 100,
                                height: 50,
                                color: Colors.grey[200],
                                alignment: Alignment.center,
                                child: Text(time),
                              );
                            }).toList(),
                          ),
                        ),
                        // Tabla desplazable
                        Expanded(
                          child: SingleChildScrollView(
                            controller: _verticalScrollController,
                            scrollDirection: Axis.vertical,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              controller: _horizontalScrollController,
                              child: Column(
                                children: _times.map((time) {
                                  return Row(
                                    children: _courts.map((court) {
                                      return Container(
                                        width: 100,
                                        height: 50,
                                        alignment: Alignment.center,
                                        child: GestureDetector(
                                          onTap: () {
                                            print('Clic en $time para Cancha $court');
                                          },
                                          child: const Text('Disponible'),
                                        ),
                                      );
                                    }).toList(),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
