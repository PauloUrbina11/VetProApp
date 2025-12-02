import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import '../config/api_config.dart';

class HorariosService {
  static const String baseUrl = ApiConfig.baseUrl;

  // Obtener horarios de una veterinaria
  static Future<List<dynamic>> getHorarios(int veterinariaId) async {
    final token = await AuthService.getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/veterinarias/$veterinariaId/horarios'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      try {
        final data = json.decode(response.body);
        return data['horarios'] ?? [];
      } catch (e) {
        throw Exception('Error al procesar la respuesta del servidor');
      }
    } else {
      try {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Error al obtener horarios');
      } catch (e) {
        throw Exception('Error del servidor (${response.statusCode})');
      }
    }
  }

  // Reemplazar todos los horarios de una veterinaria
  static Future<Map<String, dynamic>> replaceAllHorarios(
      int veterinariaId, List<Map<String, dynamic>> horarios) async {
    final token = await AuthService.getToken();
    final response = await http.put(
      Uri.parse('$baseUrl/veterinarias/$veterinariaId/horarios'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({'horarios': horarios}),
    );

    if (response.statusCode == 200) {
      try {
        return json.decode(response.body);
      } catch (e) {
        throw Exception('Error al procesar la respuesta del servidor');
      }
    } else {
      try {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Error al guardar horarios');
      } catch (e) {
        throw Exception('Error del servidor (${response.statusCode})');
      }
    }
  }

  // Crear un horario
  static Future<Map<String, dynamic>> createHorario(
      int veterinariaId, Map<String, dynamic> horario) async {
    final token = await AuthService.getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/veterinarias/$veterinariaId/horarios'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(horario),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      final error = json.decode(response.body);
      throw Exception(error['message'] ?? 'Error al crear horario');
    }
  }

  // Eliminar un horario
  static Future<Map<String, dynamic>> deleteHorario(
      int veterinariaId, int horarioId) async {
    final token = await AuthService.getToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/veterinarias/$veterinariaId/horarios/$horarioId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      final error = json.decode(response.body);
      throw Exception(error['message'] ?? 'Error al eliminar horario');
    }
  }
}
