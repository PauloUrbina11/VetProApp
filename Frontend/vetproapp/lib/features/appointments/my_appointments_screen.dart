import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../app/config/theme.dart';
import '../../app/services/appointments_service.dart';

class MyAppointmentsScreen extends StatefulWidget {
  const MyAppointmentsScreen({super.key});

  @override
  State<MyAppointmentsScreen> createState() => _MyAppointmentsScreenState();
}

class _MyAppointmentsScreenState extends State<MyAppointmentsScreen> {
  bool _loading = true;
  List<Map<String, dynamic>> _allAppointments = [];
  String _selectedFilter = 'Todas';

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    setState(() => _loading = true);
    try {
      final citas = await AppointmentsService.getMyAppointments();
      _allAppointments = List<Map<String, dynamic>>.from(
          citas.map((c) => Map<String, dynamic>.from(c)));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar citas: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  List<Map<String, dynamic>> get _filteredAppointments {
    if (_selectedFilter == 'Todas') {
      return _allAppointments;
    }

    return _allAppointments.where((apt) {
      final estadoNombre =
          (apt['estado_nombre'] ?? '').toString().toLowerCase();
      return estadoNombre.contains(_selectedFilter.toLowerCase());
    }).toList();
  }

  List<Map<String, dynamic>> get _upcomingAppointments {
    final now = DateTime.now();
    return _filteredAppointments.where((apt) {
      final fechaHora = _parseLocalDate(apt['fecha_hora']);
      return fechaHora.isAfter(now);
    }).toList()
      ..sort((a, b) {
        final dateA = _parseLocalDate(a['fecha_hora']);
        final dateB = _parseLocalDate(b['fecha_hora']);
        return dateA.compareTo(dateB);
      });
  }

  List<Map<String, dynamic>> get _pastAppointments {
    final now = DateTime.now();
    return _filteredAppointments.where((apt) {
      final fechaHora = _parseLocalDate(apt['fecha_hora']);
      return fechaHora.isBefore(now) || fechaHora.isAtSameMomentAs(now);
    }).toList()
      ..sort((a, b) {
        final dateA = _parseLocalDate(a['fecha_hora']);
        final dateB = _parseLocalDate(b['fecha_hora']);
        return dateB.compareTo(dateA); // Más recientes primero
      });
  }

  DateTime _parseLocalDate(dynamic dateValue) {
    final dateStr = dateValue.toString();
    if (dateStr.contains('T') &&
        !dateStr.contains('+') &&
        !dateStr.endsWith('Z')) {
      return DateTime.parse(dateStr);
    }
    return DateTime.parse(dateStr).toLocal();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mint,
      appBar: AppBar(
        backgroundColor: mint,
        elevation: 0,
        foregroundColor: darkGreen,
        title: const Text(
          'Mis Citas',
          style: TextStyle(
            color: darkGreen,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: darkGreen),
            onPressed: _showFilterOptions,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: softGreen))
          : RefreshIndicator(
              onRefresh: _loadAppointments,
              color: softGreen,
              child: _buildContent(),
            ),
    );
  }

  Widget _buildContent() {
    if (_allAppointments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'No tienes citas programadas',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            color: mint,
            child: TabBar(
              labelColor: darkGreen,
              unselectedLabelColor: Colors.grey,
              indicatorColor: softGreen,
              indicatorWeight: 3,
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.upcoming),
                      const SizedBox(width: 8),
                      Text('Próximas (${_upcomingAppointments.length})'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.history),
                      const SizedBox(width: 8),
                      Text('Pasadas (${_pastAppointments.length})'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildAppointmentsList(_upcomingAppointments, isUpcoming: true),
                _buildAppointmentsList(_pastAppointments, isUpcoming: false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentsList(List<Map<String, dynamic>> appointments,
      {required bool isUpcoming}) {
    if (appointments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isUpcoming ? Icons.event_available : Icons.history,
              size: 64,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              isUpcoming ? 'No hay citas próximas' : 'No hay citas pasadas',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        return _buildAppointmentCard(appointments[index],
            isUpcoming: isUpcoming);
      },
    );
  }

  Widget _buildAppointmentCard(Map<String, dynamic> appointment,
      {required bool isUpcoming}) {
    final fechaHora = _parseLocalDate(appointment['fecha_hora']);
    final dateStr = DateFormat('dd MMM yyyy', 'es_ES').format(fechaHora);
    final timeStr = DateFormat('h:mm a', 'es_ES').format(fechaHora);
    final estadoNombre = appointment['estado_nombre'] ?? 'Pendiente';

    // Color según estado
    Color statusColor = lightGreen;
    IconData statusIcon = Icons.schedule;

    if (estadoNombre.toLowerCase().contains('completada')) {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
    } else if (estadoNombre.toLowerCase().contains('cancelada')) {
      statusColor = Colors.red;
      statusIcon = Icons.cancel;
    } else if (estadoNombre.toLowerCase().contains('confirmada')) {
      statusColor = Colors.blue;
      statusIcon = Icons.check;
    } else if (estadoNombre.toLowerCase().contains('no asistió')) {
      statusColor = Colors.grey;
      statusIcon = Icons.block;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showAppointmentDetails(appointment),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(statusIcon, color: statusColor, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          estadoNombre,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.calendar_today,
                                size: 14, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              dateStr,
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Icon(Icons.access_time,
                                size: 14, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              timeStr,
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: Colors.grey[400]),
                ],
              ),
              if (appointment['notas_cliente'] != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: mint,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.note, size: 14, color: darkGreen),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          appointment['notas_cliente'],
                          style: const TextStyle(
                            color: darkGreen,
                            fontSize: 12,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showAppointmentDetails(Map<String, dynamic> appointment) {
    final fechaHora = _parseLocalDate(appointment['fecha_hora']);

    showModalBottomSheet(
      context: context,
      backgroundColor: white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Detalles de la Cita',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: darkGreen,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: darkGreen),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 16),
            _buildDetailRow(
              'Fecha',
              DateFormat('dd/MM/yyyy', 'es_ES').format(fechaHora),
              Icons.calendar_today,
            ),
            _buildDetailRow(
              'Hora',
              DateFormat('h:mm a', 'es_ES').format(fechaHora),
              Icons.access_time,
            ),
            _buildDetailRow(
              'Estado',
              appointment['estado_nombre'] ?? 'N/A',
              Icons.info,
            ),
            if (appointment['notas_cliente'] != null)
              _buildDetailRow(
                'Notas',
                appointment['notas_cliente'],
                Icons.note,
              ),
            if (appointment['notas_veterinaria'] != null)
              _buildDetailRow(
                'Observaciones de la veterinaria',
                appointment['notas_veterinaria'],
                Icons.medical_services,
              ),
            const SizedBox(height: 16),
            if (_canCancelAppointment(appointment))
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _confirmCancelAppointment(appointment),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(Icons.cancel),
                  label: const Text('Cancelar Cita'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: softGreen),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: darkGreen,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _canCancelAppointment(Map<String, dynamic> appointment) {
    final estadoNombre =
        (appointment['estado_nombre'] ?? '').toString().toLowerCase();
    final fechaHora = _parseLocalDate(appointment['fecha_hora']);
    final now = DateTime.now();

    // Solo se puede cancelar si está pendiente o confirmada, y es futura
    return (estadoNombre.contains('pendiente') ||
            estadoNombre.contains('confirmada')) &&
        fechaHora.isAfter(now);
  }

  void _confirmCancelAppointment(Map<String, dynamic> appointment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar Cita'),
        content: const Text('¿Estás seguro de que deseas cancelar esta cita?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Cerrar diálogo
              Navigator.pop(context); // Cerrar modal
              _cancelAppointment(appointment['id']);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sí, cancelar'),
          ),
        ],
      ),
    );
  }

  Future<void> _cancelAppointment(int appointmentId) async {
    try {
      await AppointmentsService.updateAppointment(appointmentId, {
        'estado_id': 4, // Estado: Cancelada
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cita cancelada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        _loadAppointments();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cancelar cita: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filtrar por Estado',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: darkGreen,
              ),
            ),
            const SizedBox(height: 16),
            _buildFilterOption('Todas'),
            _buildFilterOption('Pendiente'),
            _buildFilterOption('Confirmada'),
            _buildFilterOption('Completada'),
            _buildFilterOption('Cancelada'),
            _buildFilterOption('No asistió'),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterOption(String filterValue) {
    final isSelected = _selectedFilter == filterValue;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
        color: isSelected ? softGreen : Colors.grey,
      ),
      title: Text(
        filterValue,
        style: TextStyle(
          color: darkGreen,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      onTap: () {
        setState(() {
          _selectedFilter = filterValue;
        });
        Navigator.pop(context);
      },
    );
  }
}
