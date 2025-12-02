/**
 * Constantes de roles del sistema
 */
export const ROLES = {
  ADMIN: 1,
  USUARIO: 2,
  VETERINARIO: 3,
};

export const ROLE_NAMES = {
  [ROLES.ADMIN]: 'Administrador',
  [ROLES.USUARIO]: 'Usuario',
  [ROLES.VETERINARIO]: 'Veterinario',
};

export const VETERINARIA_ROLES = {
  ADMIN: 1,
  VETERINARIO: 2,
  ASISTENTE: 3,
};

export const VETERINARIA_ROLE_NAMES = {
  [VETERINARIA_ROLES.ADMIN]: 'Administrador',
  [VETERINARIA_ROLES.VETERINARIO]: 'Veterinario',
  [VETERINARIA_ROLES.ASISTENTE]: 'Asistente',
};
