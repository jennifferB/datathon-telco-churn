-- DDL de referencia de la tabla raw real compartida por el equipo.
-- Base: DSADEV. 21 campos del CSV + fecha_carga = 22 columnas.
-- MonthlyCharges y TotalCharges conservan texto y blancos de la fuente.
-- Sin PRIMARY KEY ni UNIQUE: la unicidad de customerID se valida mediante DQ.
-- Ejecutar solo para crear la tabla en un entorno donde no exista.
-- No es una migracion: no reemplaza ni modifica una tabla ya creada.
USE DSADEV;

CREATE TABLE raw_telco_g2 (
    customerID VARCHAR(20) NOT NULL,
    gender VARCHAR(10) DEFAULT NULL,
    SeniorCitizen TINYINT(4) DEFAULT NULL,
    Partner VARCHAR(3) DEFAULT NULL,
    Dependents VARCHAR(3) DEFAULT NULL,
    tenure INT(11) DEFAULT NULL,
    PhoneService VARCHAR(3) DEFAULT NULL,
    MultipleLines VARCHAR(30) DEFAULT NULL,
    InternetService VARCHAR(20) DEFAULT NULL,
    OnlineSecurity VARCHAR(30) DEFAULT NULL,
    OnlineBackup VARCHAR(30) DEFAULT NULL,
    DeviceProtection VARCHAR(30) DEFAULT NULL,
    TechSupport VARCHAR(30) DEFAULT NULL,
    StreamingTV VARCHAR(30) DEFAULT NULL,
    StreamingMovies VARCHAR(30) DEFAULT NULL,
    Contract VARCHAR(20) DEFAULT NULL,
    PaperlessBilling VARCHAR(3) DEFAULT NULL,
    PaymentMethod VARCHAR(40) DEFAULT NULL,
    MonthlyCharges VARCHAR(20) DEFAULT NULL,
    TotalCharges VARCHAR(20) DEFAULT NULL,
    Churn VARCHAR(3) DEFAULT NULL,
    fecha_carga DATETIME DEFAULT CURRENT_TIMESTAMP,
    SORT KEY __UNORDERED (),
    SHARD KEY ()
) AUTOSTATS_CARDINALITY_MODE=INCREMENTAL
  AUTOSTATS_HISTOGRAM_MODE=CREATE
  AUTOSTATS_SAMPLING=ON
  SQL_MODE='STRICT_ALL_TABLES,NO_AUTO_CREATE_USER'
  CHARACTER SET=utf8mb4 COLLATE=utf8mb4_bin;
