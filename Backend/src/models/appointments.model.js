import { pool } from "../config/database.js";

export const listAppointmentsByUser = async (userId) => {
  const q = `
    SELECT c.id, c.user_id, c.fecha_hora, c.estado_id, c.notas_cliente, c.notas_veterinaria,
           ec.nombre as estado_nombre,
           u.nombre_completo as usuario_nombre, u.correo as usuario_email
    FROM citas c
    LEFT JOIN estados_citas ec ON c.estado_id = ec.id
    LEFT JOIN users u ON c.user_id = u.id
    WHERE c.user_id = $1
    ORDER BY c.fecha_hora DESC
  `;
  const res = await pool.query(q, [userId]);
  return res.rows;
};

export const listAllAppointments = async () => {
  const q = `
    SELECT c.id, c.user_id, c.fecha_hora, c.estado_id, c.notas_cliente, c.notas_veterinaria,
           c.created_at, c.updated_at,
           ec.nombre as estado_nombre,
           u.nombre_completo as usuario_nombre, u.correo as usuario_email,
           u.celular as usuario_telefono,
           STRING_AGG(DISTINCT m.nombre, ', ') as mascotas,
           STRING_AGG(DISTINCT s.nombre, ', ') as servicios
    FROM citas c
    LEFT JOIN estados_citas ec ON c.estado_id = ec.id
    LEFT JOIN users u ON c.user_id = u.id
    LEFT JOIN citas_mascotas cm ON c.id = cm.cita_id
    LEFT JOIN mascotas m ON cm.mascota_id = m.id
    LEFT JOIN citas_servicios cs ON c.id = cs.cita_id
    LEFT JOIN servicios s ON cs.servicio_id = s.id
    GROUP BY c.id, c.user_id, c.fecha_hora, c.estado_id, c.notas_cliente, 
             c.notas_veterinaria, c.created_at, c.updated_at,
             ec.nombre, u.nombre_completo, u.correo, u.celular
    ORDER BY c.fecha_hora DESC
  `;
  const res = await pool.query(q);
  return res.rows;
};

export const getNextAppointmentByUser = async (userId) => {
  const q = `
    SELECT c.id, c.user_id, c.fecha_hora, c.estado_id, c.notas_cliente
    FROM citas c
    WHERE c.user_id = $1 AND c.fecha_hora > now()
    ORDER BY c.fecha_hora ASC
    LIMIT 1
  `;
  const res = await pool.query(q, [userId]);
  return res.rows[0] || null;
};

export const getCalendarCountsByUser = async (userId, fromDate, toDate) => {
  const q = `
    SELECT CAST(c.fecha_hora AS DATE) AS fecha, COUNT(*) AS cantidad
    FROM citas c
    WHERE c.user_id = $1 AND c.fecha_hora::date BETWEEN $2 AND $3
    GROUP BY fecha
    ORDER BY fecha
  `;
  const res = await pool.query(q, [userId, fromDate, toDate]);
  return res.rows; // [{ fecha: '2025-01-01', cantidad: '3' }, ...]
};

export const createAppointment = async (userId, {
  fecha_hora,
  estado_id,
  notas_cliente,
  mascota_ids = [],
  servicio_ids = [],
}) => {
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    const insertCita = `
      INSERT INTO citas (user_id, fecha_hora, estado_id, notas_cliente)
      VALUES ($1, $2, $3, $4)
      RETURNING *
    `;
    const resCita = await client.query(insertCita, [
      userId,
      fecha_hora,
      estado_id || null,
      notas_cliente || null,
    ]);
    const cita = resCita.rows[0];

    for (const mascotaId of mascota_ids) {
      await client.query(
        `INSERT INTO citas_mascotas (cita_id, mascota_id) VALUES ($1, $2)`,
        [cita.id, mascotaId]
      );
    }

    for (const servicioId of servicio_ids) {
      await client.query(
        `INSERT INTO citas_servicios (cita_id, servicio_id) VALUES ($1, $2)`,
        [cita.id, servicioId]
      );
    }

    await client.query('COMMIT');
    return cita;
  } catch (err) {
    await client.query('ROLLBACK');
    throw err;
  } finally {
    client.release();
  }
};

export const updateAppointment = async (id, {
  fecha_hora,
  estado_id,
  notas_cliente,
  notas_veterinaria,
}) => {
  const q = `
    UPDATE citas
    SET fecha_hora = COALESCE($2, fecha_hora),
        estado_id = COALESCE($3, estado_id),
        notas_cliente = COALESCE($4, notas_cliente),
        notas_veterinaria = COALESCE($5, notas_veterinaria),
        updated_at = now()
    WHERE id = $1
    RETURNING *
  `;
  const res = await pool.query(q, [id, fecha_hora || null, estado_id || null, notas_cliente || null, notas_veterinaria || null]);
  return res.rows[0];
};

export const deleteAppointment = async (id) => {
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    await client.query(`DELETE FROM citas_mascotas WHERE cita_id = $1`, [id]);
    await client.query(`DELETE FROM citas_servicios WHERE cita_id = $1`, [id]);
    const res = await client.query(`DELETE FROM citas WHERE id = $1 RETURNING id`, [id]);
    await client.query('COMMIT');
    return res.rows[0] || null;
  } catch (err) {
    await client.query('ROLLBACK');
    throw err;
  } finally {
    client.release();
  }
};
