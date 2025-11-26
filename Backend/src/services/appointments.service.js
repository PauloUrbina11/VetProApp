import {
  listAppointmentsByUser,
  listAllAppointments,
  getNextAppointmentByUser,
  getCalendarCountsByUser,
  createAppointment,
  updateAppointment,
  deleteAppointment,
} from "../models/appointments.model.js";

export const listMyAppointments = async (userId) => {
  return await listAppointmentsByUser(userId);
};

export const getMyNextAppointment = async (userId) => {
  return await getNextAppointmentByUser(userId);
};

export const getMyCalendarCounts = async (userId, from, to) => {
  return await getCalendarCountsByUser(userId, from, to);
};

export const createMyAppointment = async (userId, data) => {
  return await createAppointment(userId, data);
};

export const updateMyAppointment = async (id, data) => {
  return await updateAppointment(id, data);
};

export const removeMyAppointment = async (id) => {
  return await deleteAppointment(id);
};

export const getAllAppointments = async () => {
  return await listAllAppointments();
};
