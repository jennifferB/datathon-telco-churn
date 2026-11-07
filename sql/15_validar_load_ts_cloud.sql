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
