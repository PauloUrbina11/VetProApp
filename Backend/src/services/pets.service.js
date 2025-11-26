import {
  getEspecies,
  getRazasByEspecie,
  getMascotasByUserId,
  createMascota,
  getMascotaById,
} from "../models/pets.model.js";

export const listEspecies = async () => {
  return await getEspecies();
};

export const listRazas = async (especieId) => {
  return await getRazasByEspecie(especieId);
};

export const listMisMascotas = async (userId) => {
  return await getMascotasByUserId(userId);
};

export const addMascota = async (data, ownerUserId) => {
  return await createMascota(data, ownerUserId);
};

export const getMascota = async (id) => {
  return await getMascotaById(id);
};
