import 'package:flutter/material.dart';
import '../services/database_service.dart';

class AddCourtScreen extends StatefulWidget {
  final String clubId;

  const AddCourtScreen({required this.clubId});

  @override
  _AddCourtScreenState createState() => _AddCourtScreenState();
}

class _AddCourtScreenState extends State<AddCourtScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _court = {
    'number': null,
    'size': null,
    'surface': 'Synthetic',
    'light': false,
    'covered': false,
    'price': null,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Court')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Court Number'),
                keyboardType: TextInputType.number,
                onSaved: (value) => _court['number'] = int.tryParse(value!),
                validator: (value) => value!.isEmpty ? 'Required field' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Size'),
                keyboardType: TextInputType.number,
                onSaved: (value) => _court['size'] = int.tryParse(value!),
                validator: (value) => value!.isEmpty ? 'Required field' : null,
              ),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Surface'),
                value: _court['surface'],
                items: ['Synthetic', 'Natural', 'Concrete', 'Parquet', 'Other']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (value) => setState(() {
                  _court['surface'] = value!;
                }),
              ),
              SwitchListTile(
                title: const Text('Light'),
                value: _court['light'],
                onChanged: (value) => setState(() {
                  _court['light'] = value;
                }),
              ),
              SwitchListTile(
                title: const Text('Covered'),
                value: _court['covered'],
                onChanged: (value) => setState(() {
                  _court['covered'] = value;
                }),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                onSaved: (value) => _court['price'] = int.tryParse(value!),
                validator: (value) => value!.isEmpty ? 'Required field' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    final dbService = DatabaseService();
                    await dbService.addCourt(widget.clubId, _court);  // Agregar cancha al club específico
                    Navigator.pop(context);
                  }
                },
                child: const Text('Add Court'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
