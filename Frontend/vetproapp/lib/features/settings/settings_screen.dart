import 'package:flutter/material.dart';
import '../../../app/services/auth_service.dart';
import '../../../app/config/theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notificationsEnabled = true;
  bool notificationPrefs = true;
  bool darkTheme = false;
  String language = 'Español';
  bool permissionLocation = false;
  bool permissionCamera = false;
  bool permissionGallery = false;
  bool biometrics = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: vetproGreen,
      appBar: AppBar(
        title: const Text('Ajustes'),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 8),
          ListTile(
            title: const Text('Notificaciones',
                style: TextStyle(color: Colors.white)),
            trailing: Switch(
              value: notificationsEnabled,
              onChanged: (v) => setState(() => notificationsEnabled = v),
              activeColor: Colors.white,
              inactiveThumbColor: Colors.white70,
            ),
          ),
          if (notificationsEnabled)
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16),
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Preferencias de notificaciones',
                        style: TextStyle(color: Colors.white)),
                    value: notificationPrefs,
                    onChanged: (v) => setState(() => notificationPrefs = v),
                    activeColor: Colors.white,
                  ),
                ],
              ),
            ),
          const Divider(color: Colors.white54),
          ListTile(
            title: const Text('Tema', style: TextStyle(color: Colors.white)),
            subtitle: Text(darkTheme ? 'Oscuro' : 'Claro',
                style: const TextStyle(color: Colors.white70)),
            trailing: Switch(
              value: darkTheme,
              onChanged: (v) => setState(() => darkTheme = v),
              activeColor: Colors.white,
            ),
          ),
          ListTile(
            title: const Text('Idioma', style: TextStyle(color: Colors.white)),
            subtitle:
                Text(language, style: const TextStyle(color: Colors.white70)),
            onTap: _chooseLanguage,
          ),
          const Divider(color: Colors.white54),
          ListTile(
            title:
                const Text('Permisos', style: TextStyle(color: Colors.white)),
            subtitle: const Text('Ubicación, cámara, galería',
                style: TextStyle(color: Colors.white70)),
            onTap: _showPermissionsDialog,
          ),
          const Divider(color: Colors.white54),
          ListTile(
            title:
                const Text('Seguridad', style: TextStyle(color: Colors.white)),
            subtitle: const Text('Opciones de seguridad',
                style: TextStyle(color: Colors.white70)),
            onTap: _showSecurity,
          ),
          const Divider(color: Colors.white54),
          ListTile(
            title: const Text('Política de privacidad',
                style: TextStyle(color: Colors.white)),
            onTap: () =>
                _showInfo('Política de privacidad', 'Aquí va la política...'),
          ),
          ListTile(
            title: const Text('Términos y condiciones',
                style: TextStyle(color: Colors.white)),
            onTap: () => _showInfo('Términos y condiciones', 'Términos...'),
          ),
          ListTile(
            title: const Text('Información de la app',
                style: TextStyle(color: Colors.white)),
            onTap: () => _showInfo('Información', 'VetProApp v1.0'),
          ),
          ListTile(
            title: const Text('Contactar soporte',
                style: TextStyle(color: Colors.white)),
            onTap: () => _showInfo('Soporte', 'contacto@vetproapp.example'),
          ),
          const Divider(color: Colors.white54),
          ListTile(
            title: const Text('Cerrar sesión',
                style: TextStyle(color: Colors.white)),
            leading: const Icon(Icons.logout, color: Colors.white),
            onTap: () async {
              await AuthService.logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
    );
  }

  void _chooseLanguage() async {
    final selected = await showDialog<String>(
      context: context,
      builder: (_) => SimpleDialog(
        title: const Text('Selecciona idioma'),
        children: [
          SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 'Español'),
              child: const Text('Español')),
          SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 'Inglés'),
              child: const Text('Inglés')),
        ],
      ),
    );
    if (selected != null) setState(() => language = selected);
  }

  void _showPermissionsDialog() {
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(builder: (context, setStateDialog) {
        return AlertDialog(
          backgroundColor: vetproGreen,
          title: const Text('Permisos', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(
                title: const Text('Ubicación',
                    style: TextStyle(color: Colors.white)),
                value: permissionLocation,
                onChanged: (v) => setStateDialog(() => permissionLocation = v),
                activeColor: Colors.white,
              ),
              SwitchListTile(
                title:
                    const Text('Cámara', style: TextStyle(color: Colors.white)),
                value: permissionCamera,
                onChanged: (v) => setStateDialog(() => permissionCamera = v),
                activeColor: Colors.white,
              ),
              SwitchListTile(
                title: const Text('Galería',
                    style: TextStyle(color: Colors.white)),
                value: permissionGallery,
                onChanged: (v) => setStateDialog(() => permissionGallery = v),
                activeColor: Colors.white,
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child:
                    const Text('Cerrar', style: TextStyle(color: Colors.white)))
          ],
        );
      }),
    );
  }

  void _showSecurity() {
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(builder: (context, setStateDialog) {
        return AlertDialog(
          backgroundColor: vetproGreen,
          title: const Text('Seguridad', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(
                title: const Text('Activar biometría',
                    style: TextStyle(color: Colors.white)),
                value: biometrics,
                onChanged: (v) => setStateDialog(() => biometrics = v),
                activeColor: Colors.white,
              ),
              ListTile(
                title: const Text('Ver actividad de la cuenta',
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _showInfo('Actividad',
                      'Aquí se mostraría la actividad de la cuenta');
                },
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child:
                    const Text('Cerrar', style: TextStyle(color: Colors.white)))
          ],
        );
      }),
    );
  }

  void _showInfo(String title, String content) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: vetproGreen,
        title: Text(title, style: const TextStyle(color: Colors.white)),
        content: Text(content, style: const TextStyle(color: Colors.white)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child:
                  const Text('Cerrar', style: TextStyle(color: Colors.white)))
        ],
      ),
    );
  }
}
