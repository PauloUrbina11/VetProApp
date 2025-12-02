/**
 * Validadores para autenticación
 */

export const validateRegisterData = (data) => {
  const errors = [];

  if (!data.nombre_completo || data.nombre_completo.trim() === '') {
    errors.push('El nombre completo es obligatorio');
  }

  if (!data.correo || data.correo.trim() === '') {
    errors.push('El correo es obligatorio');
  } else if (!isValidEmail(data.correo)) {
    errors.push('El formato del correo es inválido');
  }

  if (!data.password || data.password.length < 6) {
    errors.push('La contraseña debe tener al menos 6 caracteres');
  }

  if (!data.celular || data.celular.trim() === '') {
    errors.push('El celular es obligatorio');
  }

  if (errors.length > 0) {
    throw new Error(errors.join(', '));
  }

  return true;
};

export const validateLoginData = (data) => {
  const errors = [];

  if (!data.correo || data.correo.trim() === '') {
    errors.push('El correo es obligatorio');
  }

  if (!data.password || data.password.trim() === '') {
    errors.push('La contraseña es obligatoria');
  }

  if (errors.length > 0) {
    throw new Error(errors.join(', '));
  }

  return true;
};

export const validateResetPasswordData = (token, newPassword) => {
  const errors = [];

  if (!token || token.trim() === '') {
    errors.push('El token es obligatorio');
  }

  if (!newPassword || newPassword.length < 6) {
    errors.push('La nueva contraseña debe tener al menos 6 caracteres');
  }

  if (errors.length > 0) {
    throw new Error(errors.join(', '));
  }

  return true;
};

// Función auxiliar para validar email
const isValidEmail = (email) => {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return emailRegex.test(email);
};
