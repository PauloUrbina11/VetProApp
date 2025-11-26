import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class UserService {
  static const String baseUrl = 'http://10.0.2.2:4000/api/users';

  static Future<Map<String, dynamic>?> getMyProfile() async {
    final token = await AuthService.getToken();
    if (token == null) return null;
    final url = Uri.parse('$baseUrl/me');
    final res = await http.get(url, headers: {
      'Authorization': 'Bearer $token',
    });
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data['profile'] as Map<String, dynamic>?;
    }
    return null;
  }

  static Future<Map<String, dynamic>?> updateMyProfile(
      Map<String, dynamic> payload) async {
    final token = await AuthService.getToken();
    if (token == null) return null;
    final url = Uri.parse('$baseUrl/me');
    final res = await http.put(url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
        },
        body: jsonEncode(payload));
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data['profile'] as Map<String, dynamic>?;
    }
    return null;
  }
}
