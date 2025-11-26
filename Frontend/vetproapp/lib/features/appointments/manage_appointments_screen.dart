import 'package:flutter/material.dart';
import '../../app/services/appointments_service.dart';
import '../../app/services/admin_service.dart';
import '../../app/services/auth_service.dart';

class ManageAppointmentsScreen extends StatefulWidget {
  const ManageAppointmentsScreen({super.key});

  @override
  State<ManageAppointmentsScreen> createState() =>
      _ManageAppointmentsScreenState();
}

class _ManageAppointmentsScreenState extends State<ManageAppointmentsScreen> {
  List<dynamic> _appointments = [];
  bool _loading = true;
  String? _error;
  int? _userRole;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final role = await AuthService.getRole();
    setState(() => _userRole = role);
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      List<dynamic> appointments;
      if (_userRole == 1) {
        // Admin: ver todas las citas
        appointments = await AdminService.getAllAppointments();
      } else {
        // Usuario normal: solo sus citas
        appointments = await AppointmentsService.getMyAppointments();
      }
      setState(() {
        _appointments = appointments;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _deleteAppointment(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Está seguro de eliminar esta cita?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await AppointmentsService.deleteAppointment(id);
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cita eliminada exitosamente')));
        _loadAppointments();
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontFamily: 'Montserrat',
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF15803D),
      appBar: AppBar(
        title: const Text(
          'Gestión de Citas',
          style:
              TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF15803D),
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    if (_error != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _error!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                      ),
                    if (_error != null) const SizedBox(height: 12),
                    const Text(
                      'Lista de Citas',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Montserrat',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: _appointments.isEmpty
                          ? Center(
                              child: Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: const Text(
                                  'No hay citas registradas',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Montserrat',
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            )
                          : ListView.builder(
                              itemCount: _appointments.length,
                              itemBuilder: (context, index) {
                                final appointment = _appointments[index];
                                final isAdmin = _userRole == 1;

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: ExpansionTile(
                                    tilePadding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 4),
                                    title: Text(
                                      'Cita #${appointment['id']} ${isAdmin ? '- ${appointment['usuario_nombre'] ?? 'Usuario'}' : ''}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    subtitle: Text(
                                      'Fecha: ${appointment['fecha_hora'] ?? 'N/A'}',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.8),
                                        fontFamily: 'Montserrat',
                                        fontSize: 14,
                                      ),
                                    ),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                      onPressed: () =>
                                          _deleteAppointment(appointment['id']),
                                    ),
                                    iconColor: Colors.white,
                                    collapsedIconColor: Colors.white,
                                    children: [
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            if (isAdmin) ...[
                                              _buildInfoRow(
                                                  'Usuario',
                                                  appointment[
                                                          'usuario_nombre'] ??
                                                      'N/A'),
                                              _buildInfoRow(
                                                  'Email',
                                                  appointment[
                                                          'usuario_email'] ??
                                                      'N/A'),
                                              if (appointment[
                                                      'usuario_telefono'] !=
                                                  null)
                                                _buildInfoRow(
                                                    'Teléfono',
                                                    appointment[
                                                        'usuario_telefono']),
                                              const Divider(
                                                  color: Colors.white54,
                                                  height: 20),
                                            ],
                                            _buildInfoRow(
                                                'Estado',
                                                appointment['estado_nombre'] ??
                                                    'N/A'),
                                            if (appointment['mascotas'] != null)
                                              _buildInfoRow('Mascotas',
                                                  appointment['mascotas']),
                                            if (appointment['servicios'] !=
                                                null)
                                              _buildInfoRow('Servicios',
                                                  appointment['servicios']),
                                            if (appointment['notas_cliente'] !=
                                                null)
                                              _buildInfoRow('Notas del Cliente',
                                                  appointment['notas_cliente']),
                                            if (appointment[
                                                    'notas_veterinaria'] !=
                                                null)
                                              _buildInfoRow(
                                                  'Notas Veterinaria',
                                                  appointment[
                                                      'notas_veterinaria']),
                                            if (isAdmin &&
                                                appointment['created_at'] !=
                                                    null)
                                              _buildInfoRow('Creada el',
                                                  appointment['created_at']),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
