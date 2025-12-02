import 'package:flutter/material.dart';
import '../../../../app/services/auth_service.dart';
import '../../../../app/config/theme.dart';

class ResetRequestScreen extends StatefulWidget {
  const ResetRequestScreen({super.key});

  @override
  State<ResetRequestScreen> createState() => _ResetRequestScreenState();
}

class _ResetRequestScreenState extends State<ResetRequestScreen> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController correoController = TextEditingController();
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Restablecer contraseña')),
        body: SafeArea(
            child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                          'Introduce tu correo para recibir un enlace o token de restablecimiento',
                          style: TextStyle(fontSize: 16, color: darkGreen)),
                      const SizedBox(height: 16),
                      Form(
                          key: formKey,
                          child: TextFormField(
                              controller: correoController,
                              decoration: InputDecoration(
                                  filled: true,
                                  fillColor: softGreen, // Fondo verde
                                  labelText: 'Correo electrónico',
                                  labelStyle: const TextStyle(
                                      color: Colors.white, fontSize: 15),
                                  hintText: 'usuario@example.com',
                                  hintStyle: TextStyle(
                                      color: Colors.white.withOpacity(0.6)),
                                  border: OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                      borderRadius: BorderRadius.circular(8))),
                              style: const TextStyle(
                                color:
                                    Colors.white, // Texto ingresado en blanco
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty)
                                  return 'Ingresa tu correo';
                                if (!v.contains('@')) return 'Correo inválido';
                                return null;
                              })),
                      const SizedBox(height: 20),
                      SizedBox(
                          width: double.infinity,
                          height: 45,
                          child: ElevatedButton(
                              onPressed: loading ? null : _submit,
                              child: loading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                          color: Colors.white, strokeWidth: 2))
                                  : const Text('Solicitar restablecimiento')))
                    ]))));
  }

  Future<void> _submit() async {
    if (!formKey.currentState!.validate()) return;
    setState(() => loading = true);

    final correo = correoController.text.trim();
    try {
      final res = await AuthService.requestPasswordReset(correo);
      if (res["ok"] == true) {
        // final token = res["token"] ?? res["reset_token"];
        // Mostrar dialog con token (temporal hasta enviar email)
        showDialog(
            context: context,
            builder: (_) => AlertDialog(
                    title: const Text('Solicitud enviada'),
                    content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(res["message"] ??
                              'Se ha enviado un enlace al correo'),
                        ]),
                    actions: [
                      TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            // Vaciar y volver al login
                            correoController.clear();
                            Navigator.pushReplacementNamed(context, '/login');
                          },
                          child: const Text('Ir a iniciar sesión'))
                    ]));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.red,
            content: Text(res["message"] ?? 'Error')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(backgroundColor: Colors.red, content: Text(e.toString())));
    }

    setState(() => loading = false);
  }
}
