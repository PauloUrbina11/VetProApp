import 'package:flutter/material.dart';
import '../../../../app/services/auth_service.dart';
import '../../../../app/config/theme.dart';
import '../../../../app/widgets/section_label.dart';
import '../../../../app/utils/validators.dart';
import '../../../../app/utils/snackbar_helper.dart';
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
          const SectionLabel(
            text: 'Correo Electrónico',
            color: Colors.white,
            fontSize: 15,
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
              ),
            ),
            style: const TextStyle(color: Colors.white),
            validator: Validators.email,
          ),

          const SizedBox(height: 20),

          /// LABEL CONTRASEÑA
          const SectionLabel(
            text: 'Contraseña',
            color: Colors.white,
            fontSize: 15,
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
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
            ),
          ),
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
        if (!mounted) return;
        SnackBarHelper.showSuccess(context, "Inicio de sesión exitoso");
        Navigator.pushReplacementNamed(context, "/home");
      } else {
        if (!mounted) return;
        SnackBarHelper.showError(
          context,
          result["message"] ?? "Error desconocido",
        );
      }
    } catch (e) {
      if (!mounted) return;
      SnackBarHelper.showError(
        context,
        e.toString().replaceAll("Exception:", "").trim(),
      );
    }

    setState(() => loading = false);
  }
}
