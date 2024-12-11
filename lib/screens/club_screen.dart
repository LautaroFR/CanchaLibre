import 'package:flutter/material.dart';
import '../services/database_service.dart';
import 'court_list_screen.dart';
import 'add_court_screen.dart';

class ClubScreen extends StatefulWidget {
  final String email;

  const ClubScreen({super.key, required this.email});

  @override
  _ClubScreenState createState() => _ClubScreenState();
}

class _ClubScreenState extends State<ClubScreen> {
  Map<String, dynamic>? _club;
  String? _errorMessage;

  Future<void> fetchClubData() async {
    final databaseService = DatabaseService();
    try {
      final clubDoc = await databaseService.getClubByEmail(widget.email);

      if (clubDoc != null) {
        setState(() {
          _club = clubDoc.data() as Map<String, dynamic>;
          _club!['id'] = clubDoc.id;
        });
      } else {
        setState(() {
          _club = {
            'name': '',
            'address': '',
            'phone': '',
            'court_count': 0,
            'parking': false,
            'changing_rooms': false,
            'email': widget.email,
          };
          _club!['id'] = widget.email.split('@')[0];  // Crear el 'id' basado en el email
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching club data: $e';
      });
    }
  }

  Future<void> saveChanges() async {
    final databaseService = DatabaseService();
    try {
      _club!['name'] = (_club!['name'] ?? '').toString().trim();
      _club!['address'] = (_club!['address'] ?? '').toString().trim();
      _club!['phone'] = _club!['phone'].toString().trim();
      _club!['court_count'] = int.tryParse((_club!['court_count'] ?? '0').toString()) ?? 0;
      _club!['parking'] = _club!['parking'] ?? false;
      _club!['changing_rooms'] = _club!['changing_rooms'] ?? false;

      // Use addOrUpdateClub to handle both creation and update
      await databaseService.addOrUpdateClub(widget.email, _club!);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data updated successfully')),
      );
    } catch (e) {
      print('Error al guardar datos: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving data: $e')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchClubData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Portal del Club')),
      body: _club != null
          ? SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              initialValue: _club!['name'],
              decoration: const InputDecoration(labelText: 'Club'),
              onChanged: (value) => _club!['name'] = value,
            ),
            const SizedBox(height: 10),
            TextFormField(
              initialValue: _club!['address'],
              decoration: const InputDecoration(labelText: 'Dirección'),
              onChanged: (value) => _club!['address'] = value,
            ),
            const SizedBox(height: 10),
            TextFormField(
              initialValue: _club!['phone'].toString(),
              decoration: const InputDecoration(labelText: 'Teléfono'),
              keyboardType: TextInputType.phone,
              onChanged: (value) => _club!['phone'] = value,
            ),
            const SizedBox(height: 10),
            TextFormField(
              initialValue: _club!['court_count'].toString(),
              decoration: const InputDecoration(labelText: 'Cantidad de canchas'),
              keyboardType: TextInputType.number,
              onChanged: (value) => _club!['court_count'] = int.tryParse(value) ?? 0,
            ),
            const SizedBox(height: 10),
            SwitchListTile(
              title: const Text('Estacionamiento'),
              value: _club!['parking'],
              onChanged: (value) => setState(() => _club!['parking'] = value),
            ),
            SwitchListTile(
              title: const Text('Vestuarios'),
              value: _club!['changing_rooms'],
              onChanged: (value) => setState(() => _club!['changing_rooms'] = value),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: saveChanges,
              child: const Text('Guardar cambios'),
            ),
            const Divider(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CourtListScreen(clubId: _club!['id']),
                  ),
                );
              },
              child: const Text('Ver listado de canchas'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddCourtScreen(clubId: _club!['id']),
                  ),
                );
              },
              child: const Text('Agregar cancha'),
            ),
          ],
        ),
      )
          : _errorMessage != null
          ? Center(child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)))
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
