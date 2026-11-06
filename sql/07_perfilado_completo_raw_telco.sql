-- PERFILADO RAW TELCO — SOLO LECTURA
-- Basado en SHOW CREATE TABLE proporcionado por el equipo: 22 columnas.
-- No modifica datos. Ejecutar cada bloque por separado en DBeaver.

-- BLOQUE 1: Completitud, blancos y valores distintos por columna.
SELECT 'customerID' AS columna,
       COUNT(*) AS total_filas,
       COUNT(*) - COUNT(`customerID`) AS nulos,
       COALESCE(SUM(CASE WHEN `customerID` IS NOT NULL
                         AND TRIM(CAST(`customerID` AS CHAR)) = ''
                        THEN 1 ELSE 0 END), 0) AS blancos,
       COUNT(DISTINCT `customerID`) AS valores_distintos,
       ROUND(100.0 * COALESCE(SUM(CASE WHEN `customerID` IS NOT NULL
                            AND TRIM(CAST(`customerID` AS CHAR)) <> ''
                           THEN 1 ELSE 0 END), 0)
             / NULLIF(COUNT(*), 0), 2) AS completitud_pct
FROM DSADEV.raw_telco_g2
UNION ALL
SELECT 'gender' AS columna,
       COUNT(*) AS total_filas,
       COUNT(*) - COUNT(`gender`) AS nulos,
       COALESCE(SUM(CASE WHEN `gender` IS NOT NULL
                         AND TRIM(CAST(`gender` AS CHAR)) = ''
                        THEN 1 ELSE 0 END), 0) AS blancos,
       COUNT(DISTINCT `gender`) AS valores_distintos,
       ROUND(100.0 * COALESCE(SUM(CASE WHEN `gender` IS NOT NULL
                            AND TRIM(CAST(`gender` AS CHAR)) <> ''
                           THEN 1 ELSE 0 END), 0)
             / NULLIF(COUNT(*), 0), 2) AS completitud_pct
FROM DSADEV.raw_telco_g2
UNION ALL
SELECT 'SeniorCitizen' AS columna,
       COUNT(*) AS total_filas,
       COUNT(*) - COUNT(`SeniorCitizen`) AS nulos,
       COALESCE(SUM(CASE WHEN `SeniorCitizen` IS NOT NULL
                         AND TRIM(CAST(`SeniorCitizen` AS CHAR)) = ''
                        THEN 1 ELSE 0 END), 0) AS blancos,
       COUNT(DISTINCT `SeniorCitizen`) AS valores_distintos,
       ROUND(100.0 * COALESCE(SUM(CASE WHEN `SeniorCitizen` IS NOT NULL
                            AND TRIM(CAST(`SeniorCitizen` AS CHAR)) <> ''
                           THEN 1 ELSE 0 END), 0)
             / NULLIF(COUNT(*), 0), 2) AS completitud_pct
FROM DSADEV.raw_telco_g2
UNION ALL
SELECT 'Partner' AS columna,
       COUNT(*) AS total_filas,
       COUNT(*) - COUNT(`Partner`) AS nulos,
       COALESCE(SUM(CASE WHEN `Partner` IS NOT NULL
                         AND TRIM(CAST(`Partner` AS CHAR)) = ''
                        THEN 1 ELSE 0 END), 0) AS blancos,
       COUNT(DISTINCT `Partner`) AS valores_distintos,
       ROUND(100.0 * COALESCE(SUM(CASE WHEN `Partner` IS NOT NULL
                            AND TRIM(CAST(`Partner` AS CHAR)) <> ''
                           THEN 1 ELSE 0 END), 0)
             / NULLIF(COUNT(*), 0), 2) AS completitud_pct
FROM DSADEV.raw_telco_g2
UNION ALL
SELECT 'Dependents' AS columna,
       COUNT(*) AS total_filas,
       COUNT(*) - COUNT(`Dependents`) AS nulos,
       COALESCE(SUM(CASE WHEN `Dependents` IS NOT NULL
                         AND TRIM(CAST(`Dependents` AS CHAR)) = ''
                        THEN 1 ELSE 0 END), 0) AS blancos,
       COUNT(DISTINCT `Dependents`) AS valores_distintos,
       ROUND(100.0 * COALESCE(SUM(CASE WHEN `Dependents` IS NOT NULL
                            AND TRIM(CAST(`Dependents` AS CHAR)) <> ''
                           THEN 1 ELSE 0 END), 0)
             / NULLIF(COUNT(*), 0), 2) AS completitud_pct
FROM DSADEV.raw_telco_g2
UNION ALL
SELECT 'tenure' AS columna,
       COUNT(*) AS total_filas,
       COUNT(*) - COUNT(`tenure`) AS nulos,
       COALESCE(SUM(CASE WHEN `tenure` IS NOT NULL
                         AND TRIM(CAST(`tenure` AS CHAR)) = ''
                        THEN 1 ELSE 0 END), 0) AS blancos,
       COUNT(DISTINCT `tenure`) AS valores_distintos,
       ROUND(100.0 * COALESCE(SUM(CASE WHEN `tenure` IS NOT NULL
                            AND TRIM(CAST(`tenure` AS CHAR)) <> ''
                           THEN 1 ELSE 0 END), 0)
             / NULLIF(COUNT(*), 0), 2) AS completitud_pct
FROM DSADEV.raw_telco_g2
UNION ALL
SELECT 'PhoneService' AS columna,
       COUNT(*) AS total_filas,
       COUNT(*) - COUNT(`PhoneService`) AS nulos,
       COALESCE(SUM(CASE WHEN `PhoneService` IS NOT NULL
                         AND TRIM(CAST(`PhoneService` AS CHAR)) = ''
                        THEN 1 ELSE 0 END), 0) AS blancos,
       COUNT(DISTINCT `PhoneService`) AS valores_distintos,
       ROUND(100.0 * COALESCE(SUM(CASE WHEN `PhoneService` IS NOT NULL
                            AND TRIM(CAST(`PhoneService` AS CHAR)) <> ''
                           THEN 1 ELSE 0 END), 0)
             / NULLIF(COUNT(*), 0), 2) AS completitud_pct
FROM DSADEV.raw_telco_g2
UNION ALL
SELECT 'MultipleLines' AS columna,
       COUNT(*) AS total_filas,
       COUNT(*) - COUNT(`MultipleLines`) AS nulos,
       COALESCE(SUM(CASE WHEN `MultipleLines` IS NOT NULL
                         AND TRIM(CAST(`MultipleLines` AS CHAR)) = ''
                        THEN 1 ELSE 0 END), 0) AS blancos,
       COUNT(DISTINCT `MultipleLines`) AS valores_distintos,
       ROUND(100.0 * COALESCE(SUM(CASE WHEN `MultipleLines` IS NOT NULL
                            AND TRIM(CAST(`MultipleLines` AS CHAR)) <> ''
                           THEN 1 ELSE 0 END), 0)
             / NULLIF(COUNT(*), 0), 2) AS completitud_pct
FROM DSADEV.raw_telco_g2
UNION ALL
SELECT 'InternetService' AS columna,
       COUNT(*) AS total_filas,
       COUNT(*) - COUNT(`InternetService`) AS nulos,
       COALESCE(SUM(CASE WHEN `InternetService` IS NOT NULL
                         AND TRIM(CAST(`InternetService` AS CHAR)) = ''
                        THEN 1 ELSE 0 END), 0) AS blancos,
       COUNT(DISTINCT `InternetService`) AS valores_distintos,
       ROUND(100.0 * COALESCE(SUM(CASE WHEN `InternetService` IS NOT NULL
                            AND TRIM(CAST(`InternetService` AS CHAR)) <> ''
                           THEN 1 ELSE 0 END), 0)
             / NULLIF(COUNT(*), 0), 2) AS completitud_pct
FROM DSADEV.raw_telco_g2
UNION ALL
SELECT 'OnlineSecurity' AS columna,
       COUNT(*) AS total_filas,
       COUNT(*) - COUNT(`OnlineSecurity`) AS nulos,
       COALESCE(SUM(CASE WHEN `OnlineSecurity` IS NOT NULL
                         AND TRIM(CAST(`OnlineSecurity` AS CHAR)) = ''
                        THEN 1 ELSE 0 END), 0) AS blancos,
       COUNT(DISTINCT `OnlineSecurity`) AS valores_distintos,
       ROUND(100.0 * COALESCE(SUM(CASE WHEN `OnlineSecurity` IS NOT NULL
                            AND TRIM(CAST(`OnlineSecurity` AS CHAR)) <> ''
                           THEN 1 ELSE 0 END), 0)
             / NULLIF(COUNT(*), 0), 2) AS completitud_pct
FROM DSADEV.raw_telco_g2
UNION ALL
SELECT 'OnlineBackup' AS columna,
       COUNT(*) AS total_filas,
       COUNT(*) - COUNT(`OnlineBackup`) AS nulos,
       COALESCE(SUM(CASE WHEN `OnlineBackup` IS NOT NULL
                         AND TRIM(CAST(`OnlineBackup` AS CHAR)) = ''
                        THEN 1 ELSE 0 END), 0) AS blancos,
       COUNT(DISTINCT `OnlineBackup`) AS valores_distintos,
       ROUND(100.0 * COALESCE(SUM(CASE WHEN `OnlineBackup` IS NOT NULL
                            AND TRIM(CAST(`OnlineBackup` AS CHAR)) <> ''
                           THEN 1 ELSE 0 END), 0)
             / NULLIF(COUNT(*), 0), 2) AS completitud_pct
FROM DSADEV.raw_telco_g2
UNION ALL
SELECT 'DeviceProtection' AS columna,
       COUNT(*) AS total_filas,
       COUNT(*) - COUNT(`DeviceProtection`) AS nulos,
       COALESCE(SUM(CASE WHEN `DeviceProtection` IS NOT NULL
                         AND TRIM(CAST(`DeviceProtection` AS CHAR)) = ''
                        THEN 1 ELSE 0 END), 0) AS blancos,
       COUNT(DISTINCT `DeviceProtection`) AS valores_distintos,
       ROUND(100.0 * COALESCE(SUM(CASE WHEN `DeviceProtection` IS NOT NULL
                            AND TRIM(CAST(`DeviceProtection` AS CHAR)) <> ''
                           THEN 1 ELSE 0 END), 0)
             / NULLIF(COUNT(*), 0), 2) AS completitud_pct
FROM DSADEV.raw_telco_g2
UNION ALL
SELECT 'TechSupport' AS columna,
       COUNT(*) AS total_filas,
       COUNT(*) - COUNT(`TechSupport`) AS nulos,
       COALESCE(SUM(CASE WHEN `TechSupport` IS NOT NULL
                         AND TRIM(CAST(`TechSupport` AS CHAR)) = ''
                        THEN 1 ELSE 0 END), 0) AS blancos,
       COUNT(DISTINCT `TechSupport`) AS valores_distintos,
       ROUND(100.0 * COALESCE(SUM(CASE WHEN `TechSupport` IS NOT NULL
                            AND TRIM(CAST(`TechSupport` AS CHAR)) <> ''
                           THEN 1 ELSE 0 END), 0)
             / NULLIF(COUNT(*), 0), 2) AS completitud_pct
FROM DSADEV.raw_telco_g2
UNION ALL
SELECT 'StreamingTV' AS columna,
       COUNT(*) AS total_filas,
       COUNT(*) - COUNT(`StreamingTV`) AS nulos,
       COALESCE(SUM(CASE WHEN `StreamingTV` IS NOT NULL
                         AND TRIM(CAST(`StreamingTV` AS CHAR)) = ''
                        THEN 1 ELSE 0 END), 0) AS blancos,
       COUNT(DISTINCT `StreamingTV`) AS valores_distintos,
       ROUND(100.0 * COALESCE(SUM(CASE WHEN `StreamingTV` IS NOT NULL
                            AND TRIM(CAST(`StreamingTV` AS CHAR)) <> ''
                           THEN 1 ELSE 0 END), 0)
             / NULLIF(COUNT(*), 0), 2) AS completitud_pct
FROM DSADEV.raw_telco_g2
UNION ALL
SELECT 'StreamingMovies' AS columna,
       COUNT(*) AS total_filas,
       COUNT(*) - COUNT(`StreamingMovies`) AS nulos,
       COALESCE(SUM(CASE WHEN `StreamingMovies` IS NOT NULL
                         AND TRIM(CAST(`StreamingMovies` AS CHAR)) = ''
                        THEN 1 ELSE 0 END), 0) AS blancos,
       COUNT(DISTINCT `StreamingMovies`) AS valores_distintos,
       ROUND(100.0 * COALESCE(SUM(CASE WHEN `StreamingMovies` IS NOT NULL
                            AND TRIM(CAST(`StreamingMovies` AS CHAR)) <> ''
                           THEN 1 ELSE 0 END), 0)
             / NULLIF(COUNT(*), 0), 2) AS completitud_pct
FROM DSADEV.raw_telco_g2
UNION ALL
SELECT 'Contract' AS columna,
       COUNT(*) AS total_filas,
       COUNT(*) - COUNT(`Contract`) AS nulos,
       COALESCE(SUM(CASE WHEN `Contract` IS NOT NULL
                         AND TRIM(CAST(`Contract` AS CHAR)) = ''
                        THEN 1 ELSE 0 END), 0) AS blancos,
       COUNT(DISTINCT `Contract`) AS valores_distintos,
       ROUND(100.0 * COALESCE(SUM(CASE WHEN `Contract` IS NOT NULL
                            AND TRIM(CAST(`Contract` AS CHAR)) <> ''
                           THEN 1 ELSE 0 END), 0)
             / NULLIF(COUNT(*), 0), 2) AS completitud_pct
FROM DSADEV.raw_telco_g2
UNION ALL
SELECT 'PaperlessBilling' AS columna,
       COUNT(*) AS total_filas,
       COUNT(*) - COUNT(`PaperlessBilling`) AS nulos,
       COALESCE(SUM(CASE WHEN `PaperlessBilling` IS NOT NULL
                         AND TRIM(CAST(`PaperlessBilling` AS CHAR)) = ''
                        THEN 1 ELSE 0 END), 0) AS blancos,
       COUNT(DISTINCT `PaperlessBilling`) AS valores_distintos,
       ROUND(100.0 * COALESCE(SUM(CASE WHEN `PaperlessBilling` IS NOT NULL
                            AND TRIM(CAST(`PaperlessBilling` AS CHAR)) <> ''
                           THEN 1 ELSE 0 END), 0)
             / NULLIF(COUNT(*), 0), 2) AS completitud_pct
FROM DSADEV.raw_telco_g2
UNION ALL
SELECT 'PaymentMethod' AS columna,
       COUNT(*) AS total_filas,
       COUNT(*) - COUNT(`PaymentMethod`) AS nulos,
       COALESCE(SUM(CASE WHEN `PaymentMethod` IS NOT NULL
                         AND TRIM(CAST(`PaymentMethod` AS CHAR)) = ''
                        THEN 1 ELSE 0 END), 0) AS blancos,
       COUNT(DISTINCT `PaymentMethod`) AS valores_distintos,
       ROUND(100.0 * COALESCE(SUM(CASE WHEN `PaymentMethod` IS NOT NULL
                            AND TRIM(CAST(`PaymentMethod` AS CHAR)) <> ''
                           THEN 1 ELSE 0 END), 0)
             / NULLIF(COUNT(*), 0), 2) AS completitud_pct
FROM DSADEV.raw_telco_g2
UNION ALL
SELECT 'MonthlyCharges' AS columna,
       COUNT(*) AS total_filas,
       COUNT(*) - COUNT(`MonthlyCharges`) AS nulos,
       COALESCE(SUM(CASE WHEN `MonthlyCharges` IS NOT NULL
                         AND TRIM(CAST(`MonthlyCharges` AS CHAR)) = ''
                        THEN 1 ELSE 0 END), 0) AS blancos,
       COUNT(DISTINCT `MonthlyCharges`) AS valores_distintos,
       ROUND(100.0 * COALESCE(SUM(CASE WHEN `MonthlyCharges` IS NOT NULL
                            AND TRIM(CAST(`MonthlyCharges` AS CHAR)) <> ''
                           THEN 1 ELSE 0 END), 0)
             / NULLIF(COUNT(*), 0), 2) AS completitud_pct
FROM DSADEV.raw_telco_g2
UNION ALL
SELECT 'TotalCharges' AS columna,
       COUNT(*) AS total_filas,
       COUNT(*) - COUNT(`TotalCharges`) AS nulos,
       COALESCE(SUM(CASE WHEN `TotalCharges` IS NOT NULL
                         AND TRIM(CAST(`TotalCharges` AS CHAR)) = ''
                        THEN 1 ELSE 0 END), 0) AS blancos,
       COUNT(DISTINCT `TotalCharges`) AS valores_distintos,
       ROUND(100.0 * COALESCE(SUM(CASE WHEN `TotalCharges` IS NOT NULL
                            AND TRIM(CAST(`TotalCharges` AS CHAR)) <> ''
                           THEN 1 ELSE 0 END), 0)
             / NULLIF(COUNT(*), 0), 2) AS completitud_pct
FROM DSADEV.raw_telco_g2
UNION ALL
SELECT 'Churn' AS columna,
       COUNT(*) AS total_filas,
       COUNT(*) - COUNT(`Churn`) AS nulos,
       COALESCE(SUM(CASE WHEN `Churn` IS NOT NULL
                         AND TRIM(CAST(`Churn` AS CHAR)) = ''
                        THEN 1 ELSE 0 END), 0) AS blancos,
       COUNT(DISTINCT `Churn`) AS valores_distintos,
       ROUND(100.0 * COALESCE(SUM(CASE WHEN `Churn` IS NOT NULL
                            AND TRIM(CAST(`Churn` AS CHAR)) <> ''
                           THEN 1 ELSE 0 END), 0)
             / NULLIF(COUNT(*), 0), 2) AS completitud_pct
FROM DSADEV.raw_telco_g2
UNION ALL
SELECT 'fecha_carga' AS columna,
       COUNT(*) AS total_filas,
       COUNT(*) - COUNT(`fecha_carga`) AS nulos,
       COALESCE(SUM(CASE WHEN `fecha_carga` IS NOT NULL
                         AND TRIM(CAST(`fecha_carga` AS CHAR)) = ''
                        THEN 1 ELSE 0 END), 0) AS blancos,
       COUNT(DISTINCT `fecha_carga`) AS valores_distintos,
       ROUND(100.0 * COALESCE(SUM(CASE WHEN `fecha_carga` IS NOT NULL
                            AND TRIM(CAST(`fecha_carga` AS CHAR)) <> ''
                           THEN 1 ELSE 0 END), 0)
             / NULLIF(COUNT(*), 0), 2) AS completitud_pct
FROM DSADEV.raw_telco_g2;
-- BLOQUE 2: Identificadores repetidos. Esperado: cero filas.
SELECT customerID, COUNT(*) AS repeticiones
FROM DSADEV.raw_telco_g2
GROUP BY customerID
HAVING COUNT(*) > 1
ORDER BY repeticiones DESC, customerID;

-- BLOQUE 3: Validacion de importes de texto sin conversion silenciosa.
-- Formato aceptado en este control: digitos, con punto opcional y hasta
-- dos decimales. Se recortan espacios SOLO en la consulta; raw no cambia.
-- Ambos campos son VARCHAR(20); DECIMAL(30,2) permite examinar sus
-- valores numericos validos sin depender de comparaciones de texto.
WITH textos AS (
    SELECT customerID, tenure,
           TRIM(MonthlyCharges) AS mensual_texto,
           TRIM(TotalCharges) AS total_texto
    FROM DSADEV.raw_telco_g2
), formatos AS (
    SELECT *,
        CASE WHEN mensual_texto REGEXP '^[0-9]+([.][0-9]{1,2})?$'
             THEN 1 ELSE 0 END AS mensual_valido,
        CASE WHEN total_texto REGEXP '^[0-9]+([.][0-9]{1,2})?$'
             THEN 1 ELSE 0 END AS total_valido
    FROM textos
), importes AS (
    SELECT *,
        CASE WHEN mensual_valido = 1
             THEN CAST(mensual_texto AS DECIMAL(30,2)) ELSE NULL END
             AS mensual_numero,
        CASE WHEN total_valido = 1
             THEN CAST(total_texto AS DECIMAL(30,2)) ELSE NULL END
             AS total_numero
    FROM formatos
)
SELECT COUNT(*) AS filas,
    COALESCE(SUM(CASE WHEN mensual_texto IS NULL OR mensual_texto = ''
        THEN 1 ELSE 0 END), 0) AS monthly_faltantes,
    COALESCE(SUM(CASE WHEN mensual_texto IS NOT NULL AND mensual_texto <> ''
        AND mensual_valido = 0 THEN 1 ELSE 0 END), 0) AS monthly_formato_invalido,
    MIN(mensual_numero) AS monthly_minimo,
    MAX(mensual_numero) AS monthly_maximo,
    COALESCE(SUM(CASE WHEN mensual_numero < 18 OR mensual_numero > 120
        THEN 1 ELSE 0 END), 0) AS monthly_fuera_rango_18_120,
    COALESCE(SUM(CASE WHEN mensual_numero < 18 OR mensual_numero > 125
        THEN 1 ELSE 0 END), 0) AS monthly_fuera_rango_18_125,
    COALESCE(SUM(CASE WHEN total_texto IS NULL THEN 1 ELSE 0 END), 0)
        AS totalcharges_nulos,
    COALESCE(SUM(CASE WHEN total_texto = '' THEN 1 ELSE 0 END), 0)
        AS totalcharges_blancos,
    COALESCE(SUM(CASE WHEN total_texto = '' AND tenure = 0
        THEN 1 ELSE 0 END), 0) AS blancos_con_tenure_cero,
    COALESCE(SUM(CASE WHEN total_texto = '' AND (tenure <> 0 OR tenure IS NULL)
        THEN 1 ELSE 0 END), 0) AS blancos_otro_tenure,
    COALESCE(SUM(CASE WHEN total_texto IS NOT NULL AND total_texto <> ''
        AND total_valido = 0 THEN 1 ELSE 0 END), 0) AS total_formato_invalido,
    MIN(total_numero) AS totalcharges_minimo_informado,
    MAX(total_numero) AS totalcharges_maximo_informado
FROM importes;
-- Ambos rangos se informan por separado para comparar los criterios del
-- README y del SQL existente; no se cambia ningun umbral de OpenMetadata.

-- BLOQUE 4: Exploracion por contrato y servicio de Internet.
-- Tasa historica, no prediccion ni efecto causal de una accion comercial.
SELECT Contract, InternetService,
       COUNT(*) AS clientes,
       SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS clientes_churn,
       SUM(CASE WHEN Churn IN ('Yes', 'No') THEN 1 ELSE 0 END) AS churn_valido,
       SUM(CASE WHEN Churn IS NULL OR Churn NOT IN ('Yes', 'No')
           THEN 1 ELSE 0 END) AS churn_faltante_o_invalido,
       ROUND(100.0 * SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
           / NULLIF(SUM(CASE WHEN Churn IN ('Yes','No') THEN 1 ELSE 0 END),0),
           2) AS churn_pct
FROM DSADEV.raw_telco_g2
GROUP BY Contract, InternetService
ORDER BY churn_pct DESC, clientes DESC;