-- Ejecutar los bloques por separado en la conexión telco_g2.

-- 1. Comparar el reloj de la sesión con UTC y con Ecuador continental.
SELECT NOW() AS hora_servidor,
       UTC_TIMESTAMP() AS hora_utc,
       DATE_SUB(UTC_TIMESTAMP(), INTERVAL 5 HOUR) AS hora_ecuador;

-- 2. Confirmar qué columnas de auditoría existen en el modelo.
SELECT table_name, column_name, column_type, is_nullable, column_default, extra
FROM information_schema.columns
WHERE table_schema = 'telco_g2'
  AND table_name IN (
      'dim_customer_telco_g2', 'dim_contract_telco_g2',
      'dim_service_telco_g2', 'fact_contracts_telco_g2'
  )
  AND column_name IN ('load_ts', 'load_source')
ORDER BY table_name, column_name;

-- 3. Ejecutar cuando las dos columnas existan en hechos.
-- Un timestamp existente puede venir de DEFAULT o de ON UPDATE.
-- Comprobar su procedencia antes de atribuirlo a la carga histórica.
SELECT COUNT(*) AS hechos,
       COUNT(DISTINCT customer_key) AS clientes_distintos,
       COUNT(CASE WHEN load_ts IS NULL THEN 1 END) AS sin_load_ts,
       COUNT(CASE WHEN load_source IS NULL OR TRIM(load_source) = '' THEN 1 END) AS sin_load_source,
       MIN(load_ts) AS primer_load_ts,
       MAX(load_ts) AS ultimo_load_ts
FROM telco_g2.fact_contracts_telco_g2;

-- 4. Identificar el lote de staging y el origen registrado por grupo.
SELECT source_load_id,
       NULLIF(TRIM(load_source), '') AS origen,
       COUNT(*) AS hechos,
       COUNT(load_ts) AS con_load_ts,
       MIN(load_ts) AS primer_load_ts,
       MAX(load_ts) AS ultimo_load_ts
FROM telco_g2.fact_contracts_telco_g2
GROUP BY source_load_id, NULLIF(TRIM(load_source), '')
ORDER BY source_load_id, origen;

-- 5. Conciliar los lotes de hechos con staging antes de completar auditoría.
-- Las fechas de staging sirven para ubicar el lote en el log de Talend.
WITH hechos_por_lote AS (
    SELECT source_load_id, COUNT(*) AS hechos
    FROM telco_g2.fact_contracts_telco_g2
    GROUP BY source_load_id
), staging_por_lote AS (
    SELECT load_id,
           COUNT(*) AS filas_staging,
           COUNT(DISTINCT customerID) AS clientes_staging,
           MIN(fecha_staging) AS primera_fecha_staging,
           MAX(fecha_staging) AS ultima_fecha_staging
    FROM telco_g2.stg_telco_g2
    GROUP BY load_id
)
SELECT h.source_load_id, h.hechos,
       s.filas_staging, s.clientes_staging,
       s.primera_fecha_staging, s.ultima_fecha_staging
FROM hechos_por_lote h
LEFT JOIN staging_por_lote s ON s.load_id = h.source_load_id
ORDER BY h.source_load_id;

-- 6. Verificar si staging registra el origen explícitamente.
SELECT column_name, column_type
FROM information_schema.columns
WHERE table_schema = 'telco_g2'
  AND table_name = 'stg_telco_g2'
  AND column_name IN ('load_id', 'fecha_staging', 'load_source', 'load_ts')
ORDER BY column_name;

-- 7. Verificar que el origen heredado de staging sea completo y único por lote.
WITH lotes_en_hechos AS (
    SELECT DISTINCT source_load_id
    FROM telco_g2.fact_contracts_telco_g2
)
SELECT h.source_load_id,
       COUNT(s.load_id) AS filas_staging,
       COUNT(NULLIF(TRIM(s.load_source), '')) AS filas_con_origen,
       COUNT(DISTINCT NULLIF(TRIM(s.load_source), '')) AS origenes_distintos,
       CASE
           WHEN COUNT(s.load_id) > 0
            AND COUNT(NULLIF(TRIM(s.load_source), '')) = COUNT(s.load_id)
            AND COUNT(DISTINCT NULLIF(TRIM(s.load_source), '')) = 1
           THEN MIN(NULLIF(TRIM(s.load_source), ''))
       END AS origen_verificado
FROM lotes_en_hechos h
LEFT JOIN telco_g2.stg_telco_g2 s ON s.load_id = h.source_load_id
GROUP BY h.source_load_id
ORDER BY h.source_load_id;

-- 8. Generar DDL para conservar las fechas previas y crear el campo local.
-- Respaldar las tablas y revisar los consumidores de load_ts antes de ejecutar el DDL.
-- Ejecutar cada sentencia generada por separado y en el orden indicado.
-- Copiar al nuevo campo solo las fechas con zona horaria de origen comprobada.

WITH columnas AS (
    SELECT table_name,
           MAX(CASE WHEN column_name = 'load_ts' THEN data_type END) AS tipo_actual,
           MAX(CASE WHEN column_name = 'load_ts_anterior' THEN 1 ELSE 0 END) AS tiene_anterior
    FROM information_schema.columns
    WHERE table_schema = 'telco_g2'
      AND table_name IN ('dim_customer_telco_g2', 'dim_contract_telco_g2',
                         'dim_service_telco_g2', 'fact_contracts_telco_g2')
    GROUP BY table_name
), instrucciones AS (
    SELECT table_name, 1 AS paso,
           CONCAT('ALTER TABLE telco_g2.', table_name, ' CHANGE load_ts load_ts_anterior;') AS sentencia
    FROM columnas
    WHERE tipo_actual = 'timestamp' AND tiene_anterior = 0
    UNION ALL
    SELECT table_name, 2,
           CONCAT('ALTER TABLE telco_g2.', table_name, ' ADD COLUMN load_ts DATETIME NULL;')
    FROM columnas
    WHERE (tipo_actual = 'timestamp' AND tiene_anterior = 0)
       OR (tipo_actual IS NULL AND tiene_anterior = 1)
)
SELECT table_name, paso, sentencia
FROM instrucciones
ORDER BY table_name, paso;

-- 9. Confirmar que el esquema está listo y generar el reinicio de las siete tablas.
-- Este SELECT no ejecuta TRUNCATE. Revisar las siete sentencias y ejecutarlas
-- por separado, en orden, únicamente para la prueba de recarga acordada.
WITH destinos AS (
    SELECT 1 AS paso, 'fact_contracts_telco_g2' AS tabla
    UNION ALL SELECT 2, 'dim_service_telco_g2'
    UNION ALL SELECT 3, 'dim_contract_telco_g2'
    UNION ALL SELECT 4, 'dim_customer_telco_g2'
    UNION ALL SELECT 5, 'rejects_telco_g2'
    UNION ALL SELECT 6, 'stg_telco_g2'
    UNION ALL SELECT 7, 'raw_telco_g2'
), existentes AS (
    SELECT COUNT(*) AS tablas
    FROM information_schema.tables t
    JOIN destinos d ON d.tabla = t.table_name
    WHERE t.table_schema = 'telco_g2' AND t.table_type = 'BASE TABLE'
), auditoria AS (
    SELECT
        COUNT(CASE WHEN c.column_name = 'load_ts' AND c.data_type = 'datetime'
                         AND c.column_default IS NULL
                         AND LOWER(COALESCE(c.extra, '')) NOT LIKE '%on update%' THEN 1 END) AS fechas,
        COUNT(CASE WHEN c.column_name = 'load_source' AND c.data_type = 'varchar'
                         AND c.character_maximum_length >= 100 THEN 1 END) AS origenes
    FROM information_schema.columns c
    JOIN destinos d ON d.tabla = c.table_name AND d.paso <= 4
    WHERE c.table_schema = 'telco_g2'
)
SELECT d.paso, CONCAT('TRUNCATE TABLE telco_g2.', d.tabla, ';') AS sentencia
FROM destinos d
CROSS JOIN existentes e
CROSS JOIN auditoria a
WHERE e.tablas = 7 AND a.fechas = 4 AND a.origenes = 4
ORDER BY d.paso;

-- 10. Tras la recarga, comparar la auditoría de hechos con el contexto y la hora del Run.
SELECT COUNT(*) AS hechos,
       COUNT(*) - COUNT(load_ts) AS sin_fecha,
       COUNT(*) - COUNT(NULLIF(TRIM(load_source), '')) AS sin_origen,
       COUNT(DISTINCT NULLIF(TRIM(load_source), '')) AS origenes_distintos,
       MIN(load_source) AS origen,
       MIN(load_ts) AS primera_carga_ecuador,
       MAX(load_ts) AS ultima_carga_ecuador,
       DATE_SUB(UTC_TIMESTAMP(), INTERVAL 5 HOUR) AS hora_ecuador
FROM telco_g2.fact_contracts_telco_g2;
