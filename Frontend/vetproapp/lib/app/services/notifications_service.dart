import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import '../config/api_config.dart';

class NotificationsService {
  static const String _baseUrl = ApiConfig.baseUrl;

  static Future<Map<String, String>> _headers() async {
    final token = await AuthService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<List<dynamic>> getNotifications() async {
    final h = await _headers();
    final resp = await http.get(
      Uri.parse('$_baseUrl/notifications'),
      headers: h,
    );
    final data = jsonDecode(resp.body);
    if (resp.statusCode != 200 || data['ok'] != true) {
      throw Exception(data['error'] ?? 'Error al obtener notificaciones');
    }
    return data['data'] as List<dynamic>;
  }

  static Future<int> getUnreadCount() async {
    final h = await _headers();
    final resp = await http.get(
      Uri.parse('$_baseUrl/notifications/unread-count'),
      headers: h,
    );
    final data = jsonDecode(resp.body);
    if (resp.statusCode != 200 || data['ok'] != true) {
      throw Exception(data['error'] ?? 'Error al obtener contador');
    }
    return data['data']['count'] as int;
  }

  static Future<void> markAsRead(int notificationId) async {
    final h = await _headers();
    final resp = await http.patch(
      Uri.parse('$_baseUrl/notifications/$notificationId/read'),
      headers: h,
    );
    final data = jsonDecode(resp.body);
    if (resp.statusCode != 200 || data['ok'] != true) {
      throw Exception(data['error'] ?? 'Error al marcar como leída');
    }
  }

  static Future<void> markAllAsRead() async {
    final h = await _headers();
    final resp = await http.patch(
      Uri.parse('$_baseUrl/notifications/mark-all-read'),
      headers: h,
    );
    final data = jsonDecode(resp.body);
    if (resp.statusCode != 200 || data['ok'] != true) {
      throw Exception(data['error'] ?? 'Error al marcar todas como leídas');
    }
  }

  static Future<void> deleteNotification(int notificationId) async {
    final h = await _headers();
    final resp = await http.delete(
      Uri.parse('$_baseUrl/notifications/$notificationId'),
      headers: h,
    );
    final data = jsonDecode(resp.body);
    if (resp.statusCode != 200 || data['ok'] != true) {
      throw Exception(data['error'] ?? 'Error al eliminar notificación');
    }
  }
}
