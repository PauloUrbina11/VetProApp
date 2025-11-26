import 'package:flutter/material.dart';
import 'password_field.dart';
import '../../../../app/services/auth_service.dart';
import '../../../../app/config/theme.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final formKey = GlobalKey<FormState>();

  final TextEditingController nombreController = TextEditingController();
  final TextEditingController correoController = TextEditingController();
  final TextEditingController direccionController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController celularController = TextEditingController();

  bool loading = false;
  List<Map<String, dynamic>> departamentos = [];
  List<Map<String, dynamic>> ciudades = [];
  int? selectedDepartamentoId;
  int? selectedCiudadId;

  @override
  void initState() {
    super.initState();
    _loadDepartamentos();
  }

  Future<void> _loadDepartamentos() async {
    final list = await AuthService.fetchDepartamentos();
    setState(() => departamentos = list);
  }

  Future<void> _loadCiudades(int departamentoId) async {
    final list = await AuthService.fetchCiudades(departamentoId);
    setState(() {
      ciudades = list;
      selectedCiudadId = null;
    });
  }

  Widget _departmentDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: softGreen,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<int>(
        isExpanded: true,
        value: selectedDepartamentoId,
        underline: const SizedBox.shrink(),
        dropdownColor: softGreen,
        hint: Text(
          'Selecciona un departamento',
          style: TextStyle(color: Colors.white.withOpacity(0.7)),
        ),
        items: departamentos.map((d) {
          return DropdownMenuItem<int>(
            value: d['id'],
            child: Text(d['nombre'] ?? '',
                style: const TextStyle(color: Colors.white)),
          );
        }).toList(),
        onChanged: (v) {
          setState(() {
            selectedDepartamentoId = v;
            ciudades = [];
            selectedCiudadId = null;
          });
          if (v != null) _loadCiudades(v);
        },
      ),
    );
  }

  Widget _cityDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: softGreen,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<int>(
        isExpanded: true,
        value: selectedCiudadId,
        underline: const SizedBox.shrink(),
        dropdownColor: softGreen,
        hint: Text(
          'Selecciona una ciudad',
          style: TextStyle(color: Colors.white.withOpacity(0.7)),
        ),
        items: ciudades.map((c) {
          return DropdownMenuItem<int>(
            value: c['id'],
            child: Text(c['nombre'] ?? '',
                style: const TextStyle(color: Colors.white)),
          );
        }).toList(),
        onChanged: (v) {
          setState(() => selectedCiudadId = v);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // NOMBRE
          const Text(
            'Nombre completo',
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'Montserrat',
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          _inputField(
            controller: nombreController,
            hint: 'Escribe tu nombre',
            icon: Icons.person,
          ),

          const SizedBox(height: 18),

          // EMAIL
          const Text(
            'Correo electrónico',
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'Montserrat',
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          _inputField(
            controller: correoController,
            hint: 'email@example.com',
            icon: Icons.email,
          ),

          const SizedBox(height: 18),

          // CONTRASEÑA
          const Text(
            'Contraseña',
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'Montserrat',
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          PasswordField(controller: passwordController),

          const SizedBox(height: 18),

          // DIRECCIÓN
          const Text(
            'Dirección',
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'Montserrat',
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          _inputField(
            controller: direccionController,
            hint: 'Dirección (calle, número, barrio)',
            icon: Icons.home,
          ),

          const SizedBox(height: 18),

          // CELULAR
          const Text(
            'Celular',
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'Montserrat',
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          _inputField(
            controller: celularController,
            hint: '3001234567',
            icon: Icons.phone,
          ),

          const SizedBox(height: 18),

          // DEPARTAMENTO & CIUDAD (dropdowns dependientes)
          const Text(
            'Departamento',
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'Montserrat',
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          _departmentDropdown(),

          const SizedBox(height: 12),

          const Text(
            'Ciudad',
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'Montserrat',
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          _cityDropdown(),

          const SizedBox(height: 25),

          // BOTÓN CREAR CUENTA
          SizedBox(
            width: double.infinity,
            height: 45,
            child: ElevatedButton(
              onPressed: loading ? null : _createAccount,
              style: ElevatedButton.styleFrom(
                backgroundColor: white,
                foregroundColor: darkGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: darkGreen,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Crear cuenta',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),

          const SizedBox(height: 15),
        ],
      ),
    );
  }

  Future<void> _createAccount() async {
    if (!formKey.currentState!.validate()) return;
    if (selectedDepartamentoId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            backgroundColor: Colors.red,
            content: Text('Selecciona un departamento')),
      );
      return;
    }

    if (selectedCiudadId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            backgroundColor: Colors.red,
            content: Text('Selecciona una ciudad')),
      );
      return;
    }

    setState(() => loading = true);

    final payload = {
      "nombre_completo": nombreController.text.trim(),
      "correo": correoController.text.trim(),
      "password": passwordController.text.trim(),
      "direccion": direccionController.text.trim(),
      "ciudad_id": selectedCiudadId,
      "departamento_id": selectedDepartamentoId,
      "celular": celularController.text.trim(),
    };

    try {
      final res = await AuthService.register(payload);

      if (res["ok"] == true) {
        final activationToken = res["activation_token"] ?? res["token"];

        // Vaciar formulario
        nombreController.clear();
        correoController.clear();
        passwordController.clear();
        direccionController.clear();
        celularController.clear();
        setState(() {
          selectedDepartamentoId = null;
          selectedCiudadId = null;
          ciudades = [];
        });

        if (activationToken != null) {
          // Mostrar diálogo con opción de activar o ir al login
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Registro exitoso'),
              content: Text(res["message"] ?? 'Usuario creado'),
              actions: [
                TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    final act = await AuthService.activate(activationToken);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor:
                            act["ok"] == true ? Colors.green : Colors.red,
                        content: Text(act["message"] ?? 'Resultado'),
                      ),
                    );
                  },
                  child: const Text('Activar ahora'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  child: const Text('Ir a iniciar sesión'),
                ),
              ],
            ),
          );
        } else {
          // Sin token de activación: ir directamente al login
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.green,
              content: Text(res["message"] ?? 'Registro exitoso'),
            ),
          );
          Navigator.pushReplacementNamed(context, '/login');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(res["message"] ?? 'Error al registrar'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(e.toString()),
        ),
      );
    }

    setState(() => loading = false);
  }

  // INPUT GENÉRICO ADAPTADO AL ESTILO VETPROAPP
  Widget _inputField(
      {required TextEditingController controller,
      required String hint,
      required IconData icon}) {
    return TextFormField(
      controller: controller,
      validator: (value) {
        if (value == null || value.isEmpty) return 'Campo obligatorio';
        return null;
      },
      style: const TextStyle(
        color: Colors.white,
        fontFamily: 'Montserrat',
        fontSize: 14,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: softGreen,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
        hintText: hint,
        hintStyle: TextStyle(
          color: Colors.white.withOpacity(0.6),
          fontFamily: 'Montserrat',
        ),
        prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.8)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
