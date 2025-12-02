import { authMiddleware } from "../middlewares/auth.middleware.js"; // not used directly here
import {
  listMyVeterinarias,
  getDashboardData,
  getCalendarData,
} from "../services/veterinaria_dashboard.service.js";

export const getMyVeterinariasController = async (req, res) => {
  try {
    const userId = req.user?.id;
    if (!userId) return res.status(401).json({ ok: false, error: "Unauthorized" });
    const list = await listMyVeterinarias(userId);
    res.json({ ok: true, data: list });
  } catch (err) {
    res.status(500).json({ ok: false, error: err.message });
  }
};

export const getVeterinariaDashboardController = async (req, res) => {
  try {
    const userId = req.user?.id;
    if (!userId) return res.status(401).json({ ok: false, error: "Unauthorized" });
    const { id } = req.params;
    const veterinariaId = Number(id);
    if (!veterinariaId) return res.status(400).json({ ok: false, error: "Invalid veterinaria id" });
    const data = await getDashboardData(veterinariaId, userId);
    res.json({ ok: true, data });
  } catch (err) {
    res.status(500).json({ ok: false, error: err.message });
  }
};

export const getVeterinariaCalendarController = async (req, res) => {
  try {
    const userId = req.user?.id;
    if (!userId) return res.status(401).json({ ok: false, error: "Unauthorized" });
    const { id } = req.params;
    const { from, to } = req.query;
    if (!from || !to) return res.status(400).json({ ok: false, error: "Missing from/to" });
    const veterinariaId = Number(id);
    const counts = await getCalendarData(veterinariaId, from, to);
    res.json({ ok: true, data: counts });
  } catch (err) {
    res.status(500).json({ ok: false, error: err.message });
  }
};

export const getVeterinariaPatientsController = async (req, res) => {
  try {
    const userId = req.user?.id;
    if (!userId) return res.status(401).json({ ok: false, error: "Unauthorized" });
    const { id } = req.params;
    const veterinariaId = Number(id);
    if (!veterinariaId) return res.status(400).json({ ok: false, error: "Invalid veterinaria id" });
    
    const { getPatients } = await import('../services/veterinaria_dashboard.service.js');
    const patients = await getPatients(veterinariaId);
    res.json({ ok: true, data: patients });
  } catch (err) {
    res.status(500).json({ ok: false, error: err.message });
  }
};

export const getVeterinariaStatsController = async (req, res) => {
  try {
    const userId = req.user?.id;
    if (!userId) return res.status(401).json({ ok: false, error: "Unauthorized" });
    const { id } = req.params;
    const veterinariaId = Number(id);
    if (!veterinariaId) return res.status(400).json({ ok: false, error: "Invalid veterinaria id" });
    
    const { getStats } = await import('../services/veterinaria_dashboard.service.js');
    const stats = await getStats(veterinariaId);
    res.json({ ok: true, data: stats });
  } catch (err) {
    res.status(500).json({ ok: false, error: err.message });
  }
};

export const getPatientHistoryController = async (req, res) => {
  try {
    const userId = req.user?.id;
    if (!userId) return res.status(401).json({ ok: false, error: "Unauthorized" });
    const { id, petId } = req.params;
    const veterinariaId = Number(id);
    const mascotaId = Number(petId);
    if (!veterinariaId || !mascotaId) {
      return res.status(400).json({ ok: false, error: "Invalid parameters" });
    }
    
    const { getPatientHistory } = await import('../services/veterinaria_dashboard.service.js');
    const history = await getPatientHistory(veterinariaId, mascotaId);
    res.json({ ok: true, data: history });
  } catch (err) {
    res.status(500).json({ ok: false, error: err.message });
  }
};