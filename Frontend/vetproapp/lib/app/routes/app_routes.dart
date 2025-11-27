import 'package:flutter/material.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/reset_request_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/profile/profile_menu_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/profile/manage_services_screen.dart';
import '../../features/pets/my_pets_screen.dart';
import '../../features/appointments/my_appointments_screen.dart';
import '../../features/appointments/schedule_screen.dart';
import '../../features/appointments/manage_appointments_screen.dart';
import '../../features/recommendations/recommendations_screen.dart';
import '../../features/notifications/notifications_screen.dart';
import '../../features/activation/activation_page.dart';
import '../../features/auth/presentation/screens/reset_password_screen.dart';
import '../../features/admin/create_veterinaria_screen.dart';
import '../../features/admin/manage_roles_screen.dart';
import '../../features/veterinarias/veterinarias_screen.dart';

class AppRoutes {
  static const initialRoute = '/login';

  static Map<String, WidgetBuilder> routes = {
    '/login': (context) => const LoginScreen(),
    '/reset': (context) => const ResetRequestScreen(),
    '/settings': (context) => const SettingsScreen(),
    '/profile_menu': (context) => const ProfileMenuScreen(),
    '/profile': (context) => const ProfileScreen(),
    '/my_pets': (context) => const MyPetsScreen(),
    '/my_appointments': (context) => const MyAppointmentsScreen(),
    '/schedule': (context) => const ScheduleScreen(),
    '/manage_appointments': (context) => const ManageAppointmentsScreen(),
    '/recommendations': (context) => const RecommendationsScreen(),
    '/notifications': (context) => const NotificationsScreen(),
    '/manage_services': (context) => const ManageServicesScreen(),
    '/create_veterinaria': (context) => const CreateVeterinariaScreen(),
    '/manage_roles': (context) => const ManageRolesScreen(),
    '/veterinarias': (context) => const VeterinariasScreen(),
    '/home': (context) => const HomeScreen(),
    '/activate': (context) {
      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
      final token = args != null ? (args['token'] ?? '') as String : '';
      return ActivationPage(token: token);
    },
    '/reset_password': (context) {
      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
      final token = args != null ? (args['token'] ?? '') as String : '';
      return ResetPasswordScreen(token: token);
    },
  };
}
