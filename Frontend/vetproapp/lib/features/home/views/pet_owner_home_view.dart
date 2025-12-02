import 'package:flutter/material.dart';
import '../../../app/config/theme.dart';
import '../../../app/services/pets_service.dart';
import '../../../app/services/appointments_service.dart';
import '../../../app/services/recommendations_service.dart';
import '../../profile/profile_menu_screen.dart';
import '../../pets/pet_detail_screen.dart';
import '../widgets/veterinary_map_card.dart';

class PetOwnerHomeView extends StatefulWidget {
  final String? userName;
  final VoidCallback onDataReload;

  const PetOwnerHomeView({
    super.key,
    this.userName,
    required this.onDataReload,
  });

  @override
  State<PetOwnerHomeView> createState() => _PetOwnerHomeViewState();
}

class _PetOwnerHomeViewState extends State<PetOwnerHomeView> {
  List<dynamic> _userPets = [];
  Map<String, dynamic>? _nextAppointment;
  List<dynamic> _especies = [];
  List<dynamic> _recommendations = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void didUpdateWidget(PetOwnerHomeView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Recargar datos cuando el widget se actualiza
    _loadUserData();
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
            (id) => RecommendationsService.getRecommendations(especieId: id),
          ),
        );
        for (final list in recResults) {
          recs.addAll(list);
        }
        // Eliminar duplicados
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
      // Silenciar
    }
  }

  String _getAnimalIcon(int? especieId) {
    if (especieId == null) return '🐾';
    switch (especieId) {
      case 1:
        return '🐕';
      case 2:
        return '🐈';
      case 3:
        return '🦜';
      case 4:
        return '🐹';
      case 5:
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
          'Dic',
        ];
        dateText = '${dateTime.day} ${months[dateTime.month - 1]}';
      }

      final hour = dateTime.hour > 12
          ? dateTime.hour - 12
          : (dateTime.hour == 0 ? 12 : dateTime.hour);
      final period = dateTime.hour >= 12 ? 'PM' : 'AM';
      final minute = dateTime.minute.toString().padLeft(2, '0');

      return '$dateText - $hour:$minute $period';
    } catch (e) {
      return '';
    }
  }

  String _getAppointmentDescription() {
    if (_nextAppointment == null) return '';

    // Obtener nombres de mascotas
    final mascotasArray = _nextAppointment!['mascota_nombres'];
    String mascotasText = '';
    if (mascotasArray != null &&
        mascotasArray is List &&
        mascotasArray.isNotEmpty) {
      mascotasText = mascotasArray.join(', ');
    }

    // Obtener nombres de servicios
    final serviciosArray = _nextAppointment!['servicio_nombres'];
    String serviciosText = '';
    if (serviciosArray != null &&
        serviciosArray is List &&
        serviciosArray.isNotEmpty) {
      serviciosText = serviciosArray.join(', ');
    }

    // Construir el texto final
    if (mascotasText.isNotEmpty && serviciosText.isNotEmpty) {
      return '$mascotasText - $serviciosText';
    } else if (mascotasText.isNotEmpty) {
      return mascotasText;
    } else if (serviciosText.isNotEmpty) {
      return serviciosText;
    } else {
      return 'Cita programada';
    }
  }

  @override
  Widget build(BuildContext context) {
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
                                '${widget.userName ?? ''} 👋',
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

                // Map card - Mapa interactivo de veterinarias
                const VeterinaryMapCard(),
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
                    onTap: () async {
                      await Navigator.pushNamed(context, '/my_appointments');
                      // Recargar datos después de volver de mis citas
                      _loadUserData();
                      widget.onDataReload();
                    },
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
                              _nextAppointment!['fecha_hora'],
                            ),
                            style: const TextStyle(
                              color: darkGreen,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _getAppointmentDescription(),
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
                      style: TextStyle(color: Colors.grey, fontSize: 14),
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
                      onPressed: () async {
                        await Navigator.pushNamed(context, '/my_pets');
                        _loadUserData();
                      },
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
                  ...(_userPets.take(3).map(
                        (pet) => GestureDetector(
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PetDetailScreen(pet: pet),
                              ),
                            );
                            _loadUserData();
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: vetproGreen.withOpacity(0.3),
                              ),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                          ),
                        ),
                      )),
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
                        Icon(
                          Icons.lightbulb_outline,
                          color: Colors.grey.shade400,
                          size: 32,
                        ),
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
                          Icon(
                            Icons.arrow_forward_ios,
                            color: vetproGreen,
                            size: 20,
                          ),
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
}
