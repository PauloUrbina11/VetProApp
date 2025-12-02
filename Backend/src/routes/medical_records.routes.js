import { Router } from "express";
import * as medicalRecordsController from "../controllers/medical_records.controller.js";
import { authMiddleware } from "../middlewares/auth.middleware.js";

const router = Router();

// Crear historia clínica
router.post("/", authMiddleware, medicalRecordsController.createMedicalRecordController);

// Obtener historias clínicas por mascota
router.get("/pet/:mascotaId", authMiddleware, medicalRecordsController.getMedicalRecordsByPetController);

// Obtener historia clínica por cita
router.get("/appointment/:citaId", authMiddleware, medicalRecordsController.getMedicalRecordByCitaController);

// Actualizar historia clínica
router.put("/:id", authMiddleware, medicalRecordsController.updateMedicalRecordController);

// Eliminar historia clínica
router.delete("/:id", authMiddleware, medicalRecordsController.deleteMedicalRecordController);

export default router;
