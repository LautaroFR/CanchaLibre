import 'package:flutter/material.dart';
import '../services/database_service.dart';

class CalendarScreen extends StatefulWidget {
  final String clubId;

  const CalendarScreen({super.key, required this.clubId});

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final DatabaseService _databaseService = DatabaseService();
  DateTime _selectedDate = DateTime.now();
  Map<String, dynamic>? _clubSchedule;

  Future<void> _loadSchedule() async {
    final schedule = await _databaseService.getClubSchedule(widget.clubId);
    setState(() {
      _clubSchedule = schedule;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadSchedule();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendario de Reservas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () async {
              DateTime? selectedDate = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime(2100),
              );
              if (selectedDate != null) {
                setState(() {
                  _selectedDate = selectedDate;
                });
              }
            },
          ),
        ],
      ),
      body: _clubSchedule == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _clubSchedule!.keys.length,
              itemBuilder: (context, index) {
                String courtId = _clubSchedule!.keys.elementAt(index);
                return ListTile(
                  title: Text('Cancha $courtId'),
                  subtitle: Column(
                    children: _generateTimeSlots(courtId),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _generateTimeSlots(String courtId) {
    List<Widget> timeSlots = [];
    TimeOfDay openTime = TimeOfDay(
      hour: _clubSchedule![courtId]['open'].hour,
      minute: _clubSchedule![courtId]['open'].minute,
    );
    TimeOfDay closeTime = TimeOfDay(
      hour: _clubSchedule![courtId]['close'].hour,
      minute: _clubSchedule![courtId]['close'].minute,
    );

    while (openTime.hour < closeTime.hour || (openTime.hour == closeTime.hour && openTime.minute < closeTime.minute)) {
      timeSlots.add(
        ListTile(
          title: Text('${openTime.format(context)} - ${closeTime.format(context)}'),
          onTap: () {
            // Manejar la lógica de reserva aquí
          },
        ),
      );
      openTime = openTime.replacing(minute: openTime.minute + 30);
    }
    return timeSlots;
  }
}
