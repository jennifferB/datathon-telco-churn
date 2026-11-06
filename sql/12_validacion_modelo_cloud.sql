-- Base: telco_g2. Consulta de solo lectura.
SELECT
 (SELECT COUNT(*) FROM raw_telco_g2) AS raw_filas,
 (SELECT COUNT(*) FROM raw_telco_g2 WHERE TotalCharges IS NOT NULL AND TRIM(TotalCharges)='') AS raw_blancos,
 (SELECT COUNT(*) FROM stg_telco_g2) AS staging_filas,
 (SELECT COUNT(*) FROM dim_customer_telco_g2) AS clientes,
 (SELECT COUNT(DISTINCT customer_id) FROM dim_customer_telco_g2) AS clientes_distintos,
 (SELECT COUNT(*) FROM dim_contract_telco_g2) AS contratos,
 (SELECT COUNT(*) FROM dim_service_telco_g2) AS servicios,
 (SELECT COUNT(*) FROM fact_contracts_telco_g2) AS hechos,
 (SELECT COUNT(*) FROM fact_contracts_telco_g2 WHERE churn_flag=1) AS clientes_churn,
 (SELECT COUNT(*) FROM fact_contracts_telco_g2 WHERE total_charges_imputed=1) AS imputaciones,
 (SELECT COUNT(*) FROM fact_contracts_telco_g2 f
 LEFT JOIN dim_customer_telco_g2 c ON f.customer_key=c.customer_key
 LEFT JOIN dim_contract_telco_g2 ct ON f.contract_key=ct.contract_key
 LEFT JOIN dim_service_telco_g2 sv ON f.service_key=sv.service_key
 WHERE c.customer_key IS NULL OR ct.contract_key IS NULL OR sv.service_key IS NULL) AS hechos_huerfanos,
 (SELECT COUNT(*) FROM stg_telco_g2 s
 LEFT JOIN dim_customer_telco_g2 c ON s.customerID=c.customer_id
 LEFT JOIN fact_contracts_telco_g2 f ON f.customer_key=c.customer_key
 WHERE f.customer_key IS NULL) AS clientes_sin_hecho,
 (SELECT COUNT(*) FROM fact_contracts_telco_g2 f
JOIN dim_customer_telco_g2 c ON f.customer_key=c.customer_key
JOIN dim_contract_telco_g2 ct ON f.contract_key=ct.contract_key
JOIN dim_service_telco_g2 sv ON f.service_key=sv.service_key
JOIN stg_telco_g2 s ON c.customer_id=s.customerID) AS clientes_reconciliados,
 (SELECT COUNT(*) FROM fact_contracts_telco_g2 f
JOIN dim_customer_telco_g2 c ON f.customer_key=c.customer_key
JOIN dim_contract_telco_g2 ct ON f.contract_key=ct.contract_key
JOIN dim_service_telco_g2 sv ON f.service_key=sv.service_key
JOIN stg_telco_g2 s ON c.customer_id=s.customerID WHERE NOT (f.monthly_charges <=> s.MonthlyCharges) OR NOT (f.total_charges <=> s.TotalCharges) OR NOT (f.tenure_months <=> s.tenure) OR NOT (f.churn_flag <=> CASE WHEN s.Churn = 'Yes' THEN 1 ELSE 0 END) OR NOT (f.tenure_group <=> CASE WHEN s.tenure <= 12 THEN '0-12m' WHEN s.tenure <= 24 THEN '13-24m' WHEN s.tenure <= 48 THEN '25-48m' ELSE '>48m' END) OR NOT (f.total_charges_imputed <=> s.total_charges_imputed) OR NOT (f.imputation_reason <=> s.imputation_reason) OR NOT (f.source_load_id <=> s.load_id) OR NOT (c.gender <=> s.gender) OR NOT (c.senior_citizen <=> CASE WHEN s.SeniorCitizen = 1 THEN 'Yes' ELSE 'No' END) OR NOT (c.partner <=> s.Partner) OR NOT (c.dependents <=> s.Dependents) OR NOT (ct.contract_type <=> s.Contract) OR NOT (ct.paperless_billing <=> s.PaperlessBilling) OR NOT (ct.payment_method <=> s.PaymentMethod) OR NOT (sv.phone_service <=> s.PhoneService) OR NOT (sv.multiple_lines <=> s.MultipleLines) OR NOT (sv.internet_service <=> s.InternetService) OR NOT (sv.online_security <=> s.OnlineSecurity) OR NOT (sv.online_backup <=> s.OnlineBackup) OR NOT (sv.device_protection <=> s.DeviceProtection) OR NOT (sv.tech_support <=> s.TechSupport) OR NOT (sv.streaming_tv <=> s.StreamingTV) OR NOT (sv.streaming_movies <=> s.StreamingMovies) OR NOT (sv.service_level <=> CASE WHEN s.InternetService = 'No' THEN 'Sin Internet' WHEN s.OnlineSecurity = 'Yes' OR s.TechSupport = 'Yes' THEN 'Protegido' ELSE 'Basico' END)) AS diferencias_modelo,
 (SELECT COUNT(*) FROM fact_contracts_telco_g2 WHERE churn_flag IS NULL OR churn_flag NOT IN (0,1)) AS churn_invalido
;
