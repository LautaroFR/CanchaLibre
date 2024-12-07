import 'package:flutter/material.dart';
import 'api_service.dart';
import 'edit_court_screen.dart';

class CourtListScreen extends StatelessWidget {
  final int clubId;

  CourtListScreen({required this.clubId});

  @override
  Widget build(BuildContext context) {
    final ApiService apiService = ApiService();

    return Scaffold(
      appBar: AppBar(title: Text('Canchas del Club')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: apiService.getCourtsByClubId(clubId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error al cargar canchas: ${snapshot.error}'));
          }

          final canchas = snapshot.data ?? [];

          return ListView.builder(
            itemCount: canchas.length,
            itemBuilder: (context, index) {
              final cancha = canchas[index];
              return ListTile(
                title: Text('Cancha ${cancha['numero']}'),
                subtitle: Text('Superficie: ${cancha['superficie']}'),
                trailing: Text('\$${cancha['precio']}/hora'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditCourtScreen(cancha: cancha),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
