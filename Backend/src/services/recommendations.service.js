import { listRecommendations } from "../models/recommendations.model.js";

export const getRecommendations = async (filters) => listRecommendations(filters);
