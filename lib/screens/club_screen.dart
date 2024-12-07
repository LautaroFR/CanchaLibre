import 'package:flutter/material.dart';
import 'api_service.dart';

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
      final club = await apiService.getClubByUsuario(_usuarioController.text);

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
      await apiService.updateClubByUsuario(_usuarioController.text, _club!);
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
    // Agregar un listener al controlador para verificar cuando cambia el campo del usuario
    _usuarioController.addListener(() {
      setState(() {}); // Esto actualiza el estado cada vez que el campo cambia
    });
  }

  @override
  void dispose() {
    _usuarioController.dispose(); // Asegurarse de liberar el controlador al finalizar
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Club')),
      body: _usuarioValido && _club != null
          ? SingleChildScrollView( // Uso de SingleChildScrollView para evitar el desbordamiento
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Mostrar el nombre del usuario validado
            Text('Usuario: ${_usuarioController.text}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),

            // Campos para modificar los datos del club
            TextFormField(
              initialValue: _club!['nombre'],
              decoration: const InputDecoration(labelText: 'Nombre del Club'),
              onChanged: (value) => _club!['nombre'] = value,
            ),
            const SizedBox(height: 10),
            TextFormField(
              initialValue: _club!['direccion'],
              decoration: const InputDecoration(labelText: 'Dirección'),
              onChanged: (value) => _club!['direccion'] = value,
            ),
            const SizedBox(height: 10),
            TextFormField(
              initialValue: _club!['telefono'],
              decoration: const InputDecoration(labelText: 'Teléfono'),
              onChanged: (value) => _club!['telefono'] = value,
            ),
            const SizedBox(height: 10),
            TextFormField(
              initialValue: _club!['cantidad_canchas'].toString(),
              decoration: const InputDecoration(labelText: 'Cantidad de Canchas'),
              keyboardType: TextInputType.number,
              onChanged: (value) => _club!['cantidad_canchas'] = int.tryParse(value) ?? 0,
            ),
            const SizedBox(height: 10),
            SwitchListTile(
              title: const Text('Estacionamiento'),
              value: _club!['estacionamiento'] == 1,
              onChanged: (value) => setState(() => _club!['estacionamiento'] = value ? 1 : 0),
            ),
            SwitchListTile(
              title: const Text('Vestuarios'),
              value: _club!['vestuarios'] == 1,
              onChanged: (value) => setState(() => _club!['vestuarios'] = value ? 1 : 0),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: guardarCambios,
              child: const Text('Guardar cambios'),
            ),
            const Divider(height: 40),

            // Botones adicionales para navegar a otras pantallas
            ElevatedButton(
              onPressed: () {
                // Navegar a "Ver lista de canchas"
              },
              child: const Text('Ver lista de canchas'),
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
              onPressed: _usuarioController.text.isEmpty ? null : validarUsuario, // Deshabilitar si está vacío
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
