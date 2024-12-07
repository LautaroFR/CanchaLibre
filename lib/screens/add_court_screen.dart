import 'package:flutter/material.dart';
import 'api_service.dart';

class AddCourtScreen extends StatefulWidget {
  final int clubId;

  AddCourtScreen({required this.clubId});

  @override
  _AddCourtScreenState createState() => _AddCourtScreenState();
}

class _AddCourtScreenState extends State<AddCourtScreen> {
  final _formKey = GlobalKey<FormState>();
  Map<String, dynamic> _cancha = {
    'numero': null,
    'tamano': null,
    'superficie': 'Sintetico',
    'luz': false,
    'techada': false,
    'precio': null,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Agregar Cancha')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Número de Cancha'),
                keyboardType: TextInputType.number,
                onSaved: (value) => _cancha['numero'] = int.tryParse(value!),
                validator: (value) => value!.isEmpty ? 'Campo obligatorio' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Tamaño: Futbol 5 - Futbol 7'),
                keyboardType: TextInputType.number,
                onSaved: (value) => _cancha['tamano'] = int.tryParse(value!),
                validator: (value) => value!.isEmpty ? 'Campo obligatorio' : null,
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Superficie'),
                value: _cancha['superficie'],
                items: ['Sintetico', 'Natural', 'Cemento', 'Parquet', 'Otro']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (value) => setState(() {
                  _cancha['superficie'] = value!;
                }),
              ),
              SwitchListTile(
                title: Text('Luz'),
                value: _cancha['luz'],
                onChanged: (value) => setState(() {
                  _cancha['luz'] = value;
                }),
              ),
              SwitchListTile(
                title: Text('Techada'),
                value: _cancha['techada'],
                onChanged: (value) => setState(() {
                  _cancha['techada'] = value;
                }),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Precio'),
                keyboardType: TextInputType.number,
                onSaved: (value) => _cancha['precio'] = int.tryParse(value!),
                validator: (value) => value!.isEmpty ? 'Campo obligatorio' : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    final apiService = ApiService();
                    // Aquí se agrega el clubId al mapa de cancha
                    await apiService.addCourt(widget.clubId, _cancha); // Ya no es necesario modificar nada en esta línea
                    Navigator.pop(context);
                  }
                },
                child: Text('Agregar Cancha'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
