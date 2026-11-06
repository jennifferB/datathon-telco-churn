-- ==============================================================================
-- PROYECTO: Datatón Genius Lab III - Telecomunicaciones (IBM Telco Churn)
-- SCRIPT: 04_poblado_modelo_dimensional.sql
-- DESCRIPCIÓN: Proceso ELT para poblar el Esquema Estrella en SingleStore
-- TABLA ORIGEN: DSADEV.raw_telco_g2 (7,043 registros)
-- TABLAS DESTINO: 
--   - dim_customer_telco_g2
--   - dim_contract_telco_g2
--   - dim_service_telco_g2
--   - fact_contracts_telco_g2
-- ==============================================================================

USE DSADEV;

-- ==============================================================================
-- PASO 0: LIMPIEZA PREVIA (Opcional por idempotencia)
-- ==============================================================================
-- TRUNCATE TABLE fact_contracts_telco_g2;
-- TRUNCATE TABLE dim_customer_telco_g2;
-- TRUNCATE TABLE dim_contract_telco_g2;
-- TRUNCATE TABLE dim_service_telco_g2;


-- ==============================================================================
-- PASO 1: POBLAR DIM_CUSTOMER_TELCO_G2 (7,043 clientes únicos)
-- ==============================================================================
INSERT INTO dim_customer_telco_g2 (
    customer_id,
    gender,
    senior_citizen,
    partner,
    dependents
)
SELECT 
    customerID AS customer_id,
    gender,
    CASE WHEN SeniorCitizen = 1 THEN 'Yes' ELSE 'No' END AS senior_citizen,
    Partner AS partner,
    Dependents AS dependents
FROM raw_telco_g2;


-- ==============================================================================
-- PASO 2: POBLAR DIM_CONTRACT_TELCO_G2 (Combinaciones únicas de contratos)
-- ==============================================================================
INSERT INTO dim_contract_telco_g2 (
    contract_type,
    paperless_billing,
    payment_method
)
SELECT DISTINCT 
    Contract AS contract_type,
    PaperlessBilling AS paperless_billing,
    PaymentMethod AS payment_method
FROM raw_telco_g2;


-- ==============================================================================
-- PASO 3: POBLAR DIM_SERVICE_TELCO_G2 (Perfiles únicos de servicios y nivel)
-- ==============================================================================
INSERT INTO dim_service_telco_g2 (
    phone_service,
    multiple_lines,
    internet_service,
    online_security,
    online_backup,
    device_protection,
    tech_support,
    streaming_tv,
    streaming_movies,
    service_level
)
SELECT DISTINCT 
    PhoneService AS phone_service,
    MultipleLines AS multiple_lines,
    InternetService AS internet_service,
    OnlineSecurity AS online_security,
    OnlineBackup AS online_backup,
    DeviceProtection AS device_protection,
    TechSupport AS tech_support,
    StreamingTV AS streaming_tv,
    StreamingMovies AS streaming_movies,
    CASE 
        WHEN InternetService = 'No' THEN 'Sin Internet'
        WHEN OnlineSecurity = 'Yes' OR TechSupport = 'Yes' THEN 'Protegido'
        ELSE 'Basico' 
    END AS service_level
FROM raw_telco_g2;


-- ==============================================================================
-- PASO 4: POBLAR TABLA DE HECHOS: FACT_CONTRACTS_TELCO_G2 (7,043 registros)
-- Grano: 1 fila por cliente cruzada con sus dimensiones
-- ==============================================================================
INSERT INTO fact_contracts_telco_g2 (
    customer_key,
    contract_key,
    service_key,
    tenure_months,
    tenure_group,
    monthly_charges,
    total_charges,
    churn_flag
)
SELECT 
    c.customer_key,
    ct.contract_key,
    s.service_key,
    r.tenure AS tenure_months,
    CASE 
        WHEN r.tenure <= 12 THEN '0-12m'
        WHEN r.tenure <= 24 THEN '13-24m'
        WHEN r.tenure <= 48 THEN '25-48m'
        ELSE '>48m'
    END AS tenure_group,
    r.MonthlyCharges AS monthly_charges,
    CAST(COALESCE(NULLIF(TRIM(r.TotalCharges), ''), '0.00') AS DECIMAL(10,2)) AS total_charges,
    CASE WHEN r.Churn = 'Yes' THEN 1 ELSE 0 END AS churn_flag
FROM raw_telco_g2 r
JOIN dim_customer_telco_g2 c 
    ON r.customerID = c.customer_id
JOIN dim_contract_telco_g2 ct 
    ON r.Contract = ct.contract_type
   AND r.PaperlessBilling = ct.paperless_billing
   AND r.PaymentMethod = ct.payment_method
JOIN dim_service_telco_g2 s 
    ON r.PhoneService = s.phone_service
   AND r.MultipleLines = s.multiple_lines
   AND r.InternetService = s.internet_service
   AND r.OnlineSecurity = s.online_security
   AND r.OnlineBackup = s.online_backup
   AND r.DeviceProtection = s.device_protection
   AND r.TechSupport = s.tech_support
   AND r.StreamingTV = s.streaming_tv
   AND r.StreamingMovies = s.streaming_movies;


-- ==============================================================================
-- PASO 5: VALIDACIÓN DE CARGA Y CONTROL DE INTEGRIDAD
-- ==============================================================================
SELECT 'dim_customer_telco_g2' AS tabla, COUNT(*) AS total_filas FROM dim_customer_telco_g2
UNION ALL
SELECT 'dim_contract_telco_g2', COUNT(*) FROM dim_contract_telco_g2
UNION ALL
SELECT 'dim_service_telco_g2', COUNT(*) FROM dim_service_telco_g2
UNION ALL
SELECT 'fact_contracts_telco_g2', COUNT(*) FROM fact_contracts_telco_g2;

-- Comprobación de integridad del grano (debe coincidir con los 7,043 de raw)
-- Esperado en fact_contracts_telco_g2: exactamente 7,043 registros
