import 'package:flutter/material.dart';
import '../../app/config/theme.dart';
import '../../app/services/auth_service.dart';
import '../../app/services/pets_service.dart';

class MyPetsScreen extends StatefulWidget {
  const MyPetsScreen({super.key});

  @override
  State<MyPetsScreen> createState() => _MyPetsScreenState();
}

class _MyPetsScreenState extends State<MyPetsScreen> {
  bool _loading = true;
  List<dynamic> _pets = [];
  int? _userRole;
  String? _error;

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
      List<dynamic> pets;
      if (role == 1) {
        // Admin: ver todas las mascotas
        pets = await PetsService.getAllPets();
      } else {
        // Usuario: solo sus mascotas
        pets = await PetsService.getMyPets();
      }
      setState(() {
        _userRole = role;
        _pets = pets;
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

  Future<void> _showAddPetDialog() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddPetScreen()));
    if (result == true) {
      _loadData();
    }
  }

  Future<void> _showPetDetail(dynamic pet) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PetDetailScreen(pet: pet)));
    if (result == true) {
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mint,
      appBar: AppBar(
        title: Text(
          _userRole == 1 ? 'Todas las Mascotas' : 'Mis Mascotas',
          style: const TextStyle(
            fontWeight: FontWeight.bold)),
        backgroundColor: softGreen,
        foregroundColor: white,
        elevation: 0),
      floatingActionButton: _userRole != 1
          ? FloatingActionButton(
              onPressed: _showAddPetDialog,
              backgroundColor: softGreen,
              child: const Icon(Icons.add, color: white))
          : null,
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: softGreen))
          : SafeArea(
              child: Column(
                children: [
                  if (_error != null)
                    Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: lightGreen.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8)),
                      child: Text(
                        _error!,
                        style: const TextStyle(
                          color: darkGreen))),
                  Expanded(
                    child: _pets.isEmpty
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
                                  Icon(Icons.pets,
                                      size: 64,
                                      color: darkGreen.withOpacity(0.5)),
                                  const SizedBox(height: 16),
                                  Text(
                                    _userRole == 1
                                        ? 'No hay mascotas registradas'
                                        : 'No tienes mascotas registradas',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: darkGreen,
                                      fontSize: 16)),
                                ])))
                        : RefreshIndicator(
                            onRefresh: _loadData,
                            color: softGreen,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _pets.length,
                              itemBuilder: (context, index) {
                                final pet = _pets[index];
                                return _buildPetCard(pet);
                              }))),
                ])));
  }

  Widget _buildPetCard(dynamic pet) {
    final isAdmin = _userRole == 1;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: lightGreen.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          radius: 30,
          backgroundColor: softGreen,
          child: pet['foto_principal'] != null
              ? ClipOval(
                  child: Image.network(
                    pet['foto_principal'],
                    fit: BoxFit.cover,
                    width: 60,
                    height: 60,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.pets, color: white, size: 30)))
              : const Icon(Icons.pets, color: white, size: 30)),
        title: Text(
          pet['nombre'] ?? 'Sin nombre',
          style: const TextStyle(
            color: darkGreen,
            fontWeight: FontWeight.bold,
            fontSize: 16)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isAdmin && pet['owner_name'] != null) ...[
              const SizedBox(height: 4),
              Text(
                'Dueño: ${pet['owner_name']}',
                style: TextStyle(
                  color: darkGreen.withOpacity(0.8),
                  fontSize: 13)),
            ],
            const SizedBox(height: 4),
            Text(
              '${pet['especie_nombre'] ?? 'Especie desconocida'} - ${pet['raza_nombre'] ?? 'Raza desconocida'}',
              style: TextStyle(
                color: darkGreen.withOpacity(0.7),
                fontSize: 12)),
          ]),
        trailing: Icon(Icons.chevron_right, color: darkGreen),
        onTap: () => _showPetDetail(pet)));
  }
}

class AddPetScreen extends StatefulWidget {
  const AddPetScreen({super.key});

  @override
  State<AddPetScreen> createState() => _AddPetScreenState();
}

class _AddPetScreenState extends State<AddPetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _colorCtrl = TextEditingController();
  final _pesoCtrl = TextEditingController();

  List<dynamic> _especies = [];
  List<dynamic> _razas = [];
  int? _selectedEspecieId;
  int? _selectedRazaId;
  String? _sexo;
  DateTime? _fechaNacimiento;
  bool _loading = false;
  bool _loadingData = true;

  @override
  void initState() {
    super.initState();
    _loadEspecies();
  }

  Future<void> _loadEspecies() async {
    try {
      final especies = await PetsService.getEspecies();
      setState(() {
        _especies = especies;
        _loadingData = false;
      });
    } catch (e) {
      setState(() => _loadingData = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar especies: $e'),
            backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _loadRazas(int especieId) async {
    try {
      final razas = await PetsService.getRazas(especieId);
      setState(() {
        _razas = razas;
        _selectedRazaId = null;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar razas: $e'),
            backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: softGreen,
              onPrimary: white,
              onSurface: darkGreen)),
          child: child!);
      });
    if (picked != null) {
      setState(() {
        _fechaNacimiento = picked;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedEspecieId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar( content: Text('Debes seleccionar una especie'),
          backgroundColor: Colors.red));
      return;
    }

    if (_selectedRazaId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar( content: Text('Debes seleccionar una raza'),
          backgroundColor: Colors.red));
      return;
    }

    if (_sexo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar( content: Text('Debes seleccionar el sexo'),
          backgroundColor: Colors.red));
      return;
    }

    setState(() => _loading = true);
    try {
      final payload = {
        'nombre': _nombreCtrl.text.trim(),
        'especie_id': _selectedEspecieId,
        'raza_id': _selectedRazaId,
        'sexo': _sexo,
        'color': _colorCtrl.text.trim(),
        'peso_kg': _pesoCtrl.text.isNotEmpty
            ? double.tryParse(_pesoCtrl.text.trim())
            : null,
        'fecha_nacimiento': _fechaNacimiento?.toIso8601String().split('T')[0],
      };
      await PetsService.createPet(payload);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mascota creada exitosamente'),
            backgroundColor: Colors.green));
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _colorCtrl.dispose();
    _pesoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mint,
      appBar: AppBar(
        title: const Text(
          'Agregar Mascota',
          style: TextStyle(
            fontWeight: FontWeight.bold)),
        backgroundColor: softGreen,
        foregroundColor: white,
        elevation: 0),
      body: _loadingData
          ? const Center(child: CircularProgressIndicator(color: softGreen))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('Nombre *'),
                    _buildInput(
                      controller: _nombreCtrl,
                      hint: 'Nombre de la mascota',
                      icon: Icons.pets,
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Requerido' : null),
                    const SizedBox(height: 18),
                    _label('Especie *'),
                    _buildDropdown(
                      value: _selectedEspecieId,
                      items: _especies,
                      hint: 'Selecciona especie',
                      onChanged: (val) {
                        setState(() {
                          _selectedEspecieId = val;
                          _razas = [];
                          _selectedRazaId = null;
                        });
                        if (val != null) _loadRazas(val);
                      }),
                    const SizedBox(height: 18),
                    _label('Raza *'),
                    _buildDropdown(
                      value: _selectedRazaId,
                      items: _razas,
                      hint: 'Selecciona raza',
                      onChanged: (val) => setState(() => _selectedRazaId = val),
                      enabled: _selectedEspecieId != null),
                    const SizedBox(height: 18),
                    _label('Sexo *'),
                    _buildDropdown(
                      value: _sexo,
                      items: const [
                        {'id': 'Macho', 'nombre': 'Macho'},
                        {'id': 'Hembra', 'nombre': 'Hembra'},
                      ],
                      hint: 'Selecciona sexo',
                      onChanged: (val) => setState(() => _sexo = val),
                      isString: true),
                    const SizedBox(height: 18),
                    _label('Fecha de Nacimiento'),
                    InkWell(
                      onTap: _selectDate,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 16),
                        decoration: BoxDecoration(
                          color: softGreen,
                          borderRadius: BorderRadius.circular(12)),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today,
                                color: white.withOpacity(0.85)),
                            const SizedBox(width: 12),
                            Text(
                              _fechaNacimiento != null
                                  ? '${_fechaNacimiento!.day}/${_fechaNacimiento!.month}/${_fechaNacimiento!.year}'
                                  : 'Seleccionar fecha',
                              style: TextStyle(
                                color: _fechaNacimiento != null
                                    ? white
                                    : white.withOpacity(0.6),
                                fontSize: 14)),
                          ]))),
                    const SizedBox(height: 18),
                    _label('Color'),
                    _buildInput(
                      controller: _colorCtrl,
                      hint: 'Color del pelaje',
                      icon: Icons.palette),
                    const SizedBox(height: 18),
                    _label('Peso (kg)'),
                    _buildInput(
                      controller: _pesoCtrl,
                      hint: 'Peso en kilogramos',
                      icon: Icons.monitor_weight,
                      keyboardType: TextInputType.number),
                    const SizedBox(height: 28),
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
                                  strokeWidth: 2,
                                  color: softGreen))
                            : const Text(
                                'Guardar Mascota',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold)))),
                  ]))));
  }

  Widget _label(String text) => Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          color: darkGreen,
          fontWeight: FontWeight.w600));

  Widget _buildInput({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      style: const TextStyle(
        color: white,
        fontSize: 14),
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

  Widget _buildDropdown({
    required dynamic value,
    required List<dynamic> items,
    required String hint,
    required void Function(dynamic) onChanged,
    bool enabled = true,
    bool isString = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: enabled ? softGreen : softGreen.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<dynamic>(
          isExpanded: true,
          value: value,
          iconEnabledColor: white,
          dropdownColor: softGreen,
          hint: Text(
            hint,
            style: TextStyle(color: white.withOpacity(0.7))),
          items: items.map((item) {
            final id = isString ? item['id'] : item['id'] as int;
            final nombre = item['nombre'] ?? '';
            return DropdownMenuItem<dynamic>(
              value: id,
              child: Text(
                nombre,
                style: const TextStyle(color: white)));
          }).toList(),
          onChanged: enabled ? onChanged : null)));
  }
}

class PetDetailScreen extends StatefulWidget {
  final dynamic pet;

  const PetDetailScreen({super.key, required this.pet});

  @override
  State<PetDetailScreen> createState() => _PetDetailScreenState();
}

class _PetDetailScreenState extends State<PetDetailScreen> {
  bool _deleting = false;

  Future<void> _deletePet() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          '¿Eliminar mascota?',
          style: TextStyle( color: darkGreen)),
        content: const Text(
          'Esta acción no se puede deshacer. Solo se pueden eliminar mascotas sin historial clínico.',
          style: TextStyle()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar',
                style: TextStyle())),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar',
                style: TextStyle())),
        ]));

    if (confirm != true) return;

    setState(() => _deleting = true);
    try {
      await PetsService.deletePet(widget.pet['id']);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mascota eliminada exitosamente'),
            backgroundColor: Colors.green));
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  void _viewHistorial() {
    // TODO: Navegar a la pantalla de historial clínico
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Historial clínico - Próximamente'),
        backgroundColor: Colors.blue));
  }

  Future<void> _editPet() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditPetScreen(pet: widget.pet)));
    if (result == true) {
      // Recargar los datos de la mascota
      try {
        final updatedPet = await PetsService.getPetById(widget.pet['id']);
        setState(() {
          widget.pet.clear();
          widget.pet.addAll(updatedPet);
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Mascota actualizada exitosamente'),
              backgroundColor: Colors.green));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al recargar datos: $e'),
              backgroundColor: Colors.red));
        }
      }
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      final day = date.day.toString().padLeft(2, '0');
      final month = date.month.toString().padLeft(2, '0');
      final year = date.year.toString();
      return '$day-$month-$year';
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    final pet = widget.pet;
    return Scaffold(
      backgroundColor: mint,
      appBar: AppBar(
        title: Text(
          pet['nombre'] ?? 'Detalle Mascota',
          style: const TextStyle(
            fontWeight: FontWeight.bold)),
        backgroundColor: softGreen,
        foregroundColor: white,
        elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Foto de la mascota
            Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: softGreen,
                  shape: BoxShape.circle),
                child: pet['foto_principal'] != null
                    ? ClipOval(
                        child: Image.network(
                          pet['foto_principal'],
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.pets, color: white, size: 60)))
                    : const Icon(Icons.pets, color: white, size: 60))),
            const SizedBox(height: 24),

            // Información de la mascota
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: lightGreen.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  _buildInfoRow('Nombre', pet['nombre'] ?? 'N/A'),
                  _buildInfoRow('Especie', pet['especie_nombre'] ?? 'N/A'),
                  _buildInfoRow('Raza', pet['raza_nombre'] ?? 'N/A'),
                  if (pet['sexo'] != null) _buildInfoRow('Sexo', pet['sexo']),
                  if (pet['fecha_nacimiento'] != null)
                    _buildInfoRow('Fecha Nacimiento',
                        _formatDate(pet['fecha_nacimiento'])),
                  if (pet['color'] != null)
                    _buildInfoRow('Color', pet['color']),
                  if (pet['peso_kg'] != null)
                    _buildInfoRow('Peso', '${pet['peso_kg']} kg'),
                  if (pet['owner_name'] != null)
                    _buildInfoRow('Dueño', pet['owner_name']),
                ])),
            const SizedBox(height: 24),

            // Botones de acción
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _viewHistorial,
                style: ElevatedButton.styleFrom(
                  backgroundColor: softGreen,
                  foregroundColor: white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12))),
                icon: const Icon(Icons.medical_services),
                label: const Text(
                  'Ver Historial Clínico',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold)))),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _editPet,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade400,
                  foregroundColor: white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12))),
                icon: const Icon(Icons.edit),
                label: const Text(
                  'Editar Mascota',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold)))),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _deleting ? null : _deletePet,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade400,
                  foregroundColor: white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12))),
                icon: _deleting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: white,
                          strokeWidth: 2))
                    : const Icon(Icons.delete),
                label: Text(
                  _deleting ? 'Eliminando...' : 'Eliminar Mascota',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold)))),
          ])));
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                color: darkGreen,
                fontWeight: FontWeight.bold,
                fontSize: 14))),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: darkGreen.withOpacity(0.8),
                fontSize: 14))),
        ]));
  }
}

// Pantalla para editar mascota (campos limitados)
class EditPetScreen extends StatefulWidget {
  final dynamic pet;

  const EditPetScreen({super.key, required this.pet});

  @override
  State<EditPetScreen> createState() => _EditPetScreenState();
}

class _EditPetScreenState extends State<EditPetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _colorCtrl = TextEditingController();
  final _pesoCtrl = TextEditingController();
  DateTime? _fechaNacimiento;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    // Cargar datos actuales de la mascota
    _colorCtrl.text = widget.pet['color'] ?? '';
    _pesoCtrl.text = widget.pet['peso_kg']?.toString() ?? '';

    if (widget.pet['fecha_nacimiento'] != null) {
      try {
        _fechaNacimiento = DateTime.parse(widget.pet['fecha_nacimiento']);
      } catch (e) {
        // Ignorar si no se puede parsear
      }
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fechaNacimiento ?? DateTime.now(),
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: softGreen,
              onPrimary: white,
              onSurface: darkGreen)),
          child: child!);
      });
    if (picked != null) {
      setState(() {
        _fechaNacimiento = picked;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      final payload = {
        'color':
            _colorCtrl.text.trim().isNotEmpty ? _colorCtrl.text.trim() : null,
        'peso_kg': _pesoCtrl.text.isNotEmpty
            ? double.tryParse(_pesoCtrl.text.trim())
            : null,
        'fecha_nacimiento': _fechaNacimiento?.toIso8601String().split('T')[0],
      };

      await PetsService.updatePet(widget.pet['id'], payload);

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _colorCtrl.dispose();
    _pesoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mint,
      appBar: AppBar(
        title: const Text(
          'Editar Mascota',
          style: TextStyle(
            fontWeight: FontWeight.bold)),
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
              // Información NO editable
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: lightGreen.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: darkGreen.withOpacity(0.2))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Información no editable:',
                      style: TextStyle(
                        fontSize: 14,
                        color: darkGreen,
                        fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    _buildReadOnlyRow('Nombre', widget.pet['nombre'] ?? 'N/A'),
                    _buildReadOnlyRow(
                        'Especie', widget.pet['especie_nombre'] ?? 'N/A'),
                    _buildReadOnlyRow(
                        'Raza', widget.pet['raza_nombre'] ?? 'N/A'),
                    if (widget.pet['sexo'] != null)
                      _buildReadOnlyRow('Sexo', widget.pet['sexo']),
                  ])),

              const SizedBox(height: 24),

              const Text(
                'Campos editables:',
                style: TextStyle(
                  fontSize: 14,
                  color: darkGreen,
                  fontWeight: FontWeight.bold)),

              const SizedBox(height: 18),

              _label('Fecha de Nacimiento'),
              InkWell(
                onTap: _selectDate,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                  decoration: BoxDecoration(
                    color: softGreen,
                    borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today,
                          color: white.withOpacity(0.85)),
                      const SizedBox(width: 12),
                      Text(
                        _fechaNacimiento != null
                            ? '${_fechaNacimiento!.day}/${_fechaNacimiento!.month}/${_fechaNacimiento!.year}'
                            : 'Seleccionar fecha',
                        style: TextStyle(
                          color: _fechaNacimiento != null
                              ? white
                              : white.withOpacity(0.6),
                          fontSize: 14)),
                    ]))),

              const SizedBox(height: 18),

              _label('Color'),
              _buildInput(
                controller: _colorCtrl,
                hint: 'Color del pelaje',
                icon: Icons.palette),

              const SizedBox(height: 18),

              _label('Peso (kg)'),
              _buildInput(
                controller: _pesoCtrl,
                hint: 'Peso en kilogramos',
                icon: Icons.monitor_weight,
                keyboardType: TextInputType.number),

              const SizedBox(height: 28),

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
                            strokeWidth: 2,
                            color: softGreen))
                      : const Text(
                          'Guardar Cambios',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold)))),
            ]))));
  }

  Widget _label(String text) => Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          color: darkGreen,
          fontWeight: FontWeight.w600));

  Widget _buildInput({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(
        color: white,
        fontSize: 14),
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

  Widget _buildReadOnlyRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                color: darkGreen.withOpacity(0.7),
                fontSize: 13))),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: darkGreen,
                fontSize: 13,
                fontWeight: FontWeight.w600))),
        ]));
  }
}
