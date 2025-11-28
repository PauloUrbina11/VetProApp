import { pool } from '../config/database.js';

// Obtener todos los servicios de una veterinaria
export const getServiciosByVeterinaria = async (veterinariaId) => {
    const query = `
        SELECT 
            vs.id,
            vs.veterinaria_id,
            vs.servicio_id,
            vs.precio,
            vs.activo,
            vs.created_at,
            vs.updated_at,
            s.nombre AS servicio_nombre,
            s.descripcion AS servicio_descripcion,
            s.tipo_servicio_id,
            ts.nombre AS tipo_servicio_nombre
        FROM veterinarias_servicios vs
        INNER JOIN servicios s ON vs.servicio_id = s.id
        INNER JOIN tipo_servicio ts ON s.tipo_servicio_id = ts.id
        WHERE vs.veterinaria_id = $1
        ORDER BY ts.nombre, s.nombre;
    `;
    
    const result = await pool.query(query, [veterinariaId]);
    return result.rows;
};

// Obtener servicios activos de una veterinaria
export const getServiciosActivosByVeterinaria = async (veterinariaId) => {
    const query = `
        SELECT 
            vs.id,
            vs.veterinaria_id,
            vs.servicio_id,
            vs.precio,
            vs.activo,
            s.nombre AS servicio_nombre,
            s.descripcion AS servicio_descripcion,
            s.tipo_servicio_id,
            ts.nombre AS tipo_servicio_nombre
        FROM veterinarias_servicios vs
        INNER JOIN servicios s ON vs.servicio_id = s.id
        INNER JOIN tipo_servicio ts ON s.tipo_servicio_id = ts.id
        WHERE vs.veterinaria_id = $1 AND vs.activo = true
        ORDER BY ts.nombre, s.nombre;
    `;
    
    const result = await pool.query(query, [veterinariaId]);
    return result.rows;
};

// Agregar un servicio a una veterinaria
export const addServicioToVeterinaria = async (data) => {
    const { veterinaria_id, servicio_id, precio, activo = true } = data;
    
    const query = `
        INSERT INTO veterinarias_servicios (veterinaria_id, servicio_id, precio, activo)
        VALUES ($1, $2, $3, $4)
        ON CONFLICT (veterinaria_id, servicio_id) 
        DO UPDATE SET precio = $3, activo = $4, updated_at = NOW()
        RETURNING *;
    `;
    
    const result = await pool.query(query, [
        veterinaria_id,
        servicio_id,
        precio || null,
        activo
    ]);
    
    return result.rows[0];
};

// Actualizar un servicio de veterinaria
export const updateServicioVeterinaria = async (id, data) => {
    const { precio, activo } = data;
    
    const query = `
        UPDATE veterinarias_servicios
        SET 
            precio = COALESCE($2, precio),
            activo = COALESCE($3, activo),
            updated_at = NOW()
        WHERE id = $1
        RETURNING *;
    `;
    
    const result = await pool.query(query, [
        id,
        precio !== undefined ? precio : null,
        activo
    ]);
    
    return result.rows[0];
};

// Eliminar (desactivar) un servicio de veterinaria
export const deleteServicioVeterinaria = async (id) => {
    const query = `
        UPDATE veterinarias_servicios
        SET activo = false, updated_at = NOW()
        WHERE id = $1
        RETURNING *;
    `;
    
    const result = await pool.query(query, [id]);
    return result.rows[0];
};

// Eliminar permanentemente un servicio de veterinaria
export const removeServicioVeterinaria = async (veterinariaId, servicioId) => {
    const query = `
        DELETE FROM veterinarias_servicios
        WHERE veterinaria_id = $1 AND servicio_id = $2
        RETURNING *;
    `;
    
    const result = await pool.query(query, [veterinariaId, servicioId]);
    return result.rows[0];
};
