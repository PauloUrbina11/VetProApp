import { Router } from "express";
import { getRecommendationsController, createRecommendationController } from "../controllers/recommendations.controller.js";
import { authMiddleware } from "../middlewares/auth.middleware.js";

const router = Router();

router.get("/", getRecommendationsController);
router.post("/", authMiddleware, createRecommendationController);

export default router;
