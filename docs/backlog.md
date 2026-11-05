# 📋 Backlog del Proyecto - Datatón Genius Lab III
**Reto:** Telecomunicaciones — IBM Telco Churn: Segmentación y Recomendador de Retención  
**Duración:** 4 de Noviembre - 10 de Noviembre  

---

## 📅 Sprint 0: Kickoff & Configuración Inicial (Miércoles 4 de Noviembre)
**Meta:** Repositorio inicializado, arquitectura definida, backlog publicado y README borrador aprobado.

| ID | Tarea / Historia | Responsable | Estado | Entregable |
|---|---|---|---|---|
| **KICK-01** | Inicialización del repositorio Git con estructura estándar (`/data`, `/talend_jobs`, `/sql`, `/docs`) | Presentador / PM | ✅ Completado | Estructura en GitHub |
| **KICK-02** | Carga del dataset base (`telco_churn.csv`) y validación de esquema inicial | Data Engineer | ✅ Completado | `data/telco_churn.csv` |
| **KICK-03** | Redacción y diseño del `README.md` borrador con reglas, roles y arquitectura | Presentador / PM | ✅ Completado | `README.md` |
| **KICK-04** | Definición del Backlog general y alineación de sprints por roles | Todos | ✅ Completado | `docs/backlog.md` |

---

## 🏃 Sprint 1: Ingesta, Exploración & Calidad de Datos (Jueves 5 de Noviembre)
**Meta:** Pipeline de ingesta funcional en Talend hacia SingleStore, reglas de calidad (DQ) iniciales y modelo raw listo.

| ID | Tarea / Historia | Responsable | Estado | Entregable |
|---|---|---|---|---|
| **SP1-01** | Configuración de conexión en Talend Studio hacia SingleStore (`raw_telco_g2`) | Data Engineer | ✅ Completado | Conexión Talend activa |
| **SP1-02** | Creación del Job `job_telco_ingesta` en Talend con transformaciones tMap | Data Engineer | ✅ Completado | Export en `talend_jobs/job_telco_ingesta.zip` |
| **SP1-03** | DDL de tabla de aterrizaje raw en SingleStore (`sql/01_ddl_singlestore.sql`) | Data Engineer | ✅ Completado | Script SQL DDL ejecutado (7,043 registros) |
| **SP1-04** | Perfilado exploratorio de datos (EDA) y cálculo de tasa base de churn (26.5%) | Data Analyst | ✅ Completado | Script `sql/05_eda_churn_analysis.sql` |
| **SP1-05** | Definición de las 5 reglas de Data Quality (DQ) obligatorias en OpenMetadata | Data Steward | ✅ Completado | Reporte `docs/data_quality/dq_report.md` |
| **SP1-06** | Resolución de anomalía de 11 registros en blanco en `TotalCharges` (imputación/tratamiento) | Data Steward / DE | ✅ Completado | Regla de imputación validada (TotalCharges = 0.00) |
| **SP1-07** | Primer commit diario del equipo y reporte de avance en standup | Presentador / PM | ✅ Completado | Commits diarios verificados en GitHub |

---

## 🚀 Sprint 2: ELT, Modelo Dimensional, Linaje & Analítica (Viernes 6 de Noviembre)
**Meta:** Pipeline end-to-end completado (SingleStore -> Snowflake), catálogo y linaje en OpenMetadata, modelo de segmentación y recomendador.

| ID | Tarea / Historia | Responsable | Estado | Entregable |
|---|---|---|---|---|
| **SP2-01** | Implementación del proceso ELT en Talend hacia Snowflake | Data Engineer | ⏳ Pendiente | Job ELT documentado |
| **SP2-02** | Modelado dimensional en Snowflake: creación de `dim_customer` y `fact_contracts` | Data Engineer | ⏳ Pendiente | `sql/02_snowflake_model.sql` |
| **SP2-03** | Configuración de linaje de datos fuente → destino (al menos 3 assets) en OpenMetadata | Data Steward | ⏳ Pendiente | Capturas y linaje en OpenMetadata |
| **SP2-04** | Verificación y certificación de umbral de calidad global (meta: ≥ 99%) | Data Steward | ⏳ Pendiente | Reporte DQ final |
| **SP2-05** | Desarrollo del modelo de segmentación por contrato y nivel de servicio | Data Analyst | ⏳ Pendiente | `sql/03_segmentation.sql` |
| **SP2-06** | Construcción de matriz / recomendador de acciones de retención por segmento | Data Analyst | ⏳ Pendiente | Tabla de recomendador |
| **SP2-07** | Diseño del Dashboard interactivo en Tableau con KPIs de Churn | Data Analyst | ⏳ Pendiente | Dashboard Tableau / capturas |
| **SP2-08** | Documentación de la guía de ejecución paso a paso del pipeline en el README | Data Engineer / PM | ⏳ Pendiente | Sección 6 de `README.md` |

---

## 🎤 Sprint 3: Ensayo, Pulido & Demo Day (Lunes 9 - Martes 10 de Noviembre)
**Meta:** Presentación pulida de 10 min, demo técnica en vivo, métricas de impacto calculadas y README final.

| ID | Tarea / Historia | Responsable | Estado | Entregable |
|---|---|---|---|---|
| **DEMO-01** | Cálculo del KPI estrella: % de reducción de churn esperada por segmento | Data Analyst | ⏳ Pendiente | Resultados cuantificados |
| **DEMO-02** | Estructuración y diseño del Deck de presentación (problema, arquitectura, hallazgos, KPI, próximos pasos) | Presentador / PM | ⏳ Pendiente | Presentación (slides) |
| **DEMO-03** | Ensayo general de la presentación (10 min exposición + 5 min Q&A) | Todo el equipo | ⏳ Pendiente | Grabación / feedback |
| **DEMO-04** | Pulido final de documentación y verificación de requisitos de evaluación (rúbrica al 100%) | Presentador / PM | ⏳ Pendiente | `README.md` final en repo |
| **DEMO-05** | Cierre del Datatón y Demo Day en vivo | Todo el equipo | ⏳ Pendiente | Pitch y demo en vivo |
