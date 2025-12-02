import { pool } from "../config/database.js";

export const listVeterinarias = async ({ ciudad_id }) => {
  const filters = [];
  const values = [];
  if (ciudad_id) { filters.push(`v.ciudad_id = $${values.length + 1}`); values.push(ciudad_id); }
  const where = filters.length ? `WHERE ${filters.join(' AND ')}` : '';
  const q = `
    SELECT 
      v.id, 
      v.nombre, 
      v.direccion, 
      v.telefono, 
      v.ciudad_id, 
      v.latitud, 
      v.longitud, 
      v.logo_url, 
      v.descripcion,
      c.nombre AS ciudad
    FROM veterinarias v
    LEFT JOIN ciudades c ON v.ciudad_id = c.id
    ${where}
    ORDER BY v.nombre
  `;
  const res = await pool.query(q, values);
  return res.rows;
};

export const getVeterinariaById = async (id) => {
  const q = `
    SELECT 
      v.*, 
      c.nombre AS ciudad
    FROM veterinarias v
    LEFT JOIN ciudades c ON v.ciudad_id = c.id
    WHERE v.id = $1
  `;
  const res = await pool.query(q, [id]);
  return res.rows[0];
};

export const createVeterinaria = async (data) => {
  const {
    nombre,
    direccion,
    telefono,
    ciudad_id,
    latitud,
    longitud,
    user_admin_id,
    logo_url,
    descripcion,
  } = data;
  
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    
    // Crear veterinaria
    const q = `
      INSERT INTO veterinarias (nombre, direccion, telefono, ciudad_id, latitud, longitud, user_admin_id, logo_url, descripcion)
      VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9)
      RETURNING *
    `;
    const res = await client.query(q, [
      nombre,
      direccion || null,
      telefono || null,
      ciudad_id || null,
      latitud || null,
      longitud || null,
      user_admin_id || null,
      logo_url || null,
      descripcion || null,
    ]);
    
    const veterinaria = res.rows[0];
    
    // Si hay user_admin_id, crear registro en veterinaria_user con rol administrador (1)
    if (user_admin_id) {
      const insertUserRole = `
        INSERT INTO veterinaria_user (veterinaria_id, user_id, veterinaria_rol_id)
        VALUES ($1, $2, $3)
        ON CONFLICT (veterinaria_id, user_id) DO NOTHING
      `;
      await client.query(insertUserRole, [veterinaria.id, user_admin_id, 1]);
    }
    
    await client.query('COMMIT');
    return veterinaria;
  } catch (error) {
    await client.query('ROLLBACK');
    throw error;
  } finally {
    client.release();
  }
};

export const updateVeterinaria = async (id, data) => {
  const {
    nombre,
    direccion,
    telefono,
    ciudad_id,
    latitud,
    longitud,
    logo_url,
    descripcion,
  } = data;
  const q = `
    UPDATE veterinarias
    SET nombre = COALESCE($2, nombre),
        direccion = COALESCE($3, direccion),
        telefono = COALESCE($4, telefono),
        ciudad_id = COALESCE($5, ciudad_id),
        latitud = COALESCE($6, latitud),
        longitud = COALESCE($7, longitud),
        logo_url = COALESCE($8, logo_url),
        descripcion = COALESCE($9, descripcion),
        updated_at = now()
    WHERE id = $1
    RETURNING *
  `;
  const res = await pool.query(q, [
    id, nombre || null, direccion || null, telefono || null,
    ciudad_id || null, latitud || null, longitud || null,
    logo_url || null, descripcion || null,
  ]);
  return res.rows[0];
};
