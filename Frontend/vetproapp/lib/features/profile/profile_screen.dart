import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../app/config/theme.dart';
import '../../../app/services/auth_service.dart';
import '../../../app/services/user_service.dart';
import '../../../app/widgets/custom_text_field.dart';
import '../../../app/widgets/custom_button.dart';
import '../../../app/widgets/custom_dropdown.dart';
import '../../../app/widgets/section_label.dart';
import '../../../app/utils/validators.dart';
import '../../../app/utils/snackbar_helper.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _loading = true;
  bool _saving = false;

  // Controllers
  final _nombreCtrl = TextEditingController();
  final _correoCtrl = TextEditingController();
  final _celularCtrl = TextEditingController();
  final _direccionCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController(); // Contraseña nueva

  int? _departamentoId;
  int? _ciudadId;
  List<Map<String, dynamic>> _departamentos = [];
  List<Map<String, dynamic>> _ciudades = [];

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final perfil = await UserService.getMyProfile();
    final departamentos = await AuthService.fetchDepartamentos();
    setState(() => _departamentos = departamentos);

    if (perfil != null) {
      _nombreCtrl.text = perfil['nombre_completo'] ?? '';
      _correoCtrl.text = perfil['correo'] ?? '';
      _celularCtrl.text = perfil['celular']?.toString() ?? '';
      _direccionCtrl.text = perfil['direccion'] ?? '';
      _departamentoId = perfil['departamento_id'] as int?;
      _ciudadId = perfil['ciudad_id'] as int?;
      if (_departamentoId != null) {
        _ciudades = await AuthService.fetchCiudades(_departamentoId!);
      }
    }
    setState(() => _loading = false);
  }

  Future<void> _onDepartamentoChanged(int? value) async {
    setState(() {
      _departamentoId = value;
      _ciudadId = null;
      _ciudades = [];
    });
    if (value != null) {
      final ciudades = await AuthService.fetchCiudades(value);
      setState(() => _ciudades = ciudades);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_departamentoId == null || _ciudadId == null) {
      SnackBarHelper.showError(context, 'Selecciona departamento y ciudad');
      return;
    }
    setState(() => _saving = true);
    final payload = <String, dynamic>{
      'nombre_completo': _nombreCtrl.text.trim(),
      'celular': _celularCtrl.text.trim(),
      'direccion': _direccionCtrl.text.trim(),
      'departamento_id': _departamentoId,
      'ciudad_id': _ciudadId,
    };
    if (_passwordCtrl.text.trim().isNotEmpty) {
      payload['password'] = _passwordCtrl.text.trim();
    }
    final updated = await UserService.updateMyProfile(payload);
    setState(() => _saving = false);
    if (updated != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('_vetpro_nombre', updated['nombre_completo'] ?? '');
      if (!mounted) return;
      SnackBarHelper.showSuccess(context, 'Perfil actualizado');
    } else {
      if (!mounted) return;
      SnackBarHelper.showError(context, 'Error al actualizar');
    }
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _correoCtrl.dispose();
    _celularCtrl.dispose();
    _direccionCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Mi perfil')),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : Container(
                color: mint,
                child: Form(
                    key: _formKey,
                    child:
                        ListView(padding: const EdgeInsets.all(20), children: [
                      const SectionLabel(text: 'Nombre completo'),
                      const SizedBox(height: 4),
                      CustomTextField(
                        controller: _nombreCtrl,
                        hint: 'Escribe tu nombre',
                        icon: Icons.person,
                        validator: (v) =>
                            Validators.required(v, fieldName: 'Nombre'),
                      ),
                      const SizedBox(height: 18),
                      const SectionLabel(text: 'Correo'),
                      const SizedBox(height: 4),
                      CustomTextField(
                        controller: _correoCtrl,
                        hint: 'email@example.com',
                        icon: Icons.email,
                        readOnly: true,
                      ),
                      const SizedBox(height: 18),
                      const SectionLabel(text: 'Celular'),
                      const SizedBox(height: 4),
                      CustomTextField(
                        controller: _celularCtrl,
                        hint: '3001234567',
                        icon: Icons.phone,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 18),
                      const SectionLabel(text: 'Dirección'),
                      const SizedBox(height: 4),
                      CustomTextField(
                        controller: _direccionCtrl,
                        hint: 'Calle, número, barrio',
                        icon: Icons.home,
                      ),
                      const SizedBox(height: 18),
                      const SectionLabel(text: 'Departamento'),
                      const SizedBox(height: 4),
                      _dropdownDepartamentos(),
                      const SizedBox(height: 14),
                      const SectionLabel(text: 'Ciudad'),
                      const SizedBox(height: 4),
                      _dropdownCiudades(),
                      const SizedBox(height: 18),
                      const SectionLabel(text: 'Contraseña nueva'),
                      const SizedBox(height: 4),
                      CustomTextField(
                        controller: _passwordCtrl,
                        hint: '••••••••',
                        icon: Icons.lock,
                        obscureText: true,
                      ),
                      const SizedBox(height: 28),
                      CustomButton(
                        text: 'Guardar cambios',
                        onPressed: _save,
                        loading: _saving,
                      ),
                    ]))));
  }

  Widget _dropdownDepartamentos() {
    return CustomDropdown<int>(
      value: _departamentoId,
      hint: 'Selecciona',
      items: _departamentos
          .map((d) => DropdownMenuItem<int>(
                value: d['id'] as int,
                child: Text(d['nombre'] ?? '',
                    style: const TextStyle(color: Colors.white)),
              ))
          .toList(),
      onChanged: _onDepartamentoChanged,
    );
  }

  Widget _dropdownCiudades() {
    return CustomDropdown<int>(
      value: _ciudadId,
      hint: 'Selecciona',
      items: _ciudades
          .map((c) => DropdownMenuItem<int>(
                value: c['id'] as int,
                child: Text(c['nombre'] ?? '',
                    style: const TextStyle(color: Colors.white)),
              ))
          .toList(),
      onChanged: (v) => setState(() => _ciudadId = v),
    );
  }
}
