import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/database_service.dart';
import 'court_list_screen.dart';
import 'add_court_screen.dart';
import '../widgets/address_autocomplete.dart';
import 'home_screen.dart'; // Importa la pantalla de inicio
import 'schedule_screen.dart'; // Importa la pantalla de horarios
import 'calendar_screen.dart'; // Importa la pantalla de calendario

class ClubScreen extends StatefulWidget {
  final String email;

  const ClubScreen({super.key, required this.email});

  @override
  _ClubScreenState createState() => _ClubScreenState();
}

class _ClubScreenState extends State<ClubScreen> {
  Map<String, dynamic>? _club;
  String? _errorMessage;
  final TextEditingController _addressController = TextEditingController();

  Future<void> fetchClubData() async {
    final databaseService = DatabaseService();
    try {
      final clubDoc = await databaseService.getClubByEmail(widget.email);

      if (clubDoc != null) {
        setState(() {
          _club = clubDoc.data() as Map<String, dynamic>;
          _club!['id'] = clubDoc.id;
          _addressController.text = _club!['address'] ?? ''; // Inicializar el campo de dirección
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
          _club!['id'] = widget.email.split('@')[0]; // Crear el 'id' basado en el email
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching club data: $e';
      });
    }
  }

  Future<void> saveChanges(String password) async {
    final databaseService = DatabaseService();
    final user = FirebaseAuth.instance.currentUser;

    try {
      // Re-autenticar al usuario
      final credential = EmailAuthProvider.credential(email: user!.email!, password: password);
      await user.reauthenticateWithCredential(credential);

      _club!['name'] = (_club!['name'] ?? '').toString().trim();
      _club!['address'] = _addressController.text.trim(); // Obtener el valor del controlador
      _club!['phone'] = _club!['phone'].toString().trim();
      _club!['court_count'] = int.tryParse((_club!['court_count'] ?? '0').toString()) ?? 0;
      _club!['parking'] = _club!['parking'] ?? false;
      _club!['changing_rooms'] = _club!['changing_rooms'] ?? false;

      // Use addOrUpdateClub to handle both creation and update
      await databaseService.addOrUpdateClub(widget.email, _club!);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Información actualizada satisfactoriamente')),
      );
    } catch (e) {
      print('Error al guardar datos: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar datos: $e')),
      );
    }
  }

  Future<void> _showPasswordDialog() async {
    final TextEditingController passwordController = TextEditingController();
    String? errorMessage;

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // El usuario debe ingresar la contraseña
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Confirmar Contraseña'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    const Text('Por favor ingrese su contraseña para confirmar la edición de cambios.'),
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: 'Contraseña'),
                    ),
                    if (errorMessage != null)
                      Text(
                        errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancelar'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('Confirmar'),
                  onPressed: () async {
                    final password = passwordController.text;
                    final user = FirebaseAuth.instance.currentUser;

                    try {
                      final credential = EmailAuthProvider.credential(email: user!.email!, password: password);
                      await user.reauthenticateWithCredential(credential);
                      Navigator.of(context).pop(); // Cerrar el cuadro de diálogo si la re-autenticación es exitosa
                      saveChanges(password); // Guardar los cambios
                    } catch (e) {
                      setState(() {
                        errorMessage = 'Contraseña incorrecta';
                      });
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('keepLoggedIn', false); // Actualizar el estado de mantener sesión iniciada
    await FirebaseAuth.instance.signOut(); // Cerrar sesión en Firebase

    // Redirigir a HomeScreen
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
          (Route<dynamic> route) => false,
    );
  }

  @override
  void initState() {
    super.initState();
    fetchClubData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Portal del Club'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
                  (Route<dynamic> route) => false,
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: _club != null
          ? SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: _club!['name'],
                    decoration: const InputDecoration(labelText: 'Club'),
                    onChanged: (value) => _club!['name'] = value,
                  ),
                ),
                if (_club!['verified'] == true)
                  const Icon(
                    Icons.check_circle,
                    color: Colors.blue,
                  ),
              ],
            ),
            const SizedBox(height: 10),
            AddressAutocomplete(
              controller: _addressController, // Pasa el controlador al widget
              onSelected: (value) {
                setState(() {
                  _addressController.text = value; // Actualizar el controlador con la dirección seleccionada
                  _club!['address'] = value;
                });
              },
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
              onPressed: _showPasswordDialog,
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
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ScheduleScreen(clubId: _club!['id']),
                  ),
                );
              },
              child: const Text('Configurar horarios'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CalendarScreen(clubId: _club!['id']),
                  ),
                );
              },
              child: const Text('Ver calendario'),
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
