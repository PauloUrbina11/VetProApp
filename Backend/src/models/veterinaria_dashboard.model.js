import { pool } from "../config/database.js";

export const getVeterinariasByUser = async (userId) => {
  const q = `SELECT veterinaria_id FROM veterinaria_user WHERE user_id = $1 ORDER BY created_at`;
  const res = await pool.query(q, [userId]);
  return res.rows.map(r => r.veterinaria_id);
};

export const getVeterinariaStats = async (veterinariaId) => {
  const values = [veterinariaId];
  const totalCitasQ = `
    SELECT COUNT(*)::int AS total
    FROM veterinarias_citas vc
    JOIN citas c ON vc.cita_id = c.id
    WHERE vc.veterinaria_id = $1
  `;
  const pendientesQ = `
    SELECT COUNT(*)::int AS pendientes
    FROM veterinarias_citas vc
    JOIN citas c ON vc.cita_id = c.id
    WHERE vc.veterinaria_id = $1 AND c.estado_id = 1
  `;
  const completadasQ = `
    SELECT COUNT(*)::int AS completadas
    FROM veterinarias_citas vc
    JOIN citas c ON vc.cita_id = c.id
    WHERE vc.veterinaria_id = $1 AND c.estado_id = 3
  `;
  const mascotasQ = `
    SELECT COUNT(DISTINCT cm.mascota_id)::int AS mascotas
    FROM veterinarias_citas vc
    JOIN citas c ON vc.cita_id = c.id
    JOIN citas_mascotas cm ON c.id = cm.cita_id
    WHERE vc.veterinaria_id = $1
  `;

  const [totalRes, pendRes, compRes, mascRes] = await Promise.all([
    pool.query(totalCitasQ, values),
    pool.query(pendientesQ, values),
    pool.query(completadasQ, values),
    pool.query(mascotasQ, values),
  ]);

  return {
    totalCitas: totalRes.rows[0]?.total || 0,
    citasPendientes: pendRes.rows[0]?.pendientes || 0,
    citasCompletadas: compRes.rows[0]?.completadas || 0,
    mascotasAtendidas: mascRes.rows[0]?.mascotas || 0,
  };
};

export const getVeterinariaNextAppointments = async (veterinariaId, limit = 3) => {
  const q = `
    SELECT c.id, c.fecha_hora, c.estado_id, ec.nombre AS estado_nombre,
           u.nombre_completo AS usuario_nombre, u.correo AS usuario_email
    FROM veterinarias_citas vc
    JOIN citas c ON vc.cita_id = c.id
    LEFT JOIN estados_citas ec ON c.estado_id = ec.id
    LEFT JOIN users u ON c.user_id = u.id
    WHERE vc.veterinaria_id = $1 AND c.fecha_hora > now()
    ORDER BY c.fecha_hora ASC
    LIMIT $2
  `;
  const res = await pool.query(q, [veterinariaId, limit]);
  return res.rows;
};

export const getVeterinariaCalendarCounts = async (veterinariaId, fromDate, toDate) => {
  const q = `
    SELECT CAST(c.fecha_hora AS DATE) AS fecha, COUNT(*)::int AS cantidad
    FROM veterinarias_citas vc
    JOIN citas c ON vc.cita_id = c.id
    WHERE vc.veterinaria_id = $1 AND c.fecha_hora::date BETWEEN $2 AND $3
    GROUP BY fecha
    ORDER BY fecha
  `;
  const res = await pool.query(q, [veterinariaId, fromDate, toDate]);
  return res.rows; // [{ fecha: '2025-11-25', cantidad: 3 }, ...]
};

export const isVeterinariaAdmin = async (veterinariaId, userId) => {
  const q = `SELECT 1 FROM veterinarias WHERE id = $1 AND user_admin_id = $2 LIMIT 1`;
  const res = await pool.query(q, [veterinariaId, userId]);
  return res.rowCount === 1;
};