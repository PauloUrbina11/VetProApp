import express from 'express';
import {
    getServiciosVeterinariaController,
    addServicioVeterinariaController,
    updateServicioVeterinariaController,
    deleteServicioVeterinariaController,
    removeServicioVeterinariaController
} from '../controllers/veterinaria_services.controller.js';
import { authMiddleware } from '../middlewares/auth.middleware.js';
import { requireRole } from '../middlewares/role.middleware.js';

const router = express.Router();

// Todas las rutas requieren autenticación
router.use(authMiddleware);

// GET /api/veterinarias/:veterinariaId/servicios - Obtener servicios de una veterinaria
router.get('/:veterinariaId/servicios', getServiciosVeterinariaController);

// POST /api/veterinarias/:veterinariaId/servicios - Agregar servicio (solo admin o veterinaria)
router.post('/:veterinariaId/servicios', requireRole([1, 2]), addServicioVeterinariaController);

// PUT /api/veterinarias/:veterinariaId/servicios/:id - Actualizar servicio (solo admin o veterinaria)
router.put('/:veterinariaId/servicios/:id', requireRole([1, 2]), updateServicioVeterinariaController);

// DELETE /api/veterinarias/:veterinariaId/servicios/:id - Desactivar servicio (solo admin o veterinaria)
router.delete('/:veterinariaId/servicios/:id', requireRole([1, 2]), deleteServicioVeterinariaController);

// DELETE /api/veterinarias/:veterinariaId/servicios/:servicioId/remove - Eliminar permanentemente (solo admin o veterinaria)
router.delete('/:veterinariaId/servicios/:servicioId/remove', requireRole([1, 2]), removeServicioVeterinariaController);

export default router;
