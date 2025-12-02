import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import '../config/api_config.dart';

class VeterinariaServicesService {
  static const String baseUrl = ApiConfig.baseUrl;

  // Obtener servicios de una veterinaria
  static Future<List<dynamic>> getServicios(int veterinariaId,
      {bool activosOnly = false}) async {
    final token = await AuthService.getToken();
    final url = activosOnly
        ? '$baseUrl/veterinarias/$veterinariaId/servicios?activos=true'
        : '$baseUrl/veterinarias/$veterinariaId/servicios';

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      try {
        final data = json.decode(response.body);
        return data['servicios'] ?? [];
      } catch (e) {
        throw Exception('Error al procesar la respuesta del servidor');
      }
    } else {
      try {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Error al obtener servicios');
      } catch (e) {
        throw Exception('Error del servidor (${response.statusCode})');
      }
    }
  }

  // Agregar un servicio a la veterinaria
  static Future<Map<String, dynamic>> addServicio(
      int veterinariaId, int servicioId) async {
    final token = await AuthService.getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/veterinarias/$veterinariaId/servicios'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'servicio_id': servicioId,
        'activo': true,
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      try {
        return json.decode(response.body);
      } catch (e) {
        throw Exception('Error al procesar la respuesta del servidor');
      }
    } else {
      try {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Error al agregar servicio');
      } catch (e) {
        throw Exception('Error del servidor (${response.statusCode})');
      }
    }
  }

  // Actualizar estado de un servicio
  static Future<Map<String, dynamic>> updateServicio(
      int veterinariaId, int servicioVeterinariaId, bool activo) async {
    final token = await AuthService.getToken();
    final response = await http.put(
      Uri.parse(
          '$baseUrl/veterinarias/$veterinariaId/servicios/$servicioVeterinariaId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'activo': activo,
      }),
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
        throw Exception(error['message'] ?? 'Error al actualizar servicio');
      } catch (e) {
        throw Exception('Error del servidor (${response.statusCode})');
      }
    }
  }

  // Eliminar (desactivar) un servicio
  static Future<Map<String, dynamic>> deleteServicio(
      int veterinariaId, int servicioVeterinariaId) async {
    final token = await AuthService.getToken();
    final response = await http.delete(
      Uri.parse(
          '$baseUrl/veterinarias/$veterinariaId/servicios/$servicioVeterinariaId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
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
        throw Exception(error['message'] ?? 'Error al eliminar servicio');
      } catch (e) {
        throw Exception('Error del servidor (${response.statusCode})');
      }
    }
  }

  // Eliminar permanentemente un servicio
  static Future<Map<String, dynamic>> removeServicio(
      int veterinariaId, int servicioId) async {
    final token = await AuthService.getToken();
    final response = await http.delete(
      Uri.parse(
          '$baseUrl/veterinarias/$veterinariaId/servicios/$servicioId/remove'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
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
        throw Exception(error['message'] ?? 'Error al eliminar servicio');
      } catch (e) {
        throw Exception('Error del servidor (${response.statusCode})');
      }
    }
  }
}
