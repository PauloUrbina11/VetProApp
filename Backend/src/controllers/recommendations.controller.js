import { getRecommendations } from "../services/recommendations.service.js";

export const getRecommendationsController = async (req, res) => {
  try {
    const { especie_id, veterinaria_id } = req.query;
    const list = await getRecommendations({
      especie_id: especie_id ? Number(especie_id) : undefined,
      veterinaria_id: veterinaria_id ? Number(veterinaria_id) : undefined,
    });
    res.json({ ok: true, data: list });
  } catch (err) {
    res.status(500).json({ ok: false, error: err.message });
  }
};
