import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../app/services/appointments_service.dart';
import '../../app/services/admin_service.dart';
import '../../app/services/auth_service.dart';
import '../../app/services/veterinaria_service.dart';
import '../../app/services/permissions_service.dart';
import '../../app/services/medical_records_service.dart';
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
    // Cargar permisos si es rol veterinaria
    if (role == 2) {
      await PermissionsService.loadVeterinariaRoles();
    }
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

  List<int> _getAllowedStatuses(int currentStatusId) {
    // Si es rol veterinaria (2), usar permisos basados en veterinaria_rol
    if (_userRole == 2) {
      return PermissionsService.getAllowedStatusChanges(currentStatusId);
    }

    // Admin (rol 1) puede hacer todos los cambios
    switch (currentStatusId) {
      case 1: // Pendiente
        return [2, 4]; // Confirmada, Cancelada
      case 2: // Confirmada
        return [3, 4, 5]; // Completada, Cancelada, No asistió
      case 3: // Completada (final)
        return [];
      case 4: // Cancelada (final)
        return [];
      case 5: // No asistió (final)
        return [];
      default:
        return [];
    }
  }

  Future<void> _changeAppointmentStatus(
      int appointmentId, int currentStatusId) async {
    final allowedStatuses = _getAllowedStatuses(currentStatusId);

    if (allowedStatuses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Este estado es final y no puede ser modificado'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final allEstados = [
      {'id': 1, 'nombre': 'Pendiente'},
      {'id': 2, 'nombre': 'Confirmada'},
      {'id': 3, 'nombre': 'Completada'},
      {'id': 4, 'nombre': 'Cancelada'},
      {'id': 5, 'nombre': 'No asistió'},
    ];

    final estados = allEstados
        .where((estado) => allowedStatuses.contains(estado['id']))
        .toList();

    final selectedStatus = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cambiar Estado'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: estados.map((estado) {
            return ListTile(
              title: Text(estado['nombre'] as String),
              leading: Radio<int>(
                value: estado['id'] as int,
                groupValue: null,
                onChanged: (value) => Navigator.pop(context, value),
                activeColor: softGreen,
              ),
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
      // Si el estado seleccionado es "Completada" (3), validar que la cita ya haya pasado
      if (selectedStatus == 3) {
        final appointment =
            _appointments.firstWhere((a) => a['id'] == appointmentId);

        // Verificar si la cita ya pasó (solo para veterinarias, rol 2)
        if (_userRole == 2) {
          try {
            final fechaHora =
                DateTime.parse(appointment['fecha_hora']).toLocal();
            final now = DateTime.now();

            if (fechaHora.isAfter(now)) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'No puedes completar esta cita antes de su hora programada (${DateFormat('dd/MM/yyyy HH:mm').format(fechaHora)})'),
                  backgroundColor: Colors.orange,
                  duration: const Duration(seconds: 4),
                ),
              );
              return;
            }
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error al validar la fecha de la cita: $e'),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }
        }

        await _showMedicalRecordForm(appointmentId, appointment);
      } else {
        // Para otros estados, mostrar diálogo de notas
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
              'notas_veterinaria':
                  notas.trim().isNotEmpty ? notas.trim() : null,
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
  }

  Future<void> _showMedicalRecordForm(
      int appointmentId, Map<String, dynamic> appointment) async {
    final diagnosticoController = TextEditingController();
    final tratamientoController = TextEditingController();
    final motivoController = TextEditingController();
    final descripcionController = TextEditingController();
    final notasController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title:
            const Text('Historia Clínica', style: TextStyle(color: darkGreen)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Complete la información médica de la cita:',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: motivoController,
                decoration: const InputDecoration(
                  labelText: 'Motivo de consulta',
                  border: OutlineInputBorder(),
                  hintText: 'Ej: Vacunación, chequeo general...',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descripcionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción de la visita *',
                  border: OutlineInputBorder(),
                  hintText: 'Describa lo observado durante la consulta...',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: diagnosticoController,
                decoration: const InputDecoration(
                  labelText: 'Diagnóstico',
                  border: OutlineInputBorder(),
                  hintText: 'Diagnóstico médico...',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: tratamientoController,
                decoration: const InputDecoration(
                  labelText: 'Tratamiento/Recomendaciones',
                  border: OutlineInputBorder(),
                  hintText: 'Medicamentos, instrucciones, cuidados...',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notasController,
                decoration: const InputDecoration(
                  labelText: 'Notas adicionales',
                  border: OutlineInputBorder(),
                  hintText: 'Notas para el expediente de la cita...',
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (descripcionController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('La descripción es obligatoria'),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }
              Navigator.pop(context, true);
            },
            style: ElevatedButton.styleFrom(backgroundColor: softGreen),
            child: const Text('Guardar y Completar Cita'),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        // Obtener veterinaria_id e información de mascotas de la cita
        final veterinariaIds = await VeterinariaService.getMyVeterinarias();
        if (veterinariaIds.isEmpty) {
          throw Exception('No se encontró veterinaria asociada');
        }

        // Obtener IDs de mascotas de la cita
        final mascotaIds = await _getMascotaIdsFromAppointment(appointmentId);

        if (mascotaIds.isEmpty) {
          throw Exception('No se encontraron mascotas asociadas a esta cita');
        }

        // Crear historia clínica para cada mascota
        for (final mascotaId in mascotaIds) {
          await MedicalRecordsService.createMedicalRecord({
            'mascota_id': mascotaId,
            'veterinaria_id': veterinariaIds[0],
            'cita_id': appointmentId,
            'fecha': DateTime.now().toIso8601String(),
            'motivo': motivoController.text.trim().isNotEmpty
                ? motivoController.text.trim()
                : null,
            'descripcion': descripcionController.text.trim(),
            'diagnostico': diagnosticoController.text.trim().isNotEmpty
                ? diagnosticoController.text.trim()
                : null,
            'tratamiento': tratamientoController.text.trim().isNotEmpty
                ? tratamientoController.text.trim()
                : null,
          });
        }

        // Actualizar estado de la cita a "Completada"
        await AppointmentsService.updateAppointment(
          appointmentId,
          {
            'estado_id': 3,
            'notas_veterinaria': notasController.text.trim().isNotEmpty
                ? notasController.text.trim()
                : null,
          },
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cita completada e historia clínica guardada'),
              backgroundColor: Colors.green,
            ),
          );
          _loadAppointments();
        }
      } catch (e) {
        if (mounted) {
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

  Future<List<int>> _getMascotaIdsFromAppointment(int appointmentId) async {
    final appointment =
        _appointments.firstWhere((a) => a['id'] == appointmentId);

    // Si tenemos mascota_ids en el appointment (array de PostgreSQL)
    if (appointment.containsKey('mascota_ids') &&
        appointment['mascota_ids'] != null) {
      final mascotaIds = appointment['mascota_ids'];
      if (mascotaIds is List) {
        return mascotaIds
            .map((id) => id is int ? id : int.parse(id.toString()))
            .toList();
      }
    }

    // Fallback: Si no hay mascota_ids pero hay user_id, retornar error descriptivo
    throw Exception(
        'No se pudieron obtener los IDs de las mascotas de esta cita. Datos: ${appointment.keys.toList()}');
  }

  String _formatFecha(String? fechaHora) {
    if (fechaHora == null) return 'N/A';
    try {
      final date = DateTime.parse(fechaHora).toLocal();
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
