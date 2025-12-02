import * as medicalRecordsService from "../services/medical_records.service.js";

export const createMedicalRecordController = async (req, res) => {
  try {
    const data = req.body;
    const record = await medicalRecordsService.createMedicalRecord(data);
    return res.status(201).json({ ok: true, data: record });
  } catch (error) {
    return res.status(400).json({ ok: false, message: error.message });
  }
};

export const getMedicalRecordsByPetController = async (req, res) => {
  try {
    const { mascotaId } = req.params;
    const records = await medicalRecordsService.getMedicalRecordsByPet(mascotaId);
    return res.json({ ok: true, data: records });
  } catch (error) {
    return res.status(400).json({ ok: false, message: error.message });
  }
};

export const getMedicalRecordByCitaController = async (req, res) => {
  try {
    const { citaId } = req.params;
    const record = await medicalRecordsService.getMedicalRecordByCita(citaId);
    return res.json({ ok: true, data: record });
  } catch (error) {
    return res.status(400).json({ ok: false, message: error.message });
  }
};

export const updateMedicalRecordController = async (req, res) => {
  try {
    const { id } = req.params;
    const data = req.body;
    const record = await medicalRecordsService.updateMedicalRecord(id, data);
    return res.json({ ok: true, data: record });
  } catch (error) {
    return res.status(400).json({ ok: false, message: error.message });
  }
};

export const deleteMedicalRecordController = async (req, res) => {
  try {
    const { id } = req.params;
    await medicalRecordsService.deleteMedicalRecord(id);
    return res.json({ ok: true, message: "Registro eliminado exitosamente" });
  } catch (error) {
    return res.status(400).json({ ok: false, message: error.message });
  }
};
