import { Router } from "express";
import { getRecommendationsController } from "../controllers/recommendations.controller.js";

const router = Router();

router.get("/", getRecommendationsController);

export default router;
