# 🏥 VetProApp Backend

Backend de la aplicación VetProApp - Sistema de gestión veterinaria profesional.

**Estado:** ✅ Funcionando | **Versión:** 1.0.0 | **Node.js + Express + PostgreSQL**

---

## 🚀 Inicio Rápido

```powershell
# Instalar dependencias
npm install

# Configurar variables de entorno
# Copiar .env.example a .env y configurar

# Iniciar servidor en modo desarrollo
npm run dev

# Servidor corriendo en: http://localhost:4000
```

---

## 📁 Estructura del Proyecto

```
Backend/
├── src/
│   ├── config/              # Configuración (DB, variables de entorno)
│   ├── constants/           # ⭐ Constantes del sistema
│   ├── database/            # ⭐ Migraciones y scripts de BD
│   ├── validators/          # ⭐ Validadores de datos
│   ├── middlewares/         # Middlewares (auth, validación, roles)
│   ├── utils/               # Utilidades reutilizables
│   ├── models/              # Modelos (acceso a datos)
│   ├── services/            # Lógica de negocio
│   ├── controllers/         # Controladores (request/response)
│   ├── routes/              # Definición de rutas
│   ├── app.js               # Configuración de Express
│   └── server.js            # Punto de entrada
├── ESTRUCTURA.md            # 📖 Documentación de arquitectura
├── GUIA_RAPIDA.md           # 🚀 Guía de uso rápida
└── README.md                # Este archivo
```

⭐ = Carpetas creadas en la reorganización reciente

---

## 📚 Documentación

| Archivo | Descripción |
|---------|-------------|
| [ESTRUCTURA.md](ESTRUCTURA.md) | Arquitectura completa del proyecto |
| [GUIA_RAPIDA.md](GUIA_RAPIDA.md) | Patrones y ejemplos de código |
| [CAMBIOS_REORGANIZACION.md](CAMBIOS_REORGANIZACION.md) | Detalle de la reorganización |
| [RESUMEN_EJECUTIVO.md](RESUMEN_EJECUTIVO.md) | Resumen ejecutivo de cambios |
| [CHECKLIST.md](CHECKLIST.md) | Lista de verificación |
| [LIMPIEZA.md](LIMPIEZA.md) | Scripts de limpieza |

**Recomendación:** Lee `ESTRUCTURA.md` para entender la arquitectura completa.

---

## 🛠️ Tecnologías

- **Runtime:** Node.js v22+
- **Framework:** Express 5.x
- **Base de Datos:** PostgreSQL
- **Autenticación:** JWT (jsonwebtoken)
- **Hash de Contraseñas:** bcryptjs
- **Email:** Nodemailer
- **Validación:** Validators personalizados

---

## 📦 Dependencias Principales

```json
{
  "express": "^5.1.0",
  "pg": "^8.16.3",
  "jsonwebtoken": "^9.0.2",
  "bcryptjs": "^3.0.3",
  "dotenv": "^17.2.3",
  "cors": "^2.8.5",
  "nodemailer": "^6.10.1"
}
```

---

## 🔧 Scripts Disponibles

```powershell
# Desarrollo (con hot reload)
npm run dev

# Producción
npm start

# Lint (opcional, configurar ESLint)
npm run lint
```

---

## 🌟 Características

### ✅ Arquitectura Limpia
- Separación de responsabilidades (MVC mejorado)
- Constantes centralizadas
- Validadores independientes
- Utilidades consolidadas

### ✅ Autenticación y Seguridad
- JWT tokens
- Hash de contraseñas con bcrypt
- Control de acceso por roles
- Rate limiting
- Validación de datos

### ✅ Gestión de Usuarios
- Registro con activación por email
- Login con intentos fallidos
- Reset de contraseña
- Gestión de perfiles

### ✅ Gestión Veterinaria
- CRUD de veterinarias
- Servicios por veterinaria
- Horarios de atención
- Dashboard administrativo

### ✅ Gestión de Citas
- Crear, editar, cancelar citas
- Estados de citas
- Asignación de mascotas y servicios
- Calendario de citas

### ✅ Estadísticas
- Estadísticas globales (admin)
- Estadísticas por usuario
- Dashboard con métricas

---

## 🔐 Variables de Entorno

Crea un archivo `.env` en la raíz con:

```env
# Puerto del servidor
PORT=4000

# Base de datos PostgreSQL
DB_USER=tu_usuario
DB_HOST=localhost
DB_NAME=vetproapp
DB_PASSWORD=tu_password
DB_PORT=5432

# JWT Secret
JWT_SECRET=tu_secret_key_muy_segura

# Email (Nodemailer)
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_USER=tu_email@gmail.com
EMAIL_PASSWORD=tu_password_app
```

---

## 🛣️ API Endpoints

### Autenticación
- `POST /api/auth/register` - Registro de usuario
- `POST /api/auth/login` - Login
- `POST /api/auth/activate` - Activación de cuenta
- `GET /api/auth/activate` - Redirect para activación
- `POST /api/auth/reset/request` - Solicitar reset de contraseña
- `POST /api/auth/reset/update` - Actualizar contraseña

### Usuarios
- `GET /api/users/profile` - Obtener perfil (requiere auth)
- `PUT /api/users/profile` - Actualizar perfil (requiere auth)

### Mascotas
- `GET /api/pets` - Listar mascotas del usuario
- `POST /api/pets` - Crear mascota
- `PUT /api/pets/:id` - Actualizar mascota
- `DELETE /api/pets/:id` - Eliminar mascota

### Citas
- `GET /api/appointments` - Listar citas
- `POST /api/appointments` - Crear cita
- `PUT /api/appointments/:id` - Actualizar cita
- `DELETE /api/appointments/:id` - Cancelar cita

### Veterinarias
- `GET /api/veterinarias` - Listar veterinarias
- `GET /api/veterinarias/:id` - Detalle de veterinaria
- `POST /api/veterinarias` - Crear veterinaria (admin)
- `PUT /api/veterinarias/:id` - Actualizar veterinaria

### Estadísticas
- `GET /api/stats/global` - Estadísticas globales (solo admin)
- `GET /api/stats/user` - Estadísticas del usuario

### Admin
- `GET /api/admin/*` - Endpoints administrativos (solo admin)

---

## 🔒 Autenticación

Todas las rutas protegidas requieren el header:

```
Authorization: Bearer <token_jwt>
```

### Roles Disponibles
- **Admin (1):** Acceso completo
- **Usuario (2):** Acceso a sus propios recursos
- **Veterinario (3):** Acceso a gestión veterinaria

---

## 💡 Ejemplos de Uso

### Registro de Usuario

```http
POST /api/auth/register
Content-Type: application/json

{
  "nombre_completo": "Juan Pérez",
  "correo": "juan@example.com",
  "password": "password123",
  "celular": "3001234567",
  "direccion": "Calle 123",
  "ciudad_id": 1,
  "departamento_id": 1
}
```

### Login

```http
POST /api/auth/login
Content-Type: application/json

{
  "correo": "juan@example.com",
  "password": "password123"
}
```

### Crear Cita (requiere auth)

```http
POST /api/appointments
Authorization: Bearer <token>
Content-Type: application/json

{
  "veterinaria_id": 1,
  "fecha_hora": "2025-12-01 10:00:00",
  "mascotas": [1, 2],
  "servicios": [1],
  "notas_cliente": "Vacunación anual"
}
```

---

## 🧪 Testing

```powershell
# Recomendado: Instalar Jest para tests
npm install --save-dev jest supertest

# Ejecutar tests (cuando se implementen)
npm test
```

---

## 🚀 Deployment

### Producción

```powershell
# Instalar dependencias de producción
npm install --production

# Iniciar servidor
npm start
```

### Recomendaciones
- Usar PM2 para gestión de procesos
- Configurar HTTPS/SSL
- Usar variables de entorno seguras
- Habilitar logging
- Configurar backups de BD

---

## 📊 Estado del Proyecto

- ✅ Arquitectura reorganizada profesionalmente
- ✅ Código limpio y mantenible
- ✅ Documentación completa
- ✅ Servidor funcionando sin errores
- ✅ Constantes centralizadas
- ✅ Validadores separados
- ✅ Utilidades consolidadas

---

## 🤝 Contribuir

1. Revisar `ESTRUCTURA.md` para entender la arquitectura
2. Seguir las convenciones de código establecidas
3. Usar constantes en lugar de valores hardcodeados
4. Separar validaciones en `validators/`
5. Documentar cambios importantes

---

## 📝 Convenciones

### Imports
```javascript
// ✅ Usar imports consolidados
import { generateJWT } from '../utils/tokens.js';
import { ROLES } from '../constants/index.js';

// ❌ Evitar imports de archivos antiguos
import { generateJWT } from '../utils/generateJWT.js';
```

### Constantes
```javascript
// ✅ Usar constantes
if (rol_id === ROLES.ADMIN) { ... }

// ❌ Evitar magic numbers
if (rol_id === 1) { ... }
```

### Validaciones
```javascript
// ✅ En validators y middlewares
router.post('/ruta', requireFields(['campo']), controller);

// ❌ Evitar en controllers
if (!req.body.campo) return res.status(400)...
```

---

## 📞 Contacto

**Autor:** Paulo Urbina  
**Proyecto:** VetProApp Backend  
**Versión:** 1.0.0

---

## 📄 Licencia

ISC

---

**¡Disfruta del proyecto reorganizado! 🎉**
