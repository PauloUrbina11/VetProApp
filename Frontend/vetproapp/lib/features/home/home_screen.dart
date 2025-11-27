import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../app/config/theme.dart';
import '../../../app/services/auth_service.dart';
import '../../../app/services/admin_service.dart';
import '../../../app/services/user_service.dart';
import '../../../app/services/pets_service.dart';
import '../../../app/services/appointments_service.dart';
import '../../../app/services/recommendations_service.dart';
import '../../../app/services/veterinaria_service.dart';
import '../profile/profile_menu_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int? _userRole;
  bool _loading = true;
  String? _userName; // para saludo
  String? _veterinariaNombre; // nombre de veterinaria para rol 2
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // Stats data
  Map<String, dynamic>? _globalStats;
  // Removido _userStats, reemplazado por _vetStats para rol 2
  List<dynamic> _recentActivity = [];

  // User data
  List<dynamic> _userPets = [];
  Map<String, dynamic>? _nextAppointment;
  List<dynamic> _especies = [];
  List<dynamic> _recommendations = [];
  // Veterinaria data (role 2)
  int? _veterinariaId;
  Map<String, dynamic>?
      _vetStats; // { totalCitas, citasPendientes, citasCompletadas, mascotasAtendidas }
  List<dynamic> _vetNextAppointments = [];
  Map<DateTime, int> _vetCalendarCounts = {};
  bool _vetIsAdmin = false; // reservado para futura lógica de admin veterinaria

  String _greetingText() {
    return '${_userName ?? ''}${_userRole == 2 && _veterinariaNombre != null ? ' - ' + _veterinariaNombre! : ''} 👋';
  }

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _refreshUserName() async {
    try {
      final profile = await UserService.getMyProfile();
      if (mounted && profile != null) {
        setState(() {
          _userName = profile['nombre_completo'];
        });
      }
    } catch (e) {
      // Silenciar
    }
  }

  Future<void> _loadUserRole() async {
    try {
      final role = await AuthService.getRole();
      setState(() => _userRole = role);

      // cargar nombre de perfil (independiente del rol)
      final profile = await UserService.getMyProfile();
      setState(() => _userName = profile?['nombre_completo']);

      if (role == 1) {
        final stats = await AdminService.getGlobalStats();
        final activity = await AdminService.getRecentActivity();
        setState(() {
          _globalStats = stats;
          _recentActivity = activity;
        });
      } else if (role == 3) {
        await _loadUserData();
      } else if (role == 2) {
        await _loadVeterinariaData();
      }
    } catch (e) {
      // Silenciar errores en producción; opcional: enviar a logging central
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _loadUserData() async {
    try {
      final results = await Future.wait([
        PetsService.getMyPets(),
        AppointmentsService.getNextAppointment(),
        PetsService.getEspecies(),
      ]);

      final pets = results[0] as List<dynamic>;
      final nextAppt = results[1] as Map<String, dynamic>?;
      final especies = results[2] as List<dynamic>;

      // Obtener especies únicas de las mascotas del usuario
      final speciesIds = pets
          .map((p) => p['especie_id'])
          .where((id) => id != null)
          .toSet()
          .cast<int>()
          .toList();

      // Cargar recomendaciones solo para esas especies
      List<dynamic> recs = [];
      if (speciesIds.isNotEmpty) {
        final recResults = await Future.wait(
          speciesIds.map(
              (id) => RecommendationsService.getRecommendations(especieId: id)),
        );
        for (final list in recResults) {
          recs.addAll(list);
        }
        // Opcional: eliminar duplicados si una recomendación aparece varias veces
        final seen = <int>{};
        recs = recs.where((r) {
          final rid = r['id'] as int?;
          if (rid == null) return true;
          if (seen.contains(rid)) return false;
          seen.add(rid);
          return true;
        }).toList();
      }

      setState(() {
        _userPets = pets;
        _nextAppointment = nextAppt;
        _especies = especies;
        _recommendations = recs;
      });
    } catch (e) {
      // Silenciar; opcional enviar a logging
    }
  }

  Future<void> _loadVeterinariaData() async {
    try {
      // Obtener veterinarias asociadas al usuario (tomamos la primera por ahora)
      final vets = await VeterinariaService.getMyVeterinarias();
      if (vets.isEmpty) return; // Usuario sin asociación
      _veterinariaId = vets.first;

      // Obtener nombre de la veterinaria y demás datos en paralelo
      final now = DateTime.now();
      final firstDay = DateTime(now.year, now.month, 1);
      final lastDay = DateTime(now.year, now.month + 1, 0);
      final fromDate = firstDay.toIso8601String().split('T')[0];
      final toDate = lastDay.toIso8601String().split('T')[0];

      final results = await Future.wait([
        VeterinariaService.getVeterinaria(_veterinariaId!),
        VeterinariaService.getDashboard(_veterinariaId!),
        VeterinariaService.getCalendarCounts(_veterinariaId!, fromDate, toDate),
      ]);

      final vetInfo = results[0] as Map<String, dynamic>;
      final dashboard = results[1] as Map<String, dynamic>;
      final calendarRaw = results[2] as List<dynamic>;

      final Map<DateTime, int> calMap = {};
      for (final item in calendarRaw) {
        final fecha = DateTime.parse(item['fecha']);
        calMap[DateTime(fecha.year, fecha.month, fecha.day)] =
            item['cantidad'] as int? ?? 0;
      }

      setState(() {
        _veterinariaNombre = vetInfo['nombre'] as String?;
        _vetStats = dashboard['stats'] as Map<String, dynamic>;
        _vetNextAppointments = dashboard['nextAppointments'] as List<dynamic>;
        _vetIsAdmin = dashboard['isAdmin'] as bool? ?? false;
        _vetCalendarCounts = calMap;
      });
    } catch (e) {
      // Silenciar errores iniciales
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Rol 1 = Admin, Rol 2 = Veterinaria, Rol 3 = Dueño de mascota
    if (_userRole == 1) {
      return _buildAdminHome();
    } else if (_userRole == 2) {
      return _buildVeterinaryHome();
    } else {
      return _buildPetOwnerHome();
    }
  }

  Widget _buildPetOwnerHome() {
    final bool hasAppointment = _nextAppointment != null;

    return Scaffold(
      backgroundColor: mint,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: settings, search, profile
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
                                  fontFamily: 'Montserrat',
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
                                _greetingText(),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
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
                          await Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => const ProfileMenuScreen(),
                          ));
                          _refreshUserName();
                        },
                        icon: const Icon(Icons.person),
                        color: vetproGreen,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // Veterinarias cercanas
                Text(
                  'Veterinarias cercanas',
                  style: TextStyle(
                    color: vetproGreen,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                // Map card
                Container(
                  width: double.infinity,
                  height: 140,
                  decoration: BoxDecoration(
                    color: softGreen,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  padding: const EdgeInsets.all(14),
                  child: Container(
                    decoration: BoxDecoration(
                      color: white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Image.asset(
                        'assets/images/paw_white.png',
                        width: 120,
                        height: 70,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // Próxima cita
                Text(
                  'Próxima cita',
                  style: TextStyle(
                    color: vetproGreen,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                // Mostrar cita o mensaje
                if (hasAppointment)
                  GestureDetector(
                    onTap: () =>
                        Navigator.pushNamed(context, '/my_appointments'),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: lightGreen,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _formatAppointmentDate(
                                _nextAppointment!['fecha_hora']),
                            style: const TextStyle(
                              color: darkGreen,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          if (_nextAppointment!['notas_cliente'] != null)
                            Text(
                              _nextAppointment!['notas_cliente'],
                              style: const TextStyle(
                                color: darkGreen,
                                fontSize: 14,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                  )
                else
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'No hay citas programadas',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ),

                const SizedBox(height: 18),

                // Mis mascotas
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Mis mascotas',
                      style: TextStyle(
                        color: vetproGreen,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/my_pets'),
                      child: const Text('Ver todas'),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Lista de mascotas
                if (_userPets.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        'No hay mascotas registradas',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ),
                  )
                else
                  ...(_userPets.take(3).map((pet) => Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border:
                              Border.all(color: vetproGreen.withOpacity(0.3)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Text(
                              _getAnimalIcon(pet['especie_id']),
                              style: const TextStyle(fontSize: 32),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    pet['nombre'] ?? 'Sin nombre',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _getEspecieName(pet['especie_id']),
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.chevron_right, color: vetproGreen),
                          ],
                        ),
                      ))),

                const SizedBox(height: 18),

                // Recomendaciones
                Text(
                  'Recomendaciones',
                  style: TextStyle(
                    color: vetproGreen,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                if (_recommendations.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.lightbulb_outline,
                            color: Colors.grey.shade400, size: 32),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'No hay recomendaciones disponibles',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  GestureDetector(
                    onTap: () =>
                        Navigator.pushNamed(context, '/recommendations'),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: lightGreen.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _recommendations[0]['titulo'] ??
                                      'Recomendación',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: vetproGreen,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _recommendations[0]['descripcion'] ?? '',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade700,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(Icons.arrow_forward_ios,
                              color: vetproGreen, size: 20),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  int _getVetCountForDay(DateTime day) {
    final key = DateTime(day.year, day.month, day.day);
    return _vetCalendarCounts[key] ?? 0;
  }

  Widget _buildVeterinaryHome() {
    return Scaffold(
      backgroundColor: mint,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: settings, search, profile
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
                                  fontFamily: 'Montserrat',
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
                                _greetingText(),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
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
                          await Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => const ProfileMenuScreen(),
                          ));
                          _refreshUserName();
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

                // Stats cards row (4)
                Row(
                  children: [
                    Expanded(
                        child: _buildStatCard(
                            'Citas',
                            '${_vetStats?['totalCitas'] ?? 0}',
                            Icons.event,
                            Colors.blue)),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _buildStatCard(
                            'Pendientes',
                            '${_vetStats?['citasPendientes'] ?? 0}',
                            Icons.pending_actions,
                            Colors.orange)),
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
                            Colors.green)),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _buildStatCard(
                            'Mascotas',
                            '${_vetStats?['mascotasAtendidas'] ?? 0}',
                            Icons.pets,
                            Colors.purple)),
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

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  // Método original de usuario se mantiene sólo si role 3 activo

  Color _getColorForCount(int count) {
    if (count == 0) return Colors.transparent;
    if (count <= 2) return lightGreen;
    if (count <= 5) return softGreen;
    return darkGreen;
  }

  Widget _buildAdminHome() {
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
                                  fontFamily: 'Montserrat',
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
                                '${_userName ?? ''} 👋',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
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
                          await Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => const ProfileMenuScreen(),
                          ));
                          _refreshUserName();
                        },
                        icon: const Icon(Icons.person),
                        color: vetproGreen,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // Estadísticas generales
                Text(
                  'Estadísticas Globales',
                  style: TextStyle(
                    color: vetproGreen,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                // Grid de estadísticas
                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1.5,
                  children: [
                    _buildStatCard(
                        'Usuarios',
                        '${_globalStats?['totalUsuarios'] ?? 0}',
                        Icons.people,
                        Colors.blue.shade400),
                    _buildStatCard(
                        'Veterinarias',
                        '${_globalStats?['totalVeterinarias'] ?? 0}',
                        Icons.local_hospital,
                        Colors.green.shade400),
                    _buildStatCard(
                        'Mascotas',
                        '${_globalStats?['totalMascotas'] ?? 0}',
                        Icons.pets,
                        Colors.orange.shade400),
                    _buildStatCard(
                        'Citas Hoy',
                        '${_globalStats?['citasHoy'] ?? 0}',
                        Icons.calendar_today,
                        Colors.purple.shade400),
                  ],
                ),

                const SizedBox(height: 18),

                // Gestión rápida
                Text(
                  'Gestión Rápida',
                  style: TextStyle(
                    color: vetproGreen,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                _buildAdminActionCard(
                  'Asignar Roles',
                  'Asignar roles a usuarios del sistema',
                  Icons.security,
                  Colors.blue,
                  () => Navigator.pushNamed(context, '/manage_roles'),
                ),

                _buildAdminActionCard(
                  'Crear Veterinaria',
                  'Registrar nueva clínica y asociar usuario',
                  Icons.add_business,
                  Colors.green,
                  () => Navigator.pushNamed(context, '/create_veterinaria'),
                ),

                _buildAdminActionCard(
                  'Gestión de Citas',
                  'Ver todas las citas del sistema',
                  Icons.calendar_month,
                  Colors.orange,
                  () => Navigator.pushNamed(context, '/manage_appointments'),
                ),

                _buildAdminActionCard(
                  'Gestión de Servicios',
                  'Administrar servicios disponibles',
                  Icons.miscellaneous_services,
                  Colors.purple,
                  () => Navigator.pushNamed(context, '/manage_services'),
                ),

                const SizedBox(height: 18),

                // Actividad reciente
                Text(
                  'Actividad Reciente',
                  style: TextStyle(
                    color: vetproGreen,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                if (_recentActivity.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        'No hay actividad reciente',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ),
                  )
                else
                  ..._recentActivity.map((activity) {
                    final iconData = _getIconData(activity['icon'] ?? 'event');
                    final color =
                        _getColorFromString(activity['color'] ?? 'blue');
                    final time = _formatTime(activity['time']);

                    return _buildActivityItem(
                      activity['title'] ?? 'Actividad',
                      activity['description'] ?? '',
                      time,
                      iconData,
                      color,
                    );
                  }).toList(),

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
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminActionCard(String title, String description, IconData icon,
      Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: color.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(12),
          color: color.withOpacity(0.05),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
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
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: color),
          ],
        ),
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'person_add':
        return Icons.person_add;
      case 'add_business':
        return Icons.add_business;
      case 'event_available':
        return Icons.event_available;
      default:
        return Icons.event;
    }
  }

  Color _getColorFromString(String colorName) {
    switch (colorName) {
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'orange':
        return Colors.orange;
      case 'red':
        return Colors.red;
      case 'purple':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _formatTime(String? isoTime) {
    if (isoTime == null) return '';

    try {
      final dateTime = DateTime.parse(isoTime);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inMinutes < 1) {
        return 'Ahora';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes} min';
      } else if (difference.inHours < 24) {
        return '${difference.inHours} h';
      } else if (difference.inDays < 30) {
        return '${difference.inDays} d';
      } else {
        return '${(difference.inDays / 30).floor()} mes';
      }
    } catch (e) {
      return '';
    }
  }

  String _formatAppointmentDate(String? isoDateTime) {
    if (isoDateTime == null) return '';

    try {
      final dateTime = DateTime.parse(isoDateTime);
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

  String _getAnimalIcon(int? especieId) {
    if (especieId == null) return '🐾';
    switch (especieId) {
      case 1: // Perro
        return '🐕';
      case 2: // Gato
        return '🐈';
      case 3: // Ave
        return '🦜';
      case 4: // Roedor
        return '🐹';
      case 5: // Reptil
        return '🦎';
      default:
        return '🐾';
    }
  }

  String _getEspecieName(int? especieId) {
    if (especieId == null) return 'Desconocido';

    final especie = _especies.firstWhere(
      (e) => e['id'] == especieId,
      orElse: () => {'nombre': 'Desconocido'},
    );

    return especie['nombre'] ?? 'Desconocido';
  }

  Widget _buildActivityItem(String title, String description, String time,
      IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
