import 'package:flutter/material.dart';
import '../../../app/config/theme.dart';
import '../../../app/services/auth_service.dart';
import '../../../app/services/veterinaria_service.dart';
import '../veterinarias/manage_services_screen.dart';

class ProfileMenuScreen extends StatefulWidget {
  const ProfileMenuScreen({super.key});

  @override
  State<ProfileMenuScreen> createState() => _ProfileMenuScreenState();
}

class _ProfileMenuScreenState extends State<ProfileMenuScreen> {
  int? _userRole;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    final role = await AuthService.getRole();
    setState(() {
      _userRole = role;
      _loading = false;
    });
  }

  Future<void> _navigateToManageServices() async {
    try {
      // Obtener la veterinaria del usuario logueado (rol 2)
      final veterinariaIds = await VeterinariaService.getMyVeterinarias();
      if (veterinariaIds.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No tienes una veterinaria asignada'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // Usar la primera veterinaria del usuario
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildCard(BuildContext context,
      {required IconData icon,
      required String title,
      required VoidCallback onTap}) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Card(
            color: lightGreen,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 2,
            child: ListTile(
                leading: Icon(icon, color: darkGreen),
                title: Text(title,
                    style: const TextStyle(
                        color: darkGreen, fontWeight: FontWeight.w600)),
                trailing: const Icon(Icons.chevron_right, color: darkGreen),
                onTap: onTap)));
  }

  List<Widget> _buildMenuCards() {
    final cards = <Widget>[
      const SizedBox(height: 8),
      _buildCard(context,
          icon: Icons.person,
          title: 'Mi perfil',
          onTap: () => Navigator.pushNamed(context, '/profile')),
    ];

    if (_userRole == 1) {
      // Rol 1: Administrador - Ve todo
      cards.addAll([
        _buildCard(context,
            icon: Icons.pets,
            title: 'Mis mascotas',
            onTap: () => Navigator.pushNamed(context, '/my_pets')),
        _buildCard(context,
            icon: Icons.medical_services,
            title: 'Veterinarias',
            onTap: () => Navigator.pushNamed(context, '/veterinarias')),
        _buildCard(context,
            icon: Icons.calendar_month,
            title: 'Agenda',
            onTap: () => Navigator.pushNamed(context, '/schedule')),
      ]);
    } else if (_userRole == 3) {
      // Rol 3: Dueño de mascotas
      cards.addAll([
        _buildCard(context,
            icon: Icons.pets,
            title: 'Mis mascotas',
            onTap: () => Navigator.pushNamed(context, '/my_pets')),
        _buildCard(context,
            icon: Icons.medical_services,
            title: 'Veterinarias',
            onTap: () => Navigator.pushNamed(context, '/veterinarias')),
        _buildCard(context,
            icon: Icons.calendar_today,
            title: 'Mis citas',
            onTap: () => Navigator.pushNamed(context, '/my_appointments')),
      ]);
    } else if (_userRole == 2) {
      // Rol 2: Veterinaria/Clínica
      cards.addAll([
        _buildCard(context,
            icon: Icons.calendar_month,
            title: 'Agenda',
            onTap: () => Navigator.pushNamed(context, '/schedule')),
        _buildCard(context,
            icon: Icons.mode,
            title: 'Gestión de veterinaria',
            onTap: () => Navigator.pushNamed(context, '/manage_veterinaria')),
        _buildCard(context,
            icon: Icons.medical_services,
            title: 'Gestión de citas',
            onTap: () => Navigator.pushNamed(context, '/manage_appointments')),
        _buildCard(context,
            icon: Icons.miscellaneous_services,
            title: 'Gestión de servicios',
            onTap: _navigateToManageServices),
      ]);
    }

    // Cards comunes a todos los roles
    cards.addAll([
      _buildCard(context,
          icon: Icons.notifications,
          title: 'Notificaciones',
          onTap: () => Navigator.pushNamed(context, '/notifications')),
      const SizedBox(height: 16),
    ]);

    return cards;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Perfil')),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(children: _buildMenuCards()));
  }
}
