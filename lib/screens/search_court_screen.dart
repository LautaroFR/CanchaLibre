import 'package:flutter/material.dart';

class SearchCourtScreen extends StatelessWidget {
  const SearchCourtScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buscar Cancha')),
      body: Center(
        child: const Text('Pantalla de búsqueda de cancha'),
      ),
    );
  }
}
