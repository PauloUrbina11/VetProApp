import 'package:flutter/material.dart';
import '../../app/config/theme.dart';
import '../../app/services/pets_service.dart';
import '../../app/utils/snackbar_helper.dart';

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
        SnackBarHelper.showError(context, 'Error al cargar especies: $e');
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
        SnackBarHelper.showError(context, 'Error al cargar razas: $e');
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
              onSurface: darkGreen,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _fechaNacimiento = picked;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedEspecieId == null) {
      SnackBarHelper.showError(context, 'Debes seleccionar una especie');
      return;
    }

    if (_selectedRazaId == null) {
      SnackBarHelper.showError(context, 'Debes seleccionar una raza');
      return;
    }

    if (_sexo == null) {
      SnackBarHelper.showError(context, 'Debes seleccionar el sexo');
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
        SnackBarHelper.showSuccess(context, 'Mascota creada exitosamente');
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        SnackBarHelper.showError(context, 'Error: $e');
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
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: softGreen,
        foregroundColor: white,
        elevation: 0,
      ),
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
                          v == null || v.isEmpty ? 'Requerido' : null,
                    ),
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
                      },
                    ),
                    const SizedBox(height: 18),
                    _label('Raza *'),
                    _buildDropdown(
                      value: _selectedRazaId,
                      items: _razas,
                      hint: 'Selecciona raza',
                      onChanged: (val) => setState(() => _selectedRazaId = val),
                      enabled: _selectedEspecieId != null,
                    ),
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
                      isString: true,
                    ),
                    const SizedBox(height: 18),
                    _label('Fecha de Nacimiento'),
                    InkWell(
                      onTap: _selectDate,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: softGreen,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              color: white.withOpacity(0.85),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              _fechaNacimiento != null
                                  ? '${_fechaNacimiento!.day}/${_fechaNacimiento!.month}/${_fechaNacimiento!.year}'
                                  : 'Seleccionar fecha',
                              style: TextStyle(
                                color: _fechaNacimiento != null
                                    ? white
                                    : white.withOpacity(0.6),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    _label('Color'),
                    _buildInput(
                      controller: _colorCtrl,
                      hint: 'Color del pelaje',
                      icon: Icons.palette,
                    ),
                    const SizedBox(height: 18),
                    _label('Peso (kg)'),
                    _buildInput(
                      controller: _pesoCtrl,
                      hint: 'Peso en kilogramos',
                      icon: Icons.monitor_weight,
                      keyboardType: TextInputType.number,
                    ),
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
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _loading
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: softGreen,
                                ),
                              )
                            : const Text(
                                'Guardar Mascota',
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
            ),
    );
  }

  Widget _label(String text) => Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          color: darkGreen,
          fontWeight: FontWeight.w600,
        ),
      );

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
          borderSide: BorderSide.none,
        ),
      ),
    );
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
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<dynamic>(
          isExpanded: true,
          value: value,
          iconEnabledColor: white,
          dropdownColor: softGreen,
          hint: Text(
            hint,
            style: TextStyle(color: white.withOpacity(0.7)),
          ),
          items: items.map((item) {
            final id = isString ? item['id'] : item['id'] as int;
            final nombre = item['nombre'] ?? '';
            return DropdownMenuItem<dynamic>(
              value: id,
              child: Text(nombre, style: const TextStyle(color: white)),
            );
          }).toList(),
          onChanged: enabled ? onChanged : null,
        ),
      ),
    );
  }
}
