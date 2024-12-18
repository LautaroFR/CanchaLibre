import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final CollectionReference<Map<String, dynamic>> clubsCollection = FirebaseFirestore.instance.collection('clubs');

  // Add or update a club with custom document ID
  Future<void> addOrUpdateClub(String email, Map<String, dynamic> clubData) async {
    try {
      String documentId = email.split('@')[0]; // Obtener la parte antes del @
      await clubsCollection.doc(documentId).set(clubData, SetOptions(merge: true)); // Usar SetOptions para la actualización
    } catch (error) {
      print("Error adding/updating club: $error");
      rethrow;
    }
  }

  // Get club by email
  Future<DocumentSnapshot<Map<String, dynamic>>?> getClubByEmail(String email) async {
    try {
      String documentId = email.split('@')[0]; // Obtener la parte antes del @
      DocumentSnapshot<Map<String, dynamic>> doc = await clubsCollection.doc(documentId).get();
      if (doc.exists) {
        return doc;
      } else {
        return null;
      }
    } catch (error) {
      print("Error getting club by email: $error");
      return null;
    }
  }

  // Get club by ID
  Future<Map<String, dynamic>?> getClubById(String clubId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> doc = await clubsCollection.doc(clubId).get();
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (error) {
      print("Error getting club by ID: $error");
      rethrow;
    }
  }

  // Delete court
  Future<void> deleteCourt(String clubId, String courtId) async {
    try {
      await clubsCollection.doc(clubId).collection('courts').doc(courtId).delete();
    } catch (error) {
      print("Error deleting court: $error");
      rethrow;
    }
  }

  // Add court to a club
  Future<void> addCourt(String clubId, Map<String, dynamic> courtData) async {
    try {
      await clubsCollection.doc(clubId).collection('courts').add(courtData);
    } catch (error) {
      print("Error adding court: $error");
      rethrow;
    }
  }

  // Get courts by club ID
  Future<QuerySnapshot<Map<String, dynamic>>> getCourtsByClubId(String clubId) async {
    try {
      return await clubsCollection.doc(clubId).collection('courts').get();
    } catch (error) {
      print("Error getting courts by club ID: $error");
      rethrow;
    }
  }

  // Update court information
  Future<void> updateCourt(String courtId, String clubId, Map<String, dynamic> updatedData) async {
    try {
      await clubsCollection.doc(clubId).collection('courts').doc(courtId).update(updatedData);
    } catch (error) {
      print("Error updating court: $error");
      rethrow;
    }
  }

  // Get all courts from all clubs
  Future<List<Map<String, dynamic>>> getAllCourts() async {
    try {
      QuerySnapshot<Map<String, dynamic>> clubsSnapshot = await clubsCollection.get();
      List<Map<String, dynamic>> allCourts = [];

      for (var clubDoc in clubsSnapshot.docs) {
        QuerySnapshot<Map<String, dynamic>> courtsSnapshot = await clubDoc.reference.collection('courts').get();
        for (var courtDoc in courtsSnapshot.docs) {
          var courtData = courtDoc.data();
          courtData['clubId'] = clubDoc.id; // Añadir el ID del club a los datos de la cancha
          allCourts.add(courtData);
        }
      }
      return allCourts;
    } catch (error) {
      print("Error getting all courts: $error");
      rethrow;
    }
  }

  // Reserve court
  Future<void> reserveCourt(String clubId, int courtNumber, String time, int deposit) async {
    try {
      final reservationData = {
        'time': time,
        'courtNumber': courtNumber,
        'deposit': deposit,
        'reservedAt': FieldValue.serverTimestamp(),
      };
      await clubsCollection.doc(clubId).collection('reservations').add(reservationData);
    } catch (error) {
      print("Error reserving court: $error");
      rethrow;
    }
  }

  // Update club schedule
  Future<void> updateClubSchedule(String clubId, Map<String, Map<String, String>> schedule) async {
    try {
      await clubsCollection.doc(clubId).update({
        'schedule': schedule,
      });
    } catch (error) {
      print("Error updating club schedule: $error");
      rethrow;
    }
  }

  // Get club schedule
  Future<Map<String, dynamic>?> getClubSchedule(String clubId) async {
    try {
      final doc = await clubsCollection.doc(clubId).get();
      if (doc.exists && doc.data()!.containsKey('schedule')) {
        return doc.data()!['schedule'] as Map<String, dynamic>;
      }
      return null;
    } catch (error) {
      print("Error getting club schedule: $error");
      rethrow;
    }
  }
}
