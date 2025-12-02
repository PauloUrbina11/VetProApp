import { Router } from "express";
import { authMiddleware } from "../middlewares/auth.middleware.js";
import { requireRole } from "../middlewares/role.middleware.js";
import {
  listUsersController,
  toggleUserActiveController,
  listVeterinariaUsersController,
  getUserRoleController,
  assignRoleController,
  listVeterinariaRolesController,
  assignVeterinariaRoleController,
  createVeterinariaController,
  getUserVeterinariaRolesController,
  removeVeterinariaRoleController,
} from "../controllers/admin.controller.js";
import { getAllAppointmentsController } from "../controllers/appointments.controller.js";

const router = Router();

// Admin role assumed to be rol_id = 1
const adminOnly = [1];

router.use(authMiddleware, requireRole(adminOnly));

router.get("/users", listUsersController);
router.patch("/users/:id/toggle-active", toggleUserActiveController);
router.get("/veterinaria-users", listVeterinariaUsersController);
router.get("/users/:id/role", getUserRoleController);
router.post("/users/:id/role", assignRoleController);
router.get("/veterinaria-roles", listVeterinariaRolesController);
router.post("/veterinaria-role", assignVeterinariaRoleController);
router.delete("/veterinaria-role", removeVeterinariaRoleController);
router.get("/veterinaria/:veterinaria_id/user/:user_id/roles", getUserVeterinariaRolesController);
router.post("/veterinarias", createVeterinariaController);
router.get("/appointments", getAllAppointmentsController);

export default router;
