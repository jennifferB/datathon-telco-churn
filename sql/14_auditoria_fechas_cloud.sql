-- Solo lectura. Ejecutar cada bloque por separado en SingleStore Cloud.
-- Audita fechas de registros cargados; no registra fallos de ejecuciones.
-- Mantener la zona horaria de la sesión documentada al comparar fechas.

-- BLOQUE 1. Cobertura del calendario.
-- Con el generador corregido: 36525 fechas únicas, 2000-01-01 a 2099-12-31.
SELECT COUNT(*) AS fechas,
    COUNT(DISTINCT fecha) AS fechas_distintas,
    MIN(fecha) AS primera_fecha,
    MAX(fecha) AS ultima_fecha
FROM telco_g2.dim_fecha_telco_g2;

-- BLOQUE 2. Registros por etapa, lote y día técnico.
-- Raw no tiene load_id: se informa NULL, sin inventar una relación por lote.
-- Una fecha sin correspondencia se conserva con LEFT JOIN y queda señalada.
WITH registros AS (
    SELECT 'raw' AS etapa, CAST(NULL AS CHAR(36)) AS load_id,
        DATE(fecha_carga) AS fecha_tecnica, 0 AS imputado
    FROM telco_g2.raw_telco_g2
    UNION ALL
    SELECT 'staging', load_id, DATE(fecha_staging), total_charges_imputed
    FROM telco_g2.stg_telco_g2
    UNION ALL
    SELECT 'rechazos', load_id, DATE(fecha_rechazo), 0
    FROM telco_g2.rejects_telco_g2
)
SELECT r.etapa, r.load_id, r.fecha_tecnica,
    d.anio, d.trimestre, d.mes, d.dia_semana, d.es_fin_semana,
    COUNT(*) AS registros,
    SUM(r.imputado) AS imputaciones,
    SUM(CASE WHEN r.fecha_tecnica IS NULL THEN 1 ELSE 0 END) AS sin_fecha,
    SUM(CASE WHEN r.fecha_tecnica IS NOT NULL AND d.fecha IS NULL
             THEN 1 ELSE 0 END) AS fuera_del_calendario
FROM registros r
LEFT JOIN telco_g2.dim_fecha_telco_g2 d ON d.fecha = r.fecha_tecnica
GROUP BY r.etapa, r.load_id, r.fecha_tecnica,
    d.anio, d.trimestre, d.mes, d.dia_semana, d.es_fin_semana
ORDER BY r.fecha_tecnica, r.etapa, r.load_id;

-- Si rechazos está vacía, no aparece una fila de esa etapa en el bloque 2.
-- DAYOFWEEK en el calendario: 1=domingo, 2=lunes, ..., 7=sábado.
-- Los conteos corresponden a filas presentes, no a intentos de ejecución.
