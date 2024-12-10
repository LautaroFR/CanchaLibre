import 'package:flutter/material.dart';
import '../services/database_service.dart';

class EditClubScreen extends StatefulWidget {
  const EditClubScreen({super.key});

  @override
  _EditClubScreenState createState() => _EditClubScreenState();
}

class _EditClubScreenState extends State<EditClubScreen> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String address = '';
  String phone = '';
  int courtCount = 0;
  bool parking = false;
  bool changingRooms = false;

  Future<void> saveClub() async {
    final databaseService = DatabaseService();
    final club = {
      'name': name,
      'address': address,
      'phone': phone,
      'court_count': courtCount,
      'parking': parking,
      'changing_rooms': changingRooms,
    };
    await databaseService.addClub(club);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Information saved')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Club Information')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Name'),
                onSaved: (value) => name = value ?? '',
              ),
              const SizedBox(height: 10),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Address'),
                onSaved: (value) => address = value ?? '',
              ),
              const SizedBox(height: 10),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Phone'),
                onSaved: (value) => phone = value ?? '',
              ),
              const SizedBox(height: 10),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Court Count'),
                keyboardType: TextInputType.number,
                onSaved: (value) => courtCount = int.parse(value ?? '0'),
              ),
              const SizedBox(height: 10),
              CheckboxListTile(
                title: const Text('Parking'),
                value: parking,
                onChanged: (value) => setState(() => parking = value ?? false),
              ),
              CheckboxListTile(
                title: const Text('Changing Rooms'),
                value: changingRooms,
                onChanged: (value) => setState(() => changingRooms = value ?? false),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _formKey.currentState?.save();
                  saveClub();
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
