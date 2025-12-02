/**
 * Validadores para mascotas
 */

export const validatePetData = (data) => {
  const errors = [];

  if (!data.nombre || data.nombre.trim() === '') {
    errors.push('El nombre de la mascota es obligatorio');
  }

  if (!data.especie || data.especie.trim() === '') {
    errors.push('La especie es obligatoria');
  }

  if (errors.length > 0) {
    throw new Error(errors.join(', '));
  }

  return true;
};
