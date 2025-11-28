import express from 'express';
import {
    getHorarios,
    createHorarioController,
    updateHorarioController,
    deleteHorarioController,
    replaceAllHorariosController,
    getHorariosDisponiblesController
} from '../controllers/horarios.controller.js';
import { authMiddleware } from '../middlewares/auth.middleware.js';
import { requireRole } from '../middlewares/role.middleware.js';

const router = express.Router();

// Todas las rutas requieren autenticación
router.use(authMiddleware);

// GET /api/veterinarias/:veterinariaId/horarios - Obtener horarios
router.get('/:veterinariaId/horarios', getHorarios);

// GET /api/veterinarias/:veterinariaId/horarios-disponibles - Obtener horarios disponibles
router.get('/:veterinariaId/horarios-disponibles', getHorariosDisponiblesController);

// POST /api/veterinarias/:veterinariaId/horarios - Crear horario (solo admin o veterinaria)
router.post('/:veterinariaId/horarios', requireRole([1, 2]), createHorarioController);

// PUT /api/veterinarias/:veterinariaId/horarios - Reemplazar todos los horarios (solo admin o veterinaria)
router.put('/:veterinariaId/horarios', requireRole([1, 2]), replaceAllHorariosController);

// PUT /api/veterinarias/:veterinariaId/horarios/:id - Actualizar horario (solo admin o veterinaria)
router.put('/:veterinariaId/horarios/:id', requireRole([1, 2]), updateHorarioController);

// DELETE /api/veterinarias/:veterinariaId/horarios/:id - Eliminar horario (solo admin o veterinaria)
router.delete('/:veterinariaId/horarios/:id', requireRole([1, 2]), deleteHorarioController);

export default router;
