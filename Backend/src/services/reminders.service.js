import cron from 'node-cron';
import { pool } from '../config/database.js';
import { createNotification } from '../models/notifications.model.js';

/**
 * Servicio de recordatorios automáticos
 * Envía notificaciones 24 horas antes de las citas
 */

// Tarea que se ejecuta cada hora para verificar citas del día siguiente
const appointmentReminderJob = cron.schedule('0 * * * *', async () => {
  try {
    console.log('Ejecutando job de recordatorios de citas...');
    
    // Calcular rango de tiempo: 23 a 25 horas desde ahora
    const now = new Date();
    const startTime = new Date(now.getTime() + 23 * 60 * 60 * 1000);
    const endTime = new Date(now.getTime() + 25 * 60 * 60 * 1000);
    
    // Buscar citas en ese rango que estén confirmadas o pendientes
    const result = await pool.query(`
      SELECT 
        c.id,
        c.user_id,
        c.fecha_hora,
        u.nombre_completo,
        vc.veterinaria_id,
        v.nombre as veterinaria_nombre,
        array_agg(DISTINCT m.nombre) as mascotas
      FROM citas c
      JOIN users u ON c.user_id = u.id
      LEFT JOIN veterinarias_citas vc ON c.id = vc.cita_id
      LEFT JOIN veterinarias v ON vc.veterinaria_id = v.id
      LEFT JOIN citas_mascotas cm ON c.id = cm.cita_id
      LEFT JOIN mascotas m ON cm.mascota_id = m.id
      WHERE c.fecha_hora BETWEEN $1 AND $2
        AND c.estado_id IN (1, 2)
      GROUP BY c.id, c.user_id, c.fecha_hora, u.nombre_completo, vc.veterinaria_id, v.nombre
    `, [startTime, endTime]);
    
    console.log(`Encontradas ${result.rows.length} citas para recordar`);
    
    // Crear notificación para cada cita
    for (const cita of result.rows) {
      const fechaFormateada = new Date(cita.fecha_hora).toLocaleDateString('es-ES', {
        day: 'numeric',
        month: 'long',
        year: 'numeric',
        hour: '2-digit',
        minute: '2-digit'
      });
      
      const mascotas = cita.mascotas.filter(m => m !== null).join(', ') || 'mascota';
      
      // Notificar al dueño
      await createNotification({
        user_id: cita.user_id,
        titulo: "Recordatorio de cita",
        mensaje: `Recordatorio: Tienes una cita mañana a las ${fechaFormateada} en ${cita.veterinaria_nombre || 'la veterinaria'} para ${mascotas}.`,
        tipo: "warning",
        referencia_id: cita.id,
        referencia_tipo: "cita"
      });
      
      console.log(`Recordatorio enviado a dueño ${cita.user_id} para cita ${cita.id}`);
      
      // Notificar a usuarios de la veterinaria
      if (cita.veterinaria_id) {
        const vetUsers = await pool.query(
          `SELECT DISTINCT u.id 
           FROM users u 
           JOIN veterinaria_user vu ON u.id = vu.user_id 
           WHERE vu.veterinaria_id = $1 AND u.activo = true`,
          [cita.veterinaria_id]
        );
        
        for (const user of vetUsers.rows) {
          await createNotification({
            user_id: user.id,
            titulo: "Recordatorio de cita",
            mensaje: `Recordatorio: Cita mañana a las ${fechaFormateada} para ${mascotas}.`,
            tipo: "warning",
            referencia_id: cita.id,
            referencia_tipo: "cita"
          });
        }
        
        console.log(`Recordatorio enviado a ${vetUsers.rows.length} usuarios de veterinaria ${cita.veterinaria_id}`);
      }
    }
    
  } catch (error) {
    console.error('Error en job de recordatorios:', error);
  }
}, {
  scheduled: false // No se inicia automáticamente
});

/**
 * Inicia el servicio de recordatorios
 */
export const startReminderService = () => {
  console.log('Iniciando servicio de recordatorios de citas...');
  appointmentReminderJob.start();
};

/**
 * Detiene el servicio de recordatorios
 */
export const stopReminderService = () => {
  console.log('Deteniendo servicio de recordatorios...');
  appointmentReminderJob.stop();
};

export default { startReminderService, stopReminderService };
