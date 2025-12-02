import { pool } from "../config/database.js";

// Listar roles disponibles en veterinaria_rol
export const listVeterinariaRoles = async () => {
  const q = `SELECT id, nombre, descripcion FROM veterinaria_rol ORDER BY id`;
  const res = await pool.query(q);
  return res.rows;
};

// Asignar un rol de veterinaria a un usuario (requiere que user tenga rol_id = 2)
export const assignVeterinariaRole = async (veterinariaId, userId, veterinariaRolId) => {
  // Verificar que el usuario tenga rol 2 (veterinaria)
  const checkRol = await pool.query(
    `SELECT rol_id FROM rol_user WHERE user_id = $1 LIMIT 1`,
    [userId]
  );
  if (!checkRol.rows.length || checkRol.rows[0].rol_id !== 2) {
    throw new Error("El usuario debe tener rol veterinaria (rol_id=2)");
  }

  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    
    // Verificar si el usuario ya tiene este rol en esta veterinaria
    const existingRole = await client.query(
      `SELECT id FROM veterinaria_user 
       WHERE veterinaria_id = $1 AND user_id = $2 AND veterinaria_rol_id = $3`,
      [veterinariaId, userId, veterinariaRolId]
    );
    
    if (existingRole.rows.length > 0) {
      await client.query('COMMIT');
      return existingRole.rows[0];
    }
    
    // Si el rol es administrador (1), verificar si ya existe uno diferente
    if (veterinariaRolId === 1) {
      // Buscar administrador actual (diferente al usuario actual)
      const currentAdmin = await client.query(
        `SELECT user_id FROM veterinaria_user 
         WHERE veterinaria_id = $1 AND veterinaria_rol_id = 1 AND user_id != $2`,
        [veterinariaId, userId]
      );
      
      // Si hay un administrador diferente, quitarle SOLO el rol de administrador
      if (currentAdmin.rows.length > 0) {
        await client.query(
          `DELETE FROM veterinaria_user 
           WHERE veterinaria_id = $1 AND user_id = $2 AND veterinaria_rol_id = 1`,
          [veterinariaId, currentAdmin.rows[0].user_id]
        );
      }
      
      // Actualizar user_admin_id en la tabla veterinarias
      await client.query(
        `UPDATE veterinarias SET user_admin_id = $1, updated_at = now() WHERE id = $2`,
        [userId, veterinariaId]
      );
    }
    
    // Insertar nuevo rol (sin ON CONFLICT ya que puede tener múltiples roles)
    const q = `
      INSERT INTO veterinaria_user (veterinaria_id, user_id, veterinaria_rol_id)
      VALUES ($1, $2, $3)
      RETURNING *
    `;
    const res = await client.query(q, [veterinariaId, userId, veterinariaRolId]);
    
    await client.query('COMMIT');
    return res.rows[0];
  } catch (error) {
    await client.query('ROLLBACK');
    throw error;
  } finally {
    client.release();
  }
};

// Listar usuarios con rol veterinaria (rol_id=2)
export const listUsersWithVeterinariaRole = async () => {
  const q = `
    SELECT u.id, u.nombre_completo, u.correo, u.activo
    FROM users u
    INNER JOIN rol_user ru ON ru.user_id = u.id
    WHERE ru.rol_id = 2
    ORDER BY u.id
  `;
  const res = await pool.query(q);
  return res.rows;
};

// Obtener los roles de veterinaria asignados a un usuario en una veterinaria
export const getVeterinariaUserRole = async (veterinariaId, userId) => {
  const q = `
    SELECT veterinaria_rol_id FROM veterinaria_user
    WHERE veterinaria_id = $1 AND user_id = $2
    ORDER BY veterinaria_rol_id
  `;
  const res = await pool.query(q, [veterinariaId, userId]);
  // Retornar array de roles
  return res.rows.map(row => row.veterinaria_rol_id);
};

// Obtener todos los roles de un usuario con información completa
export const getVeterinariaUserRoles = async (veterinariaId, userId) => {
  const q = `
    SELECT vu.*, vr.nombre as rol_nombre, vr.descripcion as rol_descripcion
    FROM veterinaria_user vu
    INNER JOIN veterinaria_rol vr ON vu.veterinaria_rol_id = vr.id
    WHERE vu.veterinaria_id = $1 AND vu.user_id = $2
    ORDER BY vu.veterinaria_rol_id
  `;
  const res = await pool.query(q, [veterinariaId, userId]);
  return res.rows;
};

// Eliminar un rol específico de un usuario
export const removeVeterinariaRole = async (veterinariaId, userId, veterinariaRolId) => {
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    
    // Si es rol administrador (1), actualizar user_admin_id a NULL en veterinarias
    if (veterinariaRolId === 1) {
      const currentAdmin = await client.query(
        `SELECT user_admin_id FROM veterinarias WHERE id = $1`,
        [veterinariaId]
      );
      
      if (currentAdmin.rows[0]?.user_admin_id === userId) {
        await client.query(
          `UPDATE veterinarias SET user_admin_id = NULL, updated_at = now() WHERE id = $1`,
          [veterinariaId]
        );
      }
    }
    
    // Eliminar el rol específico
    const q = `
      DELETE FROM veterinaria_user 
      WHERE veterinaria_id = $1 AND user_id = $2 AND veterinaria_rol_id = $3
      RETURNING *
    `;
    const res = await client.query(q, [veterinariaId, userId, veterinariaRolId]);
    
    await client.query('COMMIT');
    return res.rows[0];
  } catch (error) {
    await client.query('ROLLBACK');
    throw error;
  } finally {
    client.release();
  }
};
