import {
  getUserNotifications,
  markNotificationAsRead,
  markAllNotificationsAsRead,
  getUnreadNotificationsCount,
  deleteNotification,
} from "../models/notifications.model.js";

export const getUserNotificationsController = async (req, res) => {
  try {
    const userId = req.userId;
    const notifications = await getUserNotifications(userId);
    res.json({ ok: true, data: notifications });
  } catch (err) {
    res.status(500).json({ ok: false, error: err.message });
  }
};

export const markAsReadController = async (req, res) => {
  try {
    const userId = req.userId;
    const { id } = req.params;
    const notification = await markNotificationAsRead(id, userId);
    if (!notification) {
      return res.status(404).json({ ok: false, error: "Notificación no encontrada" });
    }
    res.json({ ok: true, data: notification });
  } catch (err) {
    res.status(500).json({ ok: false, error: err.message });
  }
};

export const markAllAsReadController = async (req, res) => {
  try {
    const userId = req.userId;
    const notifications = await markAllNotificationsAsRead(userId);
    res.json({ ok: true, data: notifications });
  } catch (err) {
    res.status(500).json({ ok: false, error: err.message });
  }
};

export const getUnreadCountController = async (req, res) => {
  try {
    const userId = req.userId;
    const count = await getUnreadNotificationsCount(userId);
    res.json({ ok: true, data: { count } });
  } catch (err) {
    res.status(500).json({ ok: false, error: err.message });
  }
};

export const deleteNotificationController = async (req, res) => {
  try {
    const userId = req.userId;
    const { id } = req.params;
    const notification = await deleteNotification(id, userId);
    if (!notification) {
      return res.status(404).json({ ok: false, error: "Notificación no encontrada" });
    }
    res.json({ ok: true, message: "Notificación eliminada" });
  } catch (err) {
    res.status(500).json({ ok: false, error: err.message });
  }
};
