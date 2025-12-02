-- Script para agregar coordenadas de ejemplo a las veterinarias
-- Estas son coordenadas de ejemplo en Tegucigalpa, Honduras
-- Debes reemplazarlas con las coordenadas reales de cada veterinaria

-- Ejemplo: Actualizar veterinarias con coordenadas de ubicaciones en Tegucigalpa
-- Puedes obtener las coordenadas reales usando Google Maps:
-- 1. Busca la dirección en Google Maps
-- 2. Click derecho en el marcador
-- 3. Click en las coordenadas para copiarlas
-- 4. Formato: latitud, longitud

-- Veterinaria 1 - Zona Centro
UPDATE veterinarias 
SET latitud = 14.0818, 
    longitud = -87.2068 
WHERE id = 1;

-- Veterinaria 2 - Zona Norte
UPDATE veterinarias 
SET latitud = 14.0950, 
    longitud = -87.1850 
WHERE id = 2;

-- Veterinaria 3 - Zona Sur
UPDATE veterinarias 
SET latitud = 14.0650, 
    longitud = -87.2150 
WHERE id = 3;

-- Veterinaria 4 - Zona Este
UPDATE veterinarias 
SET latitud = 14.0780, 
    longitud = -87.1950 
WHERE id = 4;

-- Veterinaria 5 - Zona Oeste
UPDATE veterinarias 
SET latitud = 14.0880, 
    longitud = -87.2200 
WHERE id = 5;

-- Verificar las actualizaciones
SELECT id, nombre, direccion, latitud, longitud 
FROM veterinarias 
WHERE latitud IS NOT NULL 
ORDER BY id;

-- Nota: Para agregar coordenadas reales:
-- 1. Identifica la ID de cada veterinaria
-- 2. Busca su dirección en Google Maps
-- 3. Obtén las coordenadas (latitud, longitud)
-- 4. Ejecuta: UPDATE veterinarias SET latitud = XX.XXXX, longitud = -XX.XXXX WHERE id = ?;
