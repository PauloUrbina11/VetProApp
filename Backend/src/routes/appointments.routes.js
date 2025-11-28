import { Router } from "express";
import { authMiddleware } from "../middlewares/auth.middleware.js";
import {
  getMyAppointmentsController,
  getNextAppointmentController,
  getCalendarCountsController,
  postAppointmentController,
  putAppointmentController,
  deleteAppointmentController,
  getVeterinariaAppointmentsController,
} from "../controllers/appointments.controller.js";

const router = Router();

router.get("/my", authMiddleware, getMyAppointmentsController);
router.get("/next", authMiddleware, getNextAppointmentController);
router.get("/calendar", authMiddleware, getCalendarCountsController);
router.get("/veterinaria/:veterinariaId", authMiddleware, getVeterinariaAppointmentsController);
router.post("/", authMiddleware, postAppointmentController);
router.put("/:id", authMiddleware, putAppointmentController);
router.delete("/:id", authMiddleware, deleteAppointmentController);

export default router;
