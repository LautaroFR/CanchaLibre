import 'package:flutter/material.dart';

class SearchClubScreen extends StatelessWidget {
  const SearchClubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buscar Club')),
      body: Center(
        child: const Text('Pantalla de búsqueda de club'),
      ),
    );
  }
}
