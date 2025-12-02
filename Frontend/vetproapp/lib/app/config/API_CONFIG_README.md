# Configuración de API

## Ubicación
`lib/app/config/api_config.dart`

## Cambiar la URL del Backend

Para cambiar la URL del backend, edita el archivo `api_config.dart` y modifica la constante `baseUrl`:

### Emulador Android
```dart
static const String baseUrl = 'http://10.0.2.2:4000/api';
```

### Dispositivo físico Android o red local
```dart
static const String baseUrl = 'http://TU_IP_LOCAL:4000/api';
// Ejemplo: 'http://192.168.1.100:4000/api'
```

### iOS Simulator
```dart
static const String baseUrl = 'http://localhost:4000/api';
```

### Producción
```dart
static const String baseUrl = 'https://tu-dominio.com/api';
```

## Servicios que usan esta configuración

Todos los servicios importan `ApiConfig`:
- ✅ AuthService → `ApiConfig.auth`
- ✅ UserService → `ApiConfig.users`
- ✅ PetsService → `ApiConfig.pets`
- ✅ AppointmentsService → `ApiConfig.appointments`
- ✅ ServicesService → `ApiConfig.services`
- ✅ VeterinariaService → `ApiConfig.veterinarias`
- ✅ RecommendationsService → `ApiConfig.recommendations`
- ✅ AdminService → `ApiConfig.baseUrl`
- ✅ HorariosService → `ApiConfig.baseUrl`
- ✅ VeterinariaServicesService → `ApiConfig.baseUrl`
- ✅ MedicalRecordsService → `ApiConfig.medicalRecords`

## Nota
Solo necesitas cambiar una vez en `api_config.dart` y todos los servicios se actualizarán automáticamente.
