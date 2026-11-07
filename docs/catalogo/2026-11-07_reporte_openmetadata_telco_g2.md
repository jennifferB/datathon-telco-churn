# Reporte de catálogo, linaje y calidad de datos

Grupo 2 · Genius Lab · Telco Customer Churn  
Corte del catálogo: 7 de noviembre de 2026, hora de Ecuador continental (UTC−05:00).

## Catálogo y gobernanza

El servicio de OpenMetadata **SingleStore_Cloud_Telco_G2** cataloga ocho tablas de la base **telco_g2**. Las ocho tienen descripción, dominio **Telecomunicaciones** y una etiqueta que identifica su función en el flujo.

| Etiqueta | Tablas |
|---|---|
| Origen | raw_telco_g2 |
| Staging | stg_telco_g2 |
| Rechazos | rejects_telco_g2 |
| Auditoría | dim_fecha_telco_g2 |
| Consumo | dim_customer_telco_g2, dim_contract_telco_g2, dim_service_telco_g2, fact_contracts_telco_g2 |

El producto **Segmentación y retención Telco G2** agrupa las cuatro tablas de consumo y enlaza el [dashboard Panorama del churn](../dashboard/telco_g2_dashboard.twb). La asignación de responsables queda pendiente de la definición de roles del equipo.

El **Glosario Telco G2** define abandono, tasa histórica de abandono, antigüedad, tipo de contrato, nivel de servicio, cargo mensual y cargo acumulado. Los términos están vinculados a 16 columnas y la tasa histórica de abandono está vinculada al producto. Se documentaron los campos load_ts y load_source en las ocho tablas.

## Linaje

Se verificaron nueve relaciones de tabla en SingleStore Cloud. Raw alimenta staging y rechazos. Staging alimenta las tres dimensiones del modelo y la tabla de hechos. Cada una de las tres dimensiones también alimenta la tabla de hechos.

La dimensión de fechas se usa para consultas de auditoría técnica. El alcance verificado del grafo termina en SingleStore. El tramo hacia Snowflake requiere evidencia propia.

**Dashboard en la demo.** El equipo presenta Panorama del churn desde Tableau Desktop Free Edition. El [archivo del dashboard](../dashboard/telco_g2_dashboard.twb) y la [captura del panel](../dashboard/telco_g2_dashboard_1.png) quedan como evidencia en el repositorio. El producto de datos enlaza el archivo. La conexión del panel a las cuatro tablas del modelo en SingleStore se documenta como parte de la arquitectura de la demo. La ingestión del panel y su linaje en OpenMetadata requieren un sitio de Tableau Cloud o Tableau Server accesible para el conector.

Referencias: [ediciones de Tableau Desktop](https://help.tableau.com/current/pro/desktop/en-us/desktop_comparison.htm) y [conector de Tableau para OpenMetadata](https://docs.open-metadata.org/v1.12.x/connectors/dashboard/tableau).

Ver [evidencia de linaje](../lineage/2026-11-06_linaje_singlestore_cloud.md) y [consulta de auditoría con calendario](../../sql/14_auditoria_fechas_cloud.sql).

## Calidad de datos

| Caso | Control | Último resultado | Hora local |
|---|---|---|---|
| STG_DQ_01_customerID_unico | Unicidad de customerID | Éxito | 2026-11-07 17:09:30 |
| STG_DQ_02_customerID_sin_nulos | Ausencia de nulos en customerID | Éxito | 2026-11-07 17:09:32 |
| STG_DQ_03_MonthlyCharges_rango | Cargo mensual entre 18 y 120 | Éxito | 2026-11-07 17:09:32 |
| STG_DQ_04_TotalCharges_sin_nulos | Ausencia de nulos en TotalCharges | Éxito | 2026-11-07 17:09:32 |
| STG_DQ_05_imputaciones_correctas | Once imputaciones con importe cero, antigüedad cero, blanco original y motivo válido | Éxito | 2026-11-07 17:09:32 |
| FACT_DQ_01_grano_y_cobertura | Un hecho por cliente y total igual al de staging | Éxito | 2026-11-07 17:07:37 |
| FACT_DQ_02_integridad_y_churn | Referencias válidas a cliente, contrato y servicio, y churn_flag en 0 o 1 | Éxito | 2026-11-07 17:07:44 |
| FACT_DQ_03_auditoria_completa | Presencia de load_ts, load_source y source_load_id | Éxito | 2026-11-07 17:07:44 |

Los controles SQL de hechos admiten **cero excepciones**. El control de auditoría comprueba la presencia de los campos. La validación de la hora de Ecuador en los datos almacenados requiere una comparación aparte con la hora real de ejecución.

El informe de staging conserva la [evidencia de las once imputaciones](../data_quality/2026-11-06_reporte_dq_staging_cloud.md). Raw conserva los blancos de la fuente y staging aplica el tratamiento.

## Cómo actualizar la evidencia

1. Ejecutar las pruebas de staging y hechos desde **Observabilidad → Calidad de datos**. Abrir cada tabla para comprobar la fecha y los resultados.
2. En **Gobernar**, revisar las tablas del dominio, los activos del producto, los términos del glosario y la clasificación. Guardar una captura del producto y otra de las pruebas si se van a presentar.
3. Abrir **Linaje** en raw_telco_g2 y descargar el grafo. OpenMetadata también permite [exportar el linaje a CSV](https://docs.open-metadata.org/v1.12.x/connectors/ingestion/lineage/export-lineage).
4. Actualizar este archivo con los resultados y enlazar las evidencias fechadas del repositorio.
