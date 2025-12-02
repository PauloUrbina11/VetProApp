import { listRecommendations, createRecommendation } from "../models/recommendations.model.js";
import { createNotification } from "../models/notifications.model.js";
import { pool } from "../config/database.js";

export const getRecommendations = async (filters) => listRecommendations(filters);

export const addRecommendation = async (data) => {
  const recommendation = await createRecommendation(data);
  
  // Notificar a dueños de mascotas de la especie correspondiente
  try {
    // Obtener dueños de mascotas de la especie
    const result = await pool.query(`
      SELECT DISTINCT m.user_id, u.nombre_completo
      FROM mascotas m
      JOIN users u ON m.user_id = u.id
      WHERE m.especie_id = $1 AND u.activo = true
    `, [data.especie_id]);
    
    console.log(`Enviando notificación de recomendación a ${result.rows.length} dueños de mascotas`);
    
    // Notificar a cada dueño
    for (const owner of result.rows) {
      await createNotification({
        user_id: owner.user_id,
        titulo: "Nueva recomendación para tu mascota",
        mensaje: `${data.titulo}: ${data.descripcion.substring(0, 100)}${data.descripcion.length > 100 ? '...' : ''}`,
        tipo: "info",
        referencia_id: recommendation.id,
        referencia_tipo: "recomendacion"
      });
    }
    
    console.log(`Notificaciones de recomendación enviadas exitosamente`);
  } catch (error) {
    console.error("Error al notificar nueva recomendación:", error);
  }
  
  return recommendation;
};
