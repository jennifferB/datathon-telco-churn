# Calidad de datos — diagnóstico raw y validación de staging

## Evolución de los controles

| Fecha y capa | Entorno | Resultado documentado |
|---|---|---|
| 5 de noviembre: raw | SingleStore compartido, DSADEV; servicio Conexion Grupo 2 TEL | 6/7 casos aprobados. Fallo conocido por 11 blancos de TotalCharges; completitud de esa columna 99,84% |
| 6 de noviembre: raw frente a staging | SingleStore Cloud, telco_g2 | Once espacios originales conservados en raw y once imputaciones identificadas en staging, solo con tenure=0 |
| 6 de noviembre: staging | Servicio SingleStore_Cloud_Telco_G2 de OpenMetadata | 5/5 casos aprobados, cero fallos y cero abortos; incluye control SQL de imputaciones |

Los dos reportes se complementan: el primero mide la fuente antes del tratamiento; el segundo comprueba resultados de la transformación. El informe de raw no se reemplaza ni se renombra como si su ejecución hubiera ocurrido en Cloud.

## Diagnóstico original que se conserva

- 7.043 registros; 22 columnas en raw incluyendo fecha_carga.
- customerID completo y único, cero NULL en las 22 columnas del perfil inicial.
- 11 blancos en TotalCharges, todos con tenure=0.
- MonthlyCharges informado con formato válido, entre 18,25 y 118,75.
- Validación SQL inicial de 17 dominios sin inválidos ni nulos y siete controles de coherencia de servicios sin inconsistencias.

Estos resultados corresponden a la fuente y a las ejecuciones históricas documentadas. La nueva carga usa el mismo dataset, pero cambiar de base no demuestra por sí solo igualdad de cada valor: se debe conciliar por customerID. fecha_carga y las claves sustitutas son datos técnicos que pueden cambiar entre entornos.

## Reportes y evidencias

- [Reporte raw del 5 de noviembre](2026-11-05_reporte_dq_inicial.md).
- [Perfilado y exploración raw](2026-11-05_perfilado_y_exploracion_raw.md).
- [Reporte de staging Cloud del 6 de noviembre](2026-11-06_reporte_dq_staging_cloud.md).
- [Cinco pruebas de staging aprobadas](2026-11-06_dq_staging_cloud_5_pruebas.png).
- [Comparación de los 11 casos raw → staging](2026-11-06_raw_vs_staging_11_imputaciones.png).
- [Diccionario de datos](../catalogo/diccionario_datos_telco.md).

**5/5 controles aprobados no equivale a calidad global del 100%.** La meta global ≥99% requiere definir cobertura y fórmula de agregación. Raw conserva los blancos; la imputación se registra fuera de esa capa.
