import {
    getServiciosVeterinariaService,
    addServicioVeterinariaService,
    updateServicioVeterinariaService,
    deleteServicioVeterinariaService,
    removeServicioVeterinariaService
} from '../services/veterinaria_services.service.js';

// GET /api/veterinarias/:veterinariaId/servicios
export const getServiciosVeterinariaController = async (req, res) => {
    try {
        const { veterinariaId } = req.params;
        const { activos } = req.query;
        
        const servicios = await getServiciosVeterinariaService(
            veterinariaId,
            activos === 'true'
        );
        
        return res.json({ ok: true, servicios });
    } catch (err) {
        return res.status(400).json({ ok: false, message: err.message });
    }
};

// POST /api/veterinarias/:veterinariaId/servicios
export const addServicioVeterinariaController = async (req, res) => {
    try {
        const { veterinariaId } = req.params;
        const data = {
            ...req.body,
            veterinaria_id: veterinariaId
        };
        
        const servicio = await addServicioVeterinariaService(data);
        return res.status(201).json({ ok: true, servicio });
    } catch (err) {
        return res.status(400).json({ ok: false, message: err.message });
    }
};

// PUT /api/veterinarias/:veterinariaId/servicios/:id
export const updateServicioVeterinariaController = async (req, res) => {
    try {
        const { id } = req.params;
        const servicio = await updateServicioVeterinariaService(id, req.body);
        return res.json({ ok: true, servicio });
    } catch (err) {
        return res.status(400).json({ ok: false, message: err.message });
    }
};

// DELETE /api/veterinarias/:veterinariaId/servicios/:id (soft delete)
export const deleteServicioVeterinariaController = async (req, res) => {
    try {
        const { id } = req.params;
        const servicio = await deleteServicioVeterinariaService(id);
        return res.json({ ok: true, servicio, message: 'Servicio desactivado' });
    } catch (err) {
        return res.status(400).json({ ok: false, message: err.message });
    }
};

// DELETE /api/veterinarias/:veterinariaId/servicios/:servicioId/remove (hard delete)
export const removeServicioVeterinariaController = async (req, res) => {
    try {
        const { veterinariaId, servicioId } = req.params;
        const servicio = await removeServicioVeterinariaService(veterinariaId, servicioId);
        return res.json({ ok: true, servicio, message: 'Servicio eliminado permanentemente' });
    } catch (err) {
        return res.status(400).json({ ok: false, message: err.message });
    }
};
