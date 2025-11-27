import {
  listEspecies,
  listRazas,
  listMisMascotas,
  addMascota,
  getMascota,
  listAllMascotas,
  removeMascota,
} from "../services/pets.service.js";

export const getEspeciesController = async (req, res) => {
  try {
    const especies = await listEspecies();
    res.json({ ok: true, data: especies });
  } catch (err) {
    res.status(500).json({ ok: false, error: err.message });
  }
};

export const getRazasController = async (req, res) => {
  try {
    const { especie_id } = req.query;
    if (!especie_id) return res.status(400).json({ ok: false, error: "Missing especie_id" });
    const razas = await listRazas(Number(especie_id));
    res.json({ ok: true, data: razas });
  } catch (err) {
    res.status(500).json({ ok: false, error: err.message });
  }
};

export const getMisMascotasController = async (req, res) => {
  try {
    const userId = req.user?.id;
    if (!userId) return res.status(401).json({ ok: false, error: "Unauthorized" });
    const mascotas = await listMisMascotas(userId);
    res.json({ ok: true, data: mascotas });
  } catch (err) {
    res.status(500).json({ ok: false, error: err.message });
  }
};

export const postMascotaController = async (req, res) => {
  try {
    const ownerUserId = req.user?.id;
    if (!ownerUserId) return res.status(401).json({ ok: false, error: "Unauthorized" });
    const pet = await addMascota(req.body, ownerUserId);
    res.status(201).json({ ok: true, data: pet });
  } catch (err) {
    res.status(500).json({ ok: false, error: err.message });
  }
};

export const getMascotaController = async (req, res) => {
  try {
    const { id } = req.params;
    const pet = await getMascota(Number(id));
    if (!pet) return res.status(404).json({ ok: false, error: "Not Found" });
    res.json({ ok: true, data: pet });
  } catch (err) {
    res.status(500).json({ ok: false, error: err.message });
  }
};

export const getAllMascotasController = async (req, res) => {
  try {
    const mascotas = await listAllMascotas();
    res.json({ ok: true, data: mascotas });
  } catch (err) {
    res.status(500).json({ ok: false, error: err.message });
  }
};

export const deleteMascotaController = async (req, res) => {
  try {
    const { id } = req.params;
    const deleted = await removeMascota(Number(id));
    res.json({ ok: true, data: deleted });
  } catch (err) {
    res.status(400).json({ ok: false, error: err.message });
  }
};

