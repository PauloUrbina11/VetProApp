import { getUserProfile, updateUserProfile } from "../services/user.service.js";

export const getMyProfileController = async (req, res) => {
  try {
    const userId = req.user.id;
    const profile = await getUserProfile(userId);
    return res.json({ ok: true, profile });
  } catch (err) {
    return res.status(400).json({ ok: false, message: err.message });
  }
};

export const updateMyProfileController = async (req, res) => {
  try {
    const userId = req.user.id;
    const updated = await updateUserProfile(userId, req.body);
    return res.json({ ok: true, profile: updated });
  } catch (err) {
    return res.status(400).json({ ok: false, message: err.message });
  }
};
