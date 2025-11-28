import 'package:flutter/material.dart';
import '../../app/config/theme.dart';
import '../../app/services/auth_service.dart';
import '../../app/services/veterinaria_service.dart';
import 'veterinarias_screen.dart';

class ManageVeterinariaScreen extends StatefulWidget {
  const ManageVeterinariaScreen({super.key});

  @override
  State<ManageVeterinariaScreen> createState() =>
      _ManageVeterinariaScreenState();
}

class _ManageVeterinariaScreenState extends State<ManageVeterinariaScreen> {
  bool _loading = true;
  bool _isAuthorized = false;
  String? _error;
  Map<String, dynamic>? _veterinaria;

  @override
  void initState() {
    super.initState();
    _checkAuthorization();
  }

  Future<void> _checkAuthorization() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // Obtener el ID del usuario actual
      final userId = await AuthService.getUserId();
      if (userId == null) {
        setState(() {
          _error = 'Usuario no autenticado';
          _isAuthorized = false;
          _loading = false;
        });
        return;
      }

      // Obtener las veterinarias del usuario
      final veterinariaIds = await VeterinariaService.getMyVeterinarias();

      if (veterinariaIds.isEmpty) {
        setState(() {
          _error = 'No tienes una veterinaria asignada';
          _isAuthorized = false;
          _loading = false;
        });
        return;
      }

      // Tomar la primera veterinaria (por ahora asumimos que tiene una)
      final vetId = veterinariaIds.first;

      // Obtener los detalles de la veterinaria
      final veterinaria = await VeterinariaService.getVeterinaria(vetId);

      // Verificar si el usuario es el admin de esta veterinaria
      final isAdmin = veterinaria['user_admin_id'] == userId;

      if (!isAdmin) {
        setState(() {
          _error =
              'No estás autorizado para editar esta veterinaria.\nSolo el administrador puede realizar cambios.';
          _isAuthorized = false;
          _loading = false;
        });
        return;
      }

      // Si llegamos aquí, el usuario está autorizado
      setState(() {
        _veterinaria = veterinaria;
        _isAuthorized = true;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error al verificar autorización: $e';
        _isAuthorized = false;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mint,
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: softGreen))
          : !_isAuthorized
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.lock_outline,
                          size: 80,
                          color: darkGreen.withOpacity(0.5)),
                        const SizedBox(height: 24),
                        Text(
                          'Acceso no autorizado',
                          style: TextStyle(
                            color: darkGreen,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        Text(
                          _error ??
                              'No tienes permisos para acceder a esta sección',
                          style: TextStyle(
                            color: darkGreen.withOpacity(0.8),
                            fontSize: 14),
                          textAlign: TextAlign.center),
                        const SizedBox(height: 32),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: softGreen,
                            foregroundColor: white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12))),
                          child: const Text(
                            'Volver',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold))),
                      ])))
              : EditVeterinariaScreen(veterinaria: _veterinaria!));
  }
}
