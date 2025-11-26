import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../app/config/theme.dart';
import '../../../app/services/auth_service.dart';
import '../../../app/services/user_service.dart';

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Selecciona departamento y ciudad'),
            backgroundColor: Colors.red),
      );
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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Perfil actualizado'), backgroundColor: Colors.green));
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Error al actualizar'), backgroundColor: Colors.red));
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
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    _label('Nombre completo'),
                    _greenInput(_nombreCtrl,
                        hint: 'Escribe tu nombre',
                        icon: Icons.person,
                        validator: _required),
                    const SizedBox(height: 18),
                    _label('Correo'),
                    _greenInput(_correoCtrl,
                        hint: 'email@example.com',
                        icon: Icons.email,
                        readOnly: true),
                    const SizedBox(height: 18),
                    _label('Celular'),
                    _greenInput(_celularCtrl,
                        hint: '3001234567', icon: Icons.phone),
                    const SizedBox(height: 18),
                    _label('Dirección'),
                    _greenInput(_direccionCtrl,
                        hint: 'Calle, número, barrio', icon: Icons.home),
                    const SizedBox(height: 18),
                    _label('Departamento'),
                    _dropdownDepartamentos(),
                    const SizedBox(height: 14),
                    _label('Ciudad'),
                    _dropdownCiudades(),
                    const SizedBox(height: 18),
                    _label('Contraseña nueva'),
                    _greenInput(_passwordCtrl,
                        hint: '••••••••', icon: Icons.lock, obscure: true),
                    const SizedBox(height: 28),
                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _saving ? null : _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: white,
                          foregroundColor: darkGreen,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _saving
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: vetproGreen))
                            : const Text('Guardar cambios',
                                style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  String? _required(String? v) =>
      v == null || v.trim().isEmpty ? 'Requerido' : null;

  Widget _label(String text) => Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontFamily: 'Montserrat',
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      );

  Widget _greenInput(TextEditingController ctrl,
      {required String hint,
      required IconData icon,
      bool readOnly = false,
      bool obscure = false,
      String? Function(String?)? validator}) {
    return TextFormField(
      controller: ctrl,
      readOnly: readOnly,
      obscureText: obscure,
      validator: validator,
      style: const TextStyle(
          color: Colors.white, fontFamily: 'Montserrat', fontSize: 14),
      decoration: InputDecoration(
        filled: true,
        fillColor: softGreen,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
        prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.85)),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
      ),
    );
  }

  Widget _dropdownDepartamentos() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
          color: softGreen, borderRadius: BorderRadius.circular(12)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          isExpanded: true,
          value: _departamentoId,
          iconEnabledColor: Colors.white,
          dropdownColor: softGreen,
          hint: Text('Selecciona',
              style: TextStyle(color: Colors.white.withOpacity(0.7))),
          items: _departamentos
              .map((d) => DropdownMenuItem<int>(
                    value: d['id'] as int,
                    child: Text(d['nombre'] ?? '',
                        style: const TextStyle(color: Colors.white)),
                  ))
              .toList(),
          onChanged: _onDepartamentoChanged,
        ),
      ),
    );
  }

  Widget _dropdownCiudades() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
          color: softGreen, borderRadius: BorderRadius.circular(12)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          isExpanded: true,
          value: _ciudadId,
          iconEnabledColor: Colors.white,
          dropdownColor: softGreen,
          hint: Text('Selecciona',
              style: TextStyle(color: Colors.white.withOpacity(0.7))),
          items: _ciudades
              .map((c) => DropdownMenuItem<int>(
                    value: c['id'] as int,
                    child: Text(c['nombre'] ?? '',
                        style: const TextStyle(color: Colors.white)),
                  ))
              .toList(),
          onChanged: (v) => setState(() => _ciudadId = v),
        ),
      ),
    );
  }
}
