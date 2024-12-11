import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/database_service.dart';
import 'add_court_screen.dart';

class CourtListScreen extends StatefulWidget {
  final String clubId;

  const CourtListScreen({super.key, required this.clubId});

  @override
  _CourtListScreenState createState() => _CourtListScreenState();
}

class _CourtListScreenState extends State<CourtListScreen> {
  late Future<List<Map<String, dynamic>>> _futureCourts;

  @override
  void initState() {
    super.initState();
    _futureCourts = fetchCourts();
  }

  Future<List<Map<String, dynamic>>> fetchCourts() async {
    final databaseService = DatabaseService();
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot = await databaseService.getCourtsByClubId(widget.clubId);
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;  // Añadir el ID de la cancha
        data['clubId'] = widget.clubId;  // Asegurarse de que 'clubId' esté presente en los datos
        return data;
      }).toList();
    } catch (error) {
      print("Error fetching courts: $error");
      return [];
    }
  }

  Future<void> deleteCourt(BuildContext context, String courtId) async {
    final databaseService = DatabaseService();
    await databaseService.deleteCourt(widget.clubId, courtId);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Court deleted successfully')),
    );
    setState(() {
      _futureCourts = fetchCourts();
    });
  }

  void navigateToAddOrEditCourt(Map<String, dynamic>? court) async {
    bool? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddCourtScreen(
          clubId: widget.clubId,
          court: court,
        ),
      ),
    );
    if (result == true) {
      setState(() {
        _futureCourts = fetchCourts();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Listado de canchas')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _futureCourts,
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
                  title: Text('Club ${court['clubId']} - Cancha #${court['number']} '),
                  subtitle: Text('Futbol ${court['size']} - ${court['surface']}  ${court['covered'] ? '- Techada' : ''}\nPrecio: \$${court['price']} - ${court['light'] ? 'Con iluminación' : 'Sin iluminación'}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => navigateToAddOrEditCourt(court),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Confirm Deletion'),
                                content: const Text('Are you sure you want to delete this court?'),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      Navigator.of(context).pop();
                                      await deleteCourt(context, court['id']);
                                    },
                                    child: const Text('Delete'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
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
