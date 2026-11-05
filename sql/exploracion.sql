-- exploracion.sql | Datatón IBM Telco Churn | Tabla: DSADEV.raw_telco_g2

-- Filas e IDs únicos (esperado: 7043 y 7043)
SELECT COUNT(*) AS filas, COUNT(DISTINCT customerID) AS ids_unicos
FROM DSADEV.raw_telco_g2;

-- Clientes con tenure = 0 (esperado: 11)
SELECT COUNT(*) FROM DSADEV.raw_telco_g2 WHERE tenure = 0;

-- De esos, TotalCharges imputado a 0 (esperado: 11)
SELECT COUNT(*) FROM DSADEV.raw_telco_g2
WHERE tenure = 0 AND TotalCharges IN ('0', '0.0', '0.00');

-- Sin nulos ni vacíos en TotalCharges (esperado: 0)
SELECT COUNT(*) FROM DSADEV.raw_telco_g2
WHERE TotalCharges IS NULL OR TRIM(TotalCharges) = '';

-- Churn global (esperado: ~26.5% Yes)
SELECT Churn, COUNT(*) AS clientes,
       ROUND(100 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS porcentaje
FROM DSADEV.raw_telco_g2
GROUP BY Churn;

-- Churn por contrato
SELECT Contract, COUNT(*) AS clientes,
       SUM(Churn = 'Yes') AS churn,
       ROUND(100 * SUM(Churn = 'Yes') / COUNT(*), 1) AS churn_pct
FROM DSADEV.raw_telco_g2
GROUP BY Contract
ORDER BY churn_pct DESC;

-- Segmentos: contrato x nivel de servicio . Hipótesis inicial de segmentos (se refinará en segmentos.sql)
SELECT Contract,
       CASE WHEN InternetService = 'No' THEN 'Sin internet'
            WHEN OnlineSecurity = 'Yes' OR TechSupport = 'Yes' THEN 'Internet protegido'
            ELSE 'Internet basico' END AS nivel_servicio,
       COUNT(*) AS clientes,
       SUM(Churn = 'Yes') AS churn,
       ROUND(100 * SUM(Churn = 'Yes') / COUNT(*), 1) AS churn_pct,
       ROUND(AVG(MonthlyCharges), 2) AS cargo_promedio
FROM DSADEV.raw_telco_g2
GROUP BY 1, 2
ORDER BY churn_pct DESC;