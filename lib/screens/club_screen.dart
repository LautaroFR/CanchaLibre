import 'package:flutter/material.dart';
import 'edit_club_screen.dart';

class ClubScreen extends StatelessWidget {
  const ClubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Club')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const TextField(
              decoration: InputDecoration(
                labelText: 'Usuario',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Aquí iría la navegación a "Ver lista canchas"
              },
              child: const Text('Ver lista canchas'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Aquí iría la navegación a "Agregar canchas"
              },
              child: const Text('Agregar canchas'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Aquí iría la navegación a "Ver calendario"
              },
              child: const Text('Ver calendario'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const EditClubScreen()),
                );
              },
              child: const Text('Editar información Club'),
            ),
          ],
        ),
      ),
    );
  }
}
