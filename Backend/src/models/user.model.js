import { pool } from "../config/database.js";

export const createUserDB = async (data) => {
    const {
        nombre_completo,
        correo,
        password_hash,
        direccion,
        ciudad_id,
        departamento_id,
        celular
    } = data;

    const query = `
        INSERT INTO users 
            (nombre_completo, correo, password_hash, direccion, ciudad_id, departamento_id, celular, ultimo_cambio_contrasena)
        VALUES ($1,$2,$3,$4,$5,$6,$7, NOW())
        RETURNING id, nombre_completo, correo;
    `;

    const values = [
        nombre_completo,
        correo,
        password_hash,
        direccion,
        ciudad_id,
        departamento_id,
        celular
    ];

    const result = await pool.query(query, values);
    return result.rows[0];
};

export const findUserByEmail = async (correo) => {
    const query = `SELECT * FROM users WHERE correo = $1`;
    const result = await pool.query(query, [correo]);
    return result.rows[0];
};


export const saveTokenActivation = async (correo, token) => {
    const query = `
        UPDATE users
        SET 
            activation_token = $2,
            activation_token_expira = NOW() + INTERVAL '5 days'
        WHERE correo = $1
        RETURNING id, correo, activation_token, activation_token_expira;
    `;

    const values = [correo, token];

    const result = await pool.query(query, values);
    return result.rows[0];
};

export const findUserByActivationToken = async (token) => {
    const query = `
        SELECT *
        FROM users
        WHERE activation_token = $1
          AND activation_token_expira > NOW()
        LIMIT 1;
    `;
    const result = await pool.query(query, [token]);
    return result.rows[0];
};

export const activateUserByTokenDB = async (token) => {
    const query = `
        UPDATE users
        SET 
            activation_token = NULL,
            activation_token_expira = NULL,
            activo = TRUE,
            activado_en = NOW()
        WHERE activation_token = $1
        RETURNING id, correo, activo, activado_en;
    `;

    const result = await pool.query(query, [token]);
    return result.rows[0];
};

export const registerFailedAttempt = async (correo) => {
    // Subir contador
    const update = `
        UPDATE users
        SET 
            ultimo_intento_ingreso = NOW(),
            intentos_fallidos = intentos_fallidos + 1
        WHERE correo = $1
        RETURNING intentos_fallidos;
    `;
    
    const result = await pool.query(update, [correo]);
    
    // Si el usuario no existe, no hay rows
    if (result.rows.length === 0) {
        return 0;
    }
    
    const fails = result.rows[0].intentos_fallidos;

    // Si llega a 5 → bloquear
    if (fails >= 5) {
        const lockUser = `
            UPDATE users
            SET activo = FALSE
            WHERE correo = $1;
        `;
        await pool.query(lockUser, [correo]);
    }

    return fails;
};

export const registerSuccessfulLogin = async (correo) => {
    const query = `
        UPDATE users
        SET 
            ultimo_ingreso = NOW(),
            ultimo_intento_ingreso = NOW(),
            intentos_fallidos = 0
        WHERE correo = $1;
    `;
    await pool.query(query, [correo]);
};

export const saveResetToken = async (correo, token) => {
    const query = `
        UPDATE users
        SET 
            reset_token = $2,
            reset_token_expira = NOW() + INTERVAL '5 days'
        WHERE correo = $1
        RETURNING id, correo;
    `;
    const result = await pool.query(query, [correo, token]);
    return result.rows[0];
};

export const findUserByResetToken = async (token) => {
    const query = `
        SELECT * FROM users
        WHERE reset_token = $1
    `;
    const result = await pool.query(query, [token]);
    return result.rows[0];
};

export const updatePassword = async (id, newHashedPassword) => {
    const query = `
        UPDATE users
        SET 
            password_hash = $2,
            ultimo_cambio_contrasena = NOW(),
            reset_token = NULL,
            reset_token_expira = NULL,
            activo = TRUE,
            intentos_fallidos = 0
        WHERE id = $1
        RETURNING id, correo;
    `;
    const result = await pool.query(query, [id, newHashedPassword]);
    return result.rows[0];
};

// Obtener perfil por id (datos básicos para edición)
export const getUserById = async (id) => {
    const query = `
        SELECT id, nombre_completo, correo, celular, direccion, departamento_id, ciudad_id
        FROM users
        WHERE id = $1
        LIMIT 1;
    `;
    const result = await pool.query(query, [id]);
    return result.rows[0];
};

// Actualizar perfil (sin contraseña)
export const updateUserProfileDB = async (id, data) => {
    const allowed = [
        'nombre_completo',
        'celular',
        'direccion',
        'departamento_id',
        'ciudad_id'
    ];

    const setParts = [];
    const values = [];
    let idx = 1;

    for (const key of allowed) {
        if (Object.prototype.hasOwnProperty.call(data, key)) {
            setParts.push(`${key} = $${idx}`);
            values.push(data[key]);
            idx++;
        }
    }

    if (setParts.length === 0) {
        // nada que actualizar
        return getUserById(id);
    }

    const query = `
        UPDATE users
        SET ${setParts.join(', ')}
        WHERE id = $${idx}
        RETURNING id, nombre_completo, correo, celular, direccion, departamento_id, ciudad_id;
    `;
    values.push(id);
    const result = await pool.query(query, values);
    return result.rows[0];
};

