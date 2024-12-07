import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = "http://192.168.0.60:3001";

  // Método para obtener los datos del club por usuario
  Future<Map<String, dynamic>?> getClubByUsuario(String usuario) async {
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
      throw Exception("Error al validar el usuario");
    }
  }
}
