import 'package:flutter/material.dart';
import 'api_service.dart';
import 'court_list_screen.dart';
import 'add_court_screen.dart';

class ClubScreen extends StatefulWidget {
  const ClubScreen({super.key});

  @override
  _ClubScreenState createState() => _ClubScreenState();
}

class _ClubScreenState extends State<ClubScreen> {
  final TextEditingController _usuarioController = TextEditingController();
  bool _usuarioValido = false;
  Map<String, dynamic>? _club; // Almacena los datos del club
  String? _mensajeError;

  // Método para validar el usuario
  Future<void> validarUsuario() async {
    final apiService = ApiService();
    try {
      final club = await apiService.getClubByUser(_usuarioController.text);

      if (club != null) {
        setState(() {
          _usuarioValido = true;
          _club = club;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuario no encontrado')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al validar el usuario: $e')),
      );
    }
  }

  // Método para guardar los cambios en la base de datos
  Future<void> guardarCambios() async {
    final apiService = ApiService();
    try {
      // Cambia la conversión a int a booleano
      _club!['estacionamiento'] = _club!['estacionamiento'] == 1;  // Convertir de int a bool
      _club!['vestuarios'] = _club!['vestuarios'] == 1;  // Convertir de int a bool

      // Enviar la solicitud PUT al servidor
      await apiService.updateClubByUser(_usuarioController.text, _club!);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Datos actualizados correctamente')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar los datos: $e')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _usuarioController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _usuarioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Club')),
      body: _usuarioValido && _club != null
          ? SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Usuario: ${_usuarioController.text}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            TextFormField(
              initialValue: _club!['nombre'],
              decoration: const InputDecoration(labelText: 'Nombre del Club'),
              onChanged: (value) => _club!['nombre'] = value,
            ),
            // Otros campos del club...
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: guardarCambios,
              child: const Text('Guardar cambios'),
            ),
            const Divider(height: 40),

            // Botones adicionales para navegar a otras pantallas
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CourtListScreen(clubId: _club!['id']),
                  ),
                );
              },
              child: const Text('Ver lista de canchas'),
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
              child: const Text('Agregar canchas'),
            ),
          ],
        ),
      )
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usuarioController,
              decoration: const InputDecoration(labelText: 'Usuario'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _usuarioController.text.isEmpty ? null : validarUsuario,
              child: const Text('Validar Usuario'),
            ),
            if (_mensajeError != null)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  _mensajeError!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
