-- ==============================================================================
-- PROYECTO: Datatón Genius Lab III - Telecomunicaciones (IBM Telco Churn)
-- SCRIPT: 04_dq_tests.sql
-- DESCRIPCIÓN: Consultas de auditoría para medir las 5 Reglas de Data Quality (DQ).
-- META DEL PROYECTO: Umbral de conformidad >= 99%
-- ==============================================================================

USE DSADEV;

-- ==============================================================================
-- REPORTE GENERAL DE CONFORMIDAD DE CALIDAD DE DATOS (5 REGLAS ACTIVAS)
-- ==============================================================================
SELECT 
    COUNT(*) AS total_registros,
    
    -- REGLA 1: UNICIDAD (customerID sin duplicados)
    ROUND(COUNT(DISTINCT customerID) * 100.0 / COUNT(*), 2) AS pct_unicidad_customerID,
    
    -- REGLA 2: COMPLETITUD (TotalCharges tratado, sin nulos ni vacíos)
    ROUND(SUM(CASE WHEN TotalCharges IS NOT NULL AND TRIM(TotalCharges) != '' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS pct_completitud_TotalCharges,
    
    -- REGLA 3: RANGO (MonthlyCharges dentro del rango de mercado [18.00 - 125.00])
    ROUND(SUM(CASE WHEN MonthlyCharges BETWEEN 18.00 AND 125.00 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS pct_rango_MonthlyCharges,
    
    -- REGLA 4: VALIDEZ DE FORMATO (Contract pertenece al dominio de contratos válidos)
    ROUND(SUM(CASE WHEN Contract IN ('Month-to-month', 'One year', 'Two year') THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS pct_validez_Contract,
    
    -- REGLA 5: CONSISTENCIA (Target Churn estrictamente binario 'Yes' o 'No')
    ROUND(SUM(CASE WHEN Churn IN ('Yes', 'No') THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS pct_consistencia_Churn
FROM raw_telco_g2;

-- ==============================================================================
-- DETALLE DE AUDITORÍA INDIVIDUAL POR REGLA
-- ==============================================================================

-- Test 1: Verificar si existen IDs duplicados (Debe dar 0 filas)
SELECT customerID, COUNT(*) AS repeticiones
FROM raw_telco_g2
GROUP BY customerID
HAVING COUNT(*) > 1;

-- Test 2: Verificar registros con TotalCharges en blanco o nulo (Debe dar 0 filas tras Talend)
SELECT customerID, tenure, TotalCharges
FROM raw_telco_g2
WHERE TotalCharges IS NULL OR TRIM(TotalCharges) = '';

-- Test 3: Verificar anomalías fuera de rango en MonthlyCharges (Debe dar 0 filas)
SELECT customerID, MonthlyCharges
FROM raw_telco_g2
WHERE MonthlyCharges < 18.00 OR MonthlyCharges > 125.00;

-- Test 4: Verificar valores extraños en tipo de contrato (Debe dar 0 filas)
SELECT DISTINCT Contract
FROM raw_telco_g2;

-- Test 5: Distribución del Target Churn (Debe mostrar ~26.5% de 'Yes')
SELECT 
    Churn,
    COUNT(*) AS cantidad_clientes,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM raw_telco_g2), 2) AS porcentaje
FROM raw_telco_g2
GROUP BY Churn;
