import { 
    createUserDB, 
    findUserByEmail, 
    saveTokenActivation,
    activateUserByTokenDB,
    findUserByActivationToken,
    registerFailedAttempt, 
    registerSuccessfulLogin,
    findUserByResetToken,
    saveResetToken,
    updatePassword
} from "../models/user.model.js";
import { assignRoleToUser, getUserRole } from "../models/role.model.js";
import { hashPassword, comparePassword } from "../utils/passwordHash.js";
import { 
  generateJWT, 
  generateActivationToken, 
  generateRandomToken 
} from "../utils/tokens.js";
import { sendActivationEmail, sendResetEmail } from "../utils/emailService.js";
import { validateRegisterData, validateLoginData } from "../validators/auth.validator.js";
import { createNotification } from "../models/notifications.model.js";
import { pool } from "../config/database.js";


// -------------------------------------------------------------
// REGISTRO DE USUARIO
// -------------------------------------------------------------
export const registerUser = async (data) => {
    // Validar datos de entrada
    validateRegisterData(data);

    const existing = await findUserByEmail(data.correo);
    if (existing) throw new Error("El correo ya está registrado");

    const hashed = await hashPassword(data.password);

    const newUser = await createUserDB({
        ...data,
        password_hash: hashed,
    });

    // Generar token de activación
    const token = generateActivationToken(newUser.id);

    // 5. Guardar token en BD
    await saveTokenActivation(newUser.correo, token);

        // 5.b Enviar correo de activación (para pruebas se envía a paurbi_1101@hotmail.com)
        try {
            await sendActivationEmail(newUser.correo, token);
        } catch (err) {
            console.error('Error al intentar enviar email de activación:', err.message || err);
        }

    // 6. Respuesta
    return {
        ok: true,
        message: "Usuario registrado. Revisa tu correo para activar la cuenta.",
        user: {
            id: newUser.id,
            correo: newUser.correo,
        },
        activation_token: token // temporal mientras no usamos emails
    };
};

// -------------------------------------------------------------
// ACTIVACIÓN DE USUARIO POR TOKEN
// -------------------------------------------------------------
export const activateUserWithRole = async (token, rol_id) => {
    
    // Buscar usuario por token
    const user = await findUserByActivationToken(token);
    if (!user) throw new Error("Token inválido o expirado");

    // Activar usuario
    const updatedUser = await activateUserByTokenDB(token);

    // Asignar rol indicado por el front
    await assignRoleToUser(updatedUser.id, rol_id);

    // No se notifica el registro de nuevos usuarios

    return {
        message: "Cuenta activada correctamente",
        user: updatedUser,
        assigned_role: rol_id
    };
};

// --------------------------------------------------------------------------------
// LOGIN DE USUARIO
// --------------------------------------------------------------------------------
export const loginUser = async ({ correo, password }) => {
    // Validar datos de entrada
    validateLoginData({ correo, password });

    const user = await findUserByEmail(correo);
    if (!user) {
        await registerFailedAttempt(correo);
        throw new Error("Usuario no encontrado");
    }

    if (!user.activo) {
        throw new Error("La cuenta está bloqueada o no ha sido activada.");
    }

    const valid = await comparePassword(password, user.password_hash);
    if (!valid) {
        const fails = await registerFailedAttempt(correo);
        throw new Error(`Contraseña incorrecta. Intento ${fails}/5`);
    }

    // si estamos aquí → login exitoso
    await registerSuccessfulLogin(correo);

    const tokenJWT = generateJWT(user.id);
    const rol_id = await getUserRole(user.id);

    return {
        message: "Login exitoso",
        tokenJWT,
        user: {
            id: user.id,
            correo: user.correo,
            rol_id: rol_id
        }
    };
};

export const requestPasswordReset = async (correo) => {
    const user = await findUserByEmail(correo);
    if (!user) throw new Error("Correo no encontrado");

    // si nunca activó su cuenta
    if (!user.activado_en && !user.activo) {
        throw new Error("La cuenta nunca ha sido activada.");
    }

    // Generar token único
    const token = generateRandomToken();

    // Guardar token en BD
    await saveResetToken(correo, token);
    // Intentar enviar correo de reset (si SMTP está configurado se enviará)
    try {
        await sendResetEmail(correo, token);
    } catch (err) {
        console.error('Error al intentar enviar email de reset:', err.message || err);
    }

    return {
        message: "Se ha enviado un enlace para restablecer tu contraseña.",
        token // temporal hasta configurar email
    };
};

export const resetPassword = async (token, newPassword) => {
    const user = await findUserByResetToken(token);
    if (!user) throw new Error("Token inválido");

    // token expirado
    if (user.reset_token_expira < new Date()) {
        throw new Error("El token ha expirado");
    }

    const hashed = await hashPassword(newPassword);

    // actualizar contraseña y activar el usuario
    const result = await updatePassword(user.id, hashed);

    return {
        message: "Contraseña actualizada correctamente.",
        user: result
    };
};