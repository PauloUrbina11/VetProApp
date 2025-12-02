import 'auth_service.dart';
import 'veterinaria_service.dart';

class PermissionsService {
  static List<int> _veterinariaRoles = [];

  static Future<void> loadVeterinariaRoles() async {
    final role = await AuthService.getRole();
    if (role == 2) {
      try {
        final veterinariaIds = await VeterinariaService.getMyVeterinarias();
        if (veterinariaIds.isNotEmpty) {
          final roles =
              await VeterinariaService.getMyVeterinariaRoles(veterinariaIds[0]);
          _veterinariaRoles = roles;
        }
      } catch (e) {
        _veterinariaRoles = [];
      }
    }
  }

  static bool hasRole(int roleId) => _veterinariaRoles.contains(roleId);

  // Permisos para CITAS
  static bool canViewAllAppointments() {
    // Todos los roles pueden ver todas las citas
    return hasRole(1) ||
        hasRole(2) ||
        hasRole(3) ||
        hasRole(4) ||
        hasRole(5) ||
        hasRole(6);
  }

  static bool canEditAppointment() {
    // Administrador, Veterinario, Auxiliar, Estilista, Especialista pueden editar
    return hasRole(1) || hasRole(2) || hasRole(3) || hasRole(5) || hasRole(6);
  }

  static bool canConfirmAppointment() {
    // Administrador y Recepcionista pueden confirmar
    return hasRole(1) || hasRole(4);
  }

  static bool canCancelAppointment() {
    // Administrador y Recepcionista pueden cancelar
    return hasRole(1) || hasRole(4);
  }

  // Permisos para PACIENTES/MASCOTAS
  static bool canViewPatients() {
    // Todos pueden ver pacientes
    return hasRole(1) ||
        hasRole(2) ||
        hasRole(3) ||
        hasRole(4) ||
        hasRole(5) ||
        hasRole(6);
  }

  static bool canViewMedicalHistory() {
    // Todos pueden ver historial clínico
    return hasRole(1) ||
        hasRole(2) ||
        hasRole(3) ||
        hasRole(4) ||
        hasRole(5) ||
        hasRole(6);
  }

  // Permisos para SERVICIOS
  static bool canViewServices() {
    // Todos pueden ver servicios
    return hasRole(1) ||
        hasRole(2) ||
        hasRole(3) ||
        hasRole(4) ||
        hasRole(5) ||
        hasRole(6);
  }

  static bool canCreateService() {
    // Solo Administrador puede crear servicios
    return hasRole(1);
  }

  static bool canEditService() {
    // Solo Administrador puede editar servicios
    return hasRole(1);
  }

  // Permisos para VETERINARIA
  static bool canEditVeterinaria() {
    // Solo Administrador puede editar datos de veterinaria
    return hasRole(1);
  }

  static bool canEditSchedule() {
    // Solo Administrador puede editar horarios
    return hasRole(1);
  }

  // Permisos para REPORTES
  static bool canViewReports() {
    // Solo Administrador puede ver reportes
    return hasRole(1);
  }

  // Obtener estados permitidos según el rol
  static List<int> getAllowedStatusChanges(int currentStatusId) {
    // Administrador: puede confirmar (2) y cancelar (4)
    if (hasRole(1)) {
      switch (currentStatusId) {
        case 1: // Pendiente
          return [2, 4]; // Confirmada, Cancelada
        case 2: // Confirmada
          return [3, 4, 5]; // Completada, Cancelada, No asistió
        default:
          return [];
      }
    }

    // Recepcionista: puede confirmar (2) y cancelar (4)
    if (hasRole(4)) {
      switch (currentStatusId) {
        case 1: // Pendiente
          return [2, 4]; // Confirmada, Cancelada
        case 2: // Confirmada
          return [4]; // Solo Cancelada
        default:
          return [];
      }
    }

    // Veterinario, Auxiliar, Estilista, Especialista: pueden editar (completada, no asistió)
    if (hasRole(2) || hasRole(3) || hasRole(5) || hasRole(6)) {
      switch (currentStatusId) {
        case 1: // Pendiente
          return []; // No pueden cambiar desde pendiente
        case 2: // Confirmada
          return [3, 5]; // Completada, No asistió
        default:
          return [];
      }
    }

    return [];
  }
}
