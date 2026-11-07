-- Recomendador integrado con la propuesta del equipo (commit 275995f).
-- Ejecutar los dos bloques por separado en DBeaver. Solo lectura.
-- No crea ni vacia tablas; no modifica una matriz existente en SingleStore.
-- Requiere aprobar los controles y conciliar los grupos de 05_segmentation.sql.
-- Los supuestos centrales 20/15/12/2% proceden de la propuesta del equipo.
-- Se interpretan como reducción RELATIVA y NO como puntos porcentuales.
-- Conservador = mitad del supuesto central; optimista = 1.5 veces.
-- Son escenarios ilustrativos sin eficacia validada ni costes evaluados.
-- La fecha de abandono y la moneda no están documentadas en el CSV.

-- BLOQUE 1. Matriz de acciones y escenarios: 4 grupos x 3 = 12 filas.
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
), propuestas AS (
    SELECT 'SEG-01' AS codigo_segmento,
        'Fibra básica mes a mes' AS nombre_segmento,
        'Revisar incidencias; ofrecer soporte y opción anual voluntaria' AS accion_propuesta,
        'Evaluar prueba de soporte; descuento sujeto a coste y aprobación' AS incentivo_propuesto,
        'Contacto por canal consentido' AS canal_propuesto,
        0.20 AS reduccion_relativa_central
    UNION ALL SELECT 'SEG-02', 'Nuevos mes a mes, excluido SEG-01',
        'Acompanamiento de incorporación, uso y facturación',
        'Evaluar asistencia inicial y seguimiento; no hay fecha de alta para programarlo',
        'Canal digital consentido', 0.15
    UNION ALL SELECT 'SEG-03', 'Cheque electrónico mes a mes, excluidos SEG-01 y SEG-02',
        'Revisar fricciones de pago y ofrecer pago automático voluntario',
        'Evaluar incentivo de adopción según coste y elegibilidad',
        'Portal de pagos o canal consentido', 0.12
    UNION ALL SELECT 'SEG-04', 'Resto de clientes: seguimiento diferenciado',
        'Revisar subgrupos por contrato y servicio; mantener atención preventiva',
        'Definir beneficio tras revisar necesidad y coste; no asumir bajo riesgo',
        'Canal consentido según preferencia', 0.02
), escenarios AS (
    SELECT 'Conservador' AS escenario, 0.5 AS factor_escenario
    UNION ALL SELECT 'Central', 1.0
    UNION ALL SELECT 'Optimista', 1.5
), evaluados AS (
    SELECT s.*, p.nombre_segmento, p.accion_propuesta, p.incentivo_propuesto,
        p.canal_propuesto, e.escenario,
        p.reduccion_relativa_central * e.factor_escenario AS reduccion_relativa
    FROM segmentos s
    JOIN propuestas p ON p.codigo_segmento = s.codigo_segmento
    CROSS JOIN escenarios e
)
SELECT codigo_segmento, nombre_segmento, clientes, abandonos_historicos,
    clientes_sin_abandono,
    ROUND(100.0 * abandonos_historicos / NULLIF(clientes, 0), 2) AS churn_historico_pct,
    accion_propuesta, incentivo_propuesto, canal_propuesto, escenario,
    ROUND(100.0 * reduccion_relativa, 2) AS reduccion_relativa_supuesta_pct,
    ROUND(100.0 * abandonos_historicos / NULLIF(clientes, 0)
        * (1 - reduccion_relativa), 2) AS churn_escenario_pct,
    ROUND(100.0 * abandonos_historicos / NULLIF(clientes, 0)
        * reduccion_relativa, 2) AS reduccion_puntos_porcentuales,
    ROUND(abandonos_historicos * reduccion_relativa, 2)
        AS abandonos_evitados_equivalentes
FROM evaluados
ORDER BY codigo_segmento, reduccion_relativa;

-- BLOQUE 2. KPI global ponderado por abandonos; no promedia tasas de grupos.
-- Agregar cada escenario por separado. No sumar las tres proyecciones.
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
), propuestas AS (
    SELECT 'SEG-01' AS codigo_segmento,
        'Fibra básica mes a mes' AS nombre_segmento,
        'Revisar incidencias; ofrecer soporte y opción anual voluntaria' AS accion_propuesta,
        'Evaluar prueba de soporte; descuento sujeto a coste y aprobación' AS incentivo_propuesto,
        'Contacto por canal consentido' AS canal_propuesto,
        0.20 AS reduccion_relativa_central
    UNION ALL SELECT 'SEG-02', 'Nuevos mes a mes, excluido SEG-01',
        'Acompanamiento de incorporación, uso y facturación',
        'Evaluar asistencia inicial y seguimiento; no hay fecha de alta para programarlo',
        'Canal digital consentido', 0.15
    UNION ALL SELECT 'SEG-03', 'Cheque electrónico mes a mes, excluidos SEG-01 y SEG-02',
        'Revisar fricciones de pago y ofrecer pago automático voluntario',
        'Evaluar incentivo de adopción según coste y elegibilidad',
        'Portal de pagos o canal consentido', 0.12
    UNION ALL SELECT 'SEG-04', 'Resto de clientes: seguimiento diferenciado',
        'Revisar subgrupos por contrato y servicio; mantener atención preventiva',
        'Definir beneficio tras revisar necesidad y coste; no asumir bajo riesgo',
        'Canal consentido según preferencia', 0.02
), escenarios AS (
    SELECT 'Conservador' AS escenario, 0.5 AS factor_escenario
    UNION ALL SELECT 'Central', 1.0
    UNION ALL SELECT 'Optimista', 1.5
), evaluados AS (
    SELECT s.*, p.nombre_segmento, p.accion_propuesta, p.incentivo_propuesto,
        p.canal_propuesto, e.escenario,
        p.reduccion_relativa_central * e.factor_escenario AS reduccion_relativa
    FROM segmentos s
    JOIN propuestas p ON p.codigo_segmento = s.codigo_segmento
    CROSS JOIN escenarios e
)
SELECT escenario, SUM(clientes) AS clientes,
    SUM(abandonos_historicos) AS abandonos_historicos,
    ROUND(100.0 * SUM(abandonos_historicos) / NULLIF(SUM(clientes), 0), 2)
        AS churn_historico_global_pct,
    ROUND(SUM(abandonos_historicos * reduccion_relativa), 2)
        AS abandonos_evitados_equivalentes,
    ROUND(100.0 * SUM(abandonos_historicos * reduccion_relativa)
        / NULLIF(SUM(abandonos_historicos), 0), 2) AS reduccion_relativa_global_pct,
    ROUND(100.0 * SUM(abandonos_historicos * (1 - reduccion_relativa))
        / NULLIF(SUM(clientes), 0), 2) AS churn_escenario_global_pct,
    ROUND(100.0 * SUM(abandonos_historicos * reduccion_relativa)
        / NULLIF(SUM(clientes), 0), 2) AS reduccion_global_puntos_porcentuales
FROM evaluados
GROUP BY escenario
ORDER BY SUM(abandonos_historicos * reduccion_relativa);
