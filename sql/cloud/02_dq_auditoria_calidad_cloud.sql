-- Adaptacion de solo lectura a SingleStore Cloud, 2026-11-06.
-- Conserva los controles originales. No representa una ejecucion nueva.
-- Ejecutar cada sentencia o bloque por separado, con telco_g2 seleccionada.
-- AUDITORIA INICIAL TELCO RAW — SOLO LECTURA
-- Tabla real: telco_g2.raw_telco_g2. Importes almacenados en VARCHAR(20).
-- Raw conserva 11 blancos del CSV; la imputacion corresponde a la capa posterior.
-- Rango DQ-03: 18-120 inclusivo, alineado con README y prueba OpenMetadata.
-- No cambia datos, pruebas ni umbrales en el catalogo.
-- Porcentajes por regla; no se declara una calidad global por promedio.
USE telco_g2;

-- 1. Resumen de calidad: formato validado antes de la conversion numerica.
WITH datos AS (
    SELECT customerID, TotalCharges, Contract, Churn,
           TRIM(MonthlyCharges) AS monthly_text
    FROM telco_g2.raw_telco_g2
), numericos AS (
    SELECT *,
        CASE WHEN monthly_text REGEXP '^[0-9]+([.][0-9]{1,2})?$'
             THEN CAST(monthly_text AS DECIMAL(30,2)) ELSE NULL END
             AS monthly_value
    FROM datos
)
SELECT COUNT(*) AS total_registros,
    ROUND(COUNT(DISTINCT customerID)*100.0/NULLIF(COUNT(*),0),2)
        AS pct_unicidad_customerID,
    ROUND(COALESCE(SUM(CASE WHEN customerID IS NOT NULL
        AND TRIM(customerID) <> '' THEN 1 ELSE 0 END),0)
        *100.0/NULLIF(COUNT(*),0),2) AS pct_completitud_customerID,
    COALESCE(SUM(CASE WHEN TotalCharges IS NULL THEN 1 ELSE 0 END),0)
        AS totalcharges_nulos,
    COALESCE(SUM(CASE WHEN TotalCharges IS NOT NULL
        AND TRIM(TotalCharges) = '' THEN 1 ELSE 0 END),0)
        AS totalcharges_blancos,
    ROUND(COALESCE(SUM(CASE WHEN TotalCharges IS NOT NULL
        AND TRIM(TotalCharges) <> '' THEN 1 ELSE 0 END),0)
        *100.0/NULLIF(COUNT(*),0),2) AS pct_completitud_TotalCharges,
    ROUND(COALESCE(SUM(CASE WHEN monthly_value BETWEEN 18 AND 120
        THEN 1 ELSE 0 END),0)*100.0/NULLIF(COUNT(*),0),2)
        AS pct_rango_MonthlyCharges,
    ROUND(COALESCE(SUM(CASE WHEN Contract IN
        ('Month-to-month','One year','Two year') THEN 1 ELSE 0 END),0)
        *100.0/NULLIF(COUNT(*),0),2) AS pct_validez_Contract,
    ROUND(COALESCE(SUM(CASE WHEN Churn IN ('Yes','No')
        THEN 1 ELSE 0 END),0)*100.0/NULLIF(COUNT(*),0),2)
        AS pct_validez_Churn
FROM numericos;
-- Referencia del archivo evaluado: 7043 filas; 11 blancos; 0 NULL
-- en TotalCharges; completitud 99.84%. No son constantes para futuras cargas.

-- 2. Duplicados y faltantes de identificador: esperado cero filas.
SELECT customerID, COUNT(*) AS repeticiones
FROM telco_g2.raw_telco_g2
GROUP BY customerID
HAVING COUNT(*) > 1 OR customerID IS NULL OR TRIM(customerID) = '';

-- 3. Blancos o NULL de TotalCharges: raw debe conservar los 11 casos
-- conocidos de este CSV, todos con tenure=0. No imputar aqui.
SELECT customerID, tenure, MonthlyCharges, TotalCharges
FROM telco_g2.raw_telco_g2
WHERE TotalCharges IS NULL OR TRIM(TotalCharges) = ''
ORDER BY customerID;

-- 4. MonthlyCharges: incluir faltantes, formato invalido y fuera de rango.
WITH conversion AS (
    SELECT customerID, MonthlyCharges,
        CASE WHEN TRIM(MonthlyCharges) REGEXP '^[0-9]+([.][0-9]{1,2})?$'
             THEN CAST(TRIM(MonthlyCharges) AS DECIMAL(30,2))
             ELSE NULL END AS monthly_value
    FROM telco_g2.raw_telco_g2
)
SELECT customerID, MonthlyCharges, monthly_value
FROM conversion
WHERE monthly_value IS NULL OR monthly_value < 18 OR monthly_value > 120;
-- Esperado cero filas para el archivo evaluado.

-- 5. Contratos invalidos: esperado cero filas, incluyendo NULL.
SELECT customerID, Contract
FROM telco_g2.raw_telco_g2
WHERE Contract IS NULL
   OR Contract NOT IN ('Month-to-month','One year','Two year');

-- 6. Categorias invalidas del target: esperado cero filas.
SELECT customerID, Churn
FROM telco_g2.raw_telco_g2
WHERE Churn IS NULL OR Churn NOT IN ('Yes','No');

-- 7. Distribucion del target (descriptiva; no es un test de validez).
SELECT Churn, COUNT(*) AS cantidad_clientes,
    ROUND(COUNT(*)*100.0 /
        NULLIF((SELECT COUNT(*) FROM telco_g2.raw_telco_g2),0),2)
        AS porcentaje
FROM telco_g2.raw_telco_g2
GROUP BY Churn;
