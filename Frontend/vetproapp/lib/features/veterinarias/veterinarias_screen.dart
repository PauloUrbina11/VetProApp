import 'package:flutter/material.dart';
import '../../app/config/theme.dart';
import '../../app/services/auth_service.dart';
import '../../app/services/veterinaria_service.dart';
import '../../app/services/horarios_service.dart';
import 'manage_horarios_screen.dart';
import '../appointments/schedule_appointment_screen.dart';

class VeterinariasScreen extends StatefulWidget {
  const VeterinariasScreen({super.key});

  @override
  State<VeterinariasScreen> createState() => _VeterinariasScreenState();
}

class _VeterinariasScreenState extends State<VeterinariasScreen> {
  bool _loading = true;
  List<dynamic> _veterinarias = [];
  List<dynamic> _filteredVeterinarias = [];
  int? _userRole;
  String? _error;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final role = await AuthService.getRole();
      final veterinarias = await VeterinariaService.getAllVeterinarias();

      setState(() {
        _userRole = role;
        _veterinarias = veterinarias;
        _filteredVeterinarias = veterinarias;
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

  void _filterVeterinarias(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredVeterinarias = _veterinarias;
      } else {
        _filteredVeterinarias = _veterinarias.where((vet) {
          final nombre = (vet['nombre'] ?? '').toString().toLowerCase();
          final direccion = (vet['direccion'] ?? '').toString().toLowerCase();
          final searchLower = query.toLowerCase();
          return nombre.contains(searchLower) ||
              direccion.contains(searchLower);
        }).toList();
      }
    });
  }

  Future<void> _showVeterinariaDetail(dynamic veterinaria) async {
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => VeterinariaDetailScreen(
                veterinaria: veterinaria, isAdmin: _userRole == 1)));
    if (result == true) {
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: mint,
        appBar: AppBar(
            title: const Text('Veterinarias',
                style: TextStyle(fontWeight: FontWeight.bold)),
            backgroundColor: softGreen,
            foregroundColor: white,
            elevation: 0),
        floatingActionButton: _userRole == 1
            ? FloatingActionButton(
                onPressed: () async {
                  final result =
                      await Navigator.pushNamed(context, '/create_veterinaria');
                  if (result == true) {
                    _loadData();
                  }
                },
                backgroundColor: softGreen,
                child: const Icon(Icons.add, color: white))
            : null,
        body: _loading
            ? const Center(child: CircularProgressIndicator(color: softGreen))
            : SafeArea(
                child: Column(children: [
                // Barra de búsqueda
                Container(
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                        onChanged: _filterVeterinarias,
                        style: const TextStyle(color: darkGreen),
                        decoration: InputDecoration(
                            filled: true,
                            fillColor: white,
                            hintText: 'Buscar veterinaria...',
                            hintStyle:
                                TextStyle(color: darkGreen.withOpacity(0.5)),
                            prefixIcon: Icon(Icons.search, color: softGreen),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 14, horizontal: 16)))),

                if (_error != null)
                  Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          color: lightGreen.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8)),
                      child: Text(_error!,
                          style: const TextStyle(color: darkGreen))),

                Expanded(
                    child: _filteredVeterinarias.isEmpty
                        ? Center(
                            child: Container(
                                padding: const EdgeInsets.all(24),
                                margin: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                    color: lightGreen.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(18)),
                                child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.local_hospital,
                                          size: 64,
                                          color: darkGreen.withOpacity(0.5)),
                                      const SizedBox(height: 16),
                                      Text(
                                          _searchQuery.isEmpty
                                              ? 'No hay veterinarias registradas'
                                              : 'No se encontraron veterinarias',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                              color: darkGreen, fontSize: 16)),
                                    ])))
                        : RefreshIndicator(
                            onRefresh: _loadData,
                            color: softGreen,
                            child: ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: _filteredVeterinarias.length,
                                itemBuilder: (context, index) {
                                  final vet = _filteredVeterinarias[index];
                                  return _buildVeterinariaCard(vet);
                                }))),
              ])));
  }

  Widget _buildVeterinariaCard(dynamic veterinaria) {
    return Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
            color: white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                  color: darkGreen.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2)),
            ]),
        child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                    color: lightGreen, borderRadius: BorderRadius.circular(8)),
                child: veterinaria['logo_url'] != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(veterinaria['logo_url'],
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                                Icons.local_hospital,
                                color: softGreen)))
                    : const Icon(Icons.local_hospital, color: softGreen)),
            title: Text(veterinaria['nombre'] ?? 'Sin nombre',
                style: const TextStyle(
                    color: darkGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
            subtitle:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(height: 4),
              if (veterinaria['direccion'] != null) ...[
                Row(children: [
                  Icon(Icons.location_on,
                      size: 14, color: darkGreen.withOpacity(0.7)),
                  const SizedBox(width: 4),
                  Expanded(
                      child: Text(
                          '${veterinaria['direccion']}${veterinaria['ciudad'] != null ? ' - ${veterinaria['ciudad']}' : ''}',
                          style: TextStyle(
                              color: darkGreen.withOpacity(0.7), fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis)),
                ]),
                const SizedBox(height: 2),
              ],
              if (veterinaria['telefono'] != null)
                Row(children: [
                  Icon(Icons.phone,
                      size: 14, color: darkGreen.withOpacity(0.7)),
                  const SizedBox(width: 4),
                  Text(veterinaria['telefono'],
                      style: TextStyle(
                          color: darkGreen.withOpacity(0.7), fontSize: 12)),
                ]),
            ]),
            trailing: Icon(Icons.chevron_right, color: softGreen),
            onTap: () => _showVeterinariaDetail(veterinaria)));
  }
}

// Pantalla de detalle de veterinaria
class VeterinariaDetailScreen extends StatefulWidget {
  final dynamic veterinaria;
  final bool isAdmin;

  const VeterinariaDetailScreen({
    super.key,
    required this.veterinaria,
    required this.isAdmin,
  });

  @override
  State<VeterinariaDetailScreen> createState() =>
      _VeterinariaDetailScreenState();
}

class _VeterinariaDetailScreenState extends State<VeterinariaDetailScreen> {
  List<dynamic> _horarios = [];
  bool _loadingHorarios = true;

  @override
  void initState() {
    super.initState();
    _loadHorarios();
  }

  Future<void> _loadHorarios() async {
    setState(() => _loadingHorarios = true);
    try {
      final horarios =
          await HorariosService.getHorarios(widget.veterinaria['id']);
      setState(() {
        _horarios = horarios;
        _loadingHorarios = false;
      });
    } catch (e) {
      setState(() => _loadingHorarios = false);
    }
  }

  Future<void> _editVeterinaria() async {
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                EditVeterinariaScreen(veterinaria: widget.veterinaria)));
    if (result == true && mounted) {
      // Recargar datos
      Navigator.pop(context, true);
    }
  }

  void _scheduleAppointment() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScheduleAppointmentScreen(
          veterinariaId: widget.veterinaria['id'],
          veterinariaNombre: widget.veterinaria['nombre'] ?? 'Veterinaria',
        ),
      ),
    );

    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cita agendada exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vet = widget.veterinaria;
    return Scaffold(
        backgroundColor: mint,
        appBar: AppBar(
            title: Text(vet['nombre'] ?? 'Detalle Veterinaria',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            backgroundColor: softGreen,
            foregroundColor: white,
            elevation: 0),
        body: SingleChildScrollView(
            child: Column(children: [
          // Logo o imagen de cabecera
          Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(color: softGreen),
              child: vet['logo_url'] != null
                  ? Image.network(vet['logo_url'],
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Center(
                          child: Icon(Icons.local_hospital,
                              size: 80, color: white)))
                  : Center(
                      child:
                          Icon(Icons.local_hospital, size: 80, color: white))),

          Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nombre
                    Text(vet['nombre'] ?? 'Sin nombre',
                        style: const TextStyle(
                            color: darkGreen,
                            fontSize: 24,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),

                    // Información en tarjeta
                    Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                            color: white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                  color: darkGreen.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2)),
                            ]),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildInfoSection('Dirección', Icons.location_on,
                                  '${vet['direccion']}${vet['ciudad'] != null ? ' - ${vet['ciudad']}' : ''}'),
                              if (vet['telefono'] != null) ...[
                                const Divider(height: 24),
                                _buildInfoSection(
                                    'Teléfono', Icons.phone, vet['telefono']),
                              ],
                              if (vet['descripcion'] != null) ...[
                                const Divider(height: 24),
                                _buildInfoSection('Descripción',
                                    Icons.info_outline, vet['descripcion']),
                              ],
                              const Divider(height: 24),
                              _buildHorarioSection(),
                            ])),

                    const SizedBox(height: 24),

                    // Botón de acción según rol
                    SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                            onPressed: widget.isAdmin
                                ? _editVeterinaria
                                : _scheduleAppointment,
                            style: ElevatedButton.styleFrom(
                                backgroundColor: widget.isAdmin
                                    ? Colors.blue.shade400
                                    : softGreen,
                                foregroundColor: white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12))),
                            icon:
                                Icon(widget.isAdmin ? Icons.edit : Icons.event),
                            label: Text(
                                widget.isAdmin
                                    ? 'Editar Veterinaria'
                                    : 'Agendar Cita',
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold)))),
                  ])),
        ])));
  }

  Widget _buildHorarioSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          const Icon(Icons.access_time, color: softGreen, size: 20),
          const SizedBox(width: 8),
          const Text(
            'Horario de atención',
            style: TextStyle(
              color: darkGreen,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ]),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.only(left: 28),
          child: _loadingHorarios
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: softGreen,
                  ),
                )
              : _horarios.isEmpty
                  ? Text(
                      'Sin horarios configurados',
                      style: TextStyle(
                        color: darkGreen.withOpacity(0.6),
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _buildHorariosList(),
                    ),
        ),
      ],
    );
  }

  List<Widget> _buildHorariosList() {
    final diasSemana = [
      'Domingo',
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sábado'
    ];

    // Agrupar horarios por día
    Map<int, List<dynamic>> horariosPorDia = {};
    for (var horario in _horarios) {
      final dia = horario['dia_semana'] as int;
      if (!horariosPorDia.containsKey(dia)) {
        horariosPorDia[dia] = [];
      }
      horariosPorDia[dia]!.add(horario);
    }

    // Crear lista de widgets
    List<Widget> widgets = [];

    // Ordenar días (Lunes a Domingo)
    List<int> ordenDias = [1, 2, 3, 4, 5, 6, 0];

    for (int dia in ordenDias) {
      if (horariosPorDia.containsKey(dia)) {
        final horariosDelDia = horariosPorDia[dia]!;

        // Verificar si es 24 horas
        bool es24Horas = horariosDelDia.any((h) =>
            h['hora_inicio'] == '00:00' &&
            (h['hora_fin'] == '23:59' || h['hora_fin'] == '24:00'));

        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                SizedBox(
                  width: 80,
                  child: Text(
                    diasSemana[dia],
                    style: TextStyle(
                      color: darkGreen.withOpacity(0.8),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    es24Horas
                        ? '24 horas'
                        : horariosDelDia.map((h) {
                            return '${_formatTime(h['hora_inicio'])} - ${_formatTime(h['hora_fin'])}';
                          }).join(', '),
                    style: TextStyle(
                      color: darkGreen.withOpacity(0.7),
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }

    return widgets.isEmpty
        ? [
            Text(
              'Sin horarios disponibles',
              style: TextStyle(
                color: darkGreen.withOpacity(0.6),
                fontSize: 13,
                fontStyle: FontStyle.italic,
              ),
            )
          ]
        : widgets;
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

  Widget _buildInfoSection(String title, IconData icon, String value) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(icon, color: softGreen, size: 20),
        const SizedBox(width: 8),
        Text(title,
            style: const TextStyle(
                color: darkGreen, fontWeight: FontWeight.bold, fontSize: 14)),
      ]),
      const SizedBox(height: 8),
      Padding(
          padding: const EdgeInsets.only(left: 28),
          child: Text(value,
              style:
                  TextStyle(color: darkGreen.withOpacity(0.8), fontSize: 14))),
    ]);
  }
}

// Pantalla de edición de veterinaria (solo admin)
class EditVeterinariaScreen extends StatefulWidget {
  final dynamic veterinaria;

  const EditVeterinariaScreen({super.key, required this.veterinaria});

  @override
  State<EditVeterinariaScreen> createState() => _EditVeterinariaScreenState();
}

class _EditVeterinariaScreenState extends State<EditVeterinariaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _direccionCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _descripcionCtrl = TextEditingController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _nombreCtrl.text = widget.veterinaria['nombre'] ?? '';
    _direccionCtrl.text = widget.veterinaria['direccion'] ?? '';
    _telefonoCtrl.text = widget.veterinaria['telefono'] ?? '';
    _descripcionCtrl.text = widget.veterinaria['descripcion'] ?? '';
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      final payload = {
        'nombre': _nombreCtrl.text.trim(),
        'direccion': _direccionCtrl.text.trim(),
        'telefono': _telefonoCtrl.text.trim(),
        'descripcion': _descripcionCtrl.text.trim(),
      };

      await VeterinariaService.updateVeterinaria(
          widget.veterinaria['id'], payload);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Veterinaria actualizada exitosamente'),
            backgroundColor: Colors.green));
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _direccionCtrl.dispose();
    _telefonoCtrl.dispose();
    _descripcionCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: mint,
        appBar: AppBar(
            title: const Text('Editar Veterinaria',
                style: TextStyle(fontWeight: FontWeight.bold)),
            backgroundColor: softGreen,
            foregroundColor: white,
            elevation: 0),
        body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
                key: _formKey,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('Nombre *'),
                      _buildInput(
                          controller: _nombreCtrl,
                          hint: 'Nombre de la veterinaria',
                          icon: Icons.local_hospital,
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Requerido' : null),
                      const SizedBox(height: 18),
                      _label('Dirección'),
                      _buildInput(
                          controller: _direccionCtrl,
                          hint: 'Dirección completa',
                          icon: Icons.location_on),
                      const SizedBox(height: 18),
                      _label('Teléfono'),
                      _buildInput(
                          controller: _telefonoCtrl,
                          hint: 'Número de teléfono',
                          icon: Icons.phone,
                          keyboardType: TextInputType.phone),
                      const SizedBox(height: 18),
                      _label('Descripción'),
                      _buildInput(
                          controller: _descripcionCtrl,
                          hint: 'Descripción de servicios',
                          icon: Icons.description,
                          maxLines: 4),
                      const SizedBox(height: 28),

                      // Botón para gestionar horarios
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ManageHorariosScreen(
                                  veterinariaId: widget.veterinaria['id'],
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.schedule),
                          label: const Text(
                            'Gestionar Horarios',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: darkGreen,
                            side: const BorderSide(color: darkGreen, width: 2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                              onPressed: _loading ? null : _save,
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: white,
                                  foregroundColor: darkGreen,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12))),
                              child: _loading
                                  ? const SizedBox(
                                      height: 22,
                                      width: 22,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2, color: softGreen))
                                  : const Text('Guardar Cambios',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold)))),
                    ]))));
  }

  Widget _label(String text) => Text(text,
      style: const TextStyle(
          fontSize: 14, color: darkGreen, fontWeight: FontWeight.w600));

  Widget _buildInput({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: const TextStyle(color: white, fontSize: 14),
        decoration: InputDecoration(
            filled: true,
            fillColor: softGreen,
            contentPadding:
                const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
            hintText: hint,
            hintStyle: TextStyle(color: white.withOpacity(0.6)),
            prefixIcon: Icon(icon, color: white.withOpacity(0.85)),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none)));
  }
}
