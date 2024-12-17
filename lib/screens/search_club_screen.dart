import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'calendar_screen.dart';
import 'schedule_screen.dart';

class SearchClubScreen extends StatefulWidget {
  const SearchClubScreen({super.key});

  @override
  _SearchClubScreenState createState() => _SearchClubScreenState();
}

class _SearchClubScreenState extends State<SearchClubScreen> {
  final TextEditingController _searchController = TextEditingController();
  Map<String, dynamic>? _selectedClub; // Información del club seleccionado
  List<Map<String, dynamic>> _clubSuggestions = []; // Lista de sugerencias

  /// Obtiene las sugerencias de clubes según el texto ingresado
  Future<void> _fetchClubSuggestions(String query) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final clubsCollection = firestore.collection('clubs');
      final querySnapshot = await clubsCollection
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: '$query\uf8ff')
          .get();

      setState(() {
        _clubSuggestions = querySnapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id; // Agregar el ID del documento
          return data;
        }).toList();
      });
    } catch (e) {
      print('Error al obtener sugerencias: $e');
    }
  }

  /// Obtiene los detalles del club seleccionado por su ID
  Future<void> _fetchClubData(String clubId) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final clubDoc = await firestore.collection('clubs').doc(clubId).get();

      if (clubDoc.exists) {
        setState(() {
          _selectedClub = clubDoc.data() as Map<String, dynamic>;
          _selectedClub!['id'] = clubDoc.id; // Agregar el ID del documento
          _clubSuggestions.clear(); // Limpiar sugerencias al seleccionar un club
        });
      }
    } catch (e) {
      print('Error al obtener los datos del club: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buscar Club')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Campo de búsqueda
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Buscar Club',
                suffixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                if (value.isNotEmpty) {
                  _fetchClubSuggestions(value);
                } else {
                  setState(() {
                    _clubSuggestions = [];
                  });
                }
              },
            ),
            const SizedBox(height: 20),

            // Lista de sugerencias o detalles del club
            Expanded(
              child: _clubSuggestions.isNotEmpty
                  ? ListView.builder(
                itemCount: _clubSuggestions.length,
                itemBuilder: (context, index) {
                  final club = _clubSuggestions[index];
                  return ListTile(
                    title: Text(
                      '${club['name']} - ${club['address'] ?? 'Sin dirección'}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    onTap: () {
                      _fetchClubData(club['id']);
                    },
                  );
                },
              )
                  : _selectedClub != null
                  ? _buildClubDetails()
                  : const Center(child: Text('Ingrese el nombre del club')),
            ),
          ],
        ),
      ),
    );
  }

  /// Widget para mostrar los detalles del club seleccionado
  Widget _buildClubDetails() {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Centrar verticalmente
          crossAxisAlignment: CrossAxisAlignment.center, // Centrar horizontalmente
          children: [
            // Nombre del club con ícono verificado al lado
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _selectedClub!['name'],
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                if (_selectedClub!['verified'] == true)
                  const Icon(Icons.check_circle, color: Colors.blue, size: 24),
              ],
            ),
            const SizedBox(height: 20),
            Text('Dirección: ${_selectedClub!['address']}',
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center),
            const SizedBox(height: 10),
            Text('Teléfono: ${_selectedClub!['phone']}',
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center),
            const SizedBox(height: 10),
            Text('${_selectedClub!['court_count']} Cancha/s',
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center),
            const SizedBox(height: 10),
            Text(
                '${_selectedClub!['parking'] ? "Estacionamiento" : ""}',
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center),
            const SizedBox(height: 10),
            Text(
                '${_selectedClub!['changing_rooms'] ? "Vestuarios" : ""}',
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ScheduleScreen(clubId: _selectedClub!['id'], isGuest: true,),
                  ),
                );
              },
              child: const Text('Ver horarios'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        CalendarScreen(clubId: _selectedClub!['id']),
                  ),
                );
              },
              child: const Text('Ver calendario'),
            ),
          ],
        ),
      ),
    );
  }
}
