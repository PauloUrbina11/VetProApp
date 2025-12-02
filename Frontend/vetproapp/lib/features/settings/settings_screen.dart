import 'package:flutter/material.dart';
import '../../app/services/auth_service.dart';
import '../../app/config/theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notificationsEnabled = true;
  String language = 'Español';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mint,
      appBar: AppBar(
        title: const Text(
          'Ajustes',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: softGreen,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Sección: Notificaciones
          _buildSectionTitle('Notificaciones'),
          _buildCard(
            child: SwitchListTile(
              title: const Text(
                'Notificaciones',
                style: TextStyle(color: darkGreen, fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                notificationsEnabled ? 'Activadas' : 'Desactivadas',
                style: TextStyle(color: darkGreen.withOpacity(0.6)),
              ),
              value: notificationsEnabled,
              onChanged: (v) => setState(() => notificationsEnabled = v),
              activeColor: softGreen,
              secondary: Icon(
                notificationsEnabled
                    ? Icons.notifications_active
                    : Icons.notifications_off,
                color: darkGreen,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Sección: Preferencias
          _buildSectionTitle('Preferencias'),
          _buildCard(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.language, color: darkGreen),
                  title: const Text(
                    'Idioma',
                    style: TextStyle(
                        color: darkGreen, fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    language,
                    style: TextStyle(color: darkGreen.withOpacity(0.6)),
                  ),
                  trailing: const Icon(Icons.chevron_right, color: darkGreen),
                  onTap: _chooseLanguage,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Sección: Información
          _buildSectionTitle('Información'),
          _buildCard(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info_outline, color: darkGreen),
                  title: const Text(
                    'Acerca de VetProApp',
                    style: TextStyle(
                        color: darkGreen, fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    'Versión 1.0.0',
                    style: TextStyle(color: darkGreen.withOpacity(0.6)),
                  ),
                  trailing: const Icon(Icons.chevron_right, color: darkGreen),
                  onTap: () => _showInfo(
                    'Acerca de VetProApp',
                    'VetProApp v1.0.0\n\nPlataforma integral para la gestión de citas veterinarias, historiales médicos y servicios para mascotas.',
                  ),
                ),
                const Divider(height: 1, color: lightGreen),
                ListTile(
                  leading: const Icon(Icons.help_outline, color: darkGreen),
                  title: const Text(
                    'Ayuda y soporte',
                    style: TextStyle(
                        color: darkGreen, fontWeight: FontWeight.w600),
                  ),
                  trailing: const Icon(Icons.chevron_right, color: darkGreen),
                  onTap: () => _showInfo(
                    'Ayuda y soporte',
                    '¿Necesitas ayuda?\n\nContacto: soporte@vetproapp.com\nTeléfono: +1 234 567 8900\n\nHorario de atención:\nLun - Vie: 8:00 AM - 6:00 PM',
                  ),
                ),
                const Divider(height: 1, color: lightGreen),
                ListTile(
                  leading:
                      const Icon(Icons.privacy_tip_outlined, color: darkGreen),
                  title: const Text(
                    'Política de privacidad',
                    style: TextStyle(
                        color: darkGreen, fontWeight: FontWeight.w600),
                  ),
                  trailing: const Icon(Icons.chevron_right, color: darkGreen),
                  onTap: () => _showInfo(
                    'Política de privacidad',
                    'Tu privacidad es importante para nosotros.\n\nVetProApp protege tus datos personales y los de tus mascotas. No compartimos tu información con terceros sin tu consentimiento.\n\nPara más información, visita nuestra política completa en www.vetproapp.com/privacidad',
                  ),
                ),
                const Divider(height: 1, color: lightGreen),
                ListTile(
                  leading:
                      const Icon(Icons.description_outlined, color: darkGreen),
                  title: const Text(
                    'Términos y condiciones',
                    style: TextStyle(
                        color: darkGreen, fontWeight: FontWeight.w600),
                  ),
                  trailing: const Icon(Icons.chevron_right, color: darkGreen),
                  onTap: () => _showInfo(
                    'Términos y condiciones',
                    'Al usar VetProApp, aceptas nuestros términos y condiciones de servicio.\n\nRevisa los términos completos en www.vetproapp.com/terminos',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Botón de cerrar sesión
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton.icon(
              onPressed: _confirmLogout,
              icon: const Icon(Icons.logout, color: white),
              label: const Text(
                'Cerrar sesión',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[400],
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: darkGreen.withOpacity(0.7),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Card(
      color: lightGreen,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          '¿Cerrar sesión?',
          style: TextStyle(color: darkGreen, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          '¿Estás seguro de que deseas cerrar sesión?',
          style: TextStyle(color: darkGreen),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar', style: TextStyle(color: darkGreen)),
          ),
          ElevatedButton(
            onPressed: () async {
              // Cerrar el diálogo primero
              Navigator.pop(dialogContext);
              // Hacer logout
              await AuthService.logout();
              // Navegar a login usando el contexto de la pantalla principal
              if (mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/login',
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[400],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Cerrar sesión', style: TextStyle(color: white)),
          ),
        ],
      ),
    );
  }

  void _chooseLanguage() async {
    final selected = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Selecciona idioma',
          style: TextStyle(color: darkGreen, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption('Español', Icons.language),
            const Divider(height: 1),
            _buildLanguageOption('English', Icons.language),
          ],
        ),
      ),
    );
    if (selected != null) setState(() => language = selected);
  }

  Widget _buildLanguageOption(String lang, IconData icon) {
    final isSelected = language == lang;
    return ListTile(
      leading: Icon(icon, color: isSelected ? softGreen : darkGreen),
      title: Text(
        lang,
        style: TextStyle(
          color: darkGreen,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing:
          isSelected ? const Icon(Icons.check_circle, color: softGreen) : null,
      onTap: () => Navigator.pop(context, lang),
    );
  }

  void _showInfo(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          title,
          style: const TextStyle(
            color: darkGreen,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Text(
            content,
            style: const TextStyle(color: darkGreen, height: 1.5),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              backgroundColor: softGreen,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text('Cerrar', style: TextStyle(color: white)),
            ),
          ),
        ],
      ),
    );
  }
}
