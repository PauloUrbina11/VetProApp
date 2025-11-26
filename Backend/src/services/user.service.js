import { getUserById, updateUserProfileDB, updatePassword } from "../models/user.model.js";
import { hashPassword } from "../utils/passwordHash.js";

export const getUserProfile = async (userId) => {
  const user = await getUserById(userId);
  if (!user) throw new Error("Usuario no encontrado");
  return user;
};

export const updateUserProfile = async (userId, data) => {
  // Separar contraseña si viene
  let updated;
  const { password, ...rest } = data;
  // Actualizar campos normales
  updated = await updateUserProfileDB(userId, rest);

  // Actualizar contraseña si se envía
  if (password && password.trim().length > 0) {
    const hashed = await hashPassword(password.trim());
    await updatePassword(userId, hashed); // retorna id y correo
    // Recuperar perfil completo nuevamente
    updated = await getUserById(userId);
  }

  return updated;
};
