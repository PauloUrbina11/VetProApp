class ApiEndpoints {
  static const String baseUrl = "http://10.0.2.2:4000/api"; // Android Emulator
  // Para dispositivo físico cambiar a: http://192.168.X.X:4000/api

  // Auth
  static const String register = "$baseUrl/auth/register";
  static const String login = "$baseUrl/auth/login";
  static const String activate = "$baseUrl/auth/activate";
  static const String resetRequest = "$baseUrl/auth/reset/request";
  static const String resetConfirm = "$baseUrl/auth/reset/update";
}
