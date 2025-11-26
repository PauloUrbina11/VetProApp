import { Router } from "express";
import { authMiddleware } from "../middlewares/auth.middleware.js";
import {
  getEspeciesController,
  getRazasController,
  getMisMascotasController,
  postMascotaController,
  getMascotaController,
} from "../controllers/pets.controller.js";

const router = Router();

router.get("/especies", getEspeciesController);
router.get("/razas", getRazasController);
router.get("/mis", authMiddleware, getMisMascotasController);
router.post("/", authMiddleware, postMascotaController);
router.get("/:id", authMiddleware, getMascotaController);

export default router;
