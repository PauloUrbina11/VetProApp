import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl = "http://10.0.2.2:4000/api/auth";
  static const String _kTokenKey = "_vetpro_token";
  static const String _kRoleKey = "_vetpro_role";
  static const String _kUserIdKey = "_vetpro_user_id";

  /// LOGIN
  static Future<Map<String, dynamic>> login(
      String correo, String password) async {
    final url = Uri.parse("$baseUrl/login");
    try {
      final requestBody = jsonEncode({
        "correo": correo,
        "password": password,
      });

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: requestBody);

      final status = response.statusCode;
      final body = response.body;

      Map<String, dynamic> data;
      try {
        data = jsonDecode(body);
      } catch (e) {
        data = {"_raw": body};
      }

      final tokenFromRoot = data["tokenJWT"];
      final tokenNested =
          data["token"] is Map ? data["token"]["tokenJWT"] : null;
      final token = tokenFromRoot ?? tokenNested;

      if (status == 200 && token != null) {
        final user = (data["user"] ??
            (data["token"] is Map ? data["token"]["user"] : null));
        final message = data["message"] ?? "Inicio de sesión exitoso";

        // Guardar token localmente
        await _saveToken(token);

        // Guardar rol y user_id si existen
        if (user != null) {
          if (user['rol_id'] != null) {
            await _saveRole(user['rol_id']);
          }
          if (user['id'] != null) {
            await _saveUserId(user['id']);
          }
        }

        return {
          "ok": true,
          "data": data,
          "tokenJWT": token,
          "user": user,
          "message": message,
        };
      }

      return {
        "ok": false,
        "message": data["message"] ?? "Error desconocido",
        "statusCode": status,
        "responseBody": body,
      };
    } catch (e) {
      return {"ok": false, "message": "Error de conexión: ${e.toString()}"};
    }
  }

  /// REGISTER
  static Future<Map<String, dynamic>> register(
      Map<String, dynamic> payload) async {
    final url = Uri.parse("$baseUrl/register");
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payload));

      final data = jsonDecode(response.body);
      return {"ok": response.statusCode == 201, ...data};
    } catch (e) {
      return {"ok": false, "message": "Error de conexión: ${e.toString()}"};
    }
  }

  /// ACTIVATE
  static Future<Map<String, dynamic>> activate(String token) async {
    final url = Uri.parse("$baseUrl/activate?token=$token");
    try {
      final response = await http.get(url);
      final data = jsonDecode(response.body);
      return {"ok": response.statusCode == 200, ...data};
    } catch (e) {
      return {"ok": false, "message": "Error de conexión: ${e.toString()}"};
    }
  }

  /// FETCH DEPARTAMENTOS
  static Future<List<Map<String, dynamic>>> fetchDepartamentos() async {
    final url = Uri.parse("http://10.0.2.2:4000/api/location/departamentos");
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final list =
            (data["departamentos"] as List).cast<Map<String, dynamic>>();
        return list;
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  /// FETCH CIUDADES POR DEPARTAMENTO
  static Future<List<Map<String, dynamic>>> fetchCiudades(
      int departamentoId) async {
    final url = Uri.parse(
        "http://10.0.2.2:4000/api/location/ciudades?departamento_id=$departamentoId");
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final list = (data["ciudades"] as List).cast<Map<String, dynamic>>();
        return list;
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  /// REQUEST PASSWORD RESET
  static Future<Map<String, dynamic>> requestPasswordReset(
      String correo) async {
    final url = Uri.parse("$baseUrl/reset/request");
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"correo": correo}));
      final data = jsonDecode(response.body);
      return {"ok": response.statusCode == 200, ...data};
    } catch (e) {
      return {"ok": false, "message": "Error de conexión: ${e.toString()}"};
    }
  }

  /// RESET PASSWORD
  static Future<Map<String, dynamic>> resetPassword(
      String token, String newPassword) async {
    final url = Uri.parse("$baseUrl/reset/update");
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"token": token, "newPassword": newPassword}));
      final data = jsonDecode(response.body);
      return {"ok": response.statusCode == 200, ...data};
    } catch (e) {
      return {"ok": false, "message": "Error de conexión: ${e.toString()}"};
    }
  }

  /// TOKEN STORAGE
  static Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kTokenKey, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kTokenKey);
  }

  /// ROLE STORAGE
  static Future<void> _saveRole(dynamic rol_id) async {
    final prefs = await SharedPreferences.getInstance();
    final role = rol_id is int ? rol_id : int.tryParse(rol_id.toString());
    if (role != null) {
      await prefs.setInt(_kRoleKey, role);
    }
  }

  static Future<int?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_kRoleKey);
  }

  /// USER ID STORAGE
  static Future<void> _saveUserId(dynamic userId) async {
    final prefs = await SharedPreferences.getInstance();
    final id = userId is int ? userId : int.tryParse(userId.toString());
    if (id != null) {
      await prefs.setInt(_kUserIdKey, id);
    }
  }

  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_kUserIdKey);
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kTokenKey);
    await prefs.remove(_kRoleKey);
    await prefs.remove(_kUserIdKey);
  }
}
