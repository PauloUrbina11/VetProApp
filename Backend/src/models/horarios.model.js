import { pool } from '../config/database.js';

// Obtener todos los horarios de una veterinaria
export const getHorariosByVeterinaria = async (veterinariaId) => {
    const query = `
        SELECT 
            id,
            veterinaria_id,
            dia_semana,
            hora_inicio,
            hora_fin,
            disponible,
            created_at,
            updated_at
        FROM horarios_veterinaria
        WHERE veterinaria_id = $1
        ORDER BY dia_semana, hora_inicio;
    `;
    
    const result = await pool.query(query, [veterinariaId]);
    return result.rows;
};

// Crear un horario para una veterinaria
export const createHorario = async (data) => {
    const { veterinaria_id, dia_semana, hora_inicio, hora_fin, disponible = true } = data;
    
    const query = `
        INSERT INTO horarios_veterinaria (veterinaria_id, dia_semana, hora_inicio, hora_fin, disponible)
        VALUES ($1, $2, $3, $4, $5)
        RETURNING *;
    `;
    
    const result = await pool.query(query, [
        veterinaria_id,
        dia_semana,
        hora_inicio,
        hora_fin,
        disponible
    ]);
    
    return result.rows[0];
};

// Actualizar un horario
export const updateHorario = async (id, data) => {
    const { dia_semana, hora_inicio, hora_fin, disponible } = data;
    
    const query = `
        UPDATE horarios_veterinaria
        SET 
            dia_semana = COALESCE($1, dia_semana),
            hora_inicio = COALESCE($2, hora_inicio),
            hora_fin = COALESCE($3, hora_fin),
            disponible = COALESCE($4, disponible),
            updated_at = NOW()
        WHERE id = $5
        RETURNING *;
    `;
    
    const result = await pool.query(query, [
        dia_semana,
        hora_inicio,
        hora_fin,
        disponible,
        id
    ]);
    
    return result.rows[0];
};

// Eliminar un horario
export const deleteHorario = async (id) => {
    const query = `
        DELETE FROM horarios_veterinaria
        WHERE id = $1
        RETURNING *;
    `;
    
    const result = await pool.query(query, [id]);
    return result.rows[0];
};

// Eliminar todos los horarios de una veterinaria
export const deleteAllHorariosByVeterinaria = async (veterinariaId) => {
    const query = `
        DELETE FROM horarios_veterinaria
        WHERE veterinaria_id = $1
        RETURNING *;
    `;
    
    const result = await pool.query(query, [veterinariaId]);
    return result.rows;
};

// Obtener citas de una veterinaria en una fecha específica
export const getCitasByVeterinariaAndDate = async (veterinariaId, fecha) => {
    const query = `
        SELECT 
            c.id,
            c.fecha_hora,
            c.user_id
        FROM citas c
        INNER JOIN veterinarias_citas vc ON c.id = vc.cita_id
        WHERE vc.veterinaria_id = $1
        AND DATE(c.fecha_hora) = $2
        AND c.estado_id != 4
        ORDER BY c.fecha_hora;
    `;
    
    const result = await pool.query(query, [veterinariaId, fecha]);
    return result.rows;
};
