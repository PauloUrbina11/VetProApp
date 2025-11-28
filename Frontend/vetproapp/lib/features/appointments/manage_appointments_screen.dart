import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../app/services/appointments_service.dart';
import '../../app/services/admin_service.dart';
import '../../app/services/auth_service.dart';
import '../../app/services/veterinaria_service.dart';
import '../../app/config/theme.dart';

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
      } else if (_userRole == 2) {
        // Veterinaria: citas de su veterinaria
        final veterinariaIds = await VeterinariaService.getMyVeterinarias();
        if (veterinariaIds.isEmpty) {
          setState(() {
            _appointments = [];
            _error = 'No tienes una veterinaria asignada';
          });
          return;
        }
        appointments = await AppointmentsService.getVeterinariaAppointments(
            veterinariaIds[0]);
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
                      child: const Text('Cancelar')),
                  TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Eliminar',
                          style: TextStyle(color: Colors.red))),
                ]));

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

  Future<void> _changeAppointmentStatus(
      int appointmentId, int currentStatusId) async {
    final estados = [
      {'id': 1, 'nombre': 'Pendiente'},
      {'id': 2, 'nombre': 'Confirmada'},
      {'id': 3, 'nombre': 'Completada'},
      {'id': 4, 'nombre': 'Cancelada'},
      {'id': 5, 'nombre': 'No asistió'},
    ];

    final selectedStatus = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cambiar Estado'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: estados.map((estado) {
            final isSelected = estado['id'] == currentStatusId;
            return ListTile(
              title: Text(estado['nombre'] as String),
              leading: Radio<int>(
                value: estado['id'] as int,
                groupValue: currentStatusId,
                onChanged: (value) => Navigator.pop(context, value),
                activeColor: softGreen,
              ),
              selected: isSelected,
              onTap: () => Navigator.pop(context, estado['id'] as int),
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );

    if (selectedStatus != null && selectedStatus != currentStatusId) {
      // Mostrar diálogo para ingresar notas
      final notasController = TextEditingController();
      final notas = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Notas de la Veterinaria'),
          content: TextField(
            controller: notasController,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Ingrese observaciones o notas sobre esta cita...',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, notasController.text),
              child: const Text('Guardar'),
            ),
          ],
        ),
      );

      if (notas != null) {
        try {
          final payload = {
            'estado_id': selectedStatus,
            'notas_veterinaria': notas.trim().isNotEmpty ? notas.trim() : null,
          };

          await AppointmentsService.updateAppointment(
            appointmentId,
            payload,
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Estado actualizado exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
          _loadAppointments();
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  String _formatFecha(String? fechaHora) {
    if (fechaHora == null) return 'N/A';
    try {
      final date = DateTime.parse(fechaHora);
      return DateFormat('dd-MM-yyyy HH:mm').format(date);
    } catch (e) {
      return fechaHora;
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('$label: ',
              style: const TextStyle(
                  color: darkGreen, fontWeight: FontWeight.bold, fontSize: 14)),
          Expanded(
              child: Text(value,
                  style: TextStyle(
                      color: darkGreen.withOpacity(0.9), fontSize: 14))),
        ]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mint,
      appBar: AppBar(
          title: const Text('Gestión de Citas',
              style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: softGreen,
          elevation: 0),
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
                              color: lightGreen.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(8)),
                          child: Text(_error!,
                              style: const TextStyle(color: darkGreen))),
                    if (_error != null) const SizedBox(height: 12),
                    const Text('Lista de Citas',
                        style: TextStyle(
                            color: darkGreen,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Expanded(
                      child: _appointments.isEmpty
                          ? Center(
                              child: Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                      color: lightGreen.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(18)),
                                  child: const Text('No hay citas registradas',
                                      style: TextStyle(
                                          color: darkGreen, fontSize: 16))))
                          : ListView.builder(
                              itemCount: _appointments.length,
                              itemBuilder: (context, index) {
                                final appointment = _appointments[index];
                                final isAdmin = _userRole == 1;

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(12)),
                                  child: ExpansionTile(
                                    tilePadding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 4),
                                    title: Text(
                                        'Cita #${appointment['id']} ${isAdmin ? '- ${appointment['usuario_nombre'] ?? 'Usuario'}' : ''}',
                                        style: const TextStyle(
                                            color: darkGreen,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16)),
                                    subtitle: Text(
                                        'Fecha: ${_formatFecha(appointment['fecha_hora'])}',
                                        style: TextStyle(
                                            color: darkGreen.withOpacity(0.8),
                                            fontSize: 14)),
                                    trailing: isAdmin
                                        ? IconButton(
                                            icon: const Icon(Icons.delete,
                                                color: Colors.red),
                                            onPressed: () => _deleteAppointment(
                                                appointment['id']))
                                        : null,
                                    iconColor: darkGreen,
                                    collapsedIconColor: darkGreen,
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
                                            if (_userRole == 1 ||
                                                _userRole == 2) ...[
                                              const SizedBox(height: 16),
                                              ElevatedButton.icon(
                                                onPressed: () =>
                                                    _changeAppointmentStatus(
                                                  appointment['id'],
                                                  appointment['estado_id'] ?? 1,
                                                ),
                                                icon: const Icon(Icons.edit),
                                                label: const Text(
                                                    'Cambiar Estado'),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: softGreen,
                                                  foregroundColor: white,
                                                ),
                                              ),
                                            ],
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
