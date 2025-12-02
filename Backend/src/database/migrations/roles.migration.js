/**
 * Scripts de inicialización de tablas de roles
 */
import { pool } from "../../config/database.js";

export const createRolesTables = async () => {
  const client = await pool.connect();
  try {
    // Tabla de roles principales del sistema
    await client.query(`
      CREATE TABLE IF NOT EXISTS roles (
        id SERIAL PRIMARY KEY,
        nombre VARCHAR(50) NOT NULL UNIQUE,
        descripcion TEXT,
        created_at TIMESTAMP DEFAULT NOW()
      );
    `);

    // Tabla de relación usuario-rol
    await client.query(`
      CREATE TABLE IF NOT EXISTS rol_user (
        id SERIAL PRIMARY KEY,
        user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
        rol_id INTEGER NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
        created_at TIMESTAMP DEFAULT NOW(),
        UNIQUE(user_id, rol_id)
      );
    `);

    // Tabla de roles de veterinaria
    await client.query(`
      CREATE TABLE IF NOT EXISTS veterinaria_roles (
        id SERIAL PRIMARY KEY,
        nombre VARCHAR(50) NOT NULL UNIQUE,
        descripcion TEXT,
        created_at TIMESTAMP DEFAULT NOW()
      );
    `);

    console.log('✅ Tablas de roles creadas correctamente');
  } catch (error) {
    console.error('❌ Error al crear tablas de roles:', error.message);
    throw error;
  } finally {
    client.release();
  }
};

export const ensureDefaultRoles = async () => {
  const client = await pool.connect();
  try {
    // Roles del sistema
    const systemRoles = [
      { id: 1, nombre: 'Administrador', descripcion: 'Administrador del sistema' },
      { id: 2, nombre: 'Usuario', descripcion: 'Usuario regular de la aplicación' },
      { id: 3, nombre: 'Veterinario', descripcion: 'Profesional veterinario' },
    ];

    for (const role of systemRoles) {
      await client.query(
        `INSERT INTO roles (id, nombre, descripcion) 
         VALUES ($1, $2, $3) 
         ON CONFLICT (nombre) DO NOTHING`,
        [role.id, role.nombre, role.descripcion]
      );
    }

    // Roles de veterinaria
    const veterinariaRoles = [
      { id: 1, nombre: 'Administrador', descripcion: 'Administrador de la veterinaria' },
      { id: 2, nombre: 'Veterinario', descripcion: 'Veterinario de la clínica' },
      { id: 3, nombre: 'Asistente', descripcion: 'Asistente veterinario' },
    ];

    for (const role of veterinariaRoles) {
      await client.query(
        `INSERT INTO veterinaria_roles (id, nombre, descripcion) 
         VALUES ($1, $2, $3) 
         ON CONFLICT (nombre) DO NOTHING`,
        [role.id, role.nombre, role.descripcion]
      );
    }

    console.log('✅ Roles por defecto insertados correctamente');
  } catch (error) {
    console.error('❌ Error al insertar roles por defecto:', error.message);
    throw error;
  } finally {
    client.release();
  }
};
