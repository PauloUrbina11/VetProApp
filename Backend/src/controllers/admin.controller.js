import { assignRoleToUser, getUserRole } from "../models/role.model.js";
import { pool } from "../config/database.js";
import { createVeterinaria } from "../models/veterinarias.model.js";
import {
  listVeterinariaRoles,
  assignVeterinariaRole,
  listUsersWithVeterinariaRole,
  getVeterinariaUserRole,
  getVeterinariaUserRoles,
  removeVeterinariaRole,
} from "../models/veterinaria_roles.model.js";

// Listar todos los usuarios (para asignar rol general)
export const listUsersController = async (req, res) => {
  try {
    const q = `
      SELECT 
        u.id, 
        u.nombre_completo AS nombre, 
        u.correo AS email, 
        u.celular,
        u.activo, 
        ru.rol_id,
        r.nombre AS rol_nombre,
        u.created_at
      FROM users u
      LEFT JOIN rol_user ru ON u.id = ru.user_id
      LEFT JOIN roles r ON ru.rol_id = r.id
      ORDER BY u.id
    `;
    const r = await pool.query(q);
    res.json({ ok: true, data: r.rows });
  } catch (err) {
    res.status(500).json({ ok: false, error: err.message });
  }
};

// Listar usuarios con rol veterinaria (para asignar roles de veterinaria_rol)
export const listVeterinariaUsersController = async (req, res) => {
  try {
    const users = await listUsersWithVeterinariaRole();
    res.json({ ok: true, data: users });
  } catch (err) {
    res.status(500).json({ ok: false, error: err.message });
  }
};

export const getUserRoleController = async (req, res) => {
  try {
    const { id } = req.params;
    const rol_id = await getUserRole(Number(id));
    res.json({ ok: true, data: { user_id: Number(id), rol_id } });
  } catch (err) {
    res.status(500).json({ ok: false, error: err.message });
  }
};

export const assignRoleController = async (req, res) => {
  try {
    const { id } = req.params;
    const { rol_id } = req.body;
    if (!rol_id) return res.status(400).json({ ok: false, error: "rol_id requerido" });
    await assignRoleToUser(Number(id), Number(rol_id));
    res.json({ ok: true, message: "Rol asignado", data: { user_id: Number(id), rol_id: Number(rol_id) } });
  } catch (err) {
    res.status(500).json({ ok: false, error: err.message });
  }
};

// Listar roles de veterinaria disponibles (veterinaria_rol)
export const listVeterinariaRolesController = async (req, res) => {
  try {
    const roles = await listVeterinariaRoles();
    res.json({ ok: true, data: roles });
  } catch (err) {
    res.status(500).json({ ok: false, error: err.message });
  }
};

// Asignar rol de veterinaria a un usuario con rol_id = 2
export const assignVeterinariaRoleController = async (req, res) => {
  try {
    const { veterinaria_id, user_id, veterinaria_rol_id } = req.body;
    if (!veterinaria_id || !user_id || !veterinaria_rol_id) {
      return res.status(400).json({ ok: false, error: "veterinaria_id, user_id y veterinaria_rol_id requeridos" });
    }
    const result = await assignVeterinariaRole(Number(veterinaria_id), Number(user_id), Number(veterinaria_rol_id));
    res.json({ ok: true, message: "Rol de veterinaria asignado", data: result });
  } catch (err) {
    res.status(500).json({ ok: false, error: err.message });
  }
};

export const createVeterinariaController = async (req, res) => {
  try {
    const data = req.body; // expects nombre + user_admin_id etc.
    if (!data.nombre) return res.status(400).json({ ok: false, error: "nombre requerido" });
    const vet = await createVeterinaria(data);
    res.status(201).json({ ok: true, data: vet });
  } catch (err) {
    res.status(500).json({ ok: false, error: err.message });
  }
};

// Obtener roles de un usuario en una veterinaria
export const getUserVeterinariaRolesController = async (req, res) => {
  try {
    const { veterinaria_id, user_id } = req.params;
    const roles = await getVeterinariaUserRoles(Number(veterinaria_id), Number(user_id));
    res.json({ ok: true, data: roles });
  } catch (err) {
    res.status(500).json({ ok: false, error: err.message });
  }
};

// Eliminar un rol específico de un usuario
export const removeVeterinariaRoleController = async (req, res) => {
  try {
    const { veterinaria_id, user_id, veterinaria_rol_id } = req.body;
    if (!veterinaria_id || !user_id || !veterinaria_rol_id) {
      return res.status(400).json({ ok: false, error: "veterinaria_id, user_id y veterinaria_rol_id requeridos" });
    }
    const result = await removeVeterinariaRole(Number(veterinaria_id), Number(user_id), Number(veterinaria_rol_id));
    res.json({ ok: true, message: "Rol de veterinaria eliminado", data: result });
  } catch (err) {
    res.status(500).json({ ok: false, error: err.message });
  }
};

// Activar/desactivar usuario
export const toggleUserActiveController = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = Number(id);

    // Primero obtenemos el estado actual
    const currentState = await pool.query(
      'SELECT activo FROM users WHERE id = $1',
      [userId]
    );

    if (currentState.rows.length === 0) {
      return res.status(404).json({ ok: false, error: "Usuario no encontrado" });
    }

    const newActiveState = !currentState.rows[0].activo;

    // Actualizamos el estado
    const result = await pool.query(
      'UPDATE users SET activo = $1 WHERE id = $2 RETURNING id, activo',
      [newActiveState, userId]
    );

    res.json({
      ok: true,
      message: `Usuario ${newActiveState ? 'activado' : 'desactivado'} correctamente`,
      data: result.rows[0]
    });
  } catch (err) {
    res.status(500).json({ ok: false, error: err.message });
  }
};
