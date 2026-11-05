
-- =====================================================
-- PROYECTO: TELCO CHURN
-- MODELO: ESQUEMA ESTRELLA
-- =====================================================

-- =====================================================
-- 1. DIMENSION: DIM_CUSTOMER_TELCO_G2
-- Datos demográficos del cliente
-- =====================================================

use DSADEV; 

CREATE TABLE dim_customer_telco_g2 (
    customer_key INT AUTO_INCREMENT,
    customer_id VARCHAR(20) NOT NULL,
    gender VARCHAR(10),
    senior_citizen VARCHAR(3),
    partner VARCHAR(3),
    dependents VARCHAR(3),

    PRIMARY KEY (customer_key),
    SHARD KEY (customer_key)
);

-- =====================================================
-- 2. DIMENSION: DIM_CONTRACT_TELCO_G2
-- Condiciones del contrato y facturación
-- =====================================================

CREATE TABLE IF NOT EXISTS dim_contract_telco_g2 (
    contract_key INT AUTO_INCREMENT,
    contract_type VARCHAR(20) NOT NULL,
    paperless_billing VARCHAR(3),
    payment_method VARCHAR(40),

    PRIMARY KEY (contract_key),
    SHARD KEY (contract_key)
);


-- =====================================================
-- 3. DIMENSION: DIM_SERVICE_TELCO_G2
-- Combinación de servicios contratados
-- =====================================================

CREATE TABLE IF NOT EXISTS dim_service_telco_g2 (
    service_key INT AUTO_INCREMENT,

    phone_service VARCHAR(3),
    multiple_lines VARCHAR(20),
    internet_service VARCHAR(20),
    online_security VARCHAR(20),
    online_backup VARCHAR(20),
    device_protection VARCHAR(20),
    tech_support VARCHAR(20),
    streaming_tv VARCHAR(20),
    streaming_movies VARCHAR(20),
    service_level VARCHAR(30),

    PRIMARY KEY (service_key),
    SHARD KEY (service_key)
);


-- =====================================================
-- 4. TABLA DE HECHOS: FACT_CONTRACTS_TELCO_G2
-- Grano: una fila por cliente
-- =====================================================

CREATE TABLE IF NOT EXISTS fact_contracts_telco_g2 (
    customer_key INT NOT NULL,
    contract_key INT NOT NULL,
    service_key INT NOT NULL,

    tenure_months INT,
    tenure_group VARCHAR(10),

    monthly_charges DECIMAL(8,2),
    total_charges DECIMAL(10,2),

    churn_flag INT,

    PRIMARY KEY (customer_key),
    SHARD KEY (customer_key)
);



