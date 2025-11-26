import 'package:flutter/material.dart';
import '../../app/services/admin_service.dart';
import '../../app/services/auth_service.dart';
import '../../app/config/theme.dart';

class CreateVeterinariaScreen extends StatefulWidget {
  const CreateVeterinariaScreen({super.key});

  @override
  State<CreateVeterinariaScreen> createState() =>
      _CreateVeterinariaScreenState();
}

class _CreateVeterinariaScreenState extends State<CreateVeterinariaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _direccionCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _descripcionCtrl = TextEditingController();

  List<dynamic> _departamentos = [];
  List<dynamic> _ciudades = [];
  List<dynamic> _adminUsers = [];
  int? _selectedDepartamentoId;
  int? _selectedCiudadId;
  int? _selectedAdminUserId;
  bool _isLoading = true;
  bool _loading = false;
  String? _error;
  String? _success;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final deps = await AuthService.fetchDepartamentos();
      final users = await AdminService.listUsers();
      setState(() {
        _departamentos = deps;
        _adminUsers = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error al cargar datos: $e')));
      }
    }
  }

  Future<void> _loadCiudades(int departamentoId) async {
    try {
      final ciudades = await AuthService.fetchCiudades(departamentoId);
      setState(() {
        _ciudades = ciudades;
        _selectedCiudadId = null;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al cargar ciudades: $e')));
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCiudadId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Debe seleccionar una ciudad')));
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
      _success = null;
    });
    try {
      final payload = <String, dynamic>{
        'nombre': _nombreCtrl.text.trim(),
        'ciudad_id': _selectedCiudadId,
      };
      if (_direccionCtrl.text.isNotEmpty)
        payload['direccion'] = _direccionCtrl.text.trim();
      if (_telefonoCtrl.text.isNotEmpty)
        payload['telefono'] = _telefonoCtrl.text.trim();
      if (_selectedAdminUserId != null)
        payload['user_admin_id'] = _selectedAdminUserId;
      if (_descripcionCtrl.text.isNotEmpty)
        payload['descripcion'] = _descripcionCtrl.text.trim();

      final vet = await AdminService.createVeterinaria(payload);
      setState(() {
        _success = 'Creada: ${vet['nombre']} (id ${vet['id']})';
      });
      _formKey.currentState!.reset();
      _nombreCtrl.clear();
      _direccionCtrl.clear();
      _telefonoCtrl.clear();
      _descripcionCtrl.clear();
      setState(() {
        _selectedDepartamentoId = null;
        _selectedCiudadId = null;
        _selectedAdminUserId = null;
        _ciudades = [];
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

  Widget _buildInput({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Montserrat',
            color: darkGreen,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            filled: true,
            fillColor: softGreen,
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(8),
            ),
            hintStyle: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontFamily: 'Montserrat',
            ),
          ),
          style: const TextStyle(color: Colors.white, fontFamily: 'Montserrat'),
          validator: validator,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required int? value,
    required List<dynamic> items,
    required String Function(dynamic) getName,
    required int Function(dynamic) getId,
    required void Function(int?) onChanged,
    bool required = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label + (required ? ' *' : ''),
          style: const TextStyle(
            fontFamily: 'Montserrat',
            color: darkGreen,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: softGreen,
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonFormField<int>(
            value: value,
            decoration: InputDecoration(
              filled: true,
              fillColor: softGreen,
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            dropdownColor: softGreen,
            style:
                const TextStyle(color: Colors.white, fontFamily: 'Montserrat'),
            items: items.map((item) {
              return DropdownMenuItem<int>(
                value: getId(item),
                child: Text(
                  getName(item),
                  style: const TextStyle(color: Colors.white),
                ),
              );
            }).toList(),
            onChanged: onChanged,
            validator: required ? (v) => v == null ? 'Requerido' : null : null,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mint,
      appBar: AppBar(
        title: const Text(
          'Crear Veterinaria',
          style:
              TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.bold),
        ),
        backgroundColor: softGreen,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: lightGreen.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    children: [
                      _buildInput(
                        controller: _nombreCtrl,
                        label: 'Nombre *',
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Requerido' : null,
                      ),
                      _buildInput(
                        controller: _direccionCtrl,
                        label: 'Dirección',
                      ),
                      _buildInput(
                        controller: _telefonoCtrl,
                        label: 'Teléfono',
                        keyboardType: TextInputType.phone,
                      ),
                      if (_isLoading)
                        const Center(
                            child:
                                CircularProgressIndicator(color: Colors.white))
                      else ...[
                        _buildDropdown(
                          label: 'Departamento',
                          value: _selectedDepartamentoId,
                          items: _departamentos,
                          getName: (item) => item['nombre'] ?? '',
                          getId: (item) => item['id'] ?? 0,
                          onChanged: (val) {
                            setState(() => _selectedDepartamentoId = val);
                            if (val != null) _loadCiudades(val);
                          },
                          required: true,
                        ),
                        _buildDropdown(
                          label: 'Ciudad',
                          value: _selectedCiudadId,
                          items: _ciudades,
                          getName: (item) => item['nombre'] ?? '',
                          getId: (item) => item['id'] ?? 0,
                          onChanged: (val) =>
                              setState(() => _selectedCiudadId = val),
                          required: true,
                        ),
                        _buildDropdown(
                          label: 'Usuario Administrador',
                          value: _selectedAdminUserId,
                          items: _adminUsers,
                          getName: (item) =>
                              item['nombre_completo'] ?? item['email'] ?? '',
                          getId: (item) => item['id'] ?? 0,
                          onChanged: (val) =>
                              setState(() => _selectedAdminUserId = val),
                        ),
                      ],
                      _buildInput(
                        controller: _descripcionCtrl,
                        label: 'Descripción',
                        maxLines: 3,
                      ),
                      if (_error != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Text(
                            _error!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontFamily: 'Montserrat',
                              fontSize: 14,
                            ),
                          ),
                        ),
                      if (_success != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Text(
                            _success!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontFamily: 'Montserrat',
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      SizedBox(
                        width: double.infinity,
                        height: 45,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: white,
                            foregroundColor: darkGreen,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: _loading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: darkGreen,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Crear Veterinaria',
                                  style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
