import 'package:flutter/material.dart';
import '../../../app/config/theme.dart';
import '../../../app/services/admin_service.dart';
import '../../profile/profile_menu_screen.dart';

class AdminHomeView extends StatefulWidget {
  final String? userName;
  final VoidCallback onDataReload;

  const AdminHomeView({
    super.key,
    this.userName,
    required this.onDataReload,
  });

  @override
  State<AdminHomeView> createState() => _AdminHomeViewState();
}

class _AdminHomeViewState extends State<AdminHomeView> {
  Map<String, dynamic>? _globalStats;
  List<dynamic> _recentActivity = [];

  @override
  void initState() {
    super.initState();
    _loadAdminData();
  }

  @override
  void didUpdateWidget(AdminHomeView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Recargar datos cuando el widget se actualiza
    _loadAdminData();
  }

  Future<void> _loadAdminData() async {
    try {
      final stats = await AdminService.getGlobalStats();
      final activity = await AdminService.getRecentActivity();
      setState(() {
        _globalStats = stats;
        _recentActivity = activity;
      });
    } catch (e) {
      // Silenciar
    }
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'person_add':
        return Icons.person_add;
      case 'add_business':
        return Icons.add_business;
      case 'event_available':
        return Icons.event_available;
      default:
        return Icons.event;
    }
  }

  Color _getColorFromString(String colorName) {
    switch (colorName) {
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'orange':
        return Colors.orange;
      case 'red':
        return Colors.red;
      case 'purple':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _formatTime(String? isoTime) {
    if (isoTime == null) return '';

    try {
      final dateTime = DateTime.parse(isoTime);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inMinutes < 1) {
        return 'Ahora';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes} min';
      } else if (difference.inHours < 24) {
        return '${difference.inHours} h';
      } else if (difference.inDays < 30) {
        return '${difference.inDays} d';
      } else {
        return '${(difference.inDays / 30).floor()} mes';
      }
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mint,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: settings, profile
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/settings');
                      },
                      icon: const Icon(Icons.settings),
                      color: vetproGreen,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Align(
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 260),
                              child: Text(
                                'Bienvenido/a',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: vetproGreen,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 200),
                              child: Text(
                                '${widget.userName ?? ''} 👋',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: vetproGreen.withOpacity(0.8),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    CircleAvatar(
                      backgroundColor: Colors.white,
                      child: IconButton(
                        onPressed: () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const ProfileMenuScreen(),
                            ),
                          );
                          widget.onDataReload();
                        },
                        icon: const Icon(Icons.person),
                        color: vetproGreen,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Estadísticas generales
                Text(
                  'Estadísticas Globales',
                  style: TextStyle(
                    color: vetproGreen,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                // Grid de estadísticas
                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1.5,
                  children: [
                    _buildStatCard(
                      'Usuarios',
                      '${_globalStats?['totalUsuarios'] ?? 0}',
                      Icons.people,
                      Colors.blue.shade400,
                    ),
                    _buildStatCard(
                      'Veterinarias',
                      '${_globalStats?['totalVeterinarias'] ?? 0}',
                      Icons.local_hospital,
                      Colors.green.shade400,
                    ),
                    _buildStatCard(
                      'Mascotas',
                      '${_globalStats?['totalMascotas'] ?? 0}',
                      Icons.pets,
                      Colors.orange.shade400,
                    ),
                    _buildStatCard(
                      'Citas Hoy',
                      '${_globalStats?['citasHoy'] ?? 0}',
                      Icons.calendar_today,
                      Colors.purple.shade400,
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Gestión rápida
                Text(
                  'Gestión Rápida',
                  style: TextStyle(
                    color: vetproGreen,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                _buildAdminActionCard(
                  'Asignar Roles',
                  'Asignar roles a usuarios de veterinarias',
                  Icons.security,
                  Colors.blue,
                  () => Navigator.pushNamed(context, '/manage_roles'),
                ),
                _buildAdminActionCard(
                  'Crear Veterinaria',
                  'Registrar nueva clínica y asociar usuario administrador',
                  Icons.add_business,
                  Colors.green,
                  () => Navigator.pushNamed(context, '/create_veterinaria'),
                ),
                _buildAdminActionCard(
                  'Gestión de Citas',
                  'Ver todas las citas del sistema',
                  Icons.calendar_month,
                  Colors.orange,
                  () => Navigator.pushNamed(context, '/manage_appointments'),
                ),
                _buildAdminActionCard(
                  'Gestión de Servicios',
                  'Administrar servicios disponibles',
                  Icons.miscellaneous_services,
                  Colors.purple,
                  () => Navigator.pushNamed(context, '/manage_services'),
                ),
                const SizedBox(height: 18),

                // Actividad reciente
                Text(
                  'Actividad Reciente',
                  style: TextStyle(
                    color: vetproGreen,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                if (_recentActivity.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        'No hay actividad reciente',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ),
                  )
                else
                  ..._recentActivity.map((activity) {
                    final iconData = _getIconData(activity['icon'] ?? 'event');
                    final color =
                        _getColorFromString(activity['color'] ?? 'blue');
                    final time = _formatTime(activity['time']);

                    return _buildActivityItem(
                      activity['title'] ?? 'Actividad',
                      activity['description'] ?? '',
                      time,
                      iconData,
                      color,
                    );
                  }),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminActionCard(String title, String description, IconData icon,
      Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: color.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(12),
          color: color.withOpacity(0.05),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: color),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(String title, String description, String time,
      IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
