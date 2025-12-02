import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import '../config/api_config.dart';

export 'auth_service.dart' show AuthService;

class AdminService {
  static const String _baseUrl = ApiConfig.baseUrl;

  static Future<Map<String, String>> _headers() async {
    final token = await AuthService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<List<dynamic>> listUsers() async {
    final h = await _headers();
    final resp = await http.get(Uri.parse('$_baseUrl/admin/users'), headers: h);
    final data = jsonDecode(resp.body);
    if (resp.statusCode != 200 || data['ok'] != true) {
      throw Exception(data['error'] ?? 'Error listUsers');
    }
    return data['data'] as List<dynamic>;
  }

  static Future<List<dynamic>> listVeterinariaUsers() async {
    final h = await _headers();
    final resp = await http.get(Uri.parse('$_baseUrl/admin/veterinaria-users'),
        headers: h);
    final data = jsonDecode(resp.body);
    if (resp.statusCode != 200 || data['ok'] != true) {
      throw Exception(data['error'] ?? 'Error listVeterinariaUsers');
    }
    return data['data'] as List<dynamic>;
  }

  static Future<List<dynamic>> listVeterinariaRoles() async {
    final h = await _headers();
    final resp = await http.get(Uri.parse('$_baseUrl/admin/veterinaria-roles'),
        headers: h);
    final data = jsonDecode(resp.body);
    if (resp.statusCode != 200 || data['ok'] != true) {
      throw Exception(data['error'] ?? 'Error listVeterinariaRoles');
    }
    return data['data'] as List<dynamic>;
  }

  static Future<void> assignRole(int userId, int rolId) async {
    final h = await _headers();
    final resp = await http.post(
        Uri.parse('$_baseUrl/admin/users/$userId/role'),
        headers: h,
        body: jsonEncode({'rol_id': rolId}));
    final data = jsonDecode(resp.body);
    if (resp.statusCode != 200 || data['ok'] != true) {
      throw Exception(data['error'] ?? 'Error assignRole');
    }
  }

  static Future<void> assignVeterinariaRole(
      int veterinariaId, int userId, int veterinariaRolId) async {
    final h = await _headers();
    final resp = await http.post(Uri.parse('$_baseUrl/admin/veterinaria-role'),
        headers: h,
        body: jsonEncode({
          'veterinaria_id': veterinariaId,
          'user_id': userId,
          'veterinaria_rol_id': veterinariaRolId,
        }));
    final data = jsonDecode(resp.body);
    if (resp.statusCode != 200 || data['ok'] != true) {
      throw Exception(data['error'] ?? 'Error assignVeterinariaRole');
    }
  }

  static Future<Map<String, dynamic>> createVeterinaria(
      Map<String, dynamic> payload) async {
    final h = await _headers();
    final resp = await http.post(Uri.parse('$_baseUrl/admin/veterinarias'),
        headers: h, body: jsonEncode(payload));
    final data = jsonDecode(resp.body);
    if (resp.statusCode != 201 || data['ok'] != true) {
      throw Exception(data['error'] ?? 'Error createVeterinaria');
    }
    return data['data'] as Map<String, dynamic>;
  }

  static Future<List<dynamic>> listVeterinarias() async {
    final h = await _headers();
    final resp =
        await http.get(Uri.parse('$_baseUrl/veterinarias'), headers: h);
    final data = jsonDecode(resp.body);
    if (resp.statusCode != 200 || data['ok'] != true) {
      throw Exception(data['error'] ?? 'Error listVeterinarias');
    }
    return data['data'] as List<dynamic>;
  }

  static Future<Map<String, dynamic>> getGlobalStats() async {
    final h = await _headers();
    final resp =
        await http.get(Uri.parse('$_baseUrl/stats/global'), headers: h);
    final data = jsonDecode(resp.body);
    if (resp.statusCode != 200 || data['ok'] != true) {
      throw Exception(data['error'] ?? 'Error getGlobalStats');
    }
    return data['data'] as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> getUserStats() async {
    final h = await _headers();
    final resp = await http.get(Uri.parse('$_baseUrl/stats/user'), headers: h);
    final data = jsonDecode(resp.body);
    if (resp.statusCode != 200 || data['ok'] != true) {
      throw Exception(data['error'] ?? 'Error getUserStats');
    }
    return data['data'] as Map<String, dynamic>;
  }

  static Future<List<dynamic>> getAllAppointments() async {
    final h = await _headers();
    final resp =
        await http.get(Uri.parse('$_baseUrl/admin/appointments'), headers: h);
    final data = jsonDecode(resp.body);
    if (resp.statusCode != 200 || data['ok'] != true) {
      throw Exception(data['error'] ?? 'Error getAllAppointments');
    }
    return data['data'] as List<dynamic>;
  }

  static Future<List<dynamic>> getRecentActivity() async {
    final h = await _headers();
    final resp = await http.get(Uri.parse('$_baseUrl/stats/recent-activity'),
        headers: h);
    final data = jsonDecode(resp.body);
    if (resp.statusCode != 200 || data['ok'] != true) {
      throw Exception(data['error'] ?? 'Error getRecentActivity');
    }
    return data['data'] as List<dynamic>;
  }

  static Future<List<dynamic>> getUserVeterinariaRoles(
      int veterinariaId, int userId) async {
    final h = await _headers();
    final resp = await http.get(
        Uri.parse(
            '$_baseUrl/admin/veterinaria/$veterinariaId/user/$userId/roles'),
        headers: h);
    final data = jsonDecode(resp.body);
    if (resp.statusCode != 200 || data['ok'] != true) {
      throw Exception(data['error'] ?? 'Error getUserVeterinariaRoles');
    }
    return data['data'] as List<dynamic>;
  }

  static Future<void> removeVeterinariaRole(
      int veterinariaId, int userId, int veterinariaRolId) async {
    final h = await _headers();
    final resp =
        await http.delete(Uri.parse('$_baseUrl/admin/veterinaria-role'),
            headers: h,
            body: jsonEncode({
              'veterinaria_id': veterinariaId,
              'user_id': userId,
              'veterinaria_rol_id': veterinariaRolId,
            }));
    final data = jsonDecode(resp.body);
    if (resp.statusCode != 200 || data['ok'] != true) {
      throw Exception(data['error'] ?? 'Error removeVeterinariaRole');
    }
  }

  static Future<Map<String, dynamic>> toggleUserActive(int userId) async {
    final h = await _headers();
    final resp = await http.patch(
      Uri.parse('$_baseUrl/admin/users/$userId/toggle-active'),
      headers: h,
    );
    final data = jsonDecode(resp.body);
    if (resp.statusCode != 200 || data['ok'] != true) {
      throw Exception(data['error'] ?? 'Error toggleUserActive');
    }
    return data['data'] as Map<String, dynamic>;
  }
}
