import 'package:flutter/material.dart';
import 'routes/app_routes.dart';
import 'config/theme.dart';

class VetProApp extends StatelessWidget {
  final GlobalKey<NavigatorState>? navigatorKey;

  const VetProApp({super.key, this.navigatorKey});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VetProApp',
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      navigatorKey: navigatorKey,
      initialRoute: AppRoutes.initialRoute,
      routes: AppRoutes.routes,
    );
  }
}
