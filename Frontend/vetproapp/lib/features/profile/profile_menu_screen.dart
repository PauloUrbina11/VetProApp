import 'package:flutter/material.dart';
import '../../../app/config/theme.dart';
import '../../../app/services/auth_service.dart';

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

  Widget _buildCard(BuildContext context,
      {required IconData icon,
      required String title,
      required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Card(
        color: vetproGreen,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: ListTile(
          leading: Icon(icon, color: Colors.white),
          title: Text(title,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w600)),
          trailing: const Icon(Icons.chevron_right, color: Colors.white),
          onTap: onTap,
        ),
      ),
    );
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
            icon: Icons.admin_panel_settings,
            title: 'Panel de administración',
            onTap: () => Navigator.pushNamed(context, '/home')),
        _buildCard(context,
            icon: Icons.add_business,
            title: 'Crear Veterinaria',
            onTap: () => Navigator.pushNamed(context, '/create_veterinaria')),
        _buildCard(context,
            icon: Icons.security,
            title: 'Asignar Roles Usuarios',
            onTap: () => Navigator.pushNamed(context, '/manage_roles')),
        _buildCard(context,
            icon: Icons.local_hospital,
            title: 'Gestión de veterinarias',
            onTap: () => Navigator.pushNamed(context, '/create_veterinaria')),
        _buildCard(context,
            icon: Icons.pets,
            title: 'Mis mascotas',
            onTap: () => Navigator.pushNamed(context, '/my_pets')),
        _buildCard(context,
            icon: Icons.calendar_today,
            title: 'Mis citas',
            onTap: () => Navigator.pushNamed(context, '/my_appointments')),
        _buildCard(context,
            icon: Icons.calendar_month,
            title: 'Agenda',
            onTap: () => Navigator.pushNamed(context, '/schedule')),
        _buildCard(context,
            icon: Icons.medical_services,
            title: 'Gestión de citas',
            onTap: () => Navigator.pushNamed(context, '/manage_appointments')),
        _buildCard(context,
            icon: Icons.miscellaneous_services,
            title: 'Gestión de servicios',
            onTap: () => Navigator.pushNamed(context, '/manage_services')),
        _buildCard(context,
            icon: Icons.thumb_up,
            title: 'Recomendaciones',
            onTap: () => Navigator.pushNamed(context, '/recommendations')),
      ]);
    } else if (_userRole == 3) {
      // Rol 3: Dueño de mascotas
      cards.addAll([
        _buildCard(context,
            icon: Icons.pets,
            title: 'Mis mascotas',
            onTap: () => Navigator.pushNamed(context, '/my_pets')),
        _buildCard(context,
            icon: Icons.calendar_today,
            title: 'Mis citas',
            onTap: () => Navigator.pushNamed(context, '/my_appointments')),
        _buildCard(context,
            icon: Icons.thumb_up,
            title: 'Recomendaciones',
            onTap: () => Navigator.pushNamed(context, '/recommendations')),
      ]);
    } else if (_userRole == 2) {
      // Rol 2: Veterinaria/Clínica
      cards.addAll([
        _buildCard(context,
            icon: Icons.calendar_month,
            title: 'Agenda',
            onTap: () => Navigator.pushNamed(context, '/schedule')),
        _buildCard(context,
            icon: Icons.medical_services,
            title: 'Gestión de citas',
            onTap: () => Navigator.pushNamed(context, '/manage_appointments')),
        _buildCard(context,
            icon: Icons.miscellaneous_services,
            title: 'Gestión de servicios',
            onTap: () => Navigator.pushNamed(context, '/manage_services')),
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
          : ListView(
              children: _buildMenuCards(),
            ),
    );
  }
}
