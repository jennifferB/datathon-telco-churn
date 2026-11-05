-- ==============================================================================
-- PROYECTO: Datatón Genius Lab III - Telecomunicaciones (IBM Telco Churn)
-- SCRIPT: 01_ddl_singlestore.sql
-- DESCRIPCIÓN: DDL para crear la tabla de aterrizaje (Landing / Raw) en SingleStore.
-- COMPATIBILIDAD: MySQL / SingleStore
-- ==============================================================================

CREATE DATABASE IF NOT EXISTS telco_db;
USE telco_db;

-- Tabla Raw / Landing para la ingesta desde Talend Studio
DROP TABLE IF EXISTS telco_raw;

CREATE TABLE telco_raw (
    customerID          VARCHAR(30) NOT NULL,
    gender              VARCHAR(10),
    SeniorCitizen       TINYINT,
    Partner             VARCHAR(5),
    Dependents          VARCHAR(5),
    tenure              INT,
    PhoneService        VARCHAR(5),
    MultipleLines       VARCHAR(25),
    InternetService     VARCHAR(25),
    OnlineSecurity      VARCHAR(25),
    OnlineBackup        VARCHAR(25),
    DeviceProtection    VARCHAR(25),
    TechSupport         VARCHAR(25),
    StreamingTV         VARCHAR(25),
    StreamingMovies     VARCHAR(25),
    Contract            VARCHAR(25),
    PaperlessBilling    VARCHAR(5),
    PaymentMethod       VARCHAR(50),
    MonthlyCharges      DECIMAL(10, 2),
    TotalCharges        DECIMAL(10, 2), -- Tratado en Talend / tMap (11 vacíos convertidos a 0.00)
    Churn               VARCHAR(5),
    
    -- Metadata de auditoría
    loaded_at           TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    PRIMARY KEY (customerID)
);

-- ==============================================================================
-- NOTA DQ (Data Quality):
-- En el archivo fuente telco_churn.csv existen 11 registros donde TotalCharges = ' '.
-- En Talend (tMap), se debe aplicar la siguiente expresión Java para evitar errores de parseo:
-- (row1.TotalCharges == null || row1.TotalCharges.trim().isEmpty()) ? 0.00 : Double.parseDouble(row1.TotalCharges.trim())
-- ==============================================================================
