import 'package:flutter/material.dart';
import 'login_page.dart';  // Importa la pantalla de inicio de sesión
import 'search_court_screen.dart';  // Importa la pantalla de búsqueda de cancha (placeholder)
import 'search_club_screen.dart';  // Importa la pantalla de búsqueda de club (placeholder)
import 'all_courts_screen.dart';  // Importa la pantalla de todas las canchas

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
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SearchCourtScreen()),  // Navegar a la pantalla de búsqueda de cancha
                );
              },
              child: const Text('Buscar cancha'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),  // Navegar a la pantalla de inicio de sesión
                );
              },
              child: const Text('Club'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SearchClubScreen()),  // Navegar a la pantalla de búsqueda de club
                );
              },
              child: const Text('Buscar club'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AllCourtsScreen()),  // Navegar a la pantalla de todas las canchas
                );
              },
              child: const Text('Ver todas las canchas'),
            ),
          ],
        ),
      ),
    );
  }
}
