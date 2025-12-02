import { pool } from "../config/database.js";

export const createMedicalRecord = async ({
  mascota_id,
  veterinaria_id,
  cita_id,
  fecha,
  motivo,
  descripcion,
  diagnostico,
  tratamiento,
  receta_url,
}) => {
  const q = `
    INSERT INTO historia_clinica_mascota 
    (mascota_id, veterinaria_id, cita_id, fecha, motivo, descripcion, diagnostico, tratamiento, receta_url)
    VALUES ($1, $2, $3, $4::timestamp, $5, $6, $7, $8, $9)
    RETURNING *
  `;
  const res = await pool.query(q, [
    mascota_id,
    veterinaria_id,
    cita_id,
    fecha || new Date().toISOString(),
    motivo || null,
    descripcion,
    diagnostico || null,
    tratamiento || null,
    receta_url || null,
  ]);
  return res.rows[0];
};

export const getMedicalRecordsByPet = async (mascotaId) => {
  const q = `
    SELECT hc.*, v.nombre as veterinaria_nombre,
           c.fecha_hora as fecha_cita
    FROM historia_clinica_mascota hc
    LEFT JOIN veterinarias v ON hc.veterinaria_id = v.id
    LEFT JOIN citas c ON hc.cita_id = c.id
    WHERE hc.mascota_id = $1
    ORDER BY hc.fecha DESC
  `;
  const res = await pool.query(q, [mascotaId]);
  return res.rows;
};

export const getMedicalRecordByCita = async (citaId) => {
  const q = `
    SELECT hc.*, v.nombre as veterinaria_nombre,
           m.nombre as mascota_nombre
    FROM historia_clinica_mascota hc
    LEFT JOIN veterinarias v ON hc.veterinaria_id = v.id
    LEFT JOIN mascotas m ON hc.mascota_id = m.id
    WHERE hc.cita_id = $1
  `;
  const res = await pool.query(q, [citaId]);
  return res.rows[0] || null;
};

export const updateMedicalRecord = async (id, {
  motivo,
  descripcion,
  diagnostico,
  tratamiento,
  receta_url,
}) => {
  const q = `
    UPDATE historia_clinica_mascota
    SET motivo = COALESCE($2, motivo),
        descripcion = COALESCE($3, descripcion),
        diagnostico = COALESCE($4, diagnostico),
        tratamiento = COALESCE($5, tratamiento),
        receta_url = COALESCE($6, receta_url),
        updated_at = now()
    WHERE id = $1
    RETURNING *
  `;
  const res = await pool.query(q, [
    id,
    motivo,
    descripcion,
    diagnostico,
    tratamiento,
    receta_url,
  ]);
  return res.rows[0];
};

export const deleteMedicalRecord = async (id) => {
  const q = `DELETE FROM historia_clinica_mascota WHERE id = $1 RETURNING id`;
  const res = await pool.query(q, [id]);
  return res.rows[0] || null;
};
