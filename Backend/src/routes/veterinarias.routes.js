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
} from "../controllers/veterinaria_dashboard.controller.js";

const router = Router();

// IMPORTANTE: rutas específicas primero, genéricas después
router.get("/by-user", authMiddleware, getMyVeterinariasController);
router.get("/", getVeterinariasController);
router.get("/:id", getVeterinariaController);
router.post("/", authMiddleware, postVeterinariaController);
router.put("/:id", authMiddleware, putVeterinariaController);
router.get("/:id/dashboard", authMiddleware, getVeterinariaDashboardController);
router.get("/:id/calendar", authMiddleware, getVeterinariaCalendarController);

export default router;
