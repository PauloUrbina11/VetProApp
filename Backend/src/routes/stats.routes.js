import express from "express";
import * as statsController from "../controllers/stats.controller.js";
import { authMiddleware } from "../middlewares/auth.middleware.js";
import { requireRole } from "../middlewares/role.middleware.js";

const router = express.Router();

/**
 * GET /api/stats/global
 * Obtener estadísticas globales del sistema (solo admin)
 */
router.get(
  "/global",
  authMiddleware,
  requireRole([1]), // Solo admin
  statsController.getGlobalStatsController
);

/**
 * GET /api/stats/user
 * Obtener estadísticas del usuario autenticado
 */
router.get(
  "/user",
  authMiddleware,
  statsController.getUserStatsController
);

/**
 * GET /api/stats/recent-activity
 * Obtener actividad reciente del sistema (solo admin)
 */
router.get(
  "/recent-activity",
  authMiddleware,
  requireRole([1]), // Solo admin
  statsController.getRecentActivityController
);

export default router;
