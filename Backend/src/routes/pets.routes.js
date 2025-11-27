import { Router } from "express";
import { authMiddleware } from "../middlewares/auth.middleware.js";
import { requireRole } from "../middlewares/role.middleware.js";
import {
  getEspeciesController,
  getRazasController,
  getMisMascotasController,
  postMascotaController,
  getMascotaController,
  getAllMascotasController,
  deleteMascotaController,
  putMascotaController,
} from "../controllers/pets.controller.js";

const router = Router();

router.get("/especies", getEspeciesController);
router.get("/razas", getRazasController);
router.get("/mis", authMiddleware, getMisMascotasController);
router.get("/all", authMiddleware, requireRole(1), getAllMascotasController);
router.post("/", authMiddleware, postMascotaController);
router.put("/:id", authMiddleware, putMascotaController);
router.delete("/:id", authMiddleware, deleteMascotaController);
router.get("/:id", authMiddleware, getMascotaController);

export default router;

