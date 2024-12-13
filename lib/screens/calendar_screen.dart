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

  @override
  void initState() {
    super.initState();
    _fetchDataFromDatabase();
  }

  Future<void> _fetchDataFromDatabase() async {
    try {
      final clubData = await _databaseService.getClubById(widget.clubId);
      print("Datos del club: $clubData");
      if (clubData != null) {
        final schedule = clubData['schedule'] as Map<String, dynamic>;
        String dayOfWeek = DateFormat('EEEE', 'es_ES').format(_selectedDate); // Obtener el día de la semana en español
        dayOfWeek = dayOfWeek[0].toUpperCase() + dayOfWeek.substring(1).toLowerCase(); // Asegurar la primera letra en mayúsculas
        print("Día de la semana: $dayOfWeek");

        if (schedule != null && schedule.containsKey(dayOfWeek)) {
          final daySchedule = schedule[dayOfWeek];
          _openingTime = _parseTimeString(daySchedule['open']);
          _closingTime = _parseTimeString(daySchedule['close']);
          print("Hora de apertura: $_openingTime");
          print("Hora de cierre: $_closingTime");

          final courtsSnapshot = await _databaseService.getCourtsByClubId(widget.clubId);
          setState(() {
            _courts = courtsSnapshot.docs.map((doc) => doc['number'] as int).toList();
            _times = _generateTimes(_openingTime!, _closingTime!);
            _isLoading = false;
            print("Datos del club cargados correctamente: $_courts, $_openingTime, $_closingTime");
          });
        } else {
          setState(() {
            _isLoading = false;
          });
          print("No se encontraron horarios del club para $dayOfWeek.");
        }
      } else {
        setState(() {
          _isLoading = false;
        });
        print("No se encontraron datos del club.");
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print("Error al cargar los datos del club: $e");
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
      startDateTime = startDateTime.add(Duration(minutes: 30)); // Incremento de 30 minutos
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
        _fetchDataFromDatabase(); // Volver a cargar los datos cuando se selecciona una nueva fecha
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('EEEE dd \'de\' MMMM yyyy', 'es_ES').format(_selectedDate);

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
            Text(
              '$formattedDate',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            Expanded(child: _buildScheduleTable()),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: [
          DataColumn(label: Text('Horario')), // Columna de horarios
          for (var court in _courts) DataColumn(label: Text('Cancha $court')), // Columnas para cada cancha
        ],
        rows: _times.map((time) {
          return DataRow(cells: [
            DataCell(Text(time)), // Fila para el horario
            for (var court in _courts) DataCell(
              Text('Disponible'),
              onTap: () {
                // Aquí puedes manejar la lógica al hacer clic en una celda
                print('Clic en $time para Cancha $court');
              },
            ), // Celdas para cada cancha
          ]);
        }).toList(),
      ),
    );
  }
}
