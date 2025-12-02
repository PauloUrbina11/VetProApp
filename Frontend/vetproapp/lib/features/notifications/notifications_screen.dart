import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../app/config/theme.dart';
import '../../app/services/notifications_service.dart';
import '../../app/services/auth_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<dynamic> _notifications = [];
  bool _loading = true;
  String? _error;
  int? _userRole;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
    _loadNotifications();
  }

  Future<void> _loadUserRole() async {
    final role = await AuthService.getRole();
    setState(() => _userRole = role);
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final notifications = await NotificationsService.getNotifications();
      setState(() {
        _notifications = notifications;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _markAsRead(dynamic notification) async {
    if (notification['leida'] == true) return;

    try {
      await NotificationsService.markAsRead(notification['id']);
      setState(() {
        final index =
            _notifications.indexWhere((n) => n['id'] == notification['id']);
        if (index != -1) {
          _notifications[index]['leida'] = true;
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Error: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _navigateToReference(dynamic notification) async {
    final referenciaTipo = notification['referencia_tipo'] as String?;

    // Marcar como leída
    await _markAsRead(notification);

    if (!mounted || referenciaTipo == null) return;

    String? route;

    switch (referenciaTipo) {
      case 'cita':
        route = _userRole == 2 ? '/manage_appointments' : '/my_appointments';
        break;
      case 'historial_medico':
        route = _userRole == 2 ? '/veterinaria/patients' : '/my_pets';
        break;
      case 'recomendacion':
        route = '/recommendations';
        break;
      case 'seguridad':
        route = '/profile';
        break;
    }

    if (route != null) {
      try {
        Navigator.of(context).pushNamed(route);
      } catch (e) {
        debugPrint('Error al navegar a $route: $e');
      }
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      await NotificationsService.markAllAsRead();
      setState(() {
        for (var notification in _notifications) {
          notification['leida'] = true;
        }
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Todas las notificaciones marcadas como leídas'),
            backgroundColor: softGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Error: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteNotification(int notificationId) async {
    try {
      await NotificationsService.deleteNotification(notificationId);
      setState(() {
        _notifications.removeWhere((n) => n['id'] == notificationId);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notificación eliminada'),
            backgroundColor: softGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Error: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Color _getTypeColor(String? tipo) {
    switch (tipo) {
      case 'success':
        return Colors.green;
      case 'warning':
        return Colors.orange;
      case 'error':
        return Colors.red;
      case 'info':
      default:
        return Colors.blue;
    }
  }

  IconData _getTypeIcon(String? tipo) {
    switch (tipo) {
      case 'success':
        return Icons.check_circle;
      case 'warning':
        return Icons.warning;
      case 'error':
        return Icons.error;
      case 'info':
      default:
        return Icons.info;
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr).toLocal();
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inMinutes < 1) {
        return 'Ahora';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes} min';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}h';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}d';
      } else {
        return DateFormat('dd/MM/yyyy').format(date);
      }
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = _notifications.where((n) => n['leida'] == false).length;

    return Scaffold(
      backgroundColor: mint,
      appBar: AppBar(
        title: const Text(
          'Notificaciones',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: softGreen,
        elevation: 0,
        actions: [
          if (unreadCount > 0)
            IconButton(
              icon: const Icon(Icons.done_all),
              onPressed: _markAllAsRead,
              tooltip: 'Marcar todas como leídas',
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: softGreen))
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline,
                          size: 64, color: Colors.red[300]),
                      const SizedBox(height: 16),
                      Text(
                        _error!,
                        style: const TextStyle(color: darkGreen),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadNotifications,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: softGreen,
                        ),
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    if (unreadCount > 0)
                      Container(
                        padding: const EdgeInsets.all(12),
                        color: lightGreen.withOpacity(0.3),
                        child: Row(
                          children: [
                            const Icon(Icons.notifications_active,
                                color: darkGreen, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Tienes $unreadCount notificación${unreadCount > 1 ? 'es' : ''} sin leer',
                              style: const TextStyle(
                                color: darkGreen,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _loadNotifications,
                        color: softGreen,
                        child: _notifications.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.notifications_none,
                                      size: 64,
                                      color: darkGreen.withOpacity(0.3),
                                    ),
                                    const SizedBox(height: 16),
                                    const Text(
                                      'No tienes notificaciones',
                                      style: TextStyle(
                                        color: darkGreen,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: _notifications.length,
                                itemBuilder: (context, index) {
                                  final notification = _notifications[index];
                                  return _buildNotificationCard(
                                    notification,
                                    onTap: () =>
                                        _navigateToReference(notification),
                                  );
                                },
                              ),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildNotificationCard(dynamic notification, {VoidCallback? onTap}) {
    final isRead = notification['leida'] == true;
    final tipo = notification['tipo'] as String?;
    final typeColor = _getTypeColor(tipo);
    final typeIcon = _getTypeIcon(tipo);

    return Dismissible(
      key: Key(notification['id'].toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: white),
      ),
      onDismissed: (direction) {
        _deleteNotification(notification['id']);
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: isRead ? 1 : 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: isRead
              ? BorderSide.none
              : BorderSide(color: typeColor.withOpacity(0.3), width: 2),
        ),
        color: isRead ? white : typeColor.withOpacity(0.05),
        child: InkWell(
          onTap: () {
            if (onTap != null) {
              onTap();
            } else {
              _markAsRead(notification);
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: typeColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(typeIcon, color: typeColor, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification['titulo'] ?? 'Sin título',
                              style: TextStyle(
                                fontWeight: isRead
                                    ? FontWeight.normal
                                    : FontWeight.bold,
                                fontSize: 16,
                                color: darkGreen,
                              ),
                            ),
                          ),
                          if (!isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: typeColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification['mensaje'] ?? '',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatDate(notification['created_at']),
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
