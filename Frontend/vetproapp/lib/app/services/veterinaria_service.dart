import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class VeterinariaService {
  static const String _baseUrl = 'http://10.0.2.2:4000/api/veterinarias';

  static Future<Map<String, String>> _headers() async {
    final token = await AuthService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<List<int>> getMyVeterinarias() async {
    final h = await _headers();
    final resp = await http.get(Uri.parse('$_baseUrl/by-user'), headers: h);
    final data = jsonDecode(resp.body);
    if (resp.statusCode != 200 || data['ok'] != true) {
      throw Exception(data['error'] ?? 'Error al obtener veterinarias');
    }
    return (data['data'] as List).map((e) => e as int).toList();
  }

  static Future<Map<String, dynamic>> getVeterinaria(int veterinariaId) async {
    final h = await _headers();
    final resp =
        await http.get(Uri.parse('$_baseUrl/$veterinariaId'), headers: h);
    final data = jsonDecode(resp.body);
    if (resp.statusCode != 200 || data['ok'] != true) {
      throw Exception(data['error'] ?? 'Error al obtener veterinaria');
    }
    return data['data'] as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> getDashboard(int veterinariaId) async {
    final h = await _headers();
    final resp = await http.get(Uri.parse('$_baseUrl/$veterinariaId/dashboard'),
        headers: h);
    final data = jsonDecode(resp.body);
    if (resp.statusCode != 200 || data['ok'] != true) {
      throw Exception(data['error'] ?? 'Error al obtener dashboard');
    }
    return data['data'] as Map<String, dynamic>;
  }

  static Future<List<dynamic>> getCalendarCounts(
      int veterinariaId, String fromDate, String toDate) async {
    final h = await _headers();
    final resp = await http.get(
        Uri.parse(
            '$_baseUrl/$veterinariaId/calendar?from=$fromDate&to=$toDate'),
        headers: h);
    final data = jsonDecode(resp.body);
    if (resp.statusCode != 200 || data['ok'] != true) {
      throw Exception(data['error'] ?? 'Error al obtener calendario');
    }
    return data['data'] as List<dynamic>;
  }
}
