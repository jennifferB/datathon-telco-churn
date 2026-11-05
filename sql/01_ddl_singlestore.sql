-- ==============================================================================
-- PROYECTO: Datatón Genius Lab III - Telecomunicaciones (IBM Telco Churn)
-- SCRIPT: 01_ddl_singlestore.sql
-- DESCRIPCIÓN: DDL oficial para la tabla Raw (Grupo 2) en SingleStore.
-- ==============================================================================

CREATE DATABASE IF NOT EXISTS telco_db;
USE telco_db;

-- Tabla de aterrizaje / Raw: raw_telco_g2
DROP TABLE IF EXISTS raw_telco_g2;

CREATE TABLE raw_telco_g2 (
    customerID          VARCHAR(20) NOT NULL,
    gender              VARCHAR(10),
    SeniorCitizen       TINYINT,
    Partner             VARCHAR(5),
    Dependents          VARCHAR(5),
    tenure              INT,
    PhoneService        VARCHAR(5),
    MultipleLines       VARCHAR(30),
    InternetService     VARCHAR(30),
    OnlineSecurity      VARCHAR(30),
    OnlineBackup        VARCHAR(30),
    DeviceProtection    VARCHAR(30),
    TechSupport         VARCHAR(30),
    StreamingTV         VARCHAR(30),
    StreamingMovies     VARCHAR(30),
    Contract            VARCHAR(30),
    PaperlessBilling    VARCHAR(5),
    PaymentMethod       VARCHAR(40),
    MonthlyCharges      DECIMAL(8,2),
    TotalCharges        VARCHAR(15), -- VARCHAR para absorber sin error los 11 valores en blanco del origen
    Churn               VARCHAR(5),
    
    PRIMARY KEY (customerID)
);
