import * as statsModel from "../models/stats.model.js";

/**
 * Obtener estadísticas globales (solo admin)
 */
async function getGlobalStatsController(req, res) {
  try {
    const stats = await statsModel.getGlobalStats();
    return res.status(200).json({
      ok: true,
      data: stats
    });
  } catch (error) {
    console.error("Error getGlobalStats:", error);
    return res.status(500).json({
      ok: false,
      error: "Error al obtener estadísticas globales"
    });
  }
}

/**
 * Obtener estadísticas de citas del usuario autenticado
 */
async function getUserStatsController(req, res) {
  try {
    const userId = req.user.id; // Del token JWT
    const stats = await statsModel.getUserAppointmentStats(userId);
    return res.status(200).json({
      ok: true,
      data: stats
    });
  } catch (error) {
    console.error("Error getUserStats:", error);
    return res.status(500).json({
      ok: false,
      error: "Error al obtener estadísticas del usuario"
    });
  }
}

/**
 * Obtener actividad reciente del sistema (solo admin)
 */
async function getRecentActivityController(req, res) {
  try {
    const activities = await statsModel.getRecentActivity();
    return res.status(200).json({
      ok: true,
      data: activities
    });
  } catch (error) {
    console.error("Error getRecentActivity:", error);
    return res.status(500).json({
      ok: false,
      error: "Error al obtener actividad reciente"
    });
  }
}

export { getGlobalStatsController, getUserStatsController, getRecentActivityController };
