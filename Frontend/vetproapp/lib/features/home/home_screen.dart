import 'package:flutter/material.dart';
import '../../app/services/auth_service.dart';
import '../../app/services/user_service.dart';
import '../../app/services/veterinaria_service.dart';
import 'views/admin_home_view.dart';
import 'views/veterinary_home_view.dart';
import 'views/pet_owner_home_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  int? _userRole;
  bool _loading = true;
  String? _userName;
  String? _veterinariaNombre;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadUserRole();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Recargar datos cuando la app vuelve a estar en primer plano
      _reloadAllData();
    }
  }

  Future<void> _refreshUserName() async {
    try {
      final profile = await UserService.getMyProfile();
      if (mounted && profile != null) {
        setState(() {
          _userName = profile['nombre_completo'];
        });
      }
    } catch (e) {
      // Silenciar
    }
  }

  Future<void> _reloadAllData() async {
    await _refreshUserName();
    if (_userRole == 2) {
      await _loadVeterinariaName();
    }
  }

  Future<void> _loadUserRole() async {
    try {
      final role = await AuthService.getRole();
      setState(() => _userRole = role);

      // Cargar nombre de perfil
      final profile = await UserService.getMyProfile();
      setState(() => _userName = profile?['nombre_completo']);

      // Si es veterinaria, cargar nombre de la veterinaria
      if (role == 2) {
        await _loadVeterinariaName();
      }
    } catch (e) {
      // Silenciar
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _loadVeterinariaName() async {
    try {
      final vets = await VeterinariaService.getMyVeterinarias();
      if (vets.isNotEmpty) {
        final veterinariaId = vets.first;
        final vetInfo = await VeterinariaService.getVeterinaria(veterinariaId);
        setState(() {
          _veterinariaNombre = vetInfo['nombre'] as String?;
        });
      }
    } catch (e) {
      // Silenciar
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Selector de vista según rol
    // Rol 1 = Admin, Rol 2 = Veterinaria, Rol 3 = Dueño de mascota
    if (_userRole == 1) {
      return AdminHomeView(
        userName: _userName,
        onDataReload: _reloadAllData,
      );
    } else if (_userRole == 2) {
      return VeterinaryHomeView(
        userName: _userName,
        veterinariaNombre: _veterinariaNombre,
        onDataReload: _reloadAllData,
      );
    } else {
      return PetOwnerHomeView(
        userName: _userName,
        onDataReload: _reloadAllData,
      );
    }
  }
}
