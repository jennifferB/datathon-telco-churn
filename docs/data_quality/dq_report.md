# Calidad de datos — Telco raw

## Resultado inicial vigente

La tabla raw conserva los valores del CSV sin imputar los 11 blancos de TotalCharges. No corresponde declarar 100% de completitud de esa columna.

- 7.043 registros; 22 columnas incluyendo fecha_carga.
- customerID completo y único.
- 0 NULL en las 22 columnas.
- 11 blancos en TotalCharges: completitud 99,84%; todos con tenure = 0.
- Importes informados con formato numérico válido; MonthlyCharges observado entre 18,25 y 118,75.
- OpenMetadata, ejecución del 5 de noviembre a las 16:57 UTC-05:00: 6 pruebas exitosas y 1 fallida por blancos conocidos de la fuente. La fracción de pruebas aprobadas (85,71%) no equivale a la completitud de TotalCharges (99,84%) ni a la calidad global.

- Validación SQL de dominios: 17 campos, cada uno con 7.043 valores válidos y cero inválidos o nulos.
- Coherencia SQL entre servicios: siete controles, cada uno sobre 7.043 filas, todos con cero inconsistencias.
- Estos controles SQL complementan los siete casos de OpenMetadata; no se contabilizan como nuevos casos del catálogo.

## Reportes y evidencias

- [Reporte DQ inicial de raw](2026-11-05_reporte_dq_inicial.md): configuración y resultados de los siete casos de OpenMetadata.
- [Perfilado y exploración SQL](2026-11-05_perfilado_y_exploracion_raw.md): resultados por columna, importes, segmentos y capturas.
- [Diccionario de datos](../catalogo/diccionario_datos_telco.md): definición de campos y tipos físicos.

Los tratamientos de TotalCharges corresponden a la capa posterior. Una prueba de ausencia de NULL no detecta blancos ni espacios. El objetivo global de 99% requiere una definición de agregación; no se declara certificación global a partir de estos controles.
