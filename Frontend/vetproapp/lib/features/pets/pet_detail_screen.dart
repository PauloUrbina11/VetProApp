import 'package:flutter/material.dart';
import '../../app/config/theme.dart';
import '../../app/services/pets_service.dart';
import '../../app/utils/snackbar_helper.dart';
import '../medical_records/medical_records_screen.dart';

class PetDetailScreen extends StatelessWidget {
  final Map<String, dynamic> pet;

  const PetDetailScreen({super.key, required this.pet});

  Future<void> _delete(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar'),
        content: const Text('¿Estás seguro de eliminar esta mascota?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      try {
        await PetsService.deletePet(pet['id']);
        if (context.mounted) {
          SnackBarHelper.showSuccess(context, 'Mascota eliminada');
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (context.mounted) {
          SnackBarHelper.showError(context, 'Error: $e');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mint,
      appBar: AppBar(
        title: const Text(
          'Detalle Mascota',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: softGreen,
        foregroundColor: white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: lightGreen,
                    child: Icon(
                      pet['foto_url'] != null
                          ? Icons.pets
                          : Icons.pets_outlined,
                      size: 50,
                      color: darkGreen,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    pet['nombre'] ?? 'Sin nombre',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: darkGreen,
                    ),
                  ),
                  if (pet['especie_nombre'] != null)
                    Text(
                      pet['especie_nombre'],
                      style: TextStyle(
                        fontSize: 15,
                        color: darkGreen.withOpacity(0.7),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildInfoCard([
              if (pet['raza_nombre'] != null)
                _buildRow('Raza', pet['raza_nombre']),
              if (pet['sexo'] != null) _buildRow('Sexo', pet['sexo']),
              if (pet['color'] != null) _buildRow('Color', pet['color']),
              if (pet['peso_kg'] != null)
                _buildRow('Peso', '${pet['peso_kg']} kg'),
              if (pet['fecha_nacimiento'] != null)
                _buildRow(
                    'F. Nacimiento', _formatDate(pet['fecha_nacimiento'])),
            ]),
            const SizedBox(height: 24),
            _buildButton(
              context,
              icon: Icons.medical_services,
              label: 'Ver Historial Clínico',
              color: softGreen,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MedicalRecordsScreen(petId: pet['id']),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _buildButton(
              context,
              icon: Icons.edit,
              label: 'Editar Mascota',
              color: vetproGreen,
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditPetScreen(pet: pet),
                  ),
                );
                if (result == true && context.mounted) {
                  Navigator.pop(context, true);
                }
              },
            ),
            const SizedBox(height: 12),
            _buildButton(
              context,
              icon: Icons.delete,
              label: 'Eliminar Mascota',
              color: Colors.red,
              onPressed: () => _delete(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> rows) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: rows,
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 14,
                color: darkGreen.withOpacity(0.7),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: darkGreen,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        label: Text(
          label,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  String _formatDate(String? date) {
    if (date == null) return '';
    try {
      final dt = DateTime.parse(date);
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (e) {
      return date;
    }
  }
}

/// Pantalla para editar mascota (solo campos limitados)
class EditPetScreen extends StatefulWidget {
  final Map<String, dynamic> pet;
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
        SnackBarHelper.showError(context, 'Error: $e');
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
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: softGreen,
        foregroundColor: white,
        elevation: 0,
      ),
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
                  border: Border.all(color: darkGreen.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Información no editable:',
                      style: TextStyle(
                        fontSize: 14,
                        color: darkGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildReadOnlyRow('Nombre', widget.pet['nombre'] ?? 'N/A'),
                    _buildReadOnlyRow(
                      'Especie',
                      widget.pet['especie_nombre'] ?? 'N/A',
                    ),
                    _buildReadOnlyRow(
                      'Raza',
                      widget.pet['raza_nombre'] ?? 'N/A',
                    ),
                    if (widget.pet['sexo'] != null)
                      _buildReadOnlyRow('Sexo', widget.pet['sexo']),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Campos editables:',
                style: TextStyle(
                  fontSize: 14,
                  color: darkGreen,
                  fontWeight: FontWeight.bold,
                ),
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
                          'Guardar Cambios',
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
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: white, fontSize: 14),
      decoration: InputDecoration(
        filled: true,
        fillColor: softGreen,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 14,
        ),
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
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: darkGreen,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
