import {
  getServiceTypes,
  getServices,
  addService,
  editService,
  disableService,
} from "../services/services.service.js";

export const getServiceTypesController = async (req, res) => {
  try {
    const types = await getServiceTypes();
    res.json({ ok: true, data: types });
  } catch (err) {
    res.status(500).json({ ok: false, error: err.message });
  }
};

export const getServicesController = async (req, res) => {
  try {
    const { tipo_servicio_id, activo } = req.query;
    const filters = {
      tipo_servicio_id: tipo_servicio_id ? Number(tipo_servicio_id) : undefined,
      activo: typeof activo !== 'undefined' ? activo === 'true' : undefined,
    };
    const list = await getServices(filters);
    res.json({ ok: true, data: list });
  } catch (err) {
    res.status(500).json({ ok: false, error: err.message });
  }
};

export const postServiceController = async (req, res) => {
  try {
    const created = await addService(req.body);
    res.status(201).json({ ok: true, data: created });
  } catch (err) {
    res.status(500).json({ ok: false, error: err.message });
  }
};

export const putServiceController = async (req, res) => {
  try {
    const { id } = req.params;
    const updated = await editService(Number(id), req.body);
    res.json({ ok: true, data: updated });
  } catch (err) {
    res.status(500).json({ ok: false, error: err.message });
  }
};

export const deleteServiceController = async (req, res) => {
  try {
    const { id } = req.params;
    const disabled = await disableService(Number(id));
    res.json({ ok: true, data: disabled });
  } catch (err) {
    res.status(500).json({ ok: false, error: err.message });
  }
};
