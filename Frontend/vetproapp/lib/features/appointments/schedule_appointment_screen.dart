import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../../app/config/theme.dart';
import '../../app/services/appointments_service.dart';
import '../../app/services/veterinaria_services_service.dart';
import '../../app/services/pets_service.dart';

class ScheduleAppointmentScreen extends StatefulWidget {
  final int veterinariaId;
  final String veterinariaNombre;

  const ScheduleAppointmentScreen({
    Key? key,
    required this.veterinariaId,
    required this.veterinariaNombre,
  }) : super(key: key);

  @override
  State<ScheduleAppointmentScreen> createState() =>
      _ScheduleAppointmentScreenState();
}

class _ScheduleAppointmentScreenState extends State<ScheduleAppointmentScreen> {
  DateTime _selectedDate = DateTime.now();
  String? _selectedTime;
  List<int> _selectedServices = [];
  List<int> _selectedPets = [];
  final TextEditingController _notasController = TextEditingController();

  bool _loadingSlots = false;
  bool _loadingServices = false;
  bool _loadingPets = false;
  bool _creatingAppointment = false;

  List<dynamic> _availableSlots = [];
  List<dynamic> _services = [];
  List<dynamic> _pets = [];

  @override
  void dispose() {
    _notasController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _initializeLocale();
    _loadInitialData();
  }

  Future<void> _initializeLocale() async {
    await initializeDateFormatting('es', null);
  }

  Future<void> _loadInitialData() async {
    await Future.wait([
      _loadServices(),
      _loadPets(),
      _loadAvailableSlots(),
    ]);
  }

  Future<void> _loadServices() async {
    setState(() => _loadingServices = true);
    try {
      final services = await VeterinariaServicesService.getServicios(
        widget.veterinariaId,
        activosOnly: true,
      );
      setState(() {
        _services = services;
        _loadingServices = false;
      });
    } catch (e) {
      setState(() => _loadingServices = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadPets() async {
    setState(() => _loadingPets = true);
    try {
      final pets = await PetsService.getMyPets();
      setState(() {
        _pets = pets;
        _loadingPets = false;
      });
    } catch (e) {
      setState(() => _loadingPets = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadAvailableSlots() async {
    setState(() {
      _loadingSlots = true;
      _selectedTime = null;
    });

    try {
      final fecha = DateFormat('yyyy-MM-dd').format(_selectedDate);
      final slots = await AppointmentsService.getAvailableSlots(
          widget.veterinariaId, fecha);

      final now = DateTime.now();
      final isToday = _selectedDate.year == now.year &&
          _selectedDate.month == now.month &&
          _selectedDate.day == now.day;

      setState(() {
        _availableSlots = slots.where((slot) {
          if (slot['disponible'] != true) return false;

          // Si es hoy, filtrar horas pasadas
          if (isToday) {
            final slotTime = slot['hora'] as String;
            final parts = slotTime.split(':');
            final slotHour = int.parse(parts[0]);
            final slotMinute = int.parse(parts[1]);

            final slotDateTime = DateTime(
              now.year,
              now.month,
              now.day,
              slotHour,
              slotMinute,
            );

            return slotDateTime.isAfter(now);
          }

          return true;
        }).toList();
        _loadingSlots = false;
      });
    } catch (e) {
      setState(() => _loadingSlots = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _createAppointment() async {
    if (_selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Seleccione una hora'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_selectedServices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Seleccione al menos un servicio'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_selectedPets.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Seleccione al menos una mascota'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _creatingAppointment = true);

    try {
      final payload = {
        'veterinaria_id': widget.veterinariaId,
        'fecha': DateFormat('yyyy-MM-dd').format(_selectedDate),
        'hora': _selectedTime,
        'servicios': _selectedServices,
        'mascotas': _selectedPets,
        'notas_cliente': _notasController.text.trim().isNotEmpty
            ? _notasController.text.trim()
            : null,
      };

      await AppointmentsService.createAppointment(payload);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cita agendada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() => _creatingAppointment = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: now,
      lastDate: now.add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: softGreen,
              onPrimary: white,
              surface: white,
              onSurface: darkGreen,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
      _loadAvailableSlots();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mint,
      appBar: AppBar(
        title: Text(
          'Agendar Cita',
          style: const TextStyle(
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Veterinaria info
            Container(
              width: double.infinity,
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.veterinariaNombre,
                    style: const TextStyle(
                      color: darkGreen,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Date selector
            _buildSectionTitle('Fecha'),
            const SizedBox(height: 8),
            InkWell(
              onTap: _selectDate,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: softGreen, width: 2),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, color: softGreen),
                        const SizedBox(width: 12),
                        Text(
                          DateFormat('EEEE, d MMMM yyyy', 'es')
                              .format(_selectedDate),
                          style: const TextStyle(
                            color: darkGreen,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const Icon(Icons.arrow_drop_down, color: softGreen),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Time slots
            _buildSectionTitle('Hora'),
            const SizedBox(height: 8),
            _buildTimeSlots(),
            const SizedBox(height: 24),

            // Services
            _buildSectionTitle('Servicios'),
            const SizedBox(height: 8),
            _buildServicesList(),
            const SizedBox(height: 24),

            // Pets
            _buildSectionTitle('Mascotas'),
            const SizedBox(height: 8),
            _buildPetsList(),
            const SizedBox(height: 24),

            // Notes
            _buildSectionTitle('Motivo de la consulta'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: lightGreen, width: 2),
              ),
              child: TextField(
                controller: _notasController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Describe los síntomas o motivo de la consulta...',
                  hintStyle: TextStyle(
                    color: darkGreen.withOpacity(0.5),
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                ),
                style: const TextStyle(
                  color: darkGreen,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Confirm button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _creatingAppointment ? null : _createAppointment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: softGreen,
                  foregroundColor: white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _creatingAppointment
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Confirmar Cita',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
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

  Widget _buildTimeSlots() {
    if (_loadingSlots) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: CircularProgressIndicator(color: softGreen),
        ),
      );
    }

    if (_availableSlots.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            'No hay horarios disponibles para esta fecha',
            style: TextStyle(
              color: darkGreen.withOpacity(0.6),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _availableSlots.map((slot) {
        final hora = slot['hora'];
        final isSelected = _selectedTime == hora;
        return InkWell(
          onTap: () => setState(() => _selectedTime = hora),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? softGreen : white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? softGreen : lightGreen,
                width: 2,
              ),
            ),
            child: Text(
              _formatTime(hora),
              style: TextStyle(
                color: isSelected ? white : darkGreen,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildServicesList() {
    if (_loadingServices) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: CircularProgressIndicator(color: softGreen),
        ),
      );
    }

    if (_services.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            'No hay servicios disponibles',
            style: TextStyle(
              color: darkGreen.withOpacity(0.6),
              fontSize: 14,
            ),
          ),
        ),
      );
    }

    return Column(
      children: _services.map((service) {
        final servicioId = service['servicio_id'];
        final isSelected = _selectedServices.contains(servicioId);
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? softGreen : lightGreen,
              width: 2,
            ),
          ),
          child: CheckboxListTile(
            value: isSelected,
            onChanged: (value) {
              setState(() {
                if (value == true) {
                  _selectedServices.add(servicioId);
                } else {
                  _selectedServices.remove(servicioId);
                }
              });
            },
            title: Text(
              service['servicio_nombre'] ?? 'Sin nombre',
              style: const TextStyle(
                color: darkGreen,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: service['servicio_descripcion'] != null
                ? Text(
                    service['servicio_descripcion'],
                    style: TextStyle(
                      color: darkGreen.withOpacity(0.6),
                      fontSize: 12,
                    ),
                  )
                : null,
            activeColor: softGreen,
            checkColor: white,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPetsList() {
    if (_loadingPets) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: CircularProgressIndicator(color: softGreen),
        ),
      );
    }

    if (_pets.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Column(
            children: [
              Text(
                'No tienes mascotas registradas',
                style: TextStyle(
                  color: darkGreen.withOpacity(0.6),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Registrar mascota'),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: _pets.map((pet) {
        final petId = pet['id'];
        final isSelected = _selectedPets.contains(petId);
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? softGreen : lightGreen,
              width: 2,
            ),
          ),
          child: CheckboxListTile(
            value: isSelected,
            onChanged: (value) {
              setState(() {
                if (value == true) {
                  _selectedPets.add(petId);
                } else {
                  _selectedPets.remove(petId);
                }
              });
            },
            title: Text(
              pet['nombre'] ?? 'Sin nombre',
              style: const TextStyle(
                color: darkGreen,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: pet['especie_nombre'] != null ||
                    pet['raza_nombre'] != null
                ? Text(
                    [
                      if (pet['especie_nombre'] != null) pet['especie_nombre'],
                      if (pet['raza_nombre'] != null) pet['raza_nombre'],
                    ].join(' - '),
                    style: TextStyle(
                      color: darkGreen.withOpacity(0.6),
                      fontSize: 12,
                    ),
                  )
                : null,
            activeColor: softGreen,
            checkColor: white,
          ),
        );
      }).toList(),
    );
  }

  String _formatTime(String time24) {
    try {
      final parts = time24.split(':');
      int hour = int.parse(parts[0]);
      final minute = parts[1];
      final period = hour >= 12 ? 'pm' : 'am';
      if (hour > 12) hour -= 12;
      if (hour == 0) hour = 12;
      return '$hour:$minute $period';
    } catch (e) {
      return time24;
    }
  }
}
