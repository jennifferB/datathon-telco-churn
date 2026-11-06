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
**Meta:** Ingesta funcional CSV → Talend → SingleStore, diagnóstico de calidad, definición dimensional y borrador de integración hacia Snowflake.

| ID | Tarea / Historia | Responsable | Estado | Entregable |
|---|---|---|---|---|
| **SP1-01** | Configuración de conexión en Talend Studio hacia SingleStore (`raw_telco_g2`) | Data Engineer | ✅ Completado | Conexión Talend activa |
| **SP1-02** | Creación del Job `job_telco_ingesta` en Talend con transformaciones tMap | Data Engineer | ✅ Completado | Export en `talend_jobs/job_telco_ingesta.zip` |
| **SP1-03** | Estructura raw en SingleStore y DDL de referencia | Data Engineer | ✅ Completado | SHOW CREATE TABLE compartido: 22 columnas; importes VARCHAR(20), sin PRIMARY KEY. Conteo: 7.043 filas. DDL alineado en sql/01_ddl_raw_singlestore.sql |
| **SP1-04** | Perfilado raw y exploración por contrato e Internet | Equipo | ✅ Completado | sql/07 y sql/08; reporte con seis capturas: 22 columnas, 17 dominios, 7 controles de coherencia; churn global 26,54% |
| **SP1-05** | Configurar y ejecutar las cinco reglas DQ, desglosadas en siete casos | Equipo | ✅ Completado | Evidencia de OpenMetadata: 6 exitosos, 1 fallido por blancos conocidos. No equivale a certificación global |
| **SP1-06** | Diagnóstico y conservación de los 11 blancos en raw | Equipo | ✅ Completado | 11 blancos, todos con tenure=0; completitud 99,84%. La imputación se traslada a la transformación posterior (SP2-09) |
| **SP1-07** | Un commit por integrante por día y registro de standup | Equipo | 🔄 Seguimiento diario | Historial Git y acuerdos del equipo; comprobar cada integrante por separado |
| **SP1-08** | Documentar diccionario de las 22 columnas | Equipo | ✅ Completado | docs/catalogo/diccionario_datos_telco.md |
| **SP1-09** | Borrador de conexión y mapeo SingleStore → Snowflake | Equipo | 🔄 Scripts disponibles | sql/Snowflake define tablas, roles y permisos; la carga y su conciliación se verifican en SP2-01 |

---

> Actualización del 6 de noviembre: las tareas de Sprint 1 conservan el diagnóstico histórico de raw en DSADEV. Los resultados Cloud se documentan en Sprint 2; los SQL de referencia Snowflake no se contabilizan como una carga ejecutada.

## 🚀 Sprint 2: ELT, Modelo Dimensional, Linaje & Analítica (Viernes 6 de Noviembre)
**Meta:** Pipeline end-to-end completado (SingleStore -> Snowflake), catálogo y linaje en OpenMetadata, modelo de segmentación y recomendador.

| ID | Tarea / Historia | Responsable | Estado | Entregable |
|---|---|---|---|---|
| **SP2-01** | Implementar y validar la integración SingleStore → Snowflake | Data Engineer | ⏳ Pendiente | Job/proceso documentado y evidencia de tablas cargadas en Snowflake |
| **SP2-02** | Crear las tres dimensiones y la tabla de hechos en SingleStore Cloud | Equipo | ✅ Creado y cargado según validación del equipo | Jobs Talend y sql/11–12. Conteos de aceptación: 7.043 clientes, 24 contratos, 322 servicios, 7.043 hechos |
| **SP2-03** | Registrar linaje raw → staging/rechazos → modelo en Cloud | Equipo | ✅ Documentado en OpenMetadata | Siete activos y nueve relaciones manuales; reporte y captura del 6 de noviembre en docs/lineage/. Snowflake fuera de este alcance |
| **SP2-04** | Validar reglas de staging y definir medición global de calidad | Equipo | 🔄 Cinco casos aprobados; agregación global pendiente | Reporte DQ Cloud del 6 de noviembre: 5/5 en Éxito. No equivale a calidad global del 100% ni certifica por sí solo el umbral global ≥99% |
| **SP2-05** | Desarrollo del modelo de segmentación por contrato y nivel de servicio | Data Analyst | ⏳ Pendiente | `sql/05_segmentation.sql` |
| **SP2-06** | Construcción de matriz / recomendador de acciones de retención por segmento | Data Analyst | ⏳ Pendiente | Tabla de recomendador |
| **SP2-07** | Diseño del Dashboard interactivo en Tableau con KPIs de Churn | Data Analyst | ⏳ Pendiente | Dashboard Tableau / capturas |
| **SP2-08** | Documentar la ejecución reproducible del pipeline | Equipo | 🔄 Guía SingleStore actualizada | README sección 6 y guías de los cinco jobs. Falta integrar ejecución completa con Snowflake y orquestación |
| **SP2-09** | Tratar datos fuera de raw y poblar el modelo en Cloud | Equipo | ✅ Carga inicial validada por el equipo | Raw conserva once espacios; staging registra once imputaciones condicionadas. Modelo cargado con validadores y controles SQL; proceso incremental/recuperación automática no implementado |
| **SP2-10** | Actualizar el catálogo al servicio SingleStore Cloud | Equipo | ✅ Siete tablas descritas | Servicio SingleStore_Cloud_Telco_G2; 22 columnas en raw, 28 en staging, 25 en rechazos, 6/4/11 en dimensiones y 11 en hechos |

---

## 🎤 Demo Day (lunes 9) y cierre (martes 10 de noviembre)
**Meta:** Presentación pulida de 10 min, demo técnica en vivo, métricas de impacto calculadas y README final.

| ID | Tarea / Historia | Responsable | Estado | Entregable |
|---|---|---|---|---|
| **DEMO-01** | Cálculo del KPI estrella: % de reducción de churn esperada por segmento | Data Analyst | ⏳ Pendiente | Resultados cuantificados |
| **DEMO-02** | Estructuración y diseño del Deck de presentación (problema, arquitectura, hallazgos, KPI, próximos pasos) | Presentador / PM | ⏳ Pendiente | Presentación (slides) |
| **DEMO-03** | Ensayo general de la presentación (10 min exposición + 5 min Q&A) | Todo el equipo | ⏳ Pendiente | Grabación / feedback |
| **DEMO-04** | Pulido final de documentación y verificación de requisitos de evaluación (rúbrica al 100%) | Presentador / PM | ⏳ Pendiente | `README.md` final en repo |
| **DEMO-05** | Demo Day el 9 de noviembre y cierre el 10 | Todo el equipo | ⏳ Pendiente | Deck + demo el 9; README final y retrospectiva el 10 |

