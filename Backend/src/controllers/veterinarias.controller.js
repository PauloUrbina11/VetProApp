import { getVeterinarias, getVeterinaria, addVeterinaria, editVeterinaria } from "../services/veterinarias.service.js";

export const getVeterinariasController = async (req, res) => {
  try {
    const { ciudad_id } = req.query;
    const list = await getVeterinarias({ ciudad_id: ciudad_id ? Number(ciudad_id) : undefined });
    res.json({ ok: true, data: list });
  } catch (err) {
    res.status(500).json({ ok: false, error: err.message });
  }
};

export const getVeterinariaController = async (req, res) => {
  try {
    const { id } = req.params;
    const vet = await getVeterinaria(Number(id));
    if (!vet) return res.status(404).json({ ok: false, error: "Not Found" });
    res.json({ ok: true, data: vet });
  } catch (err) {
    res.status(500).json({ ok: false, error: err.message });
  }
};

export const postVeterinariaController = async (req, res) => {
  try {
    const created = await addVeterinaria(req.body);
    res.status(201).json({ ok: true, data: created });
  } catch (err) {
    res.status(500).json({ ok: false, error: err.message });
  }
};

export const putVeterinariaController = async (req, res) => {
  try {
    const { id } = req.params;
    const updated = await editVeterinaria(Number(id), req.body);
    res.json({ ok: true, data: updated });
  } catch (err) {
    res.status(500).json({ ok: false, error: err.message });
  }
};
