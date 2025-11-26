import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class RecommendationsService {
  static const String _baseUrl = 'http://10.0.2.2:4000/api/recommendations';

  static Future<Map<String, String>> _headers() async {
    final token = await AuthService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<List<dynamic>> getRecommendations({
    int? especieId,
    int? veterinariaId,
  }) async {
    final h = await _headers();
    String url = _baseUrl;
    List<String> queryParams = [];

    if (especieId != null) {
      queryParams.add('especie_id=$especieId');
    }
    if (veterinariaId != null) {
      queryParams.add('veterinaria_id=$veterinariaId');
    }

    if (queryParams.isNotEmpty) {
      url += '?${queryParams.join('&')}';
    }

    final resp = await http.get(Uri.parse(url), headers: h);
    final data = jsonDecode(resp.body);
    if (resp.statusCode != 200 || data['ok'] != true) {
      throw Exception(data['error'] ?? 'Error al obtener recomendaciones');
    }
    return data['data'] as List<dynamic>;
  }
}
