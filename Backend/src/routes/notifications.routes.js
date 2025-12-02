import { Router } from "express";
import { authMiddleware } from "../middlewares/auth.middleware.js";
import {
  getUserNotificationsController,
  markAsReadController,
  markAllAsReadController,
  getUnreadCountController,
  deleteNotificationController,
} from "../controllers/notifications.controller.js";

const router = Router();

router.use(authMiddleware);

router.get("/", getUserNotificationsController);
router.get("/unread-count", getUnreadCountController);
router.patch("/:id/read", markAsReadController);
router.patch("/mark-all-read", markAllAsReadController);
router.delete("/:id", deleteNotificationController);

export default router;
