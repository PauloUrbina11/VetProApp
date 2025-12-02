import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../app/config/theme.dart';
import '../../../app/services/appointments_service.dart';
import '../../../app/services/auth_service.dart';
import '../../../app/services/veterinaria_service.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  DateTime _selectedDate = DateTime.now();
  DateTime _currentMonth = DateTime.now();
  bool _loading = true;
  List<Map<String, dynamic>> _allAppointments = [];
  int? _userRole;
  int? _veterinariaId;
  String? _selectedFilter; // null = todas, o nombre del estado

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      _userRole = await AuthService.getRole();

      if (_userRole == 2) {
        // Veterinaria: cargar citas de su veterinaria
        final vets = await VeterinariaService.getMyVeterinarias();
        if (vets.isNotEmpty) {
          _veterinariaId = vets[0]; // vets[0] ya es un int
          final citas = await AppointmentsService.getVeterinariaAppointments(
              _veterinariaId!);
          _allAppointments = List<Map<String, dynamic>>.from(
              citas.map((c) => Map<String, dynamic>.from(c)));
        }
      } else {
        // Usuario normal: cargar sus propias citas
        final citas = await AppointmentsService.getMyAppointments();
        _allAppointments = List<Map<String, dynamic>>.from(
            citas.map((c) => Map<String, dynamic>.from(c)));
      }
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

  List<Map<String, dynamic>> get _appointments {
    // Filtrar citas del día seleccionado
    var filtered = _allAppointments.where((apt) {
      // Parsear como fecha local (ya viene convertida desde el backend)
      final fechaHoraStr = apt['fecha_hora'].toString();
      final fechaHora = DateTime.parse(fechaHoraStr.endsWith('Z')
              ? fechaHoraStr
              : fechaHoraStr + '+00:00')
          .toLocal();
      final isSameDay = fechaHora.year == _selectedDate.year &&
          fechaHora.month == _selectedDate.month &&
          fechaHora.day == _selectedDate.day;

      if (!isSameDay) return false;

      // Aplicar filtro de estado si está seleccionado
      if (_selectedFilter != null && _selectedFilter != 'Todas') {
        final estadoNombre =
            (apt['estado_nombre'] ?? '').toString().toLowerCase();
        return estadoNombre.contains(_selectedFilter!.toLowerCase());
      }

      return true;
    }).toList()
      ..sort((a, b) {
        final dateAStr = a['fecha_hora'].toString();
        final dateA = DateTime.parse(
                dateAStr.endsWith('Z') ? dateAStr : dateAStr + '+00:00')
            .toLocal();
        final dateBStr = b['fecha_hora'].toString();
        final dateB = DateTime.parse(
                dateBStr.endsWith('Z') ? dateBStr : dateBStr + '+00:00')
            .toLocal();
        return dateA.compareTo(dateB);
      });

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      appBar: AppBar(
        backgroundColor: white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: darkGreen),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Agenda',
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
          : Column(
              children: [
                // Selector de mes
                _buildMonthSelector(),
                // Calendario horizontal
                _buildHorizontalCalendar(),
                // Lista de citas
                Expanded(
                  child: _buildAppointmentsList(),
                ),
              ],
            ),
    );
  }

  Widget _buildMonthSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            DateFormat('MMMM yyyy', 'es_ES').format(_currentMonth),
            style: const TextStyle(
              color: darkGreen,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.calendar_month, color: darkGreen),
            onPressed: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.light(
                        primary: softGreen,
                        onPrimary: white,
                        onSurface: darkGreen,
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (picked != null) {
                setState(() {
                  _selectedDate = picked;
                  _currentMonth = picked;
                });
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalCalendar() {
    final startOfWeek =
        _selectedDate.subtract(Duration(days: _selectedDate.weekday - 1));

    return Container(
      height: 90,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: 7,
        itemBuilder: (context, index) {
          final date = startOfWeek.add(Duration(days: index));
          final isSelected = date.day == _selectedDate.day &&
              date.month == _selectedDate.month &&
              date.year == _selectedDate.year;

          return _buildDateCard(date, isSelected);
        },
      ),
    );
  }

  Widget _buildDateCard(DateTime date, bool isSelected) {
    final dayName = DateFormat('E', 'es_ES').format(date);
    final dayNumber = date.day.toString();

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDate = date;
        });
      },
      child: Container(
        width: 50,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected ? softGreen : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              dayName,
              style: TextStyle(
                color: isSelected ? white : Colors.grey[600],
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              dayNumber,
              style: TextStyle(
                color: isSelected ? white : darkGreen,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentsList() {
    if (_appointments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'No hay citas programadas',
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
      itemCount: _appointments.length,
      itemBuilder: (context, index) {
        return _buildAppointmentCard(_appointments[index]);
      },
    );
  }

  Widget _buildAppointmentCard(Map<String, dynamic> appointment) {
    final fechaHoraStr = appointment['fecha_hora'].toString();
    // Si la fecha no tiene 'Z' o zona horaria, la tomamos como local
    final fechaHora = fechaHoraStr.contains('T') &&
            !fechaHoraStr.contains('+') &&
            !fechaHoraStr.endsWith('Z')
        ? DateTime.parse(fechaHoraStr)
        : DateTime.parse(fechaHoraStr).toLocal();
    final timeStr = DateFormat('h:mm a', 'es_ES').format(fechaHora);
    final estadoNombre = appointment['estado_nombre'] ?? 'Pendiente';
    final mascotas = appointment['mascotas'] ?? 'Sin mascota';
    final usuario = appointment['usuario_nombre'] ?? 'Usuario';
    final servicios = appointment['servicios'] ?? 'Sin servicio';

    // Color según estado
    Color statusColor = lightGreen;
    if (estadoNombre.toLowerCase().contains('completada')) {
      statusColor = Colors.green;
    } else if (estadoNombre.toLowerCase().contains('cancelada')) {
      statusColor = Colors.red;
    } else if (estadoNombre.toLowerCase().contains('confirmada')) {
      statusColor = Colors.blue;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: statusColor,
          radius: 6,
        ),
        title: Row(
          children: [
            Text(
              timeStr,
              style: const TextStyle(
                color: darkGreen,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                mascotas,
                style: const TextStyle(
                  color: darkGreen,
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                usuario,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 13,
                ),
              ),
              Text(
                servicios,
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: Colors.grey[400],
        ),
        onTap: () {
          // Navegar a detalles de la cita
          _showAppointmentDetails(appointment);
        },
      ),
    );
  }

  void _showAppointmentDetails(Map<String, dynamic> appointment) {
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
            Text(
              'Detalles de la Cita',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: darkGreen,
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
                'Fecha',
                DateFormat('dd/MM/yyyy', 'es_ES')
                    .format(_parseLocalDate(appointment['fecha_hora']))),
            _buildDetailRow(
                'Hora',
                DateFormat('h:mm a', 'es_ES')
                    .format(_parseLocalDate(appointment['fecha_hora']))),
            _buildDetailRow('Estado', appointment['estado_nombre'] ?? 'N/A'),
            _buildDetailRow('Mascota(s)', appointment['mascotas'] ?? 'N/A'),
            _buildDetailRow('Cliente', appointment['usuario_nombre'] ?? 'N/A'),
            _buildDetailRow('Servicio(s)', appointment['servicios'] ?? 'N/A'),
            if (appointment['notas_cliente'] != null)
              _buildDetailRow('Notas Cliente', appointment['notas_cliente']),
            if (appointment['notas_veterinaria'] != null)
              _buildDetailRow(
                  'Notas Veterinaria', appointment['notas_veterinaria']),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: darkGreen,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }

  DateTime _parseLocalDate(dynamic dateValue) {
    final dateStr = dateValue.toString();
    // Si la fecha no tiene zona horaria (Z o +/-), la tomamos como local
    if (dateStr.contains('T') &&
        !dateStr.contains('+') &&
        !dateStr.endsWith('Z')) {
      return DateTime.parse(dateStr);
    }
    // Si tiene zona horaria, convertimos a local
    return DateTime.parse(dateStr).toLocal();
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
            _buildFilterOption('Todas', null),
            _buildFilterOption('Pendiente', 'Pendiente'),
            _buildFilterOption('Confirmada', 'Confirmada'),
            _buildFilterOption('Completada', 'Completada'),
            _buildFilterOption('Cancelada', 'Cancelada'),
            _buildFilterOption('No Asistió', 'No asistió'),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterOption(String label, String? filterValue) {
    final isSelected = (_selectedFilter == filterValue) ||
        (_selectedFilter == null && filterValue == null);

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
        color: isSelected ? softGreen : Colors.grey,
      ),
      title: Text(
        label,
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
