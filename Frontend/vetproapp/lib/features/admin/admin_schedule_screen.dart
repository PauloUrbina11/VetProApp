import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../app/config/theme.dart';
import '../../app/services/admin_service.dart';

class AdminScheduleScreen extends StatefulWidget {
  const AdminScheduleScreen({super.key});

  @override
  State<AdminScheduleScreen> createState() => _AdminScheduleScreenState();
}

class _AdminScheduleScreenState extends State<AdminScheduleScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<dynamic>> _appointments = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    setState(() => _loading = true);

    try {
      final allAppointments = await AdminService.getAllAppointments();

      // Agrupar citas por fecha
      final Map<DateTime, List<dynamic>> appointmentsByDate = {};

      for (var apt in allAppointments) {
        try {
          final fechaHora = DateTime.parse(apt['fecha_hora']).toLocal();
          final dateKey =
              DateTime(fechaHora.year, fechaHora.month, fechaHora.day);

          if (!appointmentsByDate.containsKey(dateKey)) {
            appointmentsByDate[dateKey] = [];
          }
          appointmentsByDate[dateKey]!.add(apt);
        } catch (e) {
          debugPrint('Error parsing date: $e');
        }
      }

      setState(() {
        _appointments = appointmentsByDate;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar citas: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  List<dynamic> _getAppointmentsForDay(DateTime day) {
    final dateKey = DateTime(day.year, day.month, day.day);
    return _appointments[dateKey] ?? [];
  }

  Color _getStatusColor(int? estadoId) {
    switch (estadoId) {
      case 1:
        return Colors.orange; // Pendiente
      case 2:
        return Colors.blue; // Confirmada
      case 3:
        return Colors.green; // Completada
      case 4:
        return Colors.red; // Cancelada
      case 5:
        return Colors.grey; // No asistió
      default:
        return Colors.grey;
    }
  }

  String _getStatusName(int? estadoId) {
    switch (estadoId) {
      case 1:
        return 'Pendiente';
      case 2:
        return 'Confirmada';
      case 3:
        return 'Completada';
      case 4:
        return 'Cancelada';
      case 5:
        return 'No asistió';
      default:
        return 'Desconocido';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mint,
      appBar: AppBar(
        title: const Text(
          'Agenda Global del Sistema',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: softGreen,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAppointments,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: softGreen))
          : Column(
              children: [
                // Calendario
                Container(
                  decoration: BoxDecoration(
                    color: white,
                    boxShadow: [
                      BoxShadow(
                        color: darkGreen.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TableCalendar(
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: _focusedDay,
                    calendarFormat: _calendarFormat,
                    selectedDayPredicate: (day) {
                      return isSameDay(_selectedDay, day);
                    },
                    eventLoader: _getAppointmentsForDay,
                    onDaySelected: (selectedDay, focusedDay) {
                      if (!isSameDay(_selectedDay, selectedDay)) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                        });
                      }
                    },
                    onFormatChanged: (format) {
                      if (_calendarFormat != format) {
                        setState(() {
                          _calendarFormat = format;
                        });
                      }
                    },
                    onPageChanged: (focusedDay) {
                      _focusedDay = focusedDay;
                    },
                    calendarStyle: CalendarStyle(
                      todayDecoration: BoxDecoration(
                        color: softGreen.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      selectedDecoration: const BoxDecoration(
                        color: softGreen,
                        shape: BoxShape.circle,
                      ),
                      markerDecoration: const BoxDecoration(
                        color: darkGreen,
                        shape: BoxShape.circle,
                      ),
                      outsideDaysVisible: false,
                    ),
                    headerStyle: HeaderStyle(
                      formatButtonVisible: true,
                      titleCentered: true,
                      formatButtonShowsNext: false,
                      formatButtonDecoration: BoxDecoration(
                        color: softGreen,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      formatButtonTextStyle: const TextStyle(
                        color: white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),

                // Lista de citas del día seleccionado
                Expanded(
                  child: _buildAppointmentsList(),
                ),
              ],
            ),
    );
  }

  Widget _buildAppointmentsList() {
    final selectedDayAppointments = _getAppointmentsForDay(_selectedDay!);

    if (selectedDayAppointments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 64,
              color: darkGreen.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No hay citas para ${DateFormat('dd/MM/yyyy').format(_selectedDay!)}',
              style: const TextStyle(
                color: darkGreen,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    // Ordenar por hora
    selectedDayAppointments.sort((a, b) {
      try {
        final dateA = DateTime.parse(a['fecha_hora']);
        final dateB = DateTime.parse(b['fecha_hora']);
        return dateA.compareTo(dateB);
      } catch (e) {
        return 0;
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Citas del ${DateFormat('dd/MM/yyyy').format(_selectedDay!)} (${selectedDayAppointments.length})',
            style: const TextStyle(
              color: darkGreen,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: selectedDayAppointments.length,
            itemBuilder: (context, index) {
              final appointment = selectedDayAppointments[index];
              return _buildAppointmentCard(appointment);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAppointmentCard(dynamic appointment) {
    final fechaHora = DateTime.parse(appointment['fecha_hora']).toLocal();
    final timeStr = DateFormat('HH:mm').format(fechaHora);
    final statusColor = _getStatusColor(appointment['estado_id']);
    final statusName = _getStatusName(appointment['estado_id']);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
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
                  child: Icon(Icons.access_time, color: statusColor, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  timeStr,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: darkGreen,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    statusName,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (appointment['usuario_nombre'] != null) ...[
              Row(
                children: [
                  Icon(Icons.person, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    'Cliente: ${appointment['usuario_nombre']}',
                    style: const TextStyle(
                      color: darkGreen,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            if (appointment['veterinaria_nombre'] != null) ...[
              Row(
                children: [
                  Icon(Icons.store, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Veterinaria: ${appointment['veterinaria_nombre']}',
                      style: const TextStyle(
                        color: darkGreen,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            if (appointment['mascotas'] != null) ...[
              Row(
                children: [
                  Icon(Icons.pets, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Mascota(s): ${appointment['mascotas']}',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            if (appointment['servicios'] != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.medical_services,
                      size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Servicio(s): ${appointment['servicios']}',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
