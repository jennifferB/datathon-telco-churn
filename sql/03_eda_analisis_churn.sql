-- ==============================================================================
-- PROYECTO: Datatón Genius Lab III - Telecomunicaciones (IBM Telco Churn)
-- SCRIPT: 03_eda_analisis_churn.sql
-- DESCRIPCIÓN: Consultas de Análisis Exploratorio de Datos (EDA) y cálculo de Churn
-- ROL: Data Analyst (Sprint 1 - Tarea SP1-04)
-- ==============================================================================

USE DSADEV;

-- ==============================================================================
-- 1. CÁLCULO DE LA TASA BASE DE CHURN (MÉTRICA GLOBAL DEL NEGOCIO)
-- ==============================================================================
SELECT 
    COUNT(*) AS total_clientes,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS clientes_churn,
    SUM(CASE WHEN Churn = 'No' THEN 1 ELSE 0 END) AS clientes_retenidos,
    ROUND(SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS tasa_base_churn_pct
FROM raw_telco_g2;
-- RESULTADO ESPERADO: 26.54% de tasa base global (1,869 clientes que abandonan)


-- ==============================================================================
-- 2. CHURN POR TIPO DE CONTRATO (FACTOR #1 DE ABANDONO)
-- ==============================================================================
SELECT 
    Contract,
    COUNT(*) AS total_clientes,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS clientes_churn,
    ROUND(SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS churn_rate_pct
FROM raw_telco_g2
GROUP BY Contract
ORDER BY churn_rate_pct DESC;
-- HALLAZGO: 'Month-to-month' tiene ~42.7% de churn vs ~2.8% en contratos de 2 años.


-- ==============================================================================
-- 3. CHURN POR TIPO DE SERVICIO DE INTERNET (FIBRA VS DSL)
-- ==============================================================================
SELECT 
    InternetService,
    COUNT(*) AS total_clientes,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS clientes_churn,
    ROUND(SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS churn_rate_pct,
    ROUND(AVG(MonthlyCharges), 2) AS ticket_promedio
FROM raw_telco_g2
GROUP BY InternetService
ORDER BY churn_rate_pct DESC;
-- HALLAZGO: 'Fiber optic' tiene ~41.9% de churn pese a pagar la mensualidad más alta ($87/mes).


-- ==============================================================================
-- 4. CHURN POR CURVA DE PERMANENCIA / ANTIGÜEDAD (TENURE)
-- ==============================================================================
SELECT 
    CASE 
        WHEN tenure <= 12 THEN '01. 0 - 12 meses (Nuevos)'
        WHEN tenure <= 24 THEN '02. 13 - 24 meses (1 a 2 años)'
        WHEN tenure <= 48 THEN '03. 25 - 48 meses (2 a 4 años)'
        ELSE '04. Más de 48 meses (Fidelizados)'
    END AS tramo_antiguedad,
    COUNT(*) AS total_clientes,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS clientes_churn,
    ROUND(SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS churn_rate_pct
FROM raw_telco_g2
GROUP BY tramo_antiguedad
ORDER BY tramo_antiguedad;
-- HALLAZGO: En el primer año (0-12 meses), el churn supera el 47%.


-- ==============================================================================
-- 5. CHURN SEGÚN SOPORTE TÉCNICO Y SEGURIDAD ONLINE
-- ==============================================================================
SELECT 
    TechSupport,
    OnlineSecurity,
    COUNT(*) AS total_clientes,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS clientes_churn,
    ROUND(SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS churn_rate_pct
FROM raw_telco_g2
GROUP BY TechSupport, OnlineSecurity
ORDER BY churn_rate_pct DESC;
-- HALLAZGO: Clientes sin soporte técnico ni seguridad tienen un churn > 48%.
