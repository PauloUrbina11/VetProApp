# VetProApp

Sistema completo de gestión para clínicas veterinarias con aplicación móvil para usuarios.

## 📋 Descripción

VetProApp es una plataforma integral que conecta clínicas veterinarias con dueños de mascotas, permitiendo gestionar citas, mascotas, servicios y más.

## 🏗️ Arquitectura

### Backend (Node.js + Express + PostgreSQL)
- API RESTful
- Autenticación JWT
- Sistema de roles (Admin, Veterinaria, Usuario)
- Gestión de citas, mascotas, servicios y recomendaciones

### Frontend (Flutter)
- Aplicación móvil multiplataforma
- Interfaces diferenciadas por rol
- Dashboard para veterinarias
- Perfil de usuario editable

### Base de Datos (PostgreSQL)
- Esquema completo incluido en `Database/vetproapp_db.sql`

## 🚀 Instalación

### Requisitos Previos
- Node.js (v14 o superior)
- PostgreSQL (v12 o superior)
- Flutter SDK (v3.0 o superior)
- Android Studio o Xcode (para desarrollo móvil)

### Backend

1. Navegar a la carpeta del backend:
```bash
cd Backend
```

2. Instalar dependencias:
```bash
npm install
```

3. Configurar variables de entorno (crear archivo `.env`):
```env
PORT=4000
DB_HOST=localhost
DB_PORT=5432
DB_NAME=vetproapp_db
DB_USER=tu_usuario
DB_PASSWORD=tu_password
JWT_SECRET=tu_secreto_jwt
```

4. Crear la base de datos:
```bash
psql -U postgres -f ../Database/vetproapp_db.sql
```

5. Iniciar el servidor:
```bash
npm start
```

### Frontend

1. Navegar a la carpeta del frontend:
```bash
cd Frontend/vetproapp
```

2. Instalar dependencias:
```bash
flutter pub get
```

3. Ejecutar la aplicación:
```bash
flutter run
```

## 📱 Características

### Para Usuarios (Dueños de Mascotas)
- ✅ Registro y autenticación
- ✅ Gestión de perfil
- ✅ Registro de mascotas
- ✅ Búsqueda de veterinarias cercanas
- ✅ Agendamiento de citas
- ✅ Visualización de próximas citas
- ✅ Recomendaciones personalizadas

### Para Veterinarias
- ✅ Dashboard con estadísticas
- ✅ Calendario de citas
- ✅ Lista de próximas citas
- ✅ Gestión de servicios
- ✅ Visualización de mascotas atendidas

### Para Administradores
- ✅ Panel de control global
- ✅ Gestión de usuarios y roles
- ✅ Creación de veterinarias
- ✅ Gestión de citas del sistema
- ✅ Administración de servicios
- ✅ Actividad reciente del sistema

## 🔐 Roles y Permisos

1. **Admin (rol_id = 1)**: Acceso completo al sistema
2. **Veterinaria (rol_id = 2)**: Gestión de su clínica y citas
3. **Usuario (rol_id = 3)**: Gestión de mascotas y citas personales

## 🛠️ Tecnologías

### Backend
- Node.js
- Express.js
- PostgreSQL
- JWT (JSON Web Tokens)
- bcrypt

### Frontend
- Flutter
- Dart
- Material Design
- HTTP client
- SharedPreferences

## 📄 Licencia

Este proyecto es privado y confidencial.

## 👥 Autor

UrbinaTech

## 📞 Soporte

Para soporte o consultas, contacta al equipo de desarrollo.
