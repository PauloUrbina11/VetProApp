import { pool } from "../config/database.js";

export const getEspecies = async () => {
  const q = `SELECT id, nombre, descripcion FROM especies ORDER BY id`;
  const res = await pool.query(q);
  return res.rows;
};

export const getRazasByEspecie = async (especieId) => {
  const q = `SELECT id, nombre, descripcion FROM razas WHERE especie_id = $1 ORDER BY nombre`;
  const res = await pool.query(q, [especieId]);
  return res.rows;
};

export const getMascotasByUserId = async (userId) => {
  const q = `
    SELECT 
      m.id, m.nombre, m.especie_id, m.raza_id, m.foto_principal, m.fecha_nacimiento, 
      m.sexo, m.color, m.peso_kg,
      e.nombre as especie_nombre, r.nombre as raza_nombre
    FROM mascotas m
    JOIN mascotas_users mu ON mu.mascota_id = m.id
    LEFT JOIN especies e ON e.id = m.especie_id
    LEFT JOIN razas r ON r.id = m.raza_id
    WHERE mu.user_id = $1
    ORDER BY m.id
  `;
  const res = await pool.query(q, [userId]);
  return res.rows;
};

export const createMascota = async (data, ownerUserId) => {
  const {
    nombre,
    especie_id,
    raza_id,
    fecha_nacimiento,
    sexo,
    color,
    peso_kg,
    foto_principal,
  } = data;

  const insertMascota = `
    INSERT INTO mascotas (nombre, especie_id, raza_id, fecha_nacimiento, sexo, color, peso_kg, foto_principal)
    VALUES ($1,$2,$3,$4,$5,$6,$7,$8)
    RETURNING *
  `;
  const resPet = await pool.query(insertMascota, [
    nombre,
    especie_id,
    raza_id,
    fecha_nacimiento || null,
    sexo || null,
    color || null,
    peso_kg || null,
    foto_principal || null,
  ]);

  const pet = resPet.rows[0];
  const linkOwner = `
    INSERT INTO mascotas_users (mascota_id, user_id)
    VALUES ($1, $2)
    RETURNING id
  `;
  await pool.query(linkOwner, [pet.id, ownerUserId]);
  return pet;
};

export const getMascotaById = async (id) => {
  const q = `
    SELECT 
      m.*,
      e.nombre as especie_nombre, r.nombre as raza_nombre
    FROM mascotas m
    LEFT JOIN especies e ON e.id = m.especie_id
    LEFT JOIN razas r ON r.id = m.raza_id
    WHERE m.id = $1 
    LIMIT 1
  `;
  const res = await pool.query(q, [id]);
  return res.rows[0];
};

export const getAllMascotas = async () => {
  const q = `
    SELECT 
      m.id, m.nombre, m.especie_id, m.raza_id, m.foto_principal, m.fecha_nacimiento, 
      m.sexo, m.color, m.peso_kg, m.created_at,
      u.id as owner_id, u.nombre_completo as owner_name, u.correo as owner_email,
      e.nombre as especie_nombre, r.nombre as raza_nombre
    FROM mascotas m
    LEFT JOIN mascotas_users mu ON mu.mascota_id = m.id
    LEFT JOIN users u ON u.id = mu.user_id
    LEFT JOIN especies e ON e.id = m.especie_id
    LEFT JOIN razas r ON r.id = m.raza_id
    ORDER BY m.id DESC
  `;
  const res = await pool.query(q);
  return res.rows;
};

export const checkMascotaHasHistorial = async (mascotaId) => {
  const q = `
    SELECT COUNT(*) as count 
    FROM historia_clinica_mascota 
    WHERE mascota_id = $1
  `;
  const res = await pool.query(q, [mascotaId]);
  return parseInt(res.rows[0].count) > 0;
};

export const deleteMascota = async (id) => {
  // Primero eliminar la relación mascotas_users
  await pool.query(`DELETE FROM mascotas_users WHERE mascota_id = $1`, [id]);
  // Luego eliminar la mascota
  const q = `DELETE FROM mascotas WHERE id = $1 RETURNING *`;
  const res = await pool.query(q, [id]);
  return res.rows[0];
};

export const updateMascota = async (id, data) => {
  // Solo permitir actualizar: fecha_nacimiento, color, peso_kg, foto_principal
  const { fecha_nacimiento, color, peso_kg, foto_principal } = data;
  
  const q = `
    UPDATE mascotas 
    SET 
      fecha_nacimiento = COALESCE($1, fecha_nacimiento),
      color = COALESCE($2, color),
      peso_kg = COALESCE($3, peso_kg),
      foto_principal = COALESCE($4, foto_principal)
    WHERE id = $5
    RETURNING *
  `;
  
  const res = await pool.query(q, [
    fecha_nacimiento || null,
    color || null,
    peso_kg || null,
    foto_principal || null,
    id
  ]);
  
  return res.rows[0];
};

