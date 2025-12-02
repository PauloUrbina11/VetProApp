import 'package:flutter/material.dart';
import '../../app/config/theme.dart';
import '../../app/services/auth_service.dart';
import '../../app/services/veterinaria_service.dart';
import '../../app/services/notifications_service.dart';
import '../../app/utils/snackbar_helper.dart';
import '../veterinarias/manage_services_screen.dart';

// Modelo para items del menú
class MenuItem {
  final IconData icon;
  final String title;
  final String route;
  final VoidCallback? customAction;

  const MenuItem({
    required this.icon,
    required this.title,
    required this.route,
    this.customAction,
  });
}

class ProfileMenuScreen extends StatefulWidget {
  const ProfileMenuScreen({super.key});

  @override
  State<ProfileMenuScreen> createState() => _ProfileMenuScreenState();
}

class _ProfileMenuScreenState extends State<ProfileMenuScreen> {
  int? _userRole;
  List<int> _veterinariaRoles = [];
  int? _veterinariaId;
  bool _loading = true;
  int _unreadNotificationsCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final role = await AuthService.getRole();
    setState(() => _userRole = role);

    if (role == 2) {
      try {
        final veterinariaIds = await VeterinariaService.getMyVeterinarias();
        if (veterinariaIds.isNotEmpty) {
          _veterinariaId = veterinariaIds[0];
          final roles =
              await VeterinariaService.getMyVeterinariaRoles(_veterinariaId!);
          setState(() => _veterinariaRoles = roles);
        }
      } catch (e) {
        debugPrint('Error cargando roles: $e');
      }
    }

    // Cargar contador de notificaciones
    try {
      final count = await NotificationsService.getUnreadCount();
      setState(() => _unreadNotificationsCount = count);
    } catch (e) {
      debugPrint('Error cargando notificaciones: $e');
    }

    setState(() => _loading = false);
  }

  bool _hasRole(int roleId) => _veterinariaRoles.contains(roleId);

  Future<void> _navigateToManageServices() async {
    try {
      final veterinariaIds = await VeterinariaService.getMyVeterinarias();
      if (veterinariaIds.isEmpty) {
        if (mounted) {
          SnackBarHelper.showWarning(
            context,
            'No tienes una veterinaria asignada',
          );
        }
        return;
      }

      final veterinariaId = veterinariaIds[0];
      if (mounted) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ManageServicesScreen(
              veterinariaId: veterinariaId,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        SnackBarHelper.showError(
          context,
          e.toString().replaceAll('Exception: ', ''),
        );
      }
    }
  }

  // Definición de menús por rol
  List<MenuItem> _getMenuItemsForRole() {
    final items = <MenuItem>[
      const MenuItem(
        icon: Icons.person,
        title: 'Mi perfil',
        route: '/profile',
      ),
    ];

    if (_userRole == 1) {
      // Administrador global
      items.addAll([
        const MenuItem(
          icon: Icons.medical_services,
          title: 'Veterinarias',
          route: '/veterinarias',
        ),
        const MenuItem(
          icon: Icons.people,
          title: 'Usuarios globales',
          route: '/admin/users',
        ),
        const MenuItem(
          icon: Icons.bar_chart,
          title: 'Reportes del sistema',
          route: '/admin/reports',
        ),
        const MenuItem(
          icon: Icons.calendar_month,
          title: 'Agenda',
          route: '/admin/schedule',
        ),
      ]);
    } else if (_userRole == 3) {
      // Dueño de mascotas
      items.addAll([
        const MenuItem(
          icon: Icons.pets,
          title: 'Mis mascotas',
          route: '/my_pets',
        ),
        const MenuItem(
          icon: Icons.medical_services,
          title: 'Veterinarias',
          route: '/veterinarias',
        ),
        const MenuItem(
          icon: Icons.calendar_today,
          title: 'Mis citas',
          route: '/my_appointments',
        ),
      ]);
    } else if (_userRole == 2) {
      // Usuarios de veterinaria - menú según veterinaria_roles
      items.addAll(_getVeterinariaMenuItems());
    }

    // Notificaciones común a todos
    items.add(
      const MenuItem(
        icon: Icons.notifications,
        title: 'Notificaciones',
        route: '/notifications',
      ),
    );

    return items;
  }

  List<MenuItem> _getVeterinariaMenuItems() {
    // Administrador de veterinaria (rol 1)
    if (_hasRole(1)) {
      return [
        const MenuItem(
          icon: Icons.calendar_month,
          title: 'Agenda',
          route: '/schedule',
        ),
        const MenuItem(
          icon: Icons.medical_services,
          title: 'Gestión de citas',
          route: '/manage_appointments',
        ),
        const MenuItem(
          icon: Icons.pets,
          title: 'Pacientes',
          route: '/veterinaria/patients',
        ),
        MenuItem(
          icon: Icons.miscellaneous_services,
          title: 'Gestión de servicios',
          route: '',
          customAction: _navigateToManageServices,
        ),
        const MenuItem(
          icon: Icons.mode,
          title: 'Gestión de veterinaria',
          route: '/manage_veterinaria',
        ),
        const MenuItem(
          icon: Icons.bar_chart,
          title: 'Reportes',
          route: '/veterinaria/reports',
        ),
      ];
    }

    // Roles 2-6 (Veterinario, Auxiliar, Recepcionista, Groomer, Especialista)
    // Todos tienen el mismo menú básico
    if (_hasRole(2) ||
        _hasRole(3) ||
        _hasRole(4) ||
        _hasRole(5) ||
        _hasRole(6)) {
      return [
        const MenuItem(
          icon: Icons.calendar_month,
          title: 'Agenda',
          route: '/schedule',
        ),
        const MenuItem(
          icon: Icons.medical_services,
          title: 'Gestión de citas',
          route: '/manage_appointments',
        ),
        const MenuItem(
          icon: Icons.pets,
          title: 'Pacientes',
          route: '/veterinaria/patients',
        ),
        MenuItem(
          icon: Icons.miscellaneous_services,
          title: 'Servicios',
          route: '',
          customAction: _navigateToManageServices,
        ),
      ];
    }

    return [];
  }

  Widget _buildCard(MenuItem item) {
    final isNotifications = item.route == '/notifications';
    final showBadge = isNotifications && _unreadNotificationsCount > 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Card(
        color: lightGreen,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: ListTile(
          leading: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(item.icon, color: darkGreen),
              if (showBadge)
                Positioned(
                  right: -8,
                  top: -4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      _unreadNotificationsCount > 99
                          ? '99+'
                          : _unreadNotificationsCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          title: Text(
            item.title,
            style: const TextStyle(
              color: darkGreen,
              fontWeight: FontWeight.w600,
            ),
          ),
          trailing: const Icon(Icons.chevron_right, color: darkGreen),
          onTap: () async {
            debugPrint('MenuItem tapped: ${item.title}, route: ${item.route}');
            if (item.customAction != null) {
              debugPrint('Executing custom action for ${item.title}');
              item.customAction!();
            } else if (item.route.isNotEmpty) {
              debugPrint('Navigating to route: ${item.route}');
              try {
                // Primero cerramos el ProfileMenuScreen
                Navigator.of(context).pop();
                // Esperamos un frame para que se complete el pop
                await Future.delayed(const Duration(milliseconds: 100));
                // Luego navegamos a la ruta deseada usando el Navigator.of(context) del HomeScreen
                if (context.mounted) {
                  Navigator.of(context).pushNamed(item.route);
                }
              } catch (error) {
                debugPrint('Navigation error: $error');
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error al navegar: $error'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Menu')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final menuItems = _getMenuItemsForRole();

    return Scaffold(
      appBar: AppBar(title: const Text('Menu')),
      body: ListView.builder(
        itemCount: menuItems.length + 2, // +2 para espacios
        itemBuilder: (context, index) {
          if (index == 0) return const SizedBox(height: 8);
          if (index == menuItems.length + 1) return const SizedBox(height: 16);
          return _buildCard(menuItems[index - 1]);
        },
      ),
    );
  }
}
