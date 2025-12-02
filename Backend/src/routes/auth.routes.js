import { Router } from "express";
import {
  register,
  login,
  activateAccount,
  activateRedirect,
  resetRedirect,
  requestPasswordResetController,
  resetPasswordController,
} from "../controllers/auth.controller.js";
import { authMiddleware } from "../middlewares/auth.middleware.js";
import { requireFields, requireQueryParams } from "../middlewares/validation.middleware.js";

const router = Router();

// Registro y autenticación
router.post("/register", register);
router.post("/login", requireFields(['correo', 'password']), login);

// Activación de cuenta
router.post("/activate", requireQueryParams(['token']), requireFields(['rol_id']), activateAccount);
router.get("/activate", activateRedirect);

// Reseteo de contraseña
router.get('/reset', resetRedirect);
router.post("/reset/request", requireFields(['correo']), requestPasswordResetController);
router.post("/reset/update", requireFields(['token', 'newPassword']), resetPasswordController);

export default router;
