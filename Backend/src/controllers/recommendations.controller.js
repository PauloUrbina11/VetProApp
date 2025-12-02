import { getRecommendations, addRecommendation } from "../services/recommendations.service.js";

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

export const createRecommendationController = async (req, res) => {
  try {
    const { titulo, descripcion, especie_id, veterinaria_id, imagen_url } = req.body;
    
    if (!titulo || !descripcion || !especie_id) {
      return res.status(400).json({ 
        ok: false, 
        error: "titulo, descripcion y especie_id son requeridos" 
      });
    }
    
    const recommendation = await addRecommendation({
      titulo,
      descripcion,
      especie_id: Number(especie_id),
      veterinaria_id: veterinaria_id ? Number(veterinaria_id) : null,
      imagen_url
    });
    
    res.status(201).json({ ok: true, data: recommendation });
  } catch (err) {
    res.status(500).json({ ok: false, error: err.message });
  }
};
