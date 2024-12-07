import 'package:flutter/material.dart';
import 'club_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cancha Libre')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                // Aquí iría la navegación a "Buscar Cancha"
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Función no implementada')),
                );
              },
              child: const Text('Buscar Cancha'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ClubScreen()),
                );
              },
              child: const Text('Club'),
            ),
          ],
        ),
      ),
    );
  }
}
