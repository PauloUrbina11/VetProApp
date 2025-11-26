import { pool } from "../config/database.js";

export const listServiceTypes = async () => {
  const q = `SELECT id, nombre, descripcion FROM tipo_servicio ORDER BY nombre`;
  const res = await pool.query(q);
  return res.rows;
};

export const listServices = async ({ tipo_servicio_id, activo }) => {
  const filters = [];
  const values = [];
  if (tipo_servicio_id) { filters.push(`s.tipo_servicio_id = $${values.length + 1}`); values.push(tipo_servicio_id); }
  if (typeof activo === 'boolean') { filters.push(`s.activo = $${values.length + 1}`); values.push(activo); }
  const where = filters.length ? `WHERE ${filters.join(' AND ')}` : '';
  const q = `
    SELECT s.id, s.tipo_servicio_id, s.nombre, s.descripcion, s.activo,
           ts.nombre as tipo_nombre
    FROM servicios s
    LEFT JOIN tipo_servicio ts ON s.tipo_servicio_id = ts.id
    ${where}
    ORDER BY s.nombre
  `;
  const res = await pool.query(q, values);
  return res.rows;
};

export const createService = async ({ tipo_servicio_id, nombre, descripcion, activo }) => {
  const q = `
    INSERT INTO servicios (tipo_servicio_id, nombre, descripcion, activo)
    VALUES ($1, $2, $3, COALESCE($4, true))
    RETURNING *
  `;
  const res = await pool.query(q, [tipo_servicio_id, nombre, descripcion || null, activo ?? true]);
  return res.rows[0];
};

export const updateService = async (id, { tipo_servicio_id, nombre, descripcion, activo }) => {
  const q = `
    UPDATE servicios
    SET tipo_servicio_id = COALESCE($2, tipo_servicio_id),
        nombre = COALESCE($3, nombre),
        descripcion = COALESCE($4, descripcion),
        activo = COALESCE($5, activo),
        updated_at = now()
    WHERE id = $1
    RETURNING *
  `;
  const res = await pool.query(q, [id, tipo_servicio_id || null, nombre || null, descripcion || null, activo]);
  return res.rows[0];
};

export const deactivateService = async (id) => {
  const res = await pool.query(`UPDATE servicios SET activo = false, updated_at = now() WHERE id = $1 RETURNING *`, [id]);
  return res.rows[0];
};
