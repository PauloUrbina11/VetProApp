import {
  listVeterinarias,
  getVeterinariaById,
  createVeterinaria,
  updateVeterinaria,
} from "../models/veterinarias.model.js";

export const getVeterinarias = async (filters) => listVeterinarias(filters);
export const getVeterinaria = async (id) => getVeterinariaById(id);
export const addVeterinaria = async (data) => createVeterinaria(data);
export const editVeterinaria = async (id, data) => updateVeterinaria(id, data);
