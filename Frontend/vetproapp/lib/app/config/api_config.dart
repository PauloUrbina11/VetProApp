class ApiConfig {
  // URL base para el backend
  // Usar 10.0.2.2 para emulador Android (localhost de la máquina host)
  // Usar localhost o IP real para dispositivos físicos o iOS
  static const String baseUrl = 'http://10.0.2.2:4000/api';

  // Endpoints específicos
  static const String auth = '$baseUrl/auth';
  static const String users = '$baseUrl/users';
  static const String pets = '$baseUrl/pets';
  static const String appointments = '$baseUrl/appointments';
  static const String services = '$baseUrl/services';
  static const String veterinarias = '$baseUrl/veterinarias';
  static const String recommendations = '$baseUrl/recommendations';
  static const String admin = '$baseUrl/admin';
  static const String stats = '$baseUrl/stats';
  static const String medicalRecords = '$baseUrl/medical-records';
}
