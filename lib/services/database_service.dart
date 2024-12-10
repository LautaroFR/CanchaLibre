import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final CollectionReference<Map<String, dynamic>> clubsCollection = FirebaseFirestore.instance.collection('clubs');

  // Add a club
  Future<void> addClub(Map<String, dynamic> clubData) async {
    try {
      // Asegúrate de que `phone` se guarde como entero
      if (clubData['phone'] is String) {
        clubData['phone'] = int.parse(clubData['phone']);
      }
      await clubsCollection.add(clubData);
    } catch (error) {
      print("Error adding club: $error");
    }
  }

  // Update club information
  Future<void> updateClub(String clubId, Map<String, dynamic> updatedData) async {
    try {
      // Asegúrate de que `phone` se guarde como entero
      if (updatedData['phone'] is String) {
        updatedData['phone'] = int.parse(updatedData['phone']);
      }
      await clubsCollection.doc(clubId).update(updatedData);
    } catch (error) {
      print("Error updating club: $error");
    }
  }

  // Get club by user
  Future<DocumentSnapshot<Map<String, dynamic>>?> getClubByUser(String userId) async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await clubsCollection.where('userId', isEqualTo: userId).get();
      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.first;
      } else {
        return null;
      }
    } catch (error) {
      print("Error getting club by user: $error");
      return null;
    }
  }

  // Delete court
  Future<void> deleteCourt(String clubId, String courtId) async {
    try {
      await clubsCollection.doc(clubId).collection('courts').doc(courtId).delete();
    } catch (error) {
      print("Error deleting court: $error");
    }
  }

  // Add court to a club
  Future<void> addCourt(String clubId, Map<String, dynamic> courtData) async {
    try {
      await clubsCollection.doc(clubId).collection('courts').add(courtData);
    } catch (error) {
      print("Error adding court: $error");
    }
  }

  // Get courts by club ID
  Future<QuerySnapshot<Map<String, dynamic>>> getCourtsByClubId(String clubId) async {
    return await clubsCollection.doc(clubId).collection('courts').get();
  }

  // Update court information
  Future<void> updateCourt(String courtId, String clubId, Map<String, dynamic> updatedData) async {
    try {
      await clubsCollection.doc(clubId).collection('courts').doc(courtId).update(updatedData);
    } catch (error) {
      print("Error updating court: $error");
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
          courtData['clubId'] = clubDoc.id;  // Añadir el ID del club a los datos de la cancha
          allCourts.add(courtData);
        }
      }
      return allCourts;
    } catch (error) {
      print("Error getting all courts: $error");
      rethrow;
    }
  }
}
