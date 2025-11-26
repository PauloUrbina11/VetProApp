import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';
import 'app/app.dart';
import 'features/activation/activation_page.dart';
import 'features/auth/presentation/screens/reset_password_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  // Arranca la app con el navigatorKey accesible globalmente
  runApp(VetProApp(navigatorKey: navigatorKey));

  final appLinks = AppLinks();

  // initial link when app opened from a link
  // Ensure navigator is ready by waiting for the first frame before
  // attempting navigation. Otherwise `navigatorKey.currentState` may be null
  // and the pushNamed will silently do nothing.
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    try {
      final initial = await appLinks.getInitialAppLink();
      if (initial != null) _handleUri(initial, navigatorKey);
    } catch (e) {
      // ignore: avoid_print
      print('Error reading initial app link: $e');
    }
  });

  // listen for incoming links while app is running
  appLinks.uriLinkStream.listen((Uri? uri) {
    if (uri != null) _handleUri(uri, navigatorKey);
  }, onError: (err) {
    // ignore: avoid_print
    print('appLinks stream error: $err');
  });
}

void _handleUri(Uri uri, GlobalKey<NavigatorState> navigatorKey) {
  // Ejemplo de URI esperado: vetproapp://activate?token=ABC123
  // o http(s)://.../activate?token=ABC123
  // Para enlaces con esquema personalizado (vetproapp://activate) el
  // segmento relevante está en `uri.host` (p.ej. 'activate'). Para enlaces
  // http(s) el segmento relevante está en `uri.path` (p.ej. '/activate').
  final String pathCandidate;
  if (uri.scheme == 'vetproapp') {
    pathCandidate = uri.host.toLowerCase();
  } else {
    pathCandidate = uri.path.toLowerCase();
  }

  if (pathCandidate.contains('activate')) {
    final token = uri.queryParameters['token'] ?? '';
    if (token.isNotEmpty) {
      try {
        navigatorKey.currentState
            ?.pushNamed('/activate', arguments: {'token': token});
      } catch (e) {
        navigatorKey.currentState?.push(
            MaterialPageRoute(builder: (_) => ActivationPage(token: token)));
      }
    }
  }

  // Enlaces de restablecimiento: vetproapp://reset?token=... o /reset?token=...
  if (pathCandidate.contains('reset')) {
    final token = uri.queryParameters['token'] ?? '';
    if (token.isNotEmpty) {
      try {
        navigatorKey.currentState
            ?.pushNamed('/reset_password', arguments: {'token': token});
      } catch (e) {
        navigatorKey.currentState?.push(MaterialPageRoute(
            builder: (_) => ResetPasswordScreen(token: token)));
      }
    }
  }
}
