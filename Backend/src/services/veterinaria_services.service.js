import {
    getServiciosByVeterinaria,
    getServiciosActivosByVeterinaria,
    addServicioToVeterinaria,
    updateServicioVeterinaria,
    deleteServicioVeterinaria,
    removeServicioVeterinaria
} from '../models/veterinaria_services.model.js';

export const getServiciosVeterinariaService = async (veterinariaId, activoOnly = false) => {
    if (activoOnly) {
        return await getServiciosActivosByVeterinaria(veterinariaId);
    }
    return await getServiciosByVeterinaria(veterinariaId);
};

export const addServicioVeterinariaService = async (data) => {
    const { veterinaria_id, servicio_id, precio } = data;
    
    if (!veterinaria_id || !servicio_id) {
        throw new Error('veterinaria_id y servicio_id son requeridos');
    }
    
    if (precio && (isNaN(precio) || precio < 0)) {
        throw new Error('El precio debe ser un número válido mayor o igual a 0');
    }
    
    return await addServicioToVeterinaria(data);
};

export const updateServicioVeterinariaService = async (id, data) => {
    const { precio } = data;
    
    if (precio !== undefined && (isNaN(precio) || precio < 0)) {
        throw new Error('El precio debe ser un número válido mayor o igual a 0');
    }
    
    const result = await updateServicioVeterinaria(id, data);
    if (!result) {
        throw new Error('Servicio no encontrado');
    }
    
    return result;
};

export const deleteServicioVeterinariaService = async (id) => {
    const result = await deleteServicioVeterinaria(id);
    if (!result) {
        throw new Error('Servicio no encontrado');
    }
    return result;
};

export const removeServicioVeterinariaService = async (veterinariaId, servicioId) => {
    const result = await removeServicioVeterinaria(veterinariaId, servicioId);
    if (!result) {
        throw new Error('Servicio no encontrado');
    }
    return result;
};
