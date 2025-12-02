import { pool } from "../config/database.js";

// Obtener notificaciones de un usuario
export const getUserNotifications = async (userId) => {
  const q = `
    SELECT 
      n.id,
      n.user_id,
      n.titulo,
      n.mensaje,
      n.tipo,
      n.leida,
      n.referencia_id,
      n.referencia_tipo,
      n.created_at
    FROM notificaciones n
    WHERE n.user_id = $1
    ORDER BY n.created_at DESC
    LIMIT 50
  `;
  const res = await pool.query(q, [userId]);
  return res.rows;
};

// Marcar notificación como leída
export const markNotificationAsRead = async (notificationId, userId) => {
  const q = `
    UPDATE notificaciones
    SET leida = true
    WHERE id = $1 AND user_id = $2
    RETURNING *
  `;
  const res = await pool.query(q, [notificationId, userId]);
  return res.rows[0];
};

// Marcar todas las notificaciones como leídas
export const markAllNotificationsAsRead = async (userId) => {
  const q = `
    UPDATE notificaciones
    SET leida = true
    WHERE user_id = $1 AND leida = false
    RETURNING id
  `;
  const res = await pool.query(q, [userId]);
  return res.rows;
};

// Crear notificación
export const createNotification = async ({
  user_id,
  titulo,
  mensaje,
  tipo,
  referencia_id,
  referencia_tipo,
}) => {
  const q = `
    INSERT INTO notificaciones (user_id, titulo, mensaje, tipo, referencia_id, referencia_tipo)
    VALUES ($1, $2, $3, $4, $5, $6)
    RETURNING *
  `;
  const res = await pool.query(q, [
    user_id,
    titulo,
    mensaje,
    tipo || 'info',
    referencia_id || null,
    referencia_tipo || null,
  ]);
  return res.rows[0];
};

// Obtener cantidad de notificaciones no leídas
export const getUnreadNotificationsCount = async (userId) => {
  const q = `
    SELECT COUNT(*) as count
    FROM notificaciones
    WHERE user_id = $1 AND leida = false
  `;
  const res = await pool.query(q, [userId]);
  return parseInt(res.rows[0].count);
};

// Eliminar notificación
export const deleteNotification = async (notificationId, userId) => {
  const q = `
    DELETE FROM notificaciones
    WHERE id = $1 AND user_id = $2
    RETURNING id
  `;
  const res = await pool.query(q, [notificationId, userId]);
  return res.rows[0];
};
