import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io' show Platform;

class ActivationPage extends StatefulWidget {
  final String token;

  const ActivationPage({Key? key, required this.token}) : super(key: key);

  @override
  _ActivationPageState createState() => _ActivationPageState();
}

class _ActivationPageState extends State<ActivationPage> {
  bool _loading = false;

  Future<void> _activate(int roleId) async {
    setState(() => _loading = true);
    // On Android emulators 'localhost' refers to the emulator itself.
    // Use 10.0.2.2 to reach the host machine from the Android emulator.
    final host = Platform.isAndroid ? '10.0.2.2' : 'localhost';
    final url = Uri.parse(
        'http://$host:4000/api/auth/activate?token=${Uri.encodeComponent(widget.token)}');
    try {
      final res = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        // El backend espera `rol_id` en el body JSON.
        body: jsonEncode({'rol_id': roleId}),
      );

      final body = jsonDecode(res.body);

      if (res.statusCode == 200 && body['ok'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Activado: ${body['message'] ?? 'OK'}')));
        // Mostrar el Snackbar y luego redirigir al login reemplazando
        // la ruta actual para que el usuario no vuelva a la pantalla
        // de activación con el botón atrás.
        if (!mounted) return;
        await Future.delayed(const Duration(milliseconds: 800));
        if (!mounted) return;
        Navigator.of(context).pushReplacementNamed('/login');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content:
                Text('Error: ${body['message'] ?? 'Error de activación'}')));
      }
    } catch (e) {
      // Show a clearer message so it's easier to debug emulator vs device
      final message = e.toString();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'Network error: $message\n\nVerifica la URL del backend (emulador Android -> 10.0.2.2, iOS sim/host -> localhost).')));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Activación')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('¿Cuál es tu perfil?',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 20)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loading ? null : () => _activate(3),
                child: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Tengo una mascota'),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _loading ? null : () => _activate(2),
                child: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Tengo una veterinaria'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
