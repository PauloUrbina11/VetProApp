import { pool } from "../config/database.js";

export const listRecommendations = async ({ especie_id, veterinaria_id }) => {
  const filters = [];
  const values = [];
  if (especie_id) { filters.push(`especie_id = $${values.length + 1}`); values.push(especie_id); }
  if (veterinaria_id) { filters.push(`veterinaria_id = $${values.length + 1}`); values.push(veterinaria_id); }
  const where = filters.length ? `WHERE ${filters.join(' AND ')}` : '';
  const q = `
    SELECT id, titulo, descripcion, especie_id, veterinaria_id, imagen_url
    FROM recomendaciones
    ${where}
    ORDER BY id DESC
  `;
  const res = await pool.query(q, values);
  return res.rows;
};
