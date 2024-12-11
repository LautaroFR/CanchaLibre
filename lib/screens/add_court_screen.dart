import 'package:flutter/material.dart';
import '../services/database_service.dart';

class AddCourtScreen extends StatefulWidget {
  final String clubId;
  final Map<String, dynamic>? court;

  const AddCourtScreen({required this.clubId, this.court});

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
  void initState() {
    super.initState();
    if (widget.court != null) {
      _court['number'] = widget.court!['number'];
      _court['size'] = widget.court!['size'];
      _court['surface'] = widget.court!['surface'];
      _court['light'] = widget.court!['light'];
      _court['covered'] = widget.court!['covered'];
      _court['price'] = widget.court!['price'];
    }
  }

  Future<void> saveCourt() async {
    final dbService = DatabaseService();
    if (widget.court == null) {
      // Add new court
      await dbService.addCourt(widget.clubId, _court);
    } else {
      // Update existing court
      await dbService.updateCourt(widget.court!['id'], widget.clubId, _court);
    }
    Navigator.pop(context, true); // Indicar que se hizo un cambio
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.court == null ? 'Add Court' : 'Edit Court')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _court['number']?.toString(),
                decoration: const InputDecoration(labelText: 'Court Number'),
                keyboardType: TextInputType.number,
                onSaved: (value) => _court['number'] = int.tryParse(value!),
                validator: (value) => value!.isEmpty ? 'Required field' : null,
              ),
              TextFormField(
                initialValue: _court['size']?.toString(),
                decoration: const InputDecoration(labelText: 'Size'),
                keyboardType: TextInputType.number,
                onSaved: (value) => _court['size'] = int.tryParse(value!),
                validator: (value) => value!.isEmpty ? 'Required field' : null,
              ),
              DropdownButtonFormField<String>(
                value: _court['surface'],
                decoration: const InputDecoration(labelText: 'Surface'),
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
                initialValue: _court['price']?.toString(),
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
                    await saveCourt();
                  }
                },
                child: Text(widget.court == null ? 'Add Court' : 'Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
