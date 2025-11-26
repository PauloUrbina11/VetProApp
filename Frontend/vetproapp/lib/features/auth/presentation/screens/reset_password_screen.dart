import 'package:flutter/material.dart';
import '../../../../app/services/auth_service.dart';
import '../../../../app/config/theme.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String token;

  const ResetPasswordScreen({Key? key, required this.token}) : super(key: key);

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final newPassword = _passwordController.text.trim();
    try {
      final res = await AuthService.resetPassword(widget.token, newPassword);
      if (res['ok'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(res['message'] ?? 'Contraseña actualizada')));
        await Future.delayed(const Duration(milliseconds: 700));
        if (!mounted) return;
        Navigator.of(context).pushReplacementNamed('/login');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.red,
            content: Text(res['message'] ?? 'Error')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(backgroundColor: Colors.red, content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Restablecer contraseña')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Introduce tu nueva contraseña',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 20)),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscureNew,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: softGreen,
                    labelText: 'Nueva contraseña',
                    labelStyle: const TextStyle(
                      fontFamily: 'Montserrat',
                      color: Colors.white,
                      fontSize: 15,
                    ),
                    hintText: 'Ingresa tu nueva contraseña',
                    hintStyle: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontFamily: 'Montserrat',
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: const TextStyle(color: Colors.white, fontFamily: 'Montserrat'),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Ingresa la nueva contraseña';
                    if (v.length < 6) return 'Mínimo 6 caracteres';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _confirmController,
                  obscureText: _obscureConfirm,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: softGreen,
                    labelText: 'Confirmar contraseña',
                    labelStyle: const TextStyle(
                      fontFamily: 'Montserrat',
                      color: Colors.white,
                      fontSize: 15,
                    ),
                    hintText: 'Repite la contraseña',
                    hintStyle: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontFamily: 'Montserrat',
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirm ? Icons.visibility : Icons.visibility_off,
                        color: Colors.white.withOpacity(0.8),
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirm = !_obscureConfirm;
                        });
                      },
                    ),
                  ),
                  style: const TextStyle(color: Colors.white, fontFamily: 'Montserrat'),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Confirma la contraseña';
                    if (v != _passwordController.text) return 'Las contraseñas no coinciden';
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    child: _loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2),
                          )
                        : const Text('Cambiar contraseña'),
                  ),
                ),
                const SizedBox(height: 12)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
