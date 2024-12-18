import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/database_service.dart';

class CalendarScreen extends StatefulWidget {
  final String clubId;
  final bool isGuest; // Nuevo parámetro para indicar si es invitado

  const CalendarScreen({
    Key? key,
    required this.clubId,
    required this.isGuest,
  }) : super(key: key);

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
  Map<String, dynamic>? _clubData;

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
        _clubData = clubData;
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

  void _handleReservation(String time, int court) {
    if (widget.isGuest) {
      _showGuestReservationDialog(time, court);
    } else {
      _showUserReservationDialog(time, court);
    }
  }

  void _showGuestReservationDialog(String time, int court) {
    final DateFormat dateFormat = DateFormat('EEEE dd \'de\' MMMM yyyy', 'es_ES');
    String date = dateFormat.format(_selectedDate); List<String> dateParts = date.split(' ');
    dateParts[3] = dateParts[3][0].toUpperCase() + dateParts[3].substring(1);
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController nameController = TextEditingController();
        return AlertDialog(
          title: const Text("Reservar como invitado"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Día: $date\nHorario: $time\nCancha: $court"),
              const SizedBox(height: 20),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Tu nombre"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () {
                final name = nameController.text.trim();
                if (name.isNotEmpty) {
                  print("Hola, soy $name y deseo reservar la cancha $court el día $date a las $time.");
                  Navigator.pop(context);
                }
              },
              child: const Text("Enviar"),
            ),
          ],
        );
      },
    );
  }

  void _showUserReservationDialog(String time, int court) {
    final DateFormat dateFormat = DateFormat('EEEE dd \'de\' MMMM yyyy', 'es_ES');
    String date = dateFormat.format(_selectedDate); List<String> dateParts = date.split(' ');
    dateParts[3] = dateParts[3][0].toUpperCase() + dateParts[3].substring(1); // Capitaliza la primera letra del mes date = dateParts.join(' ');

    showDialog(
      context: context,
      builder: (context) {
        TextEditingController nameController = TextEditingController();
        TextEditingController depositController = TextEditingController();
        return AlertDialog(
          title: const Text("Reservar cancha"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Día: $date\nHorario: $time\nCancha: $court"),
              const SizedBox(height: 20),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Nombre"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: depositController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Seña a cuenta (opcional)"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () {
                final name = nameController.text.trim();
                final deposit = int.tryParse(depositController.text.trim()) ?? 0;
                if (name.isNotEmpty) {
                  print("Reserva confirmada para $date a las $time en la cancha $court. Nombre: $name. Seña: $deposit.");
                  Navigator.pop(context);
                }
              },
              child: const Text("Reservar"),
            ),
          ],
        );
      },
    );
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
                  Expanded(
                    child: Row(
                      children: [
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
                                      return GestureDetector(
                                        onTap: () => _handleReservation(time, court),
                                        child: Container(
                                          width: 100,
                                          height: 50,
                                          margin: const EdgeInsets.all(1),
                                          color: Colors.green[100],
                                          alignment: Alignment.center,
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
