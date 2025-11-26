import {
  listServiceTypes,
  listServices,
  createService,
  updateService,
  deactivateService,
} from "../models/services.model.js";

export const getServiceTypes = async () => listServiceTypes();
export const getServices = async (filters) => listServices(filters);
export const addService = async (data) => createService(data);
export const editService = async (id, data) => updateService(id, data);
export const disableService = async (id) => deactivateService(id);
