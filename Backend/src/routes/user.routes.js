import { Router } from "express";
import { authMiddleware } from "../middlewares/auth.middleware.js";
import { getMyProfileController, updateMyProfileController } from "../controllers/user.controller.js";

const router = Router();

router.get("/me", authMiddleware, getMyProfileController);
router.put("/me", authMiddleware, updateMyProfileController);

export default router;
