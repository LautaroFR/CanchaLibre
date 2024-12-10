import 'package:flutter/material.dart';
import '../services/database_service.dart';

class EditCourtScreen extends StatefulWidget {
  final String courtId;
  final String clubId;  // Añadido clubId
  final Map<String, dynamic> court;

  EditCourtScreen({required this.courtId, required this.clubId, required this.court});  // Añadido clubId

  @override
  _EditCourtScreenState createState() => _EditCourtScreenState();
}

class _EditCourtScreenState extends State<EditCourtScreen> {
  final _formKey = GlobalKey<FormState>();
  late Map<String, dynamic> _court;

  @override
  void initState() {
    super.initState();
    _court = Map<String, dynamic>.from(widget.court);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Court')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _court['number'].toString(),
                decoration: InputDecoration(labelText: 'Court Number'),
                keyboardType: TextInputType.number,
                onSaved: (value) => _court['number'] = int.tryParse(value!),
              ),
              TextFormField(
                initialValue: _court['size'].toString(),
                decoration: InputDecoration(labelText: 'Size'),
                keyboardType: TextInputType.number,
                onSaved: (value) => _court['size'] = int.tryParse(value!),
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Surface'),
                value: _court['surface'],
                items: ['Synthetic', 'Natural', 'Concrete', 'Parquet', 'Other']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (value) => setState(() {
                  _court['surface'] = value!;
                }),
              ),
              SwitchListTile(
                title: Text('Light'),
                value: _court['light'],
                onChanged: (value) => setState(() {
                  _court['light'] = value;
                }),
              ),
              SwitchListTile(
                title: Text('Covered'),
                value: _court['covered'],
                onChanged: (value) => setState(() {
                  _court['covered'] = value;
                }),
              ),
              TextFormField(
                initialValue: _court['price'].toString(),
                decoration: InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                onSaved: (value) => _court['price'] = int.tryParse(value!),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    final databaseService = DatabaseService();
                    await databaseService.updateCourt(widget.courtId, widget.clubId, _court);  // Añade clubId aquí
                    Navigator.pop(context);
                  }
                },
                child: Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
