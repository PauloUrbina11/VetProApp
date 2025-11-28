import {
    getHorariosService,
    createHorarioService,
    updateHorarioService,
    deleteHorarioService,
    replaceAllHorariosService,
    getHorariosDisponiblesService
} from '../services/horarios.service.js';

// GET /api/veterinarias/:veterinariaId/horarios
export const getHorarios = async (req, res) => {
    try {
        const { veterinariaId } = req.params;
        const horarios = await getHorariosService(veterinariaId);
        return res.json({ ok: true, horarios });
    } catch (err) {
        return res.status(400).json({ ok: false, message: err.message });
    }
};

// POST /api/veterinarias/:veterinariaId/horarios
export const createHorarioController = async (req, res) => {
    try {
        const { veterinariaId } = req.params;
        const horario = await createHorarioService({
            ...req.body,
            veterinaria_id: veterinariaId
        });
        return res.status(201).json({ ok: true, horario });
    } catch (err) {
        return res.status(400).json({ ok: false, message: err.message });
    }
};

// PUT /api/veterinarias/:veterinariaId/horarios/:id
export const updateHorarioController = async (req, res) => {
    try {
        const { id } = req.params;
        const horario = await updateHorarioService(id, req.body);
        return res.json({ ok: true, horario });
    } catch (err) {
        return res.status(400).json({ ok: false, message: err.message });
    }
};

// DELETE /api/veterinarias/:veterinariaId/horarios/:id
export const deleteHorarioController = async (req, res) => {
    try {
        const { id } = req.params;
        const horario = await deleteHorarioService(id);
        return res.json({ ok: true, horario, message: 'Horario eliminado' });
    } catch (err) {
        return res.status(400).json({ ok: false, message: err.message });
    }
};

// PUT /api/veterinarias/:veterinariaId/horarios (replace all)
export const replaceAllHorariosController = async (req, res) => {
    try {
        const { veterinariaId } = req.params;
        const { horarios } = req.body;
        
        if (!Array.isArray(horarios)) {
            return res.status(400).json({ 
                ok: false, 
                message: 'Se esperaba un array de horarios' 
            });
        }
        
        const result = await replaceAllHorariosService(veterinariaId, horarios);
        return res.json({ ok: true, horarios: result });
    } catch (err) {
        return res.status(400).json({ ok: false, message: err.message });
    }
};

// GET /api/veterinarias/:veterinariaId/horarios-disponibles?fecha=YYYY-MM-DD
export const getHorariosDisponiblesController = async (req, res) => {
    try {
        const { veterinariaId } = req.params;
        const { fecha } = req.query;
        
        if (!fecha) {
            return res.status(400).json({
                ok: false,
                message: 'El parámetro fecha es requerido (formato: YYYY-MM-DD)'
            });
        }
        
        const slots = await getHorariosDisponiblesService(veterinariaId, fecha);
        return res.json({ ok: true, slots });
    } catch (err) {
        return res.status(400).json({ ok: false, message: err.message });
    }
};
