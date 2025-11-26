import 'package:flutter/material.dart';
import '../../../../app/services/auth_service.dart';
import '../../../../app/config/theme.dart';
import 'password_field.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final formKey = GlobalKey<FormState>();

  final TextEditingController correoController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// LABEL CORREO
          const Text(
            'Correo Electrónico',
            style: TextStyle(
              fontFamily: 'Montserrat',
              color: Colors.white,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 8),

          /// INPUT CORREO
          TextFormField(
            controller: correoController,
            decoration: InputDecoration(
              filled: true,
              fillColor: softGreen,
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(8),
              ),
              hintText: 'usuario@example.com',
              hintStyle: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontFamily: 'Montserrat',
              ),
            ),
            style: const TextStyle(color: Colors.white),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Ingresa tu correo";
              }
              if (!value.contains("@")) {
                return "Correo inválido";
              }
              return null;
            },
          ),

          const SizedBox(height: 20),

          /// LABEL CONTRASEÑA
          const Text(
            'Contraseña',
            style: TextStyle(
              fontFamily: 'Montserrat',
              color: Colors.white,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 8),

          /// INPUT CONTRASEÑA
          PasswordField(
            controller: passwordController,
          ),

          const SizedBox(height: 25),

          /// BOTÓN LOGIN
          SizedBox(
            width: double.infinity,
            height: 45,
            child: ElevatedButton(
              onPressed: loading ? null : loginUser,
              style: ElevatedButton.styleFrom(
                backgroundColor: white,
                foregroundColor: darkGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
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
                      'Iniciar sesión',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
            ),
          )
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  //  FUNCIÓN REAL DE LOGIN
  // -------------------------------------------------------------
  Future<void> loginUser() async {
    if (!formKey.currentState!.validate()) return;

    setState(() => loading = true);

    final correo = correoController.text.trim();
    final password = passwordController.text.trim();

    try {
      final result = await AuthService.login(correo, password);

      if (result["ok"] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Text("Inicio de sesión exitoso"),
          ),
        );

        // Navegar al home
        Navigator.pushReplacementNamed(context, "/home");
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(result["message"] ?? "Error desconocido"),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(e.toString().replaceAll("Exception:", "").trim()),
        ),
      );
    }

    setState(() => loading = false);
  }
}
