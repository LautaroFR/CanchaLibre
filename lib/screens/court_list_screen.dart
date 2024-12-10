import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/database_service.dart';

class CourtListScreen extends StatelessWidget {
  final String clubId;

  const CourtListScreen({super.key, required this.clubId});

  Future<List<Map<String, dynamic>>> fetchCourts() async {
    final databaseService = DatabaseService();
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot = await databaseService.getCourtsByClubId(clubId);
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (error) {
      print("Error fetching courts: $error");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Court List')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchCourts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No courts found'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final court = snapshot.data![index];
                return ListTile(
                  title: Text('Court Number: ${court['number']}'),
                  subtitle: Text('Size: ${court['size']} m²\nSurface: ${court['surface']}\nPrice: \$${court['price']}'),
                  trailing: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Light: ${court['light'] ? 'Yes' : 'No'}'),
                      Text('Covered: ${court['covered'] ? 'Yes' : 'No'}'),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}