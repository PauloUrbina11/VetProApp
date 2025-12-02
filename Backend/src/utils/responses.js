/**
 * Utilidades para respuestas HTTP estandarizadas
 */

/**
 * Respuesta exitosa estándar
 * @param {object} res - Objeto response de Express
 * @param {object} data - Datos a devolver
 * @param {number} statusCode - Código HTTP (default: 200)
 */
export const sendSuccess = (res, data = {}, statusCode = 200) => {
  return res.status(statusCode).json({
    ok: true,
    ...data,
  });
};

/**
 * Respuesta de error estándar
 * @param {object} res - Objeto response de Express
 * @param {string} message - Mensaje de error
 * @param {number} statusCode - Código HTTP (default: 400)
 */
export const sendError = (res, message, statusCode = 400) => {
  return res.status(statusCode).json({
    ok: false,
    message,
  });
};

/**
 * Manejador de errores para controladores async
 * @param {Function} fn - Función async del controlador
 */
export const asyncHandler = (fn) => {
  return (req, res, next) => {
    Promise.resolve(fn(req, res, next)).catch((error) => {
      console.error('Error en controlador:', error);
      sendError(res, error.message || 'Error interno del servidor', 500);
    });
  };
};

/**
 * Respuesta de creación exitosa (201)
 */
export const sendCreated = (res, data = {}) => {
  return sendSuccess(res, data, 201);
};

/**
 * Respuesta sin contenido (204)
 */
export const sendNoContent = (res) => {
  return res.status(204).send();
};
