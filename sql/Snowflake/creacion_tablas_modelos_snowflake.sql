USE ROLE ACCOUNTADMIN;
USE WAREHOUSE COMPUTE_WH;

CREATE DATABASE IF NOT EXISTS telco_g2;
CREATE SCHEMA IF NOT EXISTS telco_g2.analytics;
USE SCHEMA telco_g2.analytics;

-- 1. TABLA RAW
CREATE TABLE IF NOT EXISTS "raw_telco_g2" (
    customerID VARCHAR(20),
    gender VARCHAR(10),
    SeniorCitizen INT,
    Partner VARCHAR(3),
    Dependents VARCHAR(3),
    tenure INT,
    PhoneService VARCHAR(3),
    MultipleLines VARCHAR(30),
    InternetService VARCHAR(20),
    OnlineSecurity VARCHAR(30),
    OnlineBackup VARCHAR(30),
    DeviceProtection VARCHAR(30),
    TechSupport VARCHAR(30),
    StreamingTV VARCHAR(30),
    StreamingMovies VARCHAR(30),
    Contract VARCHAR(20),
    PaperlessBilling VARCHAR(3),
    PaymentMethod VARCHAR(40),
    MonthlyCharges VARCHAR(20),
    TotalCharges VARCHAR(20),
    Churn VARCHAR(3),
    fecha_carga TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- 2. TABLA REJECTS
CREATE TABLE IF NOT EXISTS "rejects_telco_g2" (
    customerID VARCHAR(20),
    gender VARCHAR(10),
    SeniorCitizen INT,
    Partner VARCHAR(3),
    Dependents VARCHAR(3),
    tenure INT,
    PhoneService VARCHAR(3),
    MultipleLines VARCHAR(30),
    InternetService VARCHAR(20),
    OnlineSecurity VARCHAR(30),
    OnlineBackup VARCHAR(30),
    DeviceProtection VARCHAR(30),
    TechSupport VARCHAR(30),
    StreamingTV VARCHAR(30),
    StreamingMovies VARCHAR(30),
    Contract VARCHAR(20),
    PaperlessBilling VARCHAR(3),
    PaymentMethod VARCHAR(40),
    MonthlyCharges VARCHAR(20),
    TotalCharges VARCHAR(20),
    Churn VARCHAR(3),
    fecha_carga TIMESTAMP_NTZ,
    reject_reason VARCHAR(1024) NOT NULL,
    load_id VARCHAR(36) NOT NULL,
    fecha_rechazo TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- 3. TABLA STAGING
CREATE TABLE IF NOT EXISTS "stg_telco_g2" (
    customerID VARCHAR(20) PRIMARY KEY,
    gender VARCHAR(10),
    SeniorCitizen INT,
    Partner VARCHAR(3),
    Dependents VARCHAR(3),
    tenure INT,
    PhoneService VARCHAR(3),
    MultipleLines VARCHAR(30),
    InternetService VARCHAR(20),
    OnlineSecurity VARCHAR(30),
    OnlineBackup VARCHAR(30),
    DeviceProtection VARCHAR(30),
    TechSupport VARCHAR(30),
    StreamingTV VARCHAR(30),
    StreamingMovies VARCHAR(30),
    Contract VARCHAR(20),
    PaperlessBilling VARCHAR(3),
    PaymentMethod VARCHAR(40),
    MonthlyCharges NUMBER(8,2) NOT NULL,
    TotalCharges NUMBER(10,2) NOT NULL,
    Churn VARCHAR(3),
    fecha_carga TIMESTAMP_NTZ,
    monthly_charges_raw VARCHAR(20),
    total_charges_raw VARCHAR(20),
    total_charges_imputed INT NOT NULL,
    imputation_reason VARCHAR(64),
    load_id VARCHAR(36) NOT NULL,
    fecha_staging TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- 4. DIMENSIÓN CONTRATO
CREATE TABLE IF NOT EXISTS "dim_contract_telco_g2" (
    contract_key NUMBER IDENTITY(1,1) PRIMARY KEY,
    contract_type VARCHAR(20) NOT NULL,
    paperless_billing VARCHAR(3),
    payment_method VARCHAR(40)
);

-- 5. DIMENSIÓN CLIENTE
CREATE TABLE IF NOT EXISTS "dim_customer_telco_g2" (
    customer_key NUMBER IDENTITY(1,1) PRIMARY KEY,
    customer_id VARCHAR(20) NOT NULL,
    gender VARCHAR(10),
    senior_citizen VARCHAR(3),
    partner VARCHAR(3),
    dependents VARCHAR(3)
);

-- 6. DIMENSIÓN SERVICIO
CREATE TABLE IF NOT EXISTS "dim_service_telco_g2" (
    service_key NUMBER IDENTITY(1,1) PRIMARY KEY,
    phone_service VARCHAR(3),
    multiple_lines VARCHAR(30),
    internet_service VARCHAR(20),
    online_security VARCHAR(30),
    online_backup VARCHAR(30),
    device_protection VARCHAR(30),
    tech_support VARCHAR(30),
    streaming_tv VARCHAR(30),
    streaming_movies VARCHAR(30),
    service_level VARCHAR(30)
);

-- 7. TABLA DE HECHOS
CREATE TABLE IF NOT EXISTS "fact_contracts_telco_g2" (
    customer_key NUMBER NOT NULL,
    contract_key NUMBER NOT NULL,
    service_key NUMBER NOT NULL,
    tenure_months INT NOT NULL,
    tenure_group VARCHAR(10) NOT NULL,
    monthly_charges NUMBER(8,2) NOT NULL,
    total_charges NUMBER(10,2) NOT NULL,
    churn_flag INT NOT NULL,
    total_charges_imputed INT NOT NULL,
    imputation_reason VARCHAR(64),
    source_load_id VARCHAR(36) NOT NULL,
    CONSTRAINT pk_fact_contracts PRIMARY KEY (customer_key)
);

SHOW TABLES IN SCHEMA telco_g2.analytics;