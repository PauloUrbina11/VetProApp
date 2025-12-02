import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import '../config/api_config.dart';

class MedicalRecordsService {
  static const String _baseUrl = ApiConfig.medicalRecords;

  static Future<Map<String, dynamic>> createMedicalRecord(
      Map<String, dynamic> data) async {
    final token = await AuthService.getToken();
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 201) {
      final jsonData = jsonDecode(response.body);
      return jsonData['data'];
    } else {
      final errorBody = response.body;
      throw Exception(
          'Error al crear historia clínica: ${response.statusCode} - $errorBody');
    }
  }

  static Future<List<dynamic>> getMedicalRecordsByPet(int mascotaId) async {
    final token = await AuthService.getToken();
    final response = await http.get(
      Uri.parse('$_baseUrl/pet/$mascotaId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return jsonData['data'] ?? [];
    } else {
      throw Exception('Error al obtener historias clínicas');
    }
  }

  static Future<Map<String, dynamic>?> getMedicalRecordByCita(
      int citaId) async {
    final token = await AuthService.getToken();
    final response = await http.get(
      Uri.parse('$_baseUrl/appointment/$citaId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return jsonData['data'];
    } else {
      return null;
    }
  }

  static Future<Map<String, dynamic>> updateMedicalRecord(
      int id, Map<String, dynamic> data) async {
    final token = await AuthService.getToken();
    final response = await http.put(
      Uri.parse('$_baseUrl/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return jsonData['data'];
    } else {
      throw Exception('Error al actualizar historia clínica');
    }
  }

  static Future<void> deleteMedicalRecord(int id) async {
    final token = await AuthService.getToken();
    final response = await http.delete(
      Uri.parse('$_baseUrl/$id'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Error al eliminar historia clínica');
    }
  }
}
