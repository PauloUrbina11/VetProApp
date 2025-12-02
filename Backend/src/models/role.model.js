import { pool } from "../config/database.js";

export const assignRoleToUser = async (userId, roleId) => {
  // avoid duplicate assignments
  const existsQ = `SELECT id FROM rol_user WHERE user_id = $1 AND rol_id = $2 LIMIT 1`;
  const exists = await pool.query(existsQ, [userId, roleId]);
  if (exists.rows.length > 0) return exists.rows[0];

  const insert = `
    INSERT INTO rol_user (user_id, rol_id) VALUES ($1, $2) RETURNING id, user_id, rol_id, created_at;
  `;
  const res = await pool.query(insert, [userId, roleId]);
  return res.rows[0];
};

export const getUserRole = async (userId) => {
  const query = `
    SELECT rol_id FROM rol_user WHERE user_id = $1 LIMIT 1;
  `;
  const res = await pool.query(query, [userId]);
  return res.rows[0]?.rol_id || null;
};
