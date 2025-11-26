import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class AppointmentsService {
  static const String _baseUrl = 'http://10.0.2.2:4000/api/appointments';

  static Future<Map<String, String>> _headers() async {
    final token = await AuthService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<List<dynamic>> getMyAppointments() async {
    final h = await _headers();
    final resp = await http.get(Uri.parse('$_baseUrl/my'), headers: h);
    final data = jsonDecode(resp.body);
    if (resp.statusCode != 200 || data['ok'] != true) {
      throw Exception(data['error'] ?? 'Error al obtener citas');
    }
    return data['data'] as List<dynamic>;
  }

  static Future<void> deleteAppointment(int id) async {
    final h = await _headers();
    final resp = await http.delete(Uri.parse('$_baseUrl/$id'), headers: h);
    final data = jsonDecode(resp.body);
    if (resp.statusCode != 200 || data['ok'] != true) {
      throw Exception(data['error'] ?? 'Error al eliminar cita');
    }
  }

  static Future<void> updateAppointment(
      int id, Map<String, dynamic> payload) async {
    final h = await _headers();
    final resp = await http.put(Uri.parse('$_baseUrl/$id'),
        headers: h, body: jsonEncode(payload));
    final data = jsonDecode(resp.body);
    if (resp.statusCode != 200 || data['ok'] != true) {
      throw Exception(data['error'] ?? 'Error al actualizar cita');
    }
  }

  static Future<Map<String, dynamic>?> getNextAppointment() async {
    final h = await _headers();
    final resp = await http.get(Uri.parse('$_baseUrl/next'), headers: h);
    final data = jsonDecode(resp.body);
    if (resp.statusCode != 200 || data['ok'] != true) {
      throw Exception(data['error'] ?? 'Error al obtener próxima cita');
    }
    return data['data'] as Map<String, dynamic>?;
  }

  static Future<List<dynamic>> getCalendarCounts(
      String fromDate, String toDate) async {
    final h = await _headers();
    final resp = await http.get(
      Uri.parse('$_baseUrl/calendar?from=$fromDate&to=$toDate'),
      headers: h,
    );
    final data = jsonDecode(resp.body);
    if (resp.statusCode != 200 || data['ok'] != true) {
      throw Exception(data['error'] ?? 'Error al obtener calendario');
    }
    return data['data'] as List<dynamic>;
  }
}
