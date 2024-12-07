import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = "http://192.168.0.60:3001"; // Asegúrate de que esta IP sea accesible desde tu dispositivo

  /// Obtiene los datos del club por usuario.
  Future<Map<String, dynamic>?> getClubByUser(String usuario) async {
    final response = await http.get(Uri.parse("$baseUrl/clubs?usuario=$usuario"));

    if (response.statusCode == 200) {
      // Decodificar la respuesta en una lista
      final List<dynamic> data = json.decode(response.body);

      // Si la lista no está vacía, devolver el primer elemento como un mapa
      if (data.isNotEmpty) {
        return data[0] as Map<String, dynamic>;
      } else {
        return null; // Usuario no encontrado
      }
    } else {
      throw Exception("Error al validar el usuario: ${response.body}");
    }
  }

  /// Actualiza los datos del club para un usuario específico.
  Future<void> updateClubByUser(String usuario, Map<String, dynamic> club) async {
    if (usuario.isEmpty) {
      throw Exception("Usuario vacío");
    }

    print('Datos a enviar: ${json.encode(club)}');  // Verifica qué datos estás enviando

    final response = await http.put(
      Uri.parse("$baseUrl/clubs/$usuario"),  // Verifica que la URL esté correcta
      headers: {'Content-Type': 'application/json'},
      body: json.encode(club),
    );

    if (response.statusCode != 200) {
      throw Exception("Error al actualizar el club: ${response.body}");
    }
  }

  /// Obtiene una lista de clubes.
  Future<List<Map<String, dynamic>>> getAllClubs() async {
    final response = await http.get(Uri.parse("$baseUrl/clubs"));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception("Error al obtener la lista de clubes");
    }
  }

  // class ApiService {
  // final String baseUrl = "http://192.168.0.60:3001";

  // Obtener canchas por ID de club
  Future<List<Map<String, dynamic>>> getCourtsByClubId(int clubId) async {
  final response = await http.get(Uri.parse("$baseUrl/canchas/$clubId"));

  if (response.statusCode == 200) {
  final List<dynamic> data = json.decode(response.body);
  return data.cast<Map<String, dynamic>>();
  } else {
  throw Exception("Error al obtener las canchas: ${response.body}");
  }
  }

  // Agregar una nueva cancha
  Future<void> addCourt(int clubId, Map<String, dynamic> cancha) async {
    // Agregar el clubId al mapa de la cancha antes de enviarlo
    cancha['club_id'] = clubId;

    final response = await http.post(
      Uri.parse("$baseUrl/canchas"),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(cancha),
    );

    if (response.statusCode != 201) {
      throw Exception("Error al agregar la cancha: ${response.body}");
    }
  }

  // Actualizar una cancha
  Future<void> updateCourt(int canchaId, Map<String, dynamic> cancha) async {
  final response = await http.put(
  Uri.parse("$baseUrl/canchas/$canchaId"),
  headers: {'Content-Type': 'application/json'},
  body: json.encode(cancha),
  );

  if (response.statusCode != 200) {
  throw Exception("Error al actualizar la cancha: ${response.body}");
  }
  }
  }


