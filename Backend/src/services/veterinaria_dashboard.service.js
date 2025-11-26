import {
  getVeterinariasByUser,
  getVeterinariaStats,
  getVeterinariaNextAppointments,
  getVeterinariaCalendarCounts,
  isVeterinariaAdmin,
} from "../models/veterinaria_dashboard.model.js";

export const listMyVeterinarias = async (userId) => getVeterinariasByUser(userId);
export const getDashboardData = async (veterinariaId, userId) => {
  const [stats, nextAppointments, admin] = await Promise.all([
    getVeterinariaStats(veterinariaId),
    getVeterinariaNextAppointments(veterinariaId, 3),
    isVeterinariaAdmin(veterinariaId, userId),
  ]);
  return { stats, nextAppointments, isAdmin: admin };
};
export const getCalendarData = async (veterinariaId, fromDate, toDate) =>
  getVeterinariaCalendarCounts(veterinariaId, fromDate, toDate);