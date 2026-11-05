# ðŸ“‹ Backlog del Proyecto - DatatÃ³n Genius Lab III
**Reto:** Telecomunicaciones â€” IBM Telco Churn: SegmentaciÃ³n y Recomendador de RetenciÃ³n  
**DuraciÃ³n:** 4 de Noviembre - 10 de Noviembre  

---

## ðŸ“… Sprint 0: Kickoff & ConfiguraciÃ³n Inicial (MiÃ©rcoles 4 de Noviembre)
**Meta:** Repositorio inicializado, arquitectura definida, backlog publicado y README borrador aprobado.

| ID | Tarea / Historia | Responsable | Estado | Entregable |
|---|---|---|---|---|
| **KICK-01** | InicializaciÃ³n del repositorio Git con estructura estÃ¡ndar (`/data`, `/talend_jobs`, `/sql`, `/docs`) | Presentador / PM | âœ… Completado | Estructura en GitHub |
| **KICK-02** | Carga del dataset base (`telco_churn.csv`) y validaciÃ³n de esquema inicial | Data Engineer | âœ… Completado | `data/telco_churn.csv` |
| **KICK-03** | RedacciÃ³n y diseÃ±o del `README.md` borrador con reglas, roles y arquitectura | Presentador / PM | âœ… Completado | `README.md` |
| **KICK-04** | DefiniciÃ³n del Backlog general y alineaciÃ³n de sprints por roles | Todos | âœ… Completado | `docs/backlog.md` |

---

## ðŸƒ Sprint 1: Ingesta, ExploraciÃ³n & Calidad de Datos (Jueves 5 de Noviembre)
**Meta:** Pipeline de ingesta funcional en Talend hacia SingleStore, reglas de calidad (DQ) iniciales y modelo raw listo.

| ID | Tarea / Historia | Responsable | Estado | Entregable |
|---|---|---|---|---|
| **SP1-01** | ConfiguraciÃ³n de conexiÃ³n en Talend Studio hacia SingleStore (`raw_telco_g2`) | Data Engineer | âœ… Completado | ConexiÃ³n Talend activa |
| **SP1-02** | CreaciÃ³n del Job `job_telco_ingesta` en Talend con transformaciones tMap | Data Engineer | âœ… Completado | Export en `talend_jobs/job_telco_ingesta.zip` |
| **SP1-03** | DDL de tabla de aterrizaje raw en SingleStore (`sql/01_ddl_raw_singlestore.sql`) | Data Engineer | âœ… Completado | Script SQL DDL ejecutado (7,043 registros) |
| **SP1-04** | Perfilado exploratorio de datos (EDA) y cÃ¡lculo de tasa base de churn (26.5%) | Data Analyst | âœ… Completado | Script `sql/03_eda_analisis_churn.sql` |
| **SP1-05** | DefiniciÃ³n de las 5 reglas de Data Quality (DQ) obligatorias en OpenMetadata | Data Steward | âœ… Completado | Reporte `docs/data_quality/dq_report.md` y script `sql/02_dq_auditoria_calidad.sql` |
| **SP1-06** | ResoluciÃ³n de anomalÃ­a de 11 registros en blanco en `TotalCharges` (imputaciÃ³n/tratamiento) | Data Steward / DE | âœ… Completado | Regla de imputaciÃ³n validada (TotalCharges = 0.00) |
| **SP1-07** | Primer commit diario del equipo y reporte de avance en standup | Presentador / PM | âœ… Completado | Commits diarios verificados en GitHub |

---

## ðŸš€ Sprint 2: ELT, Modelo Dimensional, Linaje & AnalÃ­tica (Viernes 6 de Noviembre)
**Meta:** Pipeline end-to-end completado (SingleStore -> Snowflake), catÃ¡logo y linaje en OpenMetadata, modelo de segmentaciÃ³n y recomendador.

| ID | Tarea / Historia | Responsable | Estado | Entregable |
|---|---|---|---|---|
| **SP2-01** | ImplementaciÃ³n del proceso ELT en Talend hacia SingleStore | Data Engineer | â³ Pendiente | Job ELT documentado |
| **SP2-02** | Modelado dimensional en SingleStore: creaciÃ³n de `dim_customer_telco_g2`, `dim_contract_telco_g2`, `dim_service_telco_g2` y `fact_contracts_telco_g2` | Data Engineer | âœ… Completado | `sql/ddl_Modelo_Dimensional_Telco_g2.sql` |
| **SP2-03** | ConfiguraciÃ³n de linaje de datos fuente â†’ destino (al menos 3 assets) en OpenMetadata | Data Steward | â³ Pendiente | Capturas y linaje en OpenMetadata |
| **SP2-04** | VerificaciÃ³n y certificaciÃ³n de umbral de calidad global (meta: â‰¥ 99%) | Data Steward | â³ Pendiente | Reporte DQ final |
| **SP2-05** | Desarrollo del modelo de segmentaciÃ³n por contrato y nivel de servicio | Data Analyst | â³ Pendiente | `sql/05_segmentation.sql` |
| **SP2-06** | ConstrucciÃ³n de matriz / recomendador de acciones de retenciÃ³n por segmento | Data Analyst | â³ Pendiente | Tabla de recomendador |
| **SP2-07** | DiseÃ±o del Dashboard interactivo en Tableau con KPIs de Churn | Data Analyst | â³ Pendiente | Dashboard Tableau / capturas |
| **SP2-08** | DocumentaciÃ³n de la guÃ­a de ejecuciÃ³n paso a paso del pipeline en el README | Data Engineer / PM | â³ Pendiente | SecciÃ³n 6 de `README.md` |

---

## ðŸŽ¤ Sprint 3: Ensayo, Pulido & Demo Day (Lunes 9 - Martes 10 de Noviembre)
**Meta:** PresentaciÃ³n pulida de 10 min, demo tÃ©cnica en vivo, mÃ©tricas de impacto calculadas y README final.

| ID | Tarea / Historia | Responsable | Estado | Entregable |
|---|---|---|---|---|
| **DEMO-01** | CÃ¡lculo del KPI estrella: % de reducciÃ³n de churn esperada por segmento | Data Analyst | â³ Pendiente | Resultados cuantificados |
| **DEMO-02** | EstructuraciÃ³n y diseÃ±o del Deck de presentaciÃ³n (problema, arquitectura, hallazgos, KPI, prÃ³ximos pasos) | Presentador / PM | â³ Pendiente | PresentaciÃ³n (slides) |
| **DEMO-03** | Ensayo general de la presentaciÃ³n (10 min exposiciÃ³n + 5 min Q&A) | Todo el equipo | â³ Pendiente | GrabaciÃ³n / feedback |
| **DEMO-04** | Pulido final de documentaciÃ³n y verificaciÃ³n de requisitos de evaluaciÃ³n (rÃºbrica al 100%) | Presentador / PM | â³ Pendiente | `README.md` final en repo |
| **DEMO-05** | Cierre del DatatÃ³n y Demo Day en vivo | Todo el equipo | â³ Pendiente | Pitch y demo en vivo |
