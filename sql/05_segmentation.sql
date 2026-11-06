-- ==============================================================================
-- PROYECTO: Datatón Genius Lab III - Telecomunicaciones (IBM Telco Churn)
-- SCRIPT: 05_segmentation.sql
-- DESCRIPCIÓN: Modelo de Segmentación de Clientes y Matriz Recomendadora de Retención
-- ENTREGABLES: Sprint 2 - Tareas SP2-05 (Segmentación) y SP2-06 (Recomendador)
-- BASE DE DATOS: telco_g2 (SingleStore Cloud / MySQL)
-- ==============================================================================

USE telco_g2;

-- ==============================================================================
-- 1. TABLA: MATRIZ RECOMENDADORA DE ACCIONES DE RETENCIÓN (SP2-06)
-- Grano: 1 registro por cada segmento estratégico identificado
-- ==============================================================================
CREATE TABLE IF NOT EXISTS matriz_recomendador_retencion (
    segmento_id INT PRIMARY KEY,
    codigo_segmento VARCHAR(10) NOT NULL,
    nombre_segmento VARCHAR(80) NOT NULL,
    nivel_riesgo VARCHAR(20) NOT NULL,
    criterio_clasificacion VARCHAR(255) NOT NULL,
    tasa_churn_historica_pct DECIMAL(5,2) NOT NULL,
    accion_retencion VARCHAR(150) NOT NULL,
    incentivo_oferta VARCHAR(255) NOT NULL,
    canal_contacto VARCHAR(60) NOT NULL,
    reduccion_churn_esperada_pct DECIMAL(5,2) NOT NULL, -- KPI Estrella (Supuesto de impacto)
    tasa_churn_proyectada_pct DECIMAL(5,2) NOT NULL,
    justificacion_negocio TEXT NOT NULL,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Limpieza preventiva
TRUNCATE TABLE matriz_recomendador_retencion;

-- Poblado de los 4 Segmentos Estratégicos del Negocio
INSERT INTO matriz_recomendador_retencion (
    segmento_id, codigo_segmento, nombre_segmento, nivel_riesgo, criterio_clasificacion,
    tasa_churn_historica_pct, accion_retencion, incentivo_oferta, canal_contacto,
    reduccion_churn_esperada_pct, tasa_churn_proyectada_pct, justificacion_negocio
) VALUES 
(
    1,
    'SEG-01',
    'Alerta Roja: Fibra Crítica',
    'Extremo',
    'Contrato Month-to-month + Fiber Optic + Nivel Básico (Sin Soporte/Seguridad)',
    54.61,
    'Migración Bonificada a Plan Anual Protegido',
    '3 meses gratuitos de Soporte Técnico + Seguridad Online al migrar a contrato de 1 año con 15% de descuento en la mensualidad',
    'Llamada Outbound Fidelización / Notificación Push App',
    20.00,
    34.61,
    'Son clientes de alto valor monetario (~$85/mes) que pagan el ticket más alto pero sufren fricción técnica sin cobertura de soporte. Convertirlos a contrato anual con soporte elimina la causa raíz de deserción.'
),
(
    2,
    'SEG-02',
    'Nuevos en Fuga: Onboarding Frágil',
    'Alto',
    'Contrato Month-to-month + Antigüedad 0-12 meses (Excepto Fibra Crítica)',
    43.20,
    'Programa de Éxito de Cliente en Primeros 90 Días',
    'Bono de $10 de descuento en factura del mes 3 y mes 6 + Checkup proactivo de velocidad en el día 45',
    'WhatsApp Business / Email Interactivo',
    15.00,
    28.20,
    'El 47% del churn global ocurre en el primer año antes de amortizar el Costo de Adquisición (CAC). Acompañar el onboarding temprano previene el abandono por falta de uso o dudas de facturación.'
),
(
    3,
    'SEG-03',
    'Fricción Operativa: Pago Manual',
    'Medio-Alto',
    'Contrato Month-to-month + Pago Electronic Check (Antigüedad > 12m)',
    35.80,
    'Campaña de Automatización de Pagos (Paperless & Autopay)',
    'Crédito único de $15 en la siguiente factura por afiliar Tarjeta de Crédito o Débito Bancario automático',
    'SMS con Enlace Seguro / Banner en Portal de Pagos',
    12.00,
    23.80,
    'El cheque electrónico exige un esfuerzo manual recurrente mensual. Cada ciclo de pago es un recordatorio que incentiva el abandono; la domiciliación bancaria incrementa la inercia y permanencia.'
),
(
    4,
    'SEG-04',
    'Champions / Fidelizados Blindados',
    'Bajo / Mínimo',
    'Contratos One Year / Two Year O Servicio Protegido',
    5.40,
    'Programa de Lealtad y Venta Cruzada (Cross-Selling)',
    'Descuento familiar del 25% en segunda línea móvil o streaming bonificado por 6 meses por renovación anticipada',
    'Email de Agradecimiento VIP / Portal Clientes',
    2.00,
    3.40,
    'Clientes con alto LTV y mínimo riesgo. No requieren descuentos agresivos de retención, sino acciones de reconocimiento de lealtad y ampliación de canasta de servicios.'
);


-- ==============================================================================
-- 2. VISTA ANALÍTICA: SEGMENTACIÓN DE CLIENTES EN TIEMPO REAL (SP2-05)
-- Cruza fact_contracts con dimensiones y asigna dinámicamente el segmento
-- ==============================================================================
CREATE OR REPLACE VIEW vw_segmentacion_clientes_telco AS
SELECT 
    c.customer_id,
    c.gender,
    c.senior_citizen,
    c.partner,
    c.dependents,
    ct.contract_type,
    ct.paperless_billing,
    ct.payment_method,
    s.internet_service,
    s.tech_support,
    s.online_security,
    s.service_level,
    f.tenure_months,
    f.tenure_group,
    f.monthly_charges,
    f.total_charges,
    f.churn_flag,
    CASE 
        -- Segmento 1: Fibra Crítica
        WHEN ct.contract_type = 'Month-to-month' 
             AND s.internet_service = 'Fiber optic' 
             AND s.service_level = 'Basico' 
        THEN 'SEG-01'
        
        -- Segmento 2: Nuevos en Fuga (0-12m)
        WHEN ct.contract_type = 'Month-to-month' 
             AND f.tenure_months <= 12 
        THEN 'SEG-02'
        
        -- Segmento 3: Fricción Operativa (Pago manual / Cheque electrónico)
        WHEN ct.contract_type = 'Month-to-month' 
             AND ct.payment_method = 'Electronic check' 
        THEN 'SEG-03'
        
        -- Segmento 4: Fidelizados / Blindados
        ELSE 'SEG-04'
    END AS codigo_segmento,
    m.nombre_segmento,
    m.nivel_riesgo,
    m.accion_retencion,
    m.incentivo_oferta,
    m.canal_contacto,
    m.reduccion_churn_esperada_pct
FROM fact_contracts_telco_g2 f
JOIN dim_customer_telco_g2 c ON f.customer_key = c.customer_key
JOIN dim_contract_telco_g2 ct ON f.contract_key = ct.contract_key
JOIN dim_service_telco_g2 s ON f.service_key = s.service_key
LEFT JOIN matriz_recomendador_retencion m ON (
    CASE 
        WHEN ct.contract_type = 'Month-to-month' AND s.internet_service = 'Fiber optic' AND s.service_level = 'Basico' THEN 'SEG-01'
        WHEN ct.contract_type = 'Month-to-month' AND f.tenure_months <= 12 THEN 'SEG-02'
        WHEN ct.contract_type = 'Month-to-month' AND ct.payment_method = 'Electronic check' THEN 'SEG-03'
        ELSE 'SEG-04'
    END
) = m.codigo_segmento;


-- ==============================================================================
-- 3. CONSULTA RESUMEN: IMPACTO DE NEGOCIO POR SEGMENTO (PARA TABLEAU / DEMO)
-- Muestra la distribución de clientes, MRR en riesgo y ahorro proyectado
-- ==============================================================================
SELECT 
    v.codigo_segmento,
    v.nombre_segmento,
    v.nivel_riesgo,
    COUNT(*) AS total_clientes,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM fact_contracts_telco_g2), 2) AS pct_base_clientes,
    SUM(v.churn_flag) AS clientes_churn_actual,
    ROUND(SUM(v.churn_flag) * 100.0 / COUNT(*), 2) AS tasa_churn_real_pct,
    ROUND(AVG(v.monthly_charges), 2) AS mrr_promedio_por_cliente,
    ROUND(SUM(CASE WHEN v.churn_flag = 1 THEN v.monthly_charges ELSE 0 END), 2) AS mrr_mensual_perdido_actual,
    v.accion_retencion,
    v.reduccion_churn_esperada_pct AS reduccion_kpi_estrella_pct,
    -- Estimación de clientes rescatados
    ROUND(SUM(v.churn_flag) * (v.reduccion_churn_esperada_pct / 100.0), 0) AS clientes_retenidos_estimados,
    -- Impacto en ingresos recurrentes retenidos (Anualizado)
    ROUND(
        SUM(v.churn_flag) * (v.reduccion_churn_esperada_pct / 100.0) * AVG(v.monthly_charges) * 12, 
        2
    ) AS ingresos_anuales_rescatados_usd
FROM vw_segmentacion_clientes_telco v
GROUP BY 
    v.codigo_segmento, v.nombre_segmento, v.nivel_riesgo, v.accion_retencion, v.reduccion_churn_esperada_pct
ORDER BY v.codigo_segmento;


-- ==============================================================================
-- 4. KPI ESTRELLA GLOBAL DE IMPACTO (DEMO DAY - DIAPOSITIVA CLAVE)
-- ==============================================================================
SELECT 
    COUNT(*) AS base_total_clientes,
    SUM(churn_flag) AS total_churn_historico,
    ROUND(SUM(churn_flag) * 100.0 / COUNT(*), 2) AS tasa_churn_global_actual_pct,
    ROUND(
        SUM(
            CASE 
                WHEN codigo_segmento = 'SEG-01' THEN churn_flag * 0.20
                WHEN codigo_segmento = 'SEG-02' THEN churn_flag * 0.15
                WHEN codigo_segmento = 'SEG-03' THEN churn_flag * 0.12
                WHEN codigo_segmento = 'SEG-04' THEN churn_flag * 0.02
                ELSE 0 
            END
        ), 
        0
    ) AS total_clientes_rescatados_proyeccion,
    ROUND(
        (SUM(churn_flag) - SUM(
            CASE 
                WHEN codigo_segmento = 'SEG-01' THEN churn_flag * 0.20
                WHEN codigo_segmento = 'SEG-02' THEN churn_flag * 0.15
                WHEN codigo_segmento = 'SEG-03' THEN churn_flag * 0.12
                WHEN codigo_segmento = 'SEG-04' THEN churn_flag * 0.02
                ELSE 0 
            END
        )) * 100.0 / COUNT(*), 
        2
    ) AS tasa_churn_global_proyectada_pct,
    ROUND(
        (ROUND(SUM(churn_flag) * 100.0 / COUNT(*), 2) - 
         ROUND(
            (SUM(churn_flag) - SUM(
                CASE 
                    WHEN codigo_segmento = 'SEG-01' THEN churn_flag * 0.20
                    WHEN codigo_segmento = 'SEG-02' THEN churn_flag * 0.15
                    WHEN codigo_segmento = 'SEG-03' THEN churn_flag * 0.12
                    WHEN codigo_segmento = 'SEG-04' THEN churn_flag * 0.02
                    ELSE 0 
                END
            )) * 100.0 / COUNT(*), 2
         )), 
        2
    ) AS reduccion_neta_puntos_porcentuales_kpi_estrella
FROM vw_segmentacion_clientes_telco;
