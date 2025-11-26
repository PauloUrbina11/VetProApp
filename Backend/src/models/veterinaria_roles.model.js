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

  // Insertar o actualizar en veterinaria_user (unique constraint en veterinaria_id, user_id)
  const q = `
    INSERT INTO veterinaria_user (veterinaria_id, user_id, veterinaria_rol_id)
    VALUES ($1, $2, $3)
    ON CONFLICT (veterinaria_id, user_id)
    DO UPDATE SET 
      veterinaria_rol_id = EXCLUDED.veterinaria_rol_id,
      updated_at = now()
    RETURNING *
  `;
  const res = await pool.query(q, [veterinariaId, userId, veterinariaRolId]);
  return res.rows[0];
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

// Obtener el rol de veterinaria asignado a un usuario en una veterinaria
export const getVeterinariaUserRole = async (veterinariaId, userId) => {
  const q = `
    SELECT veterinaria_rol_id FROM veterinaria_user
    WHERE veterinaria_id = $1 AND user_id = $2
  `;
  const res = await pool.query(q, [veterinariaId, userId]);
  return res.rows[0]?.veterinaria_rol_id || null;
};
