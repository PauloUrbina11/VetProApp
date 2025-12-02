/**
 * Middleware para validación de datos de entrada
 */

/**
 * Middleware genérico para validar body de requests
 * @param {Function} validator - Función validadora que lanza error si falla
 */
export const validateBody = (validator) => {
  return (req, res, next) => {
    try {
      validator(req.body);
      next();
    } catch (error) {
      return res.status(400).json({
        ok: false,
        message: error.message,
      });
    }
  };
};

/**
 * Middleware para validar campos requeridos en el body
 * @param {Array<string>} fields - Array de nombres de campos requeridos
 */
export const requireFields = (fields) => {
  return (req, res, next) => {
    const missing = [];
    
    for (const field of fields) {
      if (!req.body[field]) {
        missing.push(field);
      }
    }
    
    if (missing.length > 0) {
      return res.status(400).json({
        ok: false,
        message: `Campos requeridos faltantes: ${missing.join(', ')}`,
      });
    }
    
    next();
  };
};

/**
 * Middleware para validar parámetros de query
 * @param {Array<string>} params - Array de nombres de parámetros requeridos
 */
export const requireQueryParams = (params) => {
  return (req, res, next) => {
    const missing = [];
    
    for (const param of params) {
      if (!req.query[param]) {
        missing.push(param);
      }
    }
    
    if (missing.length > 0) {
      return res.status(400).json({
        ok: false,
        message: `Parámetros requeridos faltantes: ${missing.join(', ')}`,
      });
    }
    
    next();
  };
};
