import { Router } from "express";
import { pool } from "../config/database.js";

const router = Router();

// GET /api/location/departamentos
router.get("/departamentos", async (req, res) => {
  try {
    const result = await pool.query("SELECT id, nombre FROM departamentos ORDER BY nombre");
    return res.json({ ok: true, departamentos: result.rows });
  } catch (err) {
    return res.status(500).json({ ok: false, message: err.message });
  }
});

// GET /api/location/ciudades?departamento_id=1
router.get("/ciudades", async (req, res) => {
  try {
    const { departamento_id } = req.query;
    if (!departamento_id) {
      return res.status(400).json({ ok: false, message: "departamento_id es requerido" });
    }

    const result = await pool.query(
      "SELECT id, nombre, departamento_id FROM ciudades WHERE departamento_id = $1 ORDER BY nombre",
      [departamento_id]
    );

    return res.json({ ok: true, ciudades: result.rows });
  } catch (err) {
    return res.status(500).json({ ok: false, message: err.message });
  }
});

export default router;
