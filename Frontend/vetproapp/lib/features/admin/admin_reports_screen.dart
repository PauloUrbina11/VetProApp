import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../app/config/theme.dart';
import '../../app/services/admin_service.dart';
import '../../app/services/pets_service.dart';

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
  bool _loading = true;
  Map<String, dynamic> _stats = {};

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _loading = true);

    try {
      // Cargar datos
      final users = await AdminService.listUsers();
      final veterinarias = await AdminService.listVeterinarias();
      final appointments = await AdminService.getAllAppointments();
      final especies = await PetsService.getEspecies();

      // Calcular estadísticas
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final startOfLastMonth = DateTime(now.year, now.month - 1, 1);
      final endOfLastMonth = DateTime(now.year, now.month, 0);

      // Citas por estado
      final pendientes =
          appointments.where((apt) => apt['estado_id'] == 1).length;
      final confirmadas =
          appointments.where((apt) => apt['estado_id'] == 2).length;
      final completadas =
          appointments.where((apt) => apt['estado_id'] == 3).length;
      final canceladas =
          appointments.where((apt) => apt['estado_id'] == 4).length;
      final noAsistio =
          appointments.where((apt) => apt['estado_id'] == 5).length;

      // Citas este mes
      final citasEsteMes = appointments.where((apt) {
        try {
          final fecha = DateTime.parse(apt['fecha_hora']).toLocal();
          return fecha.isAfter(startOfMonth) ||
              fecha.isAtSameMomentAs(startOfMonth);
        } catch (e) {
          return false;
        }
      }).length;

      // Citas mes pasado
      final citasMesPasado = appointments.where((apt) {
        try {
          final fecha = DateTime.parse(apt['fecha_hora']).toLocal();
          return fecha.isAfter(startOfLastMonth) &&
              fecha.isBefore(endOfLastMonth.add(const Duration(days: 1)));
        } catch (e) {
          return false;
        }
      }).length;

      // Usuarios nuevos este mes
      final usuariosEsteMes = users.where((u) {
        try {
          if (u['created_at'] == null) return false;
          final fecha = DateTime.parse(u['created_at']);
          return fecha.isAfter(startOfMonth);
        } catch (e) {
          return false;
        }
      }).length;

      // Tasa de completado
      final totalCitas = appointments.length;
      final tasaCompletado = totalCitas > 0
          ? ((completadas / totalCitas) * 100).toStringAsFixed(1)
          : '0.0';

      // Tasa de cancelación
      final tasaCancelacion = totalCitas > 0
          ? ((canceladas / totalCitas) * 100).toStringAsFixed(1)
          : '0.0';

      setState(() {
        _stats = {
          'totalUsers': users.length,
          'totalVeterinarias': veterinarias.length,
          'totalAppointments': appointments.length,
          'totalEspecies': especies.length,
          'pendientes': pendientes,
          'confirmadas': confirmadas,
          'completadas': completadas,
          'canceladas': canceladas,
          'noAsistio': noAsistio,
          'citasEsteMes': citasEsteMes,
          'citasMesPasado': citasMesPasado,
          'usuariosEsteMes': usuariosEsteMes,
          'tasaCompletado': tasaCompletado,
          'tasaCancelacion': tasaCancelacion,
          'crecimientoCitas': citasMesPasado > 0
              ? (((citasEsteMes - citasMesPasado) / citasMesPasado) * 100)
                  .toStringAsFixed(1)
              : '0.0',
        };
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
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
          'Reportes del Sistema',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: softGreen,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStats,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: softGreen))
          : RefreshIndicator(
              onRefresh: _loadStats,
              color: softGreen,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Fecha del reporte
                    Text(
                      'Reporte generado: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
                      style: TextStyle(
                        color: darkGreen.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Resumen General
                    _buildSectionTitle('Resumen General'),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Usuarios',
                            _stats['totalUsers'].toString(),
                            Icons.people,
                            darkGreen,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            'Veterinarias',
                            _stats['totalVeterinarias'].toString(),
                            Icons.store,
                            softGreen,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Total Citas',
                            _stats['totalAppointments'].toString(),
                            Icons.calendar_today,
                            Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            'Especies',
                            _stats['totalEspecies'].toString(),
                            Icons.pets,
                            Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Estado de Citas
                    _buildSectionTitle('Distribución de Citas por Estado'),
                    const SizedBox(height: 12),
                    _buildProgressCard(
                      'Completadas',
                      _stats['completadas'],
                      _stats['totalAppointments'],
                      Colors.green,
                    ),
                    const SizedBox(height: 8),
                    _buildProgressCard(
                      'Confirmadas',
                      _stats['confirmadas'],
                      _stats['totalAppointments'],
                      Colors.blue,
                    ),
                    const SizedBox(height: 8),
                    _buildProgressCard(
                      'Pendientes',
                      _stats['pendientes'],
                      _stats['totalAppointments'],
                      Colors.orange,
                    ),
                    const SizedBox(height: 8),
                    _buildProgressCard(
                      'Canceladas',
                      _stats['canceladas'],
                      _stats['totalAppointments'],
                      Colors.red,
                    ),
                    const SizedBox(height: 8),
                    _buildProgressCard(
                      'No Asistió',
                      _stats['noAsistio'],
                      _stats['totalAppointments'],
                      Colors.grey,
                    ),
                    const SizedBox(height: 32),

                    // Métricas de Rendimiento
                    _buildSectionTitle('Métricas de Rendimiento'),
                    const SizedBox(height: 12),
                    _buildMetricCard(
                      'Tasa de Completado',
                      '${_stats['tasaCompletado']}%',
                      'Porcentaje de citas completadas exitosamente',
                      Colors.green,
                      Icons.check_circle,
                    ),
                    const SizedBox(height: 12),
                    _buildMetricCard(
                      'Tasa de Cancelación',
                      '${_stats['tasaCancelacion']}%',
                      'Porcentaje de citas canceladas',
                      Colors.red,
                      Icons.cancel,
                    ),
                    const SizedBox(height: 32),

                    // Tendencias
                    _buildSectionTitle('Tendencias Mensuales'),
                    const SizedBox(height: 12),
                    _buildTrendCard(
                      'Citas Este Mes',
                      _stats['citasEsteMes'].toString(),
                      'Mes Anterior: ${_stats['citasMesPasado']}',
                      double.parse(_stats['crecimientoCitas']),
                    ),
                    const SizedBox(height: 12),
                    _buildMetricCard(
                      'Usuarios Nuevos Este Mes',
                      _stats['usuariosEsteMes'].toString(),
                      'Registros en el mes actual',
                      Colors.blue,
                      Icons.person_add,
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: darkGreen,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Container(
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
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: darkGreen.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(String label, int value, int total, Color color) {
    final percentage = total > 0 ? (value / total) : 0.0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: darkGreen.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: darkGreen,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '$value / $total',
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: color.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
      String title, String value, String subtitle, Color color, IconData icon) {
    return Container(
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
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: darkGreen,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendCard(
      String title, String value, String subtitle, double growth) {
    final isPositive = growth >= 0;
    final growthColor = isPositive ? Colors.green : Colors.red;
    final growthIcon = isPositive ? Icons.trending_up : Icons.trending_down;

    return Container(
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: darkGreen,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: darkGreen,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: growthColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(growthIcon, color: growthColor, size: 20),
                const SizedBox(width: 4),
                Text(
                  '${growth > 0 ? '+' : ''}$growth%',
                  style: TextStyle(
                    color: growthColor,
                    fontSize: 16,
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
