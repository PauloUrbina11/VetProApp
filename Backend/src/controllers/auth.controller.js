import {   
    registerUser,
    loginUser,
    activateUserWithRole,
    requestPasswordReset,
    resetPassword 
} from "../services/auth.service.js";

export const register = async (req, res) => {
    try {
        const user = await registerUser(req.body);
        return res.status(201).json({ ok: true, user });
    } catch (err) {
        return res.status(400).json({ ok: false, message: err.message });
    }
};

export const activateAccount = async (req, res) => {
        try {
        const token = req.query.token;  // viene por URL
        const { rol_id } = req.body;    // viene por JSON

        if (!token) {
            return res.status(400).json({ ok: false, message: "Token requerido" });
        }

        if (!rol_id) {
            return res.status(400).json({ ok: false, message: "rol_id requerido" });
        }

        const result = await activateUserWithRole(token, rol_id);

        return res.json({
            ok: true,
            ...result
        });

    } catch (error) {
        return res.status(400).json({ ok: false, message: error.message });
    }
};

export const login = async (req, res) => {
    try {
        const token = await loginUser(req.body);
        return res.json({ ok: true, token });
    } catch (err) {
        return res.status(401).json({ ok: false, message: err.message });
    }
};

export const requestPasswordResetController = async (req, res) => {
  try {
    const { correo } = req.body;

    if (!correo) {
      return res.status(400).json({
        ok: false,
        message: "El correo es obligatorio",
      });
    }

    const result = await requestPasswordReset(correo);

    return res.status(200).json({
      ok: true,
      ...result,
    });
  } catch (error) {
    return res.status(400).json({
      ok: false,
      message: error.message,
    });
  }
};


export const resetPasswordController = async (req, res) => {
  try {
    const { token, newPassword } = req.body;

    if (!token || !newPassword) {
      return res.status(400).json({
        ok: false,
        message: "Token y nueva contraseña son obligatorios",
      });
    }

    const result = await resetPassword(token, newPassword);

    return res.status(200).json({
      ok: true,
      ...result,
    });
  } catch (error) {
    return res.status(400).json({
      ok: false,
      message: error.message,
    });
  }
};

// Redirect handler para abrir la app móvil desde un enlace web
export const activateRedirect = async (req, res) => {
  try {
    const token = req.query.token;
    if (!token) {
      return res.status(400).send('Token requerido');
    }

    const appUrl = `vetproapp://activate?token=${encodeURIComponent(token)}`;
    // Redirigir (302) al esquema de la app. En móviles esto abrirá la app si está instalada.
    return res.redirect(appUrl);
  } catch (err) {
    return res.status(500).send('Error procesando el redirect');
  }
};

export const resetRedirect = async (req, res) => {
  try {
    const token = req.query.token;
    if (!token) {
      return res.status(400).send('Token requerido');
    }

    const appUrl = `vetproapp://reset?token=${encodeURIComponent(token)}`;
    return res.redirect(appUrl);
  } catch (err) {
    return res.status(500).send('Error procesando el redirect');
  }
};