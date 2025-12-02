import cron from 'node-cron';
import { pool } from '../config/database.js';
import { createNotification } from '../models/notifications.model.js';

/**
 * Servicio de recordatorio de cambio de contraseña
 * Notifica a usuarios que tienen más de 6 meses sin cambiar su contraseña
 */

// Tarea que se ejecuta diariamente a las 9:00 AM
const passwordReminderJob = cron.schedule('0 9 * * *', async () => {
  try {
    console.log('Ejecutando job de recordatorio de cambio de contraseña...');
    
    // Calcular fecha de hace 6 meses
    const sixMonthsAgo = new Date();
    sixMonthsAgo.setMonth(sixMonthsAgo.getMonth() - 6);
    
    // Buscar usuarios con contraseña antigua (rol 2: veterinaria, rol 3: clientes)
    // Excluimos admins (rol 1) del recordatorio
    const result = await pool.query(`
      SELECT DISTINCT u.id, u.nombre_completo, u.ultimo_cambio_contrasena, r.id as rol_id
      FROM users u
      JOIN rol_user ru ON u.id = ru.user_id
      JOIN roles r ON ru.rol_id = r.id
      WHERE u.activo = true
        AND ru.rol_id IN (2, 3)
        AND (u.ultimo_cambio_contrasena IS NULL OR u.ultimo_cambio_contrasena < $1)
    `, [sixMonthsAgo]);
    
    console.log(`Encontrados ${result.rows.length} usuarios con contraseña antigua`);
    
    // Crear notificación para cada usuario
    for (const user of result.rows) {
      // Verificar si ya tiene una notificación de cambio de contraseña sin leer
      const existingNotification = await pool.query(`
        SELECT id FROM notificaciones
        WHERE user_id = $1 
          AND titulo = 'Recordatorio: Cambia tu contraseña'
          AND leida = false
          AND created_at > NOW() - INTERVAL '7 days'
      `, [user.id]);
      
      // Si ya tiene una notificación reciente sin leer, no enviar otra
      if (existingNotification.rows.length > 0) {
        console.log(`Usuario ${user.id} ya tiene recordatorio pendiente, omitiendo...`);
        continue;
      }
      
      const mesesSinCambio = user.ultimo_cambio_contrasena 
        ? Math.floor((new Date() - new Date(user.ultimo_cambio_contrasena)) / (1000 * 60 * 60 * 24 * 30))
        : 'más de 6';
      
      await createNotification({
        user_id: user.id,
        titulo: "Recordatorio: Cambia tu contraseña",
        mensaje: `Por tu seguridad, te recomendamos cambiar tu contraseña. Han pasado ${mesesSinCambio} meses desde tu último cambio.`,
        tipo: "warning",
        referencia_id: null,
        referencia_tipo: "seguridad"
      });
      
      console.log(`Recordatorio de contraseña enviado a usuario ${user.id} (${user.nombre_completo})`);
    }
    
    console.log('Job de recordatorio de contraseña completado');
  } catch (error) {
    console.error('Error en job de recordatorio de contraseña:', error);
  }
}, {
  scheduled: false
});

/**
 * Inicia el servicio de recordatorios de contraseña
 */
export const startPasswordReminderService = () => {
  console.log('Iniciando servicio de recordatorio de cambio de contraseña...');
  passwordReminderJob.start();
};

/**
 * Detiene el servicio de recordatorios de contraseña
 */
export const stopPasswordReminderService = () => {
  console.log('Deteniendo servicio de recordatorio de contraseña...');
  passwordReminderJob.stop();
};

export default { startPasswordReminderService, stopPasswordReminderService };
