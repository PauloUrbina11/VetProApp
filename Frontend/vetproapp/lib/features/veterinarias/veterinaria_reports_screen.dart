import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../app/config/theme.dart';
import '../../app/services/permissions_service.dart';
import '../../app/services/auth_service.dart';
import '../../app/services/veterinaria_service.dart';

class VeterinariaReportsScreen extends StatefulWidget {
  const VeterinariaReportsScreen({super.key});

  @override
  State<VeterinariaReportsScreen> createState() =>
      _VeterinariaReportsScreenState();
}

class _VeterinariaReportsScreenState extends State<VeterinariaReportsScreen> {
  bool _loading = true;
  bool _canView = false;
  Map<String, dynamic>? _stats;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final role = await AuthService.getRole();
    if (role == 2) {
      await PermissionsService.loadVeterinariaRoles();
      setState(() {
        _canView = PermissionsService.canViewReports();
      });
    }

    if (_canView) {
      _loadStats();
    } else {
      setState(() => _loading = false);
    }
  }

  Future<void> _loadStats() async {
    setState(() => _loading = true);

    try {
      final veterinariaIds = await VeterinariaService.getMyVeterinarias();
      if (veterinariaIds.isEmpty) {
        throw Exception('No se pudo obtener el ID de la veterinaria');
      }

      final veterinariaId = veterinariaIds[0];
      final token = await AuthService.getToken();
      final url = Uri.parse(
          'http://10.0.2.2:4000/api/veterinarias/$veterinariaId/stats');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _stats = data['data'] as Map<String, dynamic>?;
        });
      } else {
        throw Exception('Error al cargar estadísticas');
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
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mint,
      appBar: AppBar(
        title: const Text(
          'Reportes',
          style: TextStyle(
            color: darkGreen,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: mint,
        foregroundColor: darkGreen,
        elevation: 0,
        iconTheme: const IconThemeData(color: darkGreen),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: softGreen))
          : !_canView
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock_outline,
                          size: 64, color: darkGreen.withOpacity(0.5)),
                      const SizedBox(height: 16),
                      const Text(
                        'No tienes permisos para ver reportes',
                        style: TextStyle(
                          color: darkGreen,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadStats,
                  color: softGreen,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Estados de Citas',
                          style: TextStyle(
                            color: darkGreen,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildStatCard(
                          'Confirmadas',
                          '${_stats?['citas_confirmadas'] ?? 0}',
                          Icons.check,
                          Colors.blue,
                        ),
                        _buildStatCard(
                          'Canceladas',
                          '${_stats?['citas_canceladas'] ?? 0}',
                          Icons.cancel,
                          Colors.red,
                        ),
                        _buildStatCard(
                          'No Asistió',
                          '${_stats?['citas_no_asistio'] ?? 0}',
                          Icons.block,
                          Colors.grey,
                        ),
                        _buildStatCard(
                          'Tasa de Éxito',
                          '${_stats?['tasa_completada'] ?? 0}%',
                          Icons.trending_up,
                          Colors.green,
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Métricas del Mes Actual',
                          style: TextStyle(
                            color: darkGreen,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildStatCard(
                          'Citas del Mes',
                          '${_stats?['citas_mes_actual'] ?? 0}',
                          Icons.calendar_month,
                          Colors.purple,
                        ),
                        _buildStatCard(
                          'Pacientes Nuevos',
                          '${_stats?['pacientes_nuevos_mes'] ?? 0}',
                          Icons.pets,
                          Colors.teal,
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Próximamente',
                          style: TextStyle(
                            color: darkGreen,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            '• Gráficos de citas por mes\n'
                            '• Ingresos detallados\n'
                            '• Reportes por servicio\n'
                            '• Exportar a PDF/Excel',
                            style: TextStyle(
                              color: darkGreen,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: darkGreen.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
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
                  style: TextStyle(
                    color: darkGreen.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: darkGreen,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
