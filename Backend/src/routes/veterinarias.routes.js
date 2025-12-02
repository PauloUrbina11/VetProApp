import { Router } from "express";
import { authMiddleware } from "../middlewares/auth.middleware.js";
import {
  getVeterinariasController,
  getVeterinariaController,
  postVeterinariaController,
  putVeterinariaController,
} from "../controllers/veterinarias.controller.js";
import {
  getMyVeterinariasController,
  getVeterinariaDashboardController,
  getVeterinariaCalendarController,
  getVeterinariaPatientsController,
  getVeterinariaStatsController,
  getPatientHistoryController,
} from "../controllers/veterinaria_dashboard.controller.js";

const router = Router();

// IMPORTANTE: rutas específicas primero, genéricas después
router.get("/by-user", authMiddleware, getMyVeterinariasController);
router.get("/:id/my-roles", authMiddleware, async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user?.id;
    if (!userId) {
      return res.status(401).json({ ok: false, error: "No autenticado" });
    }
    const { getVeterinariaUserRole } = await import("../models/veterinaria_roles.model.js");
    const roles = await getVeterinariaUserRole(Number(id), userId);
    res.json({ ok: true, data: roles });
  } catch (err) {
    res.status(500).json({ ok: false, error: err.message });
  }
});
router.get("/", getVeterinariasController);
router.get("/:id", getVeterinariaController);
router.post("/", authMiddleware, postVeterinariaController);
router.put("/:id", authMiddleware, putVeterinariaController);
router.get("/:id/dashboard", authMiddleware, getVeterinariaDashboardController);
router.get("/:id/calendar", authMiddleware, getVeterinariaCalendarController);
router.get("/:id/patients", authMiddleware, getVeterinariaPatientsController);
router.get("/:id/patients/:petId/history", authMiddleware, getPatientHistoryController);
router.get("/:id/stats", authMiddleware, getVeterinariaStatsController);

export default router;
