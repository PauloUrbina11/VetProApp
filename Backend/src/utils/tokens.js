/**
 * Utilidades centralizadas para generación de tokens
 */
import jwt from "jsonwebtoken";
import crypto from "crypto";

/**
 * Genera un token JWT firmado con el ID del usuario
 * @param {number} userId - ID del usuario
 * @returns {string} Token JWT
 */
export const generateJWT = (userId) => {
  if (!process.env.JWT_SECRET) {
    throw new Error("JWT_SECRET no está configurado en las variables de entorno");
  }
  
  return jwt.sign(
    { id: userId },
    process.env.JWT_SECRET,
    { expiresIn: "7d" }
  );
};

/**
 * Genera un token JWT para activación/reset (encapsula otro token)
 * Usado para tokens de activación de cuenta
 * @param {string} payload - Token o dato a encapsular
 * @returns {string} Token JWT
 */
export const generateActivationToken = (payload) => {
  if (!process.env.JWT_SECRET) {
    throw new Error("JWT_SECRET no está configurado en las variables de entorno");
  }
  
  return jwt.sign(
    { token: payload },
    process.env.JWT_SECRET,
    { expiresIn: "7d" }
  );
};

/**
 * Genera un token aleatorio sin cifrar (hex)
 * Usado para reset de contraseña y otros propósitos
 * @param {number} bytes - Número de bytes aleatorios (default: 32)
 * @returns {string} Token hexadecimal
 */
export const generateRandomToken = (bytes = 32) => {
  return crypto.randomBytes(bytes).toString("hex");
};

/**
 * Verifica y decodifica un token JWT
 * @param {string} token - Token JWT a verificar
 * @returns {object} Payload del token
 */
export const verifyToken = (token) => {
  if (!process.env.JWT_SECRET) {
    throw new Error("JWT_SECRET no está configurado en las variables de entorno");
  }
  
  try {
    return jwt.verify(token, process.env.JWT_SECRET);
  } catch (error) {
    throw new Error("Token inválido o expirado");
  }
};
