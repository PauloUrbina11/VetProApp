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

export const getVeterinariaPatients = async (veterinariaId) => {
  const q = `
    SELECT DISTINCT
      m.id,
      m.nombre,
      e.nombre AS especie,
      r.nombre AS raza,
      EXTRACT(YEAR FROM AGE(NOW(), m.fecha_nacimiento))::int AS edad_anos,
      EXTRACT(MONTH FROM AGE(NOW(), m.fecha_nacimiento))::int AS edad_meses,
      EXTRACT(DAY FROM AGE(NOW(), m.fecha_nacimiento))::int AS edad_dias,
      m.sexo,
      u.nombre_completo AS propietario_nombre,
      u.correo AS propietario_email,
      u.celular AS propietario_telefono,
      (SELECT COUNT(*)::int 
       FROM citas c 
       JOIN citas_mascotas cm ON c.id = cm.cita_id
       JOIN veterinarias_citas vc ON c.id = vc.cita_id
       WHERE cm.mascota_id = m.id AND c.estado_id = 2 AND vc.veterinaria_id = $1) AS total_citas,
      (SELECT MAX(c.fecha_hora)
       FROM citas c
       JOIN citas_mascotas cm ON c.id = cm.cita_id
       JOIN veterinarias_citas vc ON c.id = vc.cita_id
       WHERE cm.mascota_id = m.id AND c.estado_id = 3 AND vc.veterinaria_id = $1) AS ultima_visita
    FROM mascotas m
    JOIN mascotas_users mu ON mu.mascota_id = m.id 
    JOIN users u ON mu.user_id = u.id
    JOIN citas_mascotas cm ON m.id = cm.mascota_id
    JOIN veterinarias_citas vc ON cm.cita_id = vc.cita_id
    JOIN especies e ON m.especie_id = e.id
    JOIN razas r ON m.raza_id = r.id
    WHERE vc.veterinaria_id = $1
    ORDER BY ultima_visita DESC NULLS LAST, m.nombre ASC
  `;
  const res = await pool.query(q, [veterinariaId]);
  return res.rows;
};

export const getVeterinariaDetailedStats = async (veterinariaId) => {
  const values = [veterinariaId];
  
  const confirmadasQ = `
    SELECT COUNT(*)::int AS confirmadas
    FROM veterinarias_citas vc
    JOIN citas c ON vc.cita_id = c.id
    WHERE vc.veterinaria_id = $1 AND c.estado_id = 2
  `;
  
  const canceladasQ = `
    SELECT COUNT(*)::int AS canceladas
    FROM veterinarias_citas vc
    JOIN citas c ON vc.cita_id = c.id
    WHERE vc.veterinaria_id = $1 AND c.estado_id = 4
  `;
  
  const noAsistioQ = `
    SELECT COUNT(*)::int AS no_asistio
    FROM veterinarias_citas vc
    JOIN citas c ON vc.cita_id = c.id
    WHERE vc.veterinaria_id = $1 AND c.estado_id = 5
  `;
  
  const citasMesActualQ = `
    SELECT COUNT(*)::int AS total
    FROM veterinarias_citas vc
    JOIN citas c ON vc.cita_id = c.id
    WHERE vc.veterinaria_id = $1 
    AND EXTRACT(MONTH FROM c.fecha_hora) = EXTRACT(MONTH FROM NOW())
    AND EXTRACT(YEAR FROM c.fecha_hora) = EXTRACT(YEAR FROM NOW())
  `;
  
  const pacientesNuevosQ = `
    SELECT COUNT(DISTINCT cm.mascota_id)::int AS total
    FROM veterinarias_citas vc
    JOIN citas c ON vc.cita_id = c.id
    JOIN citas_mascotas cm ON c.id = cm.cita_id
    WHERE vc.veterinaria_id = $1
    AND c.id = (
      SELECT MIN(c2.id)
      FROM veterinarias_citas vc2
      JOIN citas c2 ON vc2.cita_id = c2.id
      JOIN citas_mascotas cm2 ON c2.id = cm2.cita_id
      WHERE vc2.veterinaria_id = $1 AND cm2.mascota_id = cm.mascota_id
    )
    AND EXTRACT(MONTH FROM c.fecha_hora) = EXTRACT(MONTH FROM NOW())
    AND EXTRACT(YEAR FROM c.fecha_hora) = EXTRACT(YEAR FROM NOW())
  `;
  
  const tasaCompletadaQ = `
    SELECT 
      COUNT(CASE WHEN c.estado_id = 3 THEN 1 END)::numeric / 
      NULLIF(COUNT(*)::numeric, 0) * 100 AS tasa
    FROM veterinarias_citas vc
    JOIN citas c ON vc.cita_id = c.id
    WHERE vc.veterinaria_id = $1
  `;

  const [confRes, cancelRes, noAsistRes, citasMesRes, pacNuevosRes, tasaRes] = await Promise.all([
    pool.query(confirmadasQ, values),
    pool.query(canceladasQ, values),
    pool.query(noAsistioQ, values),
    pool.query(citasMesActualQ, values),
    pool.query(pacientesNuevosQ, values),
    pool.query(tasaCompletadaQ, values),
  ]);

  return {
    citas_confirmadas: confRes.rows[0]?.confirmadas || 0,
    citas_canceladas: cancelRes.rows[0]?.canceladas || 0,
    citas_no_asistio: noAsistRes.rows[0]?.no_asistio || 0,
    citas_mes_actual: citasMesRes.rows[0]?.total || 0,
    pacientes_nuevos_mes: pacNuevosRes.rows[0]?.total || 0,
    tasa_completada: Math.round(tasaRes.rows[0]?.tasa || 0),
  };
};

export const getPatientAppointmentHistory = async (veterinariaId, mascotaId) => {
  const q = `
    SELECT 
      c.id,
      c.fecha_hora,
      c.estado_id,
      c.notas_veterinaria,
      ec.nombre AS estado_nombre
    FROM veterinarias_citas vc
    JOIN citas c ON vc.cita_id = c.id
    JOIN citas_mascotas cm ON c.id = cm.cita_id
    LEFT JOIN estados_citas ec ON c.estado_id = ec.id
    WHERE vc.veterinaria_id = $1 AND cm.mascota_id = $2
    ORDER BY c.fecha_hora DESC
  `;
  const res = await pool.query(q, [veterinariaId, mascotaId]);
  return res.rows;
};