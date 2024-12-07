import 'package:flutter/material.dart';
import 'api_service.dart';  // Asegúrate de importar la clase ApiService

class ClubScreen extends StatefulWidget {
  const ClubScreen({super.key});

  @override
  _ClubScreenState createState() => _ClubScreenState();
}

class _ClubScreenState extends State<ClubScreen> {
  final TextEditingController _usuarioController = TextEditingController();
  bool _usuarioValido = false;
  String? _mensajeError;

  // Método para validar el usuario
  Future<void> validarUsuario() async {
    final apiService = ApiService();
    try {
      final club = await apiService.getClubByUsuario(_usuarioController.text);

      if (club != null) {
        setState(() {
          _usuarioValido = true;
          // Aquí podrías guardar la información del club si la necesitas
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Club')),
      body: _usuarioValido
          ? Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                // Navegar a "Ver lista de canchas"
              },
              child: const Text('Ver lista canchas'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Navegar a "Agregar canchas"
              },
              child: const Text('Agregar canchas'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Navegar a "Ver calendario"
              },
              child: const Text('Ver calendario'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Navegar a "Editar información Club"
              },
              child: const Text('Editar información Club'),
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
              decoration: const InputDecoration(
                labelText: 'Usuario',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: validarUsuario,
              child: const Text('Validar Usuario'),
            ),
            if (_mensajeError != null)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  _mensajeError!,
                  style: TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
