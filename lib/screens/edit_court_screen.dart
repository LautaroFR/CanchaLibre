import 'package:flutter/material.dart';
import 'api_service.dart';

class EditCourtScreen extends StatefulWidget {
  final Map<String, dynamic> cancha;

  EditCourtScreen({required this.cancha});

  @override
  _EditCourtScreenState createState() => _EditCourtScreenState();
}

class _EditCourtScreenState extends State<EditCourtScreen> {
  final _formKey = GlobalKey<FormState>();
  late Map<String, dynamic> _cancha;

  @override
  void initState() {
    super.initState();
    _cancha = Map<String, dynamic>.from(widget.cancha);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Editar Cancha')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _cancha['numero'].toString(),
                decoration: InputDecoration(labelText: 'Número de Cancha'),
                keyboardType: TextInputType.number,
                onSaved: (value) => _cancha['numero'] = int.tryParse(value!),
              ),
              TextFormField(
                initialValue: _cancha['tamano'].toString(),
                decoration: InputDecoration(labelText: 'Tamaño'),
                keyboardType: TextInputType.number,
                onSaved: (value) => _cancha['tamano'] = int.tryParse(value!),
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
                initialValue: _cancha['precio'].toString(),
                decoration: InputDecoration(labelText: 'Precio'),
                keyboardType: TextInputType.number,
                onSaved: (value) => _cancha['precio'] = int.tryParse(value!),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    final apiService = ApiService();
                    await apiService.updateCourt(_cancha['id'], _cancha);
                    Navigator.pop(context);
                  }
                },
                child: Text('Guardar Cambios'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
