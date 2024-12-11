import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DatabaseService {
  final CollectionReference<Map<String, dynamic>> clubsCollection = FirebaseFirestore.instance.collection('clubs');

  // Add or update a club with custom document ID
  Future<void> addOrUpdateClub(String email, Map<String, dynamic> clubData) async {
    try {
      String documentId = email.split('@')[0];  // Obtener la parte antes del @
      await clubsCollection.doc(documentId).set(clubData, SetOptions(merge: true));  // Usar SetOptions para la actualización si el documento ya existe
    } catch (error) {
      print("Error adding/updating club: $error");
      rethrow;
    }
  }

  // Get club by email
  Future<DocumentSnapshot<Map<String, dynamic>>?> getClubByEmail(String email) async {
    try {
      String documentId = email.split('@')[0];  // Obtener la parte antes del @
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
    return await clubsCollection.doc(clubId).collection('courts').get();
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

  // Update club schedule
  Future<void> updateClubSchedule(String clubId, Map<String, Map<String, TimeOfDay>> schedule, BuildContext context) async {
    try {
      Map<String, Map<String, String>> scheduleToSave = schedule.map((key, value) => MapEntry(
        key,
        value.map((timeKey, timeValue) => MapEntry(timeKey, timeValue.format(context))),
      ));

      await clubsCollection.doc(clubId).update({
        'schedule': scheduleToSave,
      });
    } catch (error) {
      print("Error al actualizar horarios del club: $error");
      rethrow;
    }
  }

  // Get club schedule
  Future<Map<String, dynamic>?> getClubSchedule(String clubId) async {
    try {
      final doc = await clubsCollection.doc(clubId).get();
      if (doc.exists) {
        return doc.data()!['schedule'] as Map<String, dynamic>;
      }
      return null;
    } catch (error) {
      print("Error al obtener horarios del club: $error");
      rethrow;
    }
  }
}
