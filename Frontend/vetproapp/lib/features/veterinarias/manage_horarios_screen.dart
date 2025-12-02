import 'package:flutter/material.dart';
import '../../../app/config/theme.dart';
import '../../../app/services/horarios_service.dart';

class ManageHorariosScreen extends StatefulWidget {
  final int veterinariaId;

  const ManageHorariosScreen({
    Key? key,
    required this.veterinariaId,
  }) : super(key: key);

  @override
  State<ManageHorariosScreen> createState() => _ManageHorariosScreenState();
}

class _ManageHorariosScreenState extends State<ManageHorariosScreen> {
  bool _loading = true;
  bool _saving = false;

  final List<String> _diasSemana = [
    'Lunes',
    'Martes',
    'Miércoles',
    'Jueves',
    'Viernes',
    'Sábado',
    'Domingo',
  ];

  // Mapa para almacenar los horarios de cada día
  // key: día de la semana (1-7, donde 1=Lunes, 7=Domingo), value: lista de horarios
  Map<int, List<Map<String, dynamic>>> _horariosPorDia = {};

  // Mapeo de índice visual (0-6) a día de semana en BD (0=Domingo, 1=Lunes...)
  int _getDiaSemanaFromIndex(int visualIndex) {
    // visualIndex: 0=Lunes, 1=Martes, ..., 6=Domingo
    // BD: 0=Domingo, 1=Lunes, 2=Martes...
    if (visualIndex == 6) return 0; // Domingo
    return visualIndex + 1; // Lunes a Sábado
  }

  // int _getIndexFromDiaSemana(int diaSemana) {
  //   // diaSemana: 0=Domingo, 1=Lunes...
  //   // visualIndex: 0=Lunes, 1=Martes, ..., 6=Domingo
  //   if (diaSemana == 0) return 6; // Domingo
  //   return diaSemana - 1; // Lunes a Sábado
  // }

  @override
  void initState() {
    super.initState();
    _loadHorarios();
  }

  Future<void> _loadHorarios() async {
    setState(() => _loading = true);
    try {
      final horarios = await HorariosService.getHorarios(widget.veterinariaId);

      // Organizar horarios por día
      final Map<int, List<Map<String, dynamic>>> temp = {};
      for (var horario in horarios) {
        final dia = horario['dia_semana'] as int;
        if (!temp.containsKey(dia)) {
          temp[dia] = [];
        }
        // Verificar si es horario de 24 horas
        final inicio = horario['hora_inicio'];
        final fin = horario['hora_fin'];
        final is24h = inicio == '00:00' && (fin == '23:59' || fin == '24:00');

        temp[dia]!.add({
          'hora_inicio': horario['hora_inicio'],
          'hora_fin': horario['hora_fin'],
          'disponible': horario['disponible'] ?? true,
          'is24Hours': is24h,
        });
      }

      setState(() {
        _horariosPorDia = temp;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
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

  Future<void> _saveHorarios() async {
    setState(() => _saving = true);
    try {
      // Convertir el mapa a lista plana
      List<Map<String, dynamic>> todosLosHorarios = [];
      _horariosPorDia.forEach((dia, horarios) {
        for (var horario in horarios) {
          if (horario['disponible'] == true) {
            // Si es 24 horas, usar 00:00 - 23:59
            final is24h = horario['is24Hours'] ?? false;
            todosLosHorarios.add({
              'dia_semana': dia,
              'hora_inicio': is24h ? '00:00' : horario['hora_inicio'],
              'hora_fin': is24h ? '23:59' : horario['hora_fin'],
              'disponible': true,
            });
          }
        }
      });

      await HorariosService.replaceAllHorarios(
        widget.veterinariaId,
        todosLosHorarios,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Horarios guardados exitosamente'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _addHorario(int visualIndex) {
    final dia = _getDiaSemanaFromIndex(visualIndex);
    setState(() {
      if (!_horariosPorDia.containsKey(dia)) {
        _horariosPorDia[dia] = [];
      }
      _horariosPorDia[dia]!.add({
        'hora_inicio': '08:00',
        'hora_fin': '16:00',
        'disponible': true,
        'is24Hours': false,
      });
    });
  }

  void _removeHorario(int visualIndex, int horarioIndex) {
    final dia = _getDiaSemanaFromIndex(visualIndex);
    setState(() {
      if (_horariosPorDia[dia] != null &&
          _horariosPorDia[dia]!.length > horarioIndex) {
        _horariosPorDia[dia]!.removeAt(horarioIndex);
        if (_horariosPorDia[dia]!.isEmpty) {
          _horariosPorDia.remove(dia);
        }
      }
    });
  }

  void _updateHorario(
      int visualIndex, int horarioIndex, Map<String, dynamic> newHorario) {
    final dia = _getDiaSemanaFromIndex(visualIndex);
    setState(() {
      if (_horariosPorDia[dia] != null &&
          _horariosPorDia[dia]!.length > horarioIndex) {
        _horariosPorDia[dia]![horarioIndex] = newHorario;
      }
    });
  }

  List<Map<String, dynamic>> _getHorariosForDay(int visualIndex) {
    final dia = _getDiaSemanaFromIndex(visualIndex);
    return _horariosPorDia[dia] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mint,
      appBar: AppBar(
        title: const Text(
          'Días Laborales',
          style: TextStyle(
            color: darkGreen,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: mint,
        foregroundColor: darkGreen,
        elevation: 0,
        iconTheme: const IconThemeData(color: darkGreen),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: 7,
                    itemBuilder: (context, visualIndex) {
                      final horarios = _getHorariosForDay(visualIndex);
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (visualIndex > 0) const SizedBox(height: 24),

                          // Nombre del día
                          Text(
                            _diasSemana[visualIndex],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: darkGreen,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Horarios del día
                          if (horarios.isEmpty)
                            _buildEmptyHorario(visualIndex)
                          else
                            ...horarios.asMap().entries.map((entry) {
                              final horarioIndex = entry.key;
                              final horario = entry.value;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _buildHorarioRow(
                                  visualIndex,
                                  horarioIndex,
                                  horario,
                                ),
                              );
                            }).toList(),

                          // Botón para agregar más horarios
                          if (horarios.isNotEmpty)
                            TextButton.icon(
                              onPressed: () => _addHorario(visualIndex),
                              icon: const Icon(Icons.add, size: 18),
                              label: const Text('Agregar otro horario'),
                              style: TextButton.styleFrom(
                                foregroundColor: softGreen,
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),

                // Botón Guardar fijo en la parte inferior
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: mint,
                    border: Border(
                      top: BorderSide(color: lightGreen, width: 1),
                    ),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _saving ? null : _saveHorarios,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: lightGreen,
                        foregroundColor: darkGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: _saving
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: darkGreen,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Guardar',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildEmptyHorario(int visualIndex) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: lightGreen.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          const Text(
            'Sin horarios configurados',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () => _addHorario(visualIndex),
            icon: const Icon(Icons.add),
            label: const Text('Agregar horario'),
            style: TextButton.styleFrom(
              foregroundColor: softGreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHorarioRow(
      int visualIndex, int horarioIndex, Map<String, dynamic> horario) {
    final is24Hours = horario['is24Hours'] ?? false;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Hora de inicio
              Expanded(
                child: is24Hours
                    ? _buildTimeField(
                        label: 'Hora de inicio',
                        time: '00:00',
                        onTap: () {},
                      )
                    : _buildTimeField(
                        label: 'Hora de inicio',
                        time: horario['hora_inicio'],
                        onTap: () => _pickTime(visualIndex, horarioIndex, true),
                      ),
              ),
              const SizedBox(width: 16),

              // Hora de fin
              Expanded(
                child: is24Hours
                    ? _buildTimeField(
                        label: 'Hora de fin',
                        time: '23:59',
                        onTap: () {},
                      )
                    : _buildTimeField(
                        label: 'Hora de fin',
                        time: horario['hora_fin'],
                        onTap: () =>
                            _pickTime(visualIndex, horarioIndex, false),
                      ),
              ),
              const SizedBox(width: 16),

              // Switch disponible
              Switch(
                value: horario['disponible'] ?? true,
                onChanged: (value) {
                  _updateHorario(visualIndex, horarioIndex, {
                    ...horario,
                    'disponible': value,
                  });
                },
                activeColor: softGreen,
                activeTrackColor: softGreen.withOpacity(0.5),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Checkbox de 24 horas y botón eliminar
          Row(
            children: [
              Checkbox(
                value: is24Hours,
                onChanged: (value) {
                  _updateHorario(visualIndex, horarioIndex, {
                    ...horario,
                    'is24Hours': value ?? false,
                    'hora_inicio': (value ?? false) ? '00:00' : '08:00',
                    'hora_fin': (value ?? false) ? '23:59' : '16:00',
                  });
                },
                activeColor: softGreen,
              ),
              const Text(
                '24 horas',
                style: TextStyle(
                  fontSize: 14,
                  color: darkGreen,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () => _removeHorario(visualIndex, horarioIndex),
                tooltip: 'Eliminar horario',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeField({
    required String label,
    required String time,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _formatTime(time),
            style: const TextStyle(
              fontSize: 16,
              color: darkGreen,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(String time) {
    // Convertir formato 24h a 12h con am/pm
    final parts = time.split(':');
    if (parts.length < 2) return time;

    int hour = int.tryParse(parts[0]) ?? 0;
    final minute = parts[1];

    final period = hour >= 12 ? 'p.m.' : 'a.m.';
    if (hour > 12) hour -= 12;
    if (hour == 0) hour = 12;

    return '${hour.toString().padLeft(2, '0')}:$minute $period';
  }

  Future<void> _pickTime(
      int visualIndex, int horarioIndex, bool isInicio) async {
    final horarios = _getHorariosForDay(visualIndex);
    if (horarioIndex >= horarios.length) return;

    final horario = horarios[horarioIndex];
    final currentTime = isInicio ? horario['hora_inicio'] : horario['hora_fin'];
    final parts = currentTime.split(':');

    final initialTime = TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 8,
      minute: int.tryParse(parts[1]) ?? 0,
    );

    final time = await showTimePicker(
      context: context,
      initialTime: initialTime,
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

    if (time != null) {
      final newTime =
          '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
      _updateHorario(visualIndex, horarioIndex, {
        ...horario,
        isInicio ? 'hora_inicio' : 'hora_fin': newTime,
      });
    }
  }
}
