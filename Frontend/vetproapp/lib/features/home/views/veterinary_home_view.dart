import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../../app/config/theme.dart';
import '../../../app/services/veterinaria_service.dart';
import '../../profile/profile_menu_screen.dart';

class VeterinaryHomeView extends StatefulWidget {
  final String? userName;
  final String? veterinariaNombre;
  final VoidCallback onDataReload;

  const VeterinaryHomeView({
    super.key,
    this.userName,
    this.veterinariaNombre,
    required this.onDataReload,
  });

  @override
  State<VeterinaryHomeView> createState() => _VeterinaryHomeViewState();
}

class _VeterinaryHomeViewState extends State<VeterinaryHomeView> {
  int? _veterinariaId;
  Map<String, dynamic>? _vetStats;
  List<dynamic> _vetNextAppointments = [];
  Map<DateTime, int> _vetCalendarCounts = {};
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _loadVeterinariaData();
  }

  @override
  void didUpdateWidget(VeterinaryHomeView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Recargar datos cuando el widget se actualiza
    _loadVeterinariaData();
  }

  Future<void> _loadVeterinariaData() async {
    try {
      // Obtener veterinarias asociadas al usuario
      final vets = await VeterinariaService.getMyVeterinarias();
      if (vets.isEmpty) return;
      _veterinariaId = vets.first;

      // Obtener datos en paralelo
      final now = DateTime.now();
      final firstDay = DateTime(now.year, now.month, 1);
      final lastDay = DateTime(now.year, now.month + 1, 0);
      final fromDate = firstDay.toIso8601String().split('T')[0];
      final toDate = lastDay.toIso8601String().split('T')[0];

      final results = await Future.wait([
        VeterinariaService.getDashboard(_veterinariaId!),
        VeterinariaService.getCalendarCounts(_veterinariaId!, fromDate, toDate),
      ]);

      final dashboard = results[0] as Map<String, dynamic>;
      final calendarRaw = results[1] as List<dynamic>;

      final Map<DateTime, int> calMap = {};
      for (final item in calendarRaw) {
        final fecha = DateTime.parse(item['fecha']);
        calMap[DateTime(fecha.year, fecha.month, fecha.day)] =
            item['cantidad'] as int? ?? 0;
      }

      setState(() {
        _vetStats = dashboard['stats'] as Map<String, dynamic>;
        _vetNextAppointments = dashboard['nextAppointments'] as List<dynamic>;
        _vetCalendarCounts = calMap;
      });
    } catch (e) {
      // Silenciar
    }
  }

  int _getVetCountForDay(DateTime day) {
    final key = DateTime(day.year, day.month, day.day);
    return _vetCalendarCounts[key] ?? 0;
  }

  Color _getColorForCount(int count) {
    if (count == 0) return Colors.transparent;
    if (count <= 2) return lightGreen;
    if (count <= 5) return softGreen;
    return darkGreen;
  }

  String _formatAppointmentDate(String? isoDateTime) {
    if (isoDateTime == null) return '';
    try {
      final dateTime = DateTime.parse(isoDateTime).toLocal();
      final now = DateTime.now();
      final tomorrow = now.add(const Duration(days: 1));

      String dateText;
      if (dateTime.year == now.year &&
          dateTime.month == now.month &&
          dateTime.day == now.day) {
        dateText = 'Hoy';
      } else if (dateTime.year == tomorrow.year &&
          dateTime.month == tomorrow.month &&
          dateTime.day == tomorrow.day) {
        dateText = 'Mañana';
      } else {
        final months = [
          'Ene',
          'Feb',
          'Mar',
          'Abr',
          'May',
          'Jun',
          'Jul',
          'Ago',
          'Sep',
          'Oct',
          'Nov',
          'Dic'
        ];
        dateText = '${dateTime.day} ${months[dateTime.month - 1]}';
      }

      final hour = dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour;
      final period = dateTime.hour >= 12 ? 'PM' : 'AM';
      final minute = dateTime.minute.toString().padLeft(2, '0');

      return '$dateText - $hour:$minute $period';
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mint,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: settings, profile
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/settings');
                      },
                      icon: const Icon(Icons.settings),
                      color: vetproGreen,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Align(
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 260),
                              child: Text(
                                'Bienvenido/a',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: vetproGreen,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 200),
                              child: Text(
                                '${widget.userName ?? ''}${widget.veterinariaNombre != null ? ' - ${widget.veterinariaNombre}' : ''} 👋',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: vetproGreen.withOpacity(0.8),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    CircleAvatar(
                      backgroundColor: Colors.white,
                      child: IconButton(
                        onPressed: () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const ProfileMenuScreen(),
                            ),
                          );
                          widget.onDataReload();
                        },
                        icon: const Icon(Icons.person),
                        color: vetproGreen,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Estadísticas de la veterinaria
                Text(
                  'Estadísticas de la Veterinaria',
                  style: TextStyle(
                    color: vetproGreen,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                // Stats cards row
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Citas',
                        '${_vetStats?['totalCitas'] ?? 0}',
                        Icons.event,
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Pendientes',
                        '${_vetStats?['citasPendientes'] ?? 0}',
                        Icons.pending_actions,
                        Colors.orange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Completadas',
                        '${_vetStats?['citasCompletadas'] ?? 0}',
                        Icons.check_circle,
                        Colors.green,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Mascotas',
                        '${_vetStats?['mascotasAtendidas'] ?? 0}',
                        Icons.pets,
                        Colors.purple,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Próximas citas
                Text(
                  'Próximas citas',
                  style: TextStyle(
                    color: vetproGreen,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                ..._vetNextAppointments.map((appt) => Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        border: Border.all(color: vetproGreen.withOpacity(0.3)),
                        borderRadius: BorderRadius.circular(12),
                        color: vetproGreen.withOpacity(0.05),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.event, color: vetproGreen, size: 28),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _formatAppointmentDate(appt['fecha_hora']),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  appt['usuario_nombre'] ?? 'Paciente',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            appt['estado_nombre'] ?? '',
                            style: TextStyle(
                              color: vetproGreen,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    )),
                if (_vetNextAppointments.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: vetproGreen.withOpacity(0.3)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'No hay próximas citas',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ),
                const SizedBox(height: 18),

                // Calendario
                Text(
                  'Calendario de citas',
                  style: TextStyle(
                    color: vetproGreen,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/schedule'),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: vetproGreen.withOpacity(0.3)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: TableCalendar(
                      firstDay: DateTime.utc(2020, 1, 1),
                      lastDay: DateTime.utc(2030, 12, 31),
                      focusedDay: _focusedDay,
                      calendarFormat: _calendarFormat,
                      locale: 'es_ES',
                      selectedDayPredicate: (day) {
                        return isSameDay(_selectedDay, day);
                      },
                      onDaySelected: (selectedDay, focusedDay) {
                        Navigator.pushNamed(context, '/schedule');
                      },
                      onFormatChanged: (format) {
                        setState(() {
                          _calendarFormat = format;
                        });
                      },
                      onPageChanged: (focusedDay) {
                        _focusedDay = focusedDay;
                      },
                      calendarStyle: CalendarStyle(
                        todayDecoration: BoxDecoration(
                          color: vetproGreen.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        selectedDecoration: BoxDecoration(
                          color: vetproGreen,
                          shape: BoxShape.circle,
                        ),
                        markerDecoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                      headerStyle: HeaderStyle(
                        formatButtonVisible: false,
                        titleCentered: true,
                        titleTextStyle: TextStyle(
                          color: vetproGreen,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      calendarBuilders: CalendarBuilders(
                        defaultBuilder: (context, day, focusedDay) {
                          final count = _getVetCountForDay(day);
                          return Container(
                            margin: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: _getColorForCount(count),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${day.day}',
                                style: TextStyle(
                                  color:
                                      count > 0 ? Colors.white : Colors.black,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Leyenda de colores
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildLegendItem('1-2', lightGreen),
                    const SizedBox(width: 12),
                    _buildLegendItem('3-5', softGreen),
                    const SizedBox(width: 12),
                    _buildLegendItem('6+', darkGreen),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}
