import { getUserRole } from "../models/role.model.js";

// Usage: requireRole([1]) for admin, or multiple roles
export const requireRole = (allowedRoles) => {
  return async (req, res, next) => {
    try {
      const userId = req.user?.id;
      if (!userId) return res.status(401).json({ ok: false, error: "Unauthorized" });
      const rol_id = await getUserRole(userId);
      if (!allowedRoles.includes(rol_id)) {
        return res.status(403).json({ ok: false, error: "Forbidden" });
      }
      req.user.rol_id = rol_id;
      next();
    } catch (err) {
      return res.status(500).json({ ok: false, error: err.message });
    }
  };
};
