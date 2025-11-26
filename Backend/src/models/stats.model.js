import { pool } from "../config/database.js";

/**
 * Obtener estadísticas globales del sistema
 */
async function getGlobalStats() {
  const client = await pool.connect();
  try {
    // Total de usuarios
    const usersResult = await client.query(
      "SELECT COUNT(*) as total FROM users"
    );
    
    // Total de veterinarias
    const veterinariasResult = await client.query(
      "SELECT COUNT(*) as total FROM veterinarias"
    );
    
    // Total de mascotas
    const mascotasResult = await client.query(
      "SELECT COUNT(*) as total FROM mascotas"
    );
    
    // Citas de hoy
    const citasHoyResult = await client.query(
      `SELECT COUNT(*) as total 
       FROM citas 
       WHERE DATE(fecha_hora) = CURRENT_DATE`
    );
    
    // Citas cumplidas (estado_id = 3, asumiendo que 3 es "completada")
    const citasCumplidasResult = await client.query(
      `SELECT COUNT(*) as total 
       FROM citas 
       WHERE estado_id = 3`
    );
    
    // Citas pendientes (estado_id = 1, asumiendo que 1 es "pendiente")
    const citasPendientesResult = await client.query(
      `SELECT COUNT(*) as total 
       FROM citas 
       WHERE estado_id = 1 AND fecha_hora >= NOW()`
    );

    return {
      totalUsuarios: parseInt(usersResult.rows[0].total),
      totalVeterinarias: parseInt(veterinariasResult.rows[0].total),
      totalMascotas: parseInt(mascotasResult.rows[0].total),
      citasHoy: parseInt(citasHoyResult.rows[0].total),
      citasCumplidas: parseInt(citasCumplidasResult.rows[0].total),
      citasPendientes: parseInt(citasPendientesResult.rows[0].total)
    };
  } finally {
    client.release();
  }
}

/**
 * Obtener estadísticas de citas por usuario
 */
async function getUserAppointmentStats(userId) {
  const client = await pool.connect();
  try {
    // Citas cumplidas del usuario
    const cumplidasResult = await client.query(
      `SELECT COUNT(*) as total 
       FROM citas 
       WHERE user_id = $1 AND estado_id = 3`,
      [userId]
    );
    
    // Citas pendientes del usuario
    const pendientesResult = await client.query(
      `SELECT COUNT(*) as total 
       FROM citas 
       WHERE user_id = $1 AND estado_id = 1 AND fecha_hora >= NOW()`,
      [userId]
    );

    return {
      citasCumplidas: parseInt(cumplidasResult.rows[0].total),
      citasPendientes: parseInt(pendientesResult.rows[0].total)
    };
  } finally {
    client.release();
  }
}

/**
 * Obtener actividad reciente del sistema (últimos 10 eventos)
 */
async function getRecentActivity() {
  const client = await pool.connect();
  try {
    const activities = [];
    
    // Últimos usuarios registrados (últimos 3)
    const usersResult = await client.query(
      `SELECT u.id, u.nombre_completo, u.correo, u.created_at, ru.rol_id
       FROM users u
       LEFT JOIN rol_user ru ON u.id = ru.user_id
       ORDER BY u.created_at DESC
       LIMIT 3`
    );
    
    for (const user of usersResult.rows) {
      let rolNombre = 'usuario';
      if (user.rol_id === 1) rolNombre = 'administrador';
      else if (user.rol_id === 2) rolNombre = 'veterinaria'
      else if (user.rol_id === 3) rolNombre = 'dueño de mascota';
      
      activities.push({
        type: 'user_registered',
        title: 'Nuevo usuario registrado',
        description: `${user.nombre_completo} se registró como ${rolNombre}`,
        time: user.created_at,
        icon: 'person_add',
        color: 'blue'
      });
    }
    
    // Últimas veterinarias creadas (últimas 2)
    const veterinariasResult = await client.query(
      `SELECT id, nombre, created_at
       FROM veterinarias
       ORDER BY created_at DESC
       LIMIT 2`
    );
    
    for (const vet of veterinariasResult.rows) {
      activities.push({
        type: 'veterinaria_created',
        title: 'Nueva veterinaria registrada',
        description: vet.nombre,
        time: vet.created_at,
        icon: 'add_business',
        color: 'green'
      });
    }
    
    // Últimas citas creadas (últimas 5)
    const citasResult = await client.query(
      `SELECT c.id, c.created_at, u.nombre_completo, m.nombre as mascota_nombre
       FROM citas c
       LEFT JOIN users u ON c.user_id = u.id
       LEFT JOIN citas_mascotas cm ON c.id = cm.cita_id
       LEFT JOIN mascotas m ON cm.mascota_id = m.id
       ORDER BY c.created_at DESC
       LIMIT 5`
    );
    
    for (const cita of citasResult.rows) {
      const mascotaNombre = cita.mascota_nombre || 'mascota';
      const usuarioNombre = cita.nombre_completo || 'Usuario';
      activities.push({
        type: 'appointment_created',
        title: 'Cita agendada',
        description: `${mascotaNombre} - ${usuarioNombre}`,
        time: cita.created_at,
        icon: 'event_available',
        color: 'orange'
      });
    }
    
    // Ordenar todas las actividades por fecha (más reciente primero)
    activities.sort((a, b) => new Date(b.time) - new Date(a.time));
    
    // Devolver solo las 10 más recientes
    return activities.slice(0, 10);
  } finally {
    client.release();
  }
}

export { getGlobalStats, getUserAppointmentStats, getRecentActivity };
