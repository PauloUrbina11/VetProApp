import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import '../config/api_config.dart';

class ServicesService {
  static const String _baseUrl = ApiConfig.services;

  static Future<Map<String, String>> _headers() async {
    final token = await AuthService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<List<dynamic>> getServiceTypes() async {
    final resp = await http.get(Uri.parse('$_baseUrl/types'));
    final data = jsonDecode(resp.body);
    if (resp.statusCode != 200 || data['ok'] != true) {
      throw Exception(data['error'] ?? 'Error al obtener tipos de servicio');
    }
    return data['data'] as List<dynamic>;
  }

  static Future<List<dynamic>> getServices() async {
    final resp = await http.get(Uri.parse(_baseUrl));
    final data = jsonDecode(resp.body);
    if (resp.statusCode != 200 || data['ok'] != true) {
      throw Exception(data['error'] ?? 'Error al obtener servicios');
    }
    return data['data'] as List<dynamic>;
  }

  static Future<void> createService(Map<String, dynamic> payload) async {
    final h = await _headers();
    final resp = await http.post(Uri.parse(_baseUrl),
        headers: h, body: jsonEncode(payload));
    final data = jsonDecode(resp.body);
    if (resp.statusCode != 201 || data['ok'] != true) {
      throw Exception(data['error'] ?? 'Error al crear servicio');
    }
  }

  static Future<void> updateService(
      int id, Map<String, dynamic> payload) async {
    final h = await _headers();
    final resp = await http.put(Uri.parse('$_baseUrl/$id'),
        headers: h, body: jsonEncode(payload));
    final data = jsonDecode(resp.body);
    if (resp.statusCode != 200 || data['ok'] != true) {
      throw Exception(data['error'] ?? 'Error al actualizar servicio');
    }
  }

  static Future<void> deleteService(int id) async {
    final h = await _headers();
    final resp = await http.delete(Uri.parse('$_baseUrl/$id'), headers: h);
    final data = jsonDecode(resp.body);
    if (resp.statusCode != 200 || data['ok'] != true) {
      throw Exception(data['error'] ?? 'Error al eliminar servicio');
    }
  }
}
