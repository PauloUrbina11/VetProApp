/**
 * Validadores para citas
 */

export const validateAppointmentData = (data) => {
  const errors = [];

  if (!data.fecha_hora && !(data.fecha && data.hora)) {
    errors.push('La fecha y hora son obligatorias');
  }

  if (!data.mascota_ids || data.mascota_ids.length === 0) {
    if (!data.mascotas || data.mascotas.length === 0) {
      errors.push('Debe seleccionar al menos una mascota');
    }
  }

  if (errors.length > 0) {
    throw new Error(errors.join(', '));
  }

  return true;
};

export const validateUpdateAppointmentData = (data) => {
  // Validación más flexible para actualización
  if (data.estado_id && ![1, 2, 3, 4, 5].includes(data.estado_id)) {
    throw new Error('Estado de cita inválido');
  }

  return true;
};
