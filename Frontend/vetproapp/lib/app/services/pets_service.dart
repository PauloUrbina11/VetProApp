import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class PetsService {
  static const String _baseUrl = 'http://10.0.2.2:4000/api/pets';

  static Future<Map<String, String>> _headers() async {
    final token = await AuthService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<List<dynamic>> getMyPets() async {
    final h = await _headers();
    final resp = await http.get(Uri.parse('$_baseUrl/mis'), headers: h);
    final data = jsonDecode(resp.body);
    if (resp.statusCode != 200 || data['ok'] != true) {
      throw Exception(data['error'] ?? 'Error al obtener mascotas');
    }
    return data['data'] as List<dynamic>;
  }

  static Future<List<dynamic>> getEspecies() async {
    final h = await _headers();
    final resp = await http.get(Uri.parse('$_baseUrl/especies'), headers: h);
    final data = jsonDecode(resp.body);
    if (resp.statusCode != 200 || data['ok'] != true) {
      throw Exception(data['error'] ?? 'Error al obtener especies');
    }
    return data['data'] as List<dynamic>;
  }

  static Future<List<dynamic>> getRazas(int? especieId) async {
    final h = await _headers();
    String url = '$_baseUrl/razas';
    if (especieId != null) {
      url += '?especie_id=$especieId';
    }
    final resp = await http.get(Uri.parse(url), headers: h);
    final data = jsonDecode(resp.body);
    if (resp.statusCode != 200 || data['ok'] != true) {
      throw Exception(data['error'] ?? 'Error al obtener razas');
    }
    return data['data'] as List<dynamic>;
  }

  static Future<void> createPet(Map<String, dynamic> payload) async {
    final h = await _headers();
    final resp = await http.post(Uri.parse(_baseUrl),
        headers: h, body: jsonEncode(payload));
    final data = jsonDecode(resp.body);
    if (resp.statusCode != 200 && resp.statusCode != 201 || data['ok'] != true) {
      throw Exception(data['error'] ?? 'Error al crear mascota');
    }
  }

  static Future<List<dynamic>> getAllPets() async {
    final h = await _headers();
    final resp = await http.get(Uri.parse('$_baseUrl/all'), headers: h);
    final data = jsonDecode(resp.body);
    if (resp.statusCode != 200 || data['ok'] != true) {
      throw Exception(data['error'] ?? 'Error al obtener todas las mascotas');
    }
    return data['data'] as List<dynamic>;
  }

  static Future<dynamic> getPetById(int id) async {
    final h = await _headers();
    final resp = await http.get(Uri.parse('$_baseUrl/$id'), headers: h);
    final data = jsonDecode(resp.body);
    if (resp.statusCode != 200 || data['ok'] != true) {
      throw Exception(data['error'] ?? 'Error al obtener mascota');
    }
    return data['data'];
  }

  static Future<void> deletePet(int id) async {
    final h = await _headers();
    final resp = await http.delete(Uri.parse('$_baseUrl/$id'), headers: h);
    final data = jsonDecode(resp.body);
    if (resp.statusCode != 200 || data['ok'] != true) {
      throw Exception(data['error'] ?? 'Error al eliminar mascota');
    }
  }
}

