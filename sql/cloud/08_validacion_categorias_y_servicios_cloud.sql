-- Adaptacion de solo lectura a SingleStore Cloud, 2026-11-06.
-- Conserva los controles originales. No representa una ejecucion nueva.
-- Ejecutar cada sentencia o bloque por separado, con telco_g2 seleccionada.
﻿-- VALIDACION DE CATEGORIAS Y CONSISTENCIA DE SERVICIOS — TELCO RAW
-- Solo lectura. No corrige ni modifica raw. Ejecutar cada bloque por separado.
-- No phone service y No internet service son respuestas validas, no faltantes.
-- Comparacion exacta, sin TRIM: los espacios inesperados se detectan.

-- BLOQUE 1: Dominios de 17 columnas. Incluye NULL como invalido.
SELECT 'gender' AS columna, COUNT(*) AS filas,
    COALESCE(SUM(CASE WHEN `gender` IN ('Female', 'Male') THEN 1 ELSE 0 END),0) AS validos,
    COALESCE(SUM(CASE WHEN `gender` IN ('Female', 'Male') THEN 0 ELSE 1 END),0) AS invalidos_o_nulos
FROM telco_g2.raw_telco_g2
UNION ALL
SELECT 'SeniorCitizen' AS columna, COUNT(*) AS filas,
    COALESCE(SUM(CASE WHEN `SeniorCitizen` IN (0, 1) THEN 1 ELSE 0 END),0) AS validos,
    COALESCE(SUM(CASE WHEN `SeniorCitizen` IN (0, 1) THEN 0 ELSE 1 END),0) AS invalidos_o_nulos
FROM telco_g2.raw_telco_g2
UNION ALL
SELECT 'Partner' AS columna, COUNT(*) AS filas,
    COALESCE(SUM(CASE WHEN `Partner` IN ('Yes', 'No') THEN 1 ELSE 0 END),0) AS validos,
    COALESCE(SUM(CASE WHEN `Partner` IN ('Yes', 'No') THEN 0 ELSE 1 END),0) AS invalidos_o_nulos
FROM telco_g2.raw_telco_g2
UNION ALL
SELECT 'Dependents' AS columna, COUNT(*) AS filas,
    COALESCE(SUM(CASE WHEN `Dependents` IN ('Yes', 'No') THEN 1 ELSE 0 END),0) AS validos,
    COALESCE(SUM(CASE WHEN `Dependents` IN ('Yes', 'No') THEN 0 ELSE 1 END),0) AS invalidos_o_nulos
FROM telco_g2.raw_telco_g2
UNION ALL
SELECT 'PhoneService' AS columna, COUNT(*) AS filas,
    COALESCE(SUM(CASE WHEN `PhoneService` IN ('Yes', 'No') THEN 1 ELSE 0 END),0) AS validos,
    COALESCE(SUM(CASE WHEN `PhoneService` IN ('Yes', 'No') THEN 0 ELSE 1 END),0) AS invalidos_o_nulos
FROM telco_g2.raw_telco_g2
UNION ALL
SELECT 'MultipleLines' AS columna, COUNT(*) AS filas,
    COALESCE(SUM(CASE WHEN `MultipleLines` IN ('Yes', 'No', 'No phone service') THEN 1 ELSE 0 END),0) AS validos,
    COALESCE(SUM(CASE WHEN `MultipleLines` IN ('Yes', 'No', 'No phone service') THEN 0 ELSE 1 END),0) AS invalidos_o_nulos
FROM telco_g2.raw_telco_g2
UNION ALL
SELECT 'InternetService' AS columna, COUNT(*) AS filas,
    COALESCE(SUM(CASE WHEN `InternetService` IN ('DSL', 'Fiber optic', 'No') THEN 1 ELSE 0 END),0) AS validos,
    COALESCE(SUM(CASE WHEN `InternetService` IN ('DSL', 'Fiber optic', 'No') THEN 0 ELSE 1 END),0) AS invalidos_o_nulos
FROM telco_g2.raw_telco_g2
UNION ALL
SELECT 'OnlineSecurity' AS columna, COUNT(*) AS filas,
    COALESCE(SUM(CASE WHEN `OnlineSecurity` IN ('Yes', 'No', 'No internet service') THEN 1 ELSE 0 END),0) AS validos,
    COALESCE(SUM(CASE WHEN `OnlineSecurity` IN ('Yes', 'No', 'No internet service') THEN 0 ELSE 1 END),0) AS invalidos_o_nulos
FROM telco_g2.raw_telco_g2
UNION ALL
SELECT 'OnlineBackup' AS columna, COUNT(*) AS filas,
    COALESCE(SUM(CASE WHEN `OnlineBackup` IN ('Yes', 'No', 'No internet service') THEN 1 ELSE 0 END),0) AS validos,
    COALESCE(SUM(CASE WHEN `OnlineBackup` IN ('Yes', 'No', 'No internet service') THEN 0 ELSE 1 END),0) AS invalidos_o_nulos
FROM telco_g2.raw_telco_g2
UNION ALL
SELECT 'DeviceProtection' AS columna, COUNT(*) AS filas,
    COALESCE(SUM(CASE WHEN `DeviceProtection` IN ('Yes', 'No', 'No internet service') THEN 1 ELSE 0 END),0) AS validos,
    COALESCE(SUM(CASE WHEN `DeviceProtection` IN ('Yes', 'No', 'No internet service') THEN 0 ELSE 1 END),0) AS invalidos_o_nulos
FROM telco_g2.raw_telco_g2
UNION ALL
SELECT 'TechSupport' AS columna, COUNT(*) AS filas,
    COALESCE(SUM(CASE WHEN `TechSupport` IN ('Yes', 'No', 'No internet service') THEN 1 ELSE 0 END),0) AS validos,
    COALESCE(SUM(CASE WHEN `TechSupport` IN ('Yes', 'No', 'No internet service') THEN 0 ELSE 1 END),0) AS invalidos_o_nulos
FROM telco_g2.raw_telco_g2
UNION ALL
SELECT 'StreamingTV' AS columna, COUNT(*) AS filas,
    COALESCE(SUM(CASE WHEN `StreamingTV` IN ('Yes', 'No', 'No internet service') THEN 1 ELSE 0 END),0) AS validos,
    COALESCE(SUM(CASE WHEN `StreamingTV` IN ('Yes', 'No', 'No internet service') THEN 0 ELSE 1 END),0) AS invalidos_o_nulos
FROM telco_g2.raw_telco_g2
UNION ALL
SELECT 'StreamingMovies' AS columna, COUNT(*) AS filas,
    COALESCE(SUM(CASE WHEN `StreamingMovies` IN ('Yes', 'No', 'No internet service') THEN 1 ELSE 0 END),0) AS validos,
    COALESCE(SUM(CASE WHEN `StreamingMovies` IN ('Yes', 'No', 'No internet service') THEN 0 ELSE 1 END),0) AS invalidos_o_nulos
FROM telco_g2.raw_telco_g2
UNION ALL
SELECT 'Contract' AS columna, COUNT(*) AS filas,
    COALESCE(SUM(CASE WHEN `Contract` IN ('Month-to-month', 'One year', 'Two year') THEN 1 ELSE 0 END),0) AS validos,
    COALESCE(SUM(CASE WHEN `Contract` IN ('Month-to-month', 'One year', 'Two year') THEN 0 ELSE 1 END),0) AS invalidos_o_nulos
FROM telco_g2.raw_telco_g2
UNION ALL
SELECT 'PaperlessBilling' AS columna, COUNT(*) AS filas,
    COALESCE(SUM(CASE WHEN `PaperlessBilling` IN ('Yes', 'No') THEN 1 ELSE 0 END),0) AS validos,
    COALESCE(SUM(CASE WHEN `PaperlessBilling` IN ('Yes', 'No') THEN 0 ELSE 1 END),0) AS invalidos_o_nulos
FROM telco_g2.raw_telco_g2
UNION ALL
SELECT 'PaymentMethod' AS columna, COUNT(*) AS filas,
    COALESCE(SUM(CASE WHEN `PaymentMethod` IN ('Electronic check', 'Mailed check', 'Bank transfer (automatic)', 'Credit card (automatic)') THEN 1 ELSE 0 END),0) AS validos,
    COALESCE(SUM(CASE WHEN `PaymentMethod` IN ('Electronic check', 'Mailed check', 'Bank transfer (automatic)', 'Credit card (automatic)') THEN 0 ELSE 1 END),0) AS invalidos_o_nulos
FROM telco_g2.raw_telco_g2
UNION ALL
SELECT 'Churn' AS columna, COUNT(*) AS filas,
    COALESCE(SUM(CASE WHEN `Churn` IN ('Yes', 'No') THEN 1 ELSE 0 END),0) AS validos,
    COALESCE(SUM(CASE WHEN `Churn` IN ('Yes', 'No') THEN 0 ELSE 1 END),0) AS invalidos_o_nulos
FROM telco_g2.raw_telco_g2;

-- BLOQUE 2: Siete controles de coherencia entre servicios.
SELECT 'PhoneService_MultipleLines' AS regla, COUNT(*) AS filas,
    COALESCE(SUM(CASE WHEN (PhoneService = 'No' AND MultipleLines = 'No phone service') OR (PhoneService = 'Yes' AND MultipleLines IN ('Yes','No')) THEN 0 ELSE 1 END),0) AS inconsistencias
FROM telco_g2.raw_telco_g2
UNION ALL
SELECT 'InternetService_OnlineSecurity' AS regla, COUNT(*) AS filas,
    COALESCE(SUM(CASE WHEN (InternetService = 'No' AND `OnlineSecurity` = 'No internet service') OR (InternetService IN ('DSL','Fiber optic') AND `OnlineSecurity` IN ('Yes','No')) THEN 0 ELSE 1 END),0) AS inconsistencias
FROM telco_g2.raw_telco_g2
UNION ALL
SELECT 'InternetService_OnlineBackup' AS regla, COUNT(*) AS filas,
    COALESCE(SUM(CASE WHEN (InternetService = 'No' AND `OnlineBackup` = 'No internet service') OR (InternetService IN ('DSL','Fiber optic') AND `OnlineBackup` IN ('Yes','No')) THEN 0 ELSE 1 END),0) AS inconsistencias
FROM telco_g2.raw_telco_g2
UNION ALL
SELECT 'InternetService_DeviceProtection' AS regla, COUNT(*) AS filas,
    COALESCE(SUM(CASE WHEN (InternetService = 'No' AND `DeviceProtection` = 'No internet service') OR (InternetService IN ('DSL','Fiber optic') AND `DeviceProtection` IN ('Yes','No')) THEN 0 ELSE 1 END),0) AS inconsistencias
FROM telco_g2.raw_telco_g2
UNION ALL
SELECT 'InternetService_TechSupport' AS regla, COUNT(*) AS filas,
    COALESCE(SUM(CASE WHEN (InternetService = 'No' AND `TechSupport` = 'No internet service') OR (InternetService IN ('DSL','Fiber optic') AND `TechSupport` IN ('Yes','No')) THEN 0 ELSE 1 END),0) AS inconsistencias
FROM telco_g2.raw_telco_g2
UNION ALL
SELECT 'InternetService_StreamingTV' AS regla, COUNT(*) AS filas,
    COALESCE(SUM(CASE WHEN (InternetService = 'No' AND `StreamingTV` = 'No internet service') OR (InternetService IN ('DSL','Fiber optic') AND `StreamingTV` IN ('Yes','No')) THEN 0 ELSE 1 END),0) AS inconsistencias
FROM telco_g2.raw_telco_g2
UNION ALL
SELECT 'InternetService_StreamingMovies' AS regla, COUNT(*) AS filas,
    COALESCE(SUM(CASE WHEN (InternetService = 'No' AND `StreamingMovies` = 'No internet service') OR (InternetService IN ('DSL','Fiber optic') AND `StreamingMovies` IN ('Yes','No')) THEN 0 ELSE 1 END),0) AS inconsistencias
FROM telco_g2.raw_telco_g2;

-- BLOQUE 3: Distribucion de respuestas para cada columna categorica.
-- Conserva por separado las tres respuestas de servicios, cuando existen.
SELECT 'gender' AS columna, CAST(`gender` AS CHAR) AS respuesta, COUNT(*) AS clientes
FROM telco_g2.raw_telco_g2 GROUP BY `gender`
UNION ALL
SELECT 'SeniorCitizen' AS columna, CAST(`SeniorCitizen` AS CHAR) AS respuesta, COUNT(*) AS clientes
FROM telco_g2.raw_telco_g2 GROUP BY `SeniorCitizen`
UNION ALL
SELECT 'Partner' AS columna, CAST(`Partner` AS CHAR) AS respuesta, COUNT(*) AS clientes
FROM telco_g2.raw_telco_g2 GROUP BY `Partner`
UNION ALL
SELECT 'Dependents' AS columna, CAST(`Dependents` AS CHAR) AS respuesta, COUNT(*) AS clientes
FROM telco_g2.raw_telco_g2 GROUP BY `Dependents`
UNION ALL
SELECT 'PhoneService' AS columna, CAST(`PhoneService` AS CHAR) AS respuesta, COUNT(*) AS clientes
FROM telco_g2.raw_telco_g2 GROUP BY `PhoneService`
UNION ALL
SELECT 'MultipleLines' AS columna, CAST(`MultipleLines` AS CHAR) AS respuesta, COUNT(*) AS clientes
FROM telco_g2.raw_telco_g2 GROUP BY `MultipleLines`
UNION ALL
SELECT 'InternetService' AS columna, CAST(`InternetService` AS CHAR) AS respuesta, COUNT(*) AS clientes
FROM telco_g2.raw_telco_g2 GROUP BY `InternetService`
UNION ALL
SELECT 'OnlineSecurity' AS columna, CAST(`OnlineSecurity` AS CHAR) AS respuesta, COUNT(*) AS clientes
FROM telco_g2.raw_telco_g2 GROUP BY `OnlineSecurity`
UNION ALL
SELECT 'OnlineBackup' AS columna, CAST(`OnlineBackup` AS CHAR) AS respuesta, COUNT(*) AS clientes
FROM telco_g2.raw_telco_g2 GROUP BY `OnlineBackup`
UNION ALL
SELECT 'DeviceProtection' AS columna, CAST(`DeviceProtection` AS CHAR) AS respuesta, COUNT(*) AS clientes
FROM telco_g2.raw_telco_g2 GROUP BY `DeviceProtection`
UNION ALL
SELECT 'TechSupport' AS columna, CAST(`TechSupport` AS CHAR) AS respuesta, COUNT(*) AS clientes
FROM telco_g2.raw_telco_g2 GROUP BY `TechSupport`
UNION ALL
SELECT 'StreamingTV' AS columna, CAST(`StreamingTV` AS CHAR) AS respuesta, COUNT(*) AS clientes
FROM telco_g2.raw_telco_g2 GROUP BY `StreamingTV`
UNION ALL
SELECT 'StreamingMovies' AS columna, CAST(`StreamingMovies` AS CHAR) AS respuesta, COUNT(*) AS clientes
FROM telco_g2.raw_telco_g2 GROUP BY `StreamingMovies`
UNION ALL
SELECT 'Contract' AS columna, CAST(`Contract` AS CHAR) AS respuesta, COUNT(*) AS clientes
FROM telco_g2.raw_telco_g2 GROUP BY `Contract`
UNION ALL
SELECT 'PaperlessBilling' AS columna, CAST(`PaperlessBilling` AS CHAR) AS respuesta, COUNT(*) AS clientes
FROM telco_g2.raw_telco_g2 GROUP BY `PaperlessBilling`
UNION ALL
SELECT 'PaymentMethod' AS columna, CAST(`PaymentMethod` AS CHAR) AS respuesta, COUNT(*) AS clientes
FROM telco_g2.raw_telco_g2 GROUP BY `PaymentMethod`
UNION ALL
SELECT 'Churn' AS columna, CAST(`Churn` AS CHAR) AS respuesta, COUNT(*) AS clientes
FROM telco_g2.raw_telco_g2 GROUP BY `Churn`
ORDER BY columna, respuesta;
