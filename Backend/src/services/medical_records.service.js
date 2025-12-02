import * as medicalRecordsModel from "../models/medical_records.model.js";
import { createNotification } from "../models/notifications.model.js";
import { pool } from "../config/database.js";

export const createMedicalRecord = async (data) => {
  const record = await medicalRecordsModel.createMedicalRecord(data);
  
  // Obtener el dueño de la mascota para notificarle
  try {
    const result = await pool.query(
      'SELECT user_id FROM mascotas WHERE id = $1',
      [data.mascota_id]
    );
    
    if (result.rows.length > 0) {
      const ownerId = result.rows[0].user_id;
      await createNotification({
        user_id: ownerId,
        titulo: "Historial médico actualizado",
        mensaje: "Se ha agregado un nuevo registro al historial médico de tu mascota.",
        tipo: "info",
        referencia_id: record.id,
        referencia_tipo: "historial_medico"
      });
    }
  } catch (error) {
    console.error("Error al notificar historial médico:", error);
  }
  
  return record;
};

export const getMedicalRecordsByPet = async (mascotaId) => {
  return await medicalRecordsModel.getMedicalRecordsByPet(mascotaId);
};

export const getMedicalRecordByCita = async (citaId) => {
  return await medicalRecordsModel.getMedicalRecordByCita(citaId);
};

export const updateMedicalRecord = async (id, data) => {
  const record = await medicalRecordsModel.updateMedicalRecord(id, data);
  // No se notifica la actualización de historiales médicos
  return record;
};

export const deleteMedicalRecord = async (id) => {
  return await medicalRecordsModel.deleteMedicalRecord(id);
};
