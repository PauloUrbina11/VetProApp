import { Router } from "express";
import { authMiddleware } from "../middlewares/auth.middleware.js";
import {
  getServiceTypesController,
  getServicesController,
  postServiceController,
  putServiceController,
  deleteServiceController,
} from "../controllers/services.controller.js";

const router = Router();

router.get("/types", getServiceTypesController);
router.get("/", getServicesController);
router.post("/", authMiddleware, postServiceController);
router.put("/:id", authMiddleware, putServiceController);
router.delete("/:id", authMiddleware, deleteServiceController);

export default router;
