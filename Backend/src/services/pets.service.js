import {
  getEspecies,
  getRazasByEspecie,
  getMascotasByUserId,
  createMascota,
  getMascotaById,
  getAllMascotas,
  checkMascotaHasHistorial,
  deleteMascota,
  updateMascota,
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

export const listAllMascotas = async () => {
  return await getAllMascotas();
};

export const removeMascota = async (id) => {
  const hasHistorial = await checkMascotaHasHistorial(id);
  if (hasHistorial) {
    throw new Error('No se puede eliminar una mascota con historial clínico');
  }
  return await deleteMascota(id);
};

export const updateMascotaData = async (id, data) => {
  return await updateMascota(id, data);
};

