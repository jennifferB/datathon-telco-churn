-- Base: telco_g2. Referencia: el job ya crea las tablas.
CREATE TABLE IF NOT EXISTS dim_customer_telco_g2 (
 customer_key BIGINT NOT NULL AUTO_INCREMENT,
 `customer_id` VARCHAR(20) NOT NULL,
 `gender` VARCHAR(10) NULL,
 `senior_citizen` VARCHAR(3) NULL,
 `partner` VARCHAR(3) NULL,
 `dependents` VARCHAR(3) NULL,
 `load_ts` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
 `load_source` VARCHAR(100) NULL,
 PRIMARY KEY (customer_key),
 SHARD KEY (customer_key),
 SORT KEY ()
) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;

CREATE TABLE IF NOT EXISTS dim_contract_telco_g2 (
 contract_key BIGINT NOT NULL AUTO_INCREMENT,
 `contract_type` VARCHAR(20) NOT NULL,
 `paperless_billing` VARCHAR(3) NULL,
 `payment_method` VARCHAR(40) NULL,
 `load_ts` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
 `load_source` VARCHAR(100) NULL,
 PRIMARY KEY (contract_key),
 SHARD KEY (contract_key),
 SORT KEY ()
) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;

CREATE TABLE IF NOT EXISTS dim_service_telco_g2 (
 service_key BIGINT NOT NULL AUTO_INCREMENT,
 `phone_service` VARCHAR(3) NULL,
 `multiple_lines` VARCHAR(30) NULL,
 `internet_service` VARCHAR(20) NULL,
 `online_security` VARCHAR(30) NULL,
 `online_backup` VARCHAR(30) NULL,
 `device_protection` VARCHAR(30) NULL,
 `tech_support` VARCHAR(30) NULL,
 `streaming_tv` VARCHAR(30) NULL,
 `streaming_movies` VARCHAR(30) NULL,
 `service_level` VARCHAR(30) NULL,
 `load_ts` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
 `load_source` VARCHAR(100) NULL,
 PRIMARY KEY (service_key),
 SHARD KEY (service_key),
 SORT KEY ()
) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;

CREATE TABLE IF NOT EXISTS fact_contracts_telco_g2 (
 `customer_key` BIGINT NOT NULL,
 `contract_key` BIGINT NOT NULL,
 `service_key` BIGINT NOT NULL,
 `tenure_months` INT NOT NULL,
 `tenure_group` VARCHAR(10) NOT NULL,
 `monthly_charges` DECIMAL(8,2) NOT NULL,
 `total_charges` DECIMAL(10,2) NOT NULL,
 `churn_flag` INT NOT NULL,
 `total_charges_imputed` INT NOT NULL,
 `imputation_reason` VARCHAR(64) NULL,
 `source_load_id` VARCHAR(36) NOT NULL,
 `load_ts` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
 `load_source` VARCHAR(100) NULL,
 PRIMARY KEY (customer_key),
 SHARD KEY (customer_key),
 SORT KEY ()
) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;
