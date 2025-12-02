import {
  listAppointmentsByUser,
  listAllAppointments,
  listAppointmentsByVeterinaria,
  getNextAppointmentByUser,
  getCalendarCountsByUser,
  createAppointment,
  updateAppointment,
  deleteAppointment,
} from "../models/appointments.model.js";
import { createNotification } from "../models/notifications.model.js";

export const listMyAppointments = async (userId) => {
  return await listAppointmentsByUser(userId);
};

export const getMyNextAppointment = async (userId) => {
  return await getNextAppointmentByUser(userId);
};

export const getMyCalendarCounts = async (userId, from, to) => {
  return await getCalendarCountsByUser(userId, from, to);
};

export const createMyAppointment = async (userId, data) => {
  const appointment = await createAppointment(userId, data);
  
  // Notificar a la veterinaria sobre la nueva cita
  try {
    // Obtener usuarios de la veterinaria para notificarles
    const { pool } = await import('../config/database.js');
    const result = await pool.query(
      `SELECT DISTINCT u.id 
       FROM users u 
       JOIN veterinaria_user vu ON u.id = vu.user_id 
       WHERE vu.veterinaria_id = $1 AND u.activo = true`,
      [data.veterinaria_id]
    );
    
    const fechaFormateada = new Date(data.fecha_hora || `${data.fecha}T${data.hora}`).toLocaleDateString('es-ES', {
      day: 'numeric',
      month: 'long',
      year: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
    });
    
    // Notificar a cada usuario de la veterinaria
    for (const user of result.rows) {
      await createNotification({
        user_id: user.id,
        titulo: "Nueva cita agendada",
        mensaje: `Se ha agendado una nueva cita para el ${fechaFormateada}.`,
        tipo: "info",
        referencia_id: appointment.id,
        referencia_tipo: "cita"
      });
    }
  } catch (error) {
    console.error("Error al crear notificación de cita:", error);
  }
  
  return appointment;
};

export const updateMyAppointment = async (id, data, userId) => {
  // Agregar el userId como update_user si viene
  if (userId) {
    data.update_user = userId;
  }
  const appointment = await updateAppointment(id, data);
  
  // Notificar sobre la actualización
  try {
    const { pool } = await import('../config/database.js');
    
    // Si se cambió el estado a confirmada - notificar al dueño
    if (data.estado_id === 2) {
      // Obtener el dueño de la cita
      const citaResult = await pool.query(
        'SELECT user_id FROM citas WHERE id = $1',
        [id]
      );
      
      if (citaResult.rows.length > 0) {
        await createNotification({
          user_id: citaResult.rows[0].user_id,
          titulo: "Cita confirmada",
          mensaje: "Tu cita ha sido confirmada.",
          tipo: "success",
          referencia_id: id,
          referencia_tipo: "cita"
        });
      }
    } 
    // Si se cambió el estado a cancelada - notificar a dueño Y veterinaria
    else if (data.estado_id === 4) {
      // Obtener dueño y veterinaria de la cita
      const citaResult = await pool.query(
        `SELECT c.user_id, vc.veterinaria_id 
         FROM citas c
         LEFT JOIN veterinarias_citas vc ON c.id = vc.cita_id
         WHERE c.id = $1`,
        [id]
      );
      
      if (citaResult.rows.length > 0) {
        const { user_id: duenoId, veterinaria_id: vetId } = citaResult.rows[0];
        
        // Notificar al dueño
        await createNotification({
          user_id: duenoId,
          titulo: "Cita cancelada",
          mensaje: "Tu cita ha sido cancelada.",
          tipo: "warning",
          referencia_id: id,
          referencia_tipo: "cita"
        });
        
        // Notificar a usuarios de la veterinaria
        if (vetId) {
          const vetUsers = await pool.query(
            `SELECT DISTINCT u.id 
             FROM users u 
             JOIN veterinaria_user vu ON u.id = vu.user_id 
             WHERE vu.veterinaria_id = $1 AND u.activo = true`,
            [vetId]
          );
          
          for (const user of vetUsers.rows) {
            await createNotification({
              user_id: user.id,
              titulo: "Cita cancelada",
              mensaje: "Una cita ha sido cancelada.",
              tipo: "warning",
              referencia_id: id,
              referencia_tipo: "cita"
            });
          }
        }
      }
    }
  } catch (error) {
    console.error("Error al crear notificación de actualización:", error);
  }
  
  return appointment;
};

export const removeMyAppointment = async (id) => {
  return await deleteAppointment(id);
};

export const getAllAppointments = async () => {
  return await listAllAppointments();
};

export const getAppointmentsByVeterinaria = async (veterinariaId) => {
  return await listAppointmentsByVeterinaria(veterinariaId);
};
