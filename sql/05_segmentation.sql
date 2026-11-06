-- Integración: propuesta estratégica del equipo (commit 275995f) y controles/segmentación dimensional.
-- SingleStore Cloud: ejecutar cada bloque por separado en DBeaver.
-- Solo lectura. Fuente: modelo dimensional de telco_g2.
-- Grano: un cliente de la instantánea; churn es histórico, no una predicción.
-- Antes del análisis: ejecutar job_telco_validar_modelo.

-- BLOQUE 1. Control de relaciones. Los tres contadores deben ser cero.
-- Evita que un INNER JOIN oculte hechos sin dimensión.
SELECT
    COUNT(*) AS hechos,
    COUNT(DISTINCT f.customer_key) AS clientes_distintos,
    SUM(CASE WHEN c.customer_key IS NULL THEN 1 ELSE 0 END) AS sin_cliente,
    SUM(CASE WHEN ct.contract_key IS NULL THEN 1 ELSE 0 END) AS sin_contrato,
    SUM(CASE WHEN sv.service_key IS NULL THEN 1 ELSE 0 END) AS sin_servicio,
    SUM(CASE WHEN f.churn_flag IS NULL OR f.churn_flag NOT IN (0, 1)
             THEN 1 ELSE 0 END) AS churn_invalido
FROM telco_g2.fact_contracts_telco_g2 f
LEFT JOIN telco_g2.dim_customer_telco_g2 c ON c.customer_key = f.customer_key
LEFT JOIN telco_g2.dim_contract_telco_g2 ct ON ct.contract_key = f.contract_key
LEFT JOIN telco_g2.dim_service_telco_g2 sv ON sv.service_key = f.service_key;

-- BLOQUE 2. Línea base del modelo. CSV de referencia: 7043 / 1869 / 26.54%.
SELECT
    COUNT(*) AS clientes,
    SUM(churn_flag) AS abandonos_historicos,
    SUM(CASE WHEN churn_flag = 0 THEN 1 ELSE 0 END) AS clientes_sin_abandono,
    ROUND(100.0 * SUM(churn_flag) / NULLIF(COUNT(*), 0), 2) AS churn_pct,
    ROUND(AVG(monthly_charges), 2) AS cargo_mensual_promedio,
    SUM(total_charges_imputed) AS total_imputaciones
FROM telco_g2.fact_contracts_telco_g2;

-- BLOQUE 3. Segmentación para dashboard y priorización.
-- service_level usa la regla implementada en Talend:
-- Sin Internet; Protegido (seguridad o soporte); Basico (resto con Internet).
-- Ordenar por volumen de abandonos dirige el análisis al impacto potencial.
WITH segmentos AS (
    SELECT ct.contract_type, sv.service_level,
        COUNT(*) AS clientes,
        SUM(f.churn_flag) AS abandonos_historicos,
        SUM(CASE WHEN f.churn_flag = 0 THEN 1 ELSE 0 END) AS clientes_sin_abandono,
        SUM(f.monthly_charges) AS suma_cargos_mensuales,
        AVG(f.monthly_charges) AS cargo_mensual_promedio,
        AVG(f.tenure_months) AS antiguedad_promedio_meses,
        SUM(f.total_charges_imputed) AS imputaciones
    FROM telco_g2.fact_contracts_telco_g2 f
    JOIN telco_g2.dim_contract_telco_g2 ct ON ct.contract_key = f.contract_key
    JOIN telco_g2.dim_service_telco_g2 sv ON sv.service_key = f.service_key
    GROUP BY ct.contract_type, sv.service_level
), globales AS (
    SELECT COUNT(*) AS clientes_globales, SUM(churn_flag) AS abandonos_globales
    FROM telco_g2.fact_contracts_telco_g2
)
SELECT s.contract_type, s.service_level,
    s.clientes, s.abandonos_historicos, s.clientes_sin_abandono,
    ROUND(100.0 * s.abandonos_historicos / NULLIF(s.clientes, 0), 2) AS churn_pct,
    ROUND(100.0 * s.clientes / NULLIF(g.clientes_globales, 0), 2) AS clientes_pct,
    ROUND(100.0 * s.abandonos_historicos / NULLIF(g.abandonos_globales, 0), 2)
        AS participacion_abandonos_pct,
    ROUND((1.0 * s.abandonos_historicos / NULLIF(s.clientes, 0)) /
        NULLIF(1.0 * g.abandonos_globales / NULLIF(g.clientes_globales, 0), 0), 2)
        AS razon_churn_vs_global,
    ROUND(s.cargo_mensual_promedio, 2) AS cargo_mensual_promedio,
    ROUND(s.antiguedad_promedio_meses, 2) AS antiguedad_promedio_meses,
    s.imputaciones
FROM segmentos s
CROSS JOIN globales g
ORDER BY s.abandonos_historicos DESC, churn_pct DESC;

-- BLOQUE 4. Cuatro grupos estratégicos del equipo, con prioridad explícita.
-- El CASE asigna cada cliente al PRIMER criterio que cumple.
-- SEG-04 es el resto de clientes: no equivale a fidelizados ni a bajo riesgo.
WITH clasificados AS (
    SELECT f.customer_key, f.churn_flag, f.monthly_charges,
        CASE
            WHEN ct.contract_type = 'Month-to-month'
                 AND sv.internet_service = 'Fiber optic' AND sv.service_level = 'Basico'
                THEN 'SEG-01'
            WHEN ct.contract_type = 'Month-to-month' AND f.tenure_months <= 12
                THEN 'SEG-02'
            WHEN ct.contract_type = 'Month-to-month' AND ct.payment_method = 'Electronic check'
                THEN 'SEG-03'
            ELSE 'SEG-04'
        END AS codigo_segmento
    FROM telco_g2.fact_contracts_telco_g2 f
    JOIN telco_g2.dim_contract_telco_g2 ct ON ct.contract_key = f.contract_key
    JOIN telco_g2.dim_service_telco_g2 sv ON sv.service_key = f.service_key
), segmentos AS (
    SELECT codigo_segmento, COUNT(*) AS clientes,
        SUM(churn_flag) AS abandonos_historicos,
        SUM(CASE WHEN churn_flag = 0 THEN 1 ELSE 0 END) AS clientes_sin_abandono,
        AVG(monthly_charges) AS cargo_mensual_promedio
    FROM clasificados GROUP BY codigo_segmento
)
SELECT codigo_segmento, clientes, abandonos_historicos, clientes_sin_abandono,
    ROUND(100.0 * abandonos_historicos / NULLIF(clientes, 0), 2) AS churn_pct,
    ROUND(cargo_mensual_promedio, 2) AS cargo_mensual_promedio
FROM segmentos
ORDER BY codigo_segmento;
