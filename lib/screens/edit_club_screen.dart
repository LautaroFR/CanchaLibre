import 'package:flutter/material.dart';

class EditClubScreen extends StatefulWidget {
  const EditClubScreen({super.key});

  @override
  _EditClubScreenState createState() => _EditClubScreenState();
}

class _EditClubScreenState extends State<EditClubScreen> {
  final _formKey = GlobalKey<FormState>();
  String nombre = '';
  String direccion = '';
  String telefono = '';
  int cantidadCanchas = 0;
  bool estacionamiento = false;
  bool vestuarios = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar información del Club')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Nombre'),
                onSaved: (value) => nombre = value ?? '',
              ),
              const SizedBox(height: 10),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Dirección'),
                onSaved: (value) => direccion = value ?? '',
              ),
              const SizedBox(height: 10),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Teléfono'),
                onSaved: (value) => telefono = value ?? '',
              ),
              const SizedBox(height: 10),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Cantidad de canchas'),
                keyboardType: TextInputType.number,
                onSaved: (value) => cantidadCanchas = int.parse(value ?? '0'),
              ),
              const SizedBox(height: 10),
              CheckboxListTile(
                title: const Text('Estacionamiento'),
                value: estacionamiento,
                onChanged: (value) => setState(() => estacionamiento = value ?? false),
              ),
              CheckboxListTile(
                title: const Text('Vestuarios'),
                value: vestuarios,
                onChanged: (value) => setState(() => vestuarios = value ?? false),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _formKey.currentState?.save();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Información guardada')),
                  );
                  Navigator.pop(context);
                },
                child: const Text('Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
