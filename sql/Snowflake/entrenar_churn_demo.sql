-- Ejecutar en una sola sesión de Snowsight como TELCO_WRITER.
-- Si falta el permiso, el administrador puede ejecutar:
-- GRANT CREATE SNOWFLAKE.ML.CLASSIFICATION ON SCHEMA TELCO_G2.ANALYTICS TO ROLE TELCO_WRITER;
-- El modelo queda en ANALYTICS. Las tablas auxiliares son temporales.
USE ROLE TELCO_WRITER;
USE WAREHOUSE COMPUTE_WH;
USE SCHEMA TELCO_G2.ANALYTICS;

-- Reservar aproximadamente el 20% de cada clase. El hash del ID hace
-- reproducible la partición. El ID se excluye de las variables predictoras.
CREATE OR REPLACE TEMP TABLE TELCO_CHURN_DEMO_SPLIT AS
SELECT
    c."customer_id" AS customer_id,
    f."churn_flag"::VARCHAR AS churn_label,
    f."tenure_months" AS tenure_months,
    f."monthly_charges"::DOUBLE AS monthly_charges,
    ct."contract_type" AS contract_type,
    ct."payment_method" AS payment_method,
    ct."paperless_billing" AS paperless_billing,
    s."internet_service" AS internet_service,
    s."online_security" AS online_security,
    s."tech_support" AS tech_support,
    MOD(ROW_NUMBER() OVER (
        PARTITION BY f."churn_flag"
        ORDER BY HASH(c."customer_id"), c."customer_id"
    ), 5) = 0 AS holdout
FROM "fact_contracts_telco_g2" f
JOIN "dim_customer_telco_g2" c ON c."customer_key" = f."customer_key"
JOIN "dim_contract_telco_g2" ct ON ct."contract_key" = f."contract_key"
JOIN "dim_service_telco_g2" s ON s."service_key" = f."service_key"
WHERE f."churn_flag" IN (0, 1);

-- Revisar antes de entrenar. Para el lote del laboratorio, deben sumar
-- 7.043 clientes únicos, incluidos 1.869 abandonos.
SELECT holdout, churn_label, COUNT(*) AS filas, COUNT(DISTINCT customer_id) AS clientes
FROM TELCO_CHURN_DEMO_SPLIT
GROUP BY holdout, churn_label
ORDER BY holdout, churn_label;

CREATE OR REPLACE SNOWFLAKE.ML.CLASSIFICATION TELCO_CHURN_DEMO_V1(
    INPUT_DATA => SYSTEM$QUERY_REFERENCE(
        'SELECT churn_label, tenure_months, monthly_charges, contract_type,
                payment_method, paperless_billing, internet_service, online_security, tech_support
         FROM TELCO_G2.ANALYTICS.TELCO_CHURN_DEMO_SPLIT WHERE NOT holdout'
    ),
    TARGET_COLNAME => 'CHURN_LABEL',
    CONFIG_OBJECT => {'evaluate': FALSE}
);

-- Pasar las mismas variables de entrenamiento, sin la etiqueta real.
CREATE OR REPLACE TEMP TABLE TELCO_CHURN_DEMO_EVAL AS
SELECT churn_label, prediction:class::VARCHAR AS predicted_label,
       GET(prediction:probability, '1')::DOUBLE AS churn_score
FROM (
    SELECT churn_label, TELCO_CHURN_DEMO_V1!PREDICT(INPUT_DATA => OBJECT_CONSTRUCT(
        'TENURE_MONTHS', tenure_months, 'MONTHLY_CHARGES', monthly_charges,
        'CONTRACT_TYPE', contract_type, 'PAYMENT_METHOD', payment_method,
        'PAPERLESS_BILLING', paperless_billing, 'INTERNET_SERVICE', internet_service,
        'ONLINE_SECURITY', online_security, 'TECH_SUPPORT', tech_support
    )) AS prediction
    FROM TELCO_CHURN_DEMO_SPLIT
    WHERE holdout
);

-- Comparar con una regla que siempre predice permanencia.
WITH matriz AS (
    SELECT COUNT(*) AS filas,
           COUNT_IF(churn_score IS NULL) AS sin_score,
           COALESCE(COUNT_IF(churn_label = '1' AND predicted_label = '1'), 0) AS tp,
           COALESCE(COUNT_IF(churn_label = '0' AND predicted_label = '1'), 0) AS fp,
           COALESCE(COUNT_IF(churn_label = '1' AND predicted_label = '0'), 0) AS fn,
           COALESCE(COUNT_IF(churn_label = '0' AND predicted_label = '0'), 0) AS tn
    FROM TELCO_CHURN_DEMO_EVAL
)
SELECT filas, COALESCE(sin_score, 0) AS sin_score, tp, fp, fn, tn,
       ROUND(100.0 * (tn + fp) / NULLIF(filas, 0), 2) AS exactitud_base_pct,
       ROUND(100.0 * (tp + tn) / NULLIF(filas, 0), 2) AS exactitud_modelo_pct,
       ROUND(100.0 * tp / NULLIF(tp + fp, 0), 2) AS precision_churn_pct,
       ROUND(100.0 * tp / NULLIF(tp + fn, 0), 2) AS recall_churn_pct,
       ROUND(2.0 * tp / NULLIF(2 * tp + fp + fn, 0), 3) AS f1_churn
FROM matriz;
