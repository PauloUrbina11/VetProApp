import jwt from "jsonwebtoken";

export const authMiddleware = (req, res, next) => {
    const token = req.headers["authorization"];

    if (!token) {
        return res.status(401).json({
            ok: false,
            message: "Token no enviado"
        });
    }

    try {
        const cleanToken = token.replace("Bearer ", "");
        const decoded = jwt.verify(cleanToken, process.env.JWT_SECRET);

        // Agregar info del usuario al request
        req.user = decoded;

        next(); // continuar a la ruta
    } catch (err) {
        return res.status(401).json({
            ok: false,
            message: "Token inválido o expirado"
        });
    }
};
