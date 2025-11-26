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

const router = Router();

// Endpoints reales
router.post("/register", register);
router.post("/login", login);
router.post("/activate", activateAccount);
// GET usado para redirigir desde el correo al esquema deep link de la app
router.get("/activate", activateRedirect);
router.get('/reset', resetRedirect);
router.post("/reset/request", requestPasswordResetController);
router.post("/reset/update", resetPasswordController);

export default router;
