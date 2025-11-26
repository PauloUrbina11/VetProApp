import {
  listMyAppointments,
  getAllAppointments,
  getMyNextAppointment,
  getMyCalendarCounts,
  createMyAppointment,
  updateMyAppointment,
  removeMyAppointment,
} from "../services/appointments.service.js";

export const getMyAppointmentsController = async (req, res) => {
  try {
    const userId = req.user?.id;
    if (!userId) return res.status(401).json({ ok: false, error: "Unauthorized" });
    const citas = await listMyAppointments(userId);
    res.json({ ok: true, data: citas });
  } catch (err) {
    res.status(500).json({ ok: false, error: err.message });
  }
};

export const getNextAppointmentController = async (req, res) => {
  try {
    const userId = req.user?.id;
    if (!userId) return res.status(401).json({ ok: false, error: "Unauthorized" });
    const cita = await getMyNextAppointment(userId);
    res.json({ ok: true, data: cita });
  } catch (err) {
    res.status(500).json({ ok: false, error: err.message });
  }
};

export const getCalendarCountsController = async (req, res) => {
  try {
    const userId = req.user?.id;
    if (!userId) return res.status(401).json({ ok: false, error: "Unauthorized" });
    const { from, to } = req.query;
    if (!from || !to) return res.status(400).json({ ok: false, error: "Missing from/to dates" });
    const counts = await getMyCalendarCounts(userId, from, to);
    res.json({ ok: true, data: counts });
  } catch (err) {
    res.status(500).json({ ok: false, error: err.message });
  }
};

export const postAppointmentController = async (req, res) => {
  try {
    const userId = req.user?.id;
    if (!userId) return res.status(401).json({ ok: false, error: "Unauthorized" });
    const cita = await createMyAppointment(userId, req.body);
    res.status(201).json({ ok: true, data: cita });
  } catch (err) {
    res.status(500).json({ ok: false, error: err.message });
  }
};

export const putAppointmentController = async (req, res) => {
  try {
    const { id } = req.params;
    const cita = await updateMyAppointment(Number(id), req.body);
    res.json({ ok: true, data: cita });
  } catch (err) {
    res.status(500).json({ ok: false, error: err.message });
  }
};

export const deleteAppointmentController = async (req, res) => {
  try {
    const { id } = req.params;
    const deleted = await removeMyAppointment(Number(id));
    res.json({ ok: true, data: deleted });
  } catch (err) {
    res.status(500).json({ ok: false, error: err.message });
  }
};

export const getAllAppointmentsController = async (req, res) => {
  try {
    const citas = await getAllAppointments();
    res.json({ ok: true, data: citas });
  } catch (err) {
    res.status(500).json({ ok: false, error: err.message });
  }
};
