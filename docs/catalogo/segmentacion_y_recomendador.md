# Segmentación y acciones de retención

Preparado el 6 de noviembre de 2026 para SingleStore Cloud, base `telco_g2`.
El equipo ejecutó la segmentación y los dos bloques del recomendador en Cloud. Los resultados y seis capturas se conservan en [el reporte del 6 de noviembre](../analisis/2026-11-06_segmentacion_y_retencion_cloud.md). Esta guía describe las reglas y cómo repetir las consultas; no acredita la ejecución de los SQL de calendario y auditoría.

## Qué responde

Integra la propuesta estratégica del equipo publicada en el commit 275995f con los controles y el análisis por **tipo de contrato × nivel de servicio**. Usa las dimensiones y la tabla de hechos que cargan los jobs Talend. El análisis inicial de raw se conserva como diagnóstico de origen.

El nivel de servicio sigue exactamente la regla del job del modelo: Sin Internet si no tiene Internet; Protegido si tiene Internet y seguridad en línea o soporte técnico; Basico en los demás casos con Internet. Las etiquetas son valores técnicos existentes; no renombrarlas solo en una consulta.

## Ejecución en DBeaver

1. Seleccionar la conexión Cloud y la base `telco_g2`.
2. Ejecutar el bloque 1 de [05_segmentation.sql](../../sql/05_segmentation.sql). Deben coincidir hechos y clientes distintos; sin_cliente, sin_contrato, sin_servicio y churn_invalido deben ser cero. Si falla, resolver el modelo antes de interpretar segmentos.
3. Ejecutar el bloque 2. Para el CSV del reto, la referencia es 7.043 clientes, 1.869 abandonos históricos, churn 26,54% y 11 imputaciones.
4. Ejecutar el bloque 3 y exportar el resultado a CSV para el dashboard. Los nueve segmentos del CSV deben sumar 7.043 clientes y 1.869 abandonos. Cada cliente pertenece a un único segmento.
5. Ejecutar el bloque 4 para los cuatro grupos estratégicos. No sustituye a los nueve cruces del bloque anterior: representa una segunda clasificación para organizar acciones.
6. Abrir [06_recomendador_retencion.sql](../../sql/06_recomendador_retencion.sql) y ejecutar cada bloque por separado. El primero devuelve cuatro grupos × tres escenarios = 12 filas; el segundo devuelve los tres escenarios globales ponderados. No se crea una tabla física ni se alteran los datos. Si ya se ejecutó la versión inicial del compañero, su matriz y vista existentes permanecen intactas y no se actualizan con estas consultas.
7. Guardar evidencia fechada de los resultados y registrar los hallazgos observados antes de actualizar el estado del backlog.

## Grupos estratégicos y acciones

El CASE se evalúa en el orden siguiente. Cada cliente se asigna al primer criterio que cumple; por ello los grupos no se solapan.

| Código | Criterio efectivo | Acción propuesta |
|---|---|---|
| SEG-01 | Mes a mes, fibra y nivel Basico | Revisar incidencias; ofrecer soporte y opción anual voluntaria |
| SEG-02 | Mes a mes y antigüedad ≤12 meses, excluidos SEG-01 | Acompañar incorporación, uso y facturación |
| SEG-03 | Mes a mes y Electronic check, excluidos SEG-01/02 | Revisar fricciones y ofrecer pago automático voluntario |
| SEG-04 | Todos los clientes restantes | Seguimiento diferenciado por contrato y servicio; no asumir bajo riesgo |

El último grupo contiene también clientes mes a mes. No se denomina “fidelizados blindados”. Las tasas se calculan sobre los grupos definitivos y no se guardan como constantes en una matriz. La consulta tampoco etiqueta los grupos como probabilidades individuales de abandono futuro.

La comprobación local sobre el CSV y la ejecución Cloud del equipo coincidieron en estos grupos:

| Grupo | Clientes | Abandonos históricos | Churn |
|---|---:|---:|---:|
| SEG-01 | 1.524 | 925 | 60,70% |
| SEG-02 | 1.230 | 467 | 37,97% |
| SEG-03 | 451 | 146 | 32,37% |
| SEG-04 | 3.838 | 331 | 8,62% |

Los cuatro grupos suman 7.043 clientes y 1.869 abandonos; la captura del reporte acredita estos resultados en Cloud. La tasa 54,61% del análisis previo corresponde a todo el grupo mes a mes con fibra; no corresponde al subconjunto de nivel Basico de SEG-01.

## Cómo interpretar los resultados

- **churn_pct:** abandonos históricos / clientes del segmento × 100.
- **participacion_abandonos_pct:** cuánto aporta el segmento al total de abandonos. Complementa la tasa: un grupo pequeño puede tener una tasa alta y pocos casos.
- **razon_churn_vs_global:** tasa del segmento / tasa global; superior a 1 indica una tasa histórica mayor que la global.
- **clientes_sin_abandono:** clientes con churn_flag = 0 en esta instantánea. No demuestra que sigan activos actualmente.
- **accion_propuesta:** hipótesis comercial según contrato y servicios. Revisar factibilidad y costes con el equipo; las asociaciones del dataset no demuestran que la acción reduzca el abandono.

Los importes no tienen moneda documentada. El cargo mensual medio no representa margen, beneficio ni ingreso recuperado demostrado. No se genera una campaña real dirigida a clientes que ya abandonaron.

## KPI de reducción esperada: escenario explícito

El dataset no contiene resultados de campañas. Se conservan como hipótesis centrales las reducciones de la propuesta del equipo, reinterpretadas de forma consistente como porcentajes relativos: 20%, 15%, 12% y 2% para SEG-01 a SEG-04. No están estimadas a partir de una evaluación de eficacia. Para sensibilidad, el escenario conservador usa la mitad de cada supuesto y el optimista 1,5 veces. No se confunden con niveles de confianza.

| Grupo | Conservador | Central | Optimista |
|---|---:|---:|---:|
| SEG-01 | 10% | 20% | 30% |
| SEG-02 | 7,5% | 15% | 22,5% |
| SEG-03 | 6% | 12% | 18% |
| SEG-04 | 1% | 2% | 3% |

Si un segmento tiene churn histórico del 40% y se supone una reducción relativa del 10%, la tasa del escenario es 36%: baja 4 puntos porcentuales, no 10 puntos. Fórmulas:

- Tasa del escenario = tasa histórica × (1 − reducción relativa supuesta).
- Reducción en puntos porcentuales = tasa histórica porcentual × reducción relativa supuesta.
- Abandonos evitados equivalentes = abandonos históricos × reducción relativa supuesta.

Los equivalentes pueden ser decimales: son una proyección sobre una población comparable, no personas efectivamente retenidas. Comparar escenarios por separado; no sumar las tres filas de un mismo segmento ni sumar clientes repetidos entre escenarios. El KPI global pondera los abandonos de cada grupo y calcula con valores sin redondear; no promedia las cuatro tasas ni resta tasas previamente redondeadas. Para demostrar impacto real haría falta evaluar una intervención sobre clientes elegibles y medir el resultado frente a un grupo comparable.

Esta versión conserva las ideas de soporte, incorporación, pago automático y seguimiento de la propuesta original, pero retira la afirmación de causalidad demostrada, los importes en una moneda no documentada y la estimación de ingresos recuperados sin costes ni horizonte observado. Las ofertas y los canales deben revisarse con el equipo antes de cualquier campaña real.

## Dimensión de fecha para auditoría

El equipo publicó [13_script_dim_fecha.sql](../../sql/13_script_dim_fecha.sql). La tabla usa fecha (DATE) como PRIMARY KEY y SHARD KEY; incluye anio, trimestre, mes, dia, dia_semana y es_fin_semana. DAYOFWEEK numera domingo como 1 y sábado como 7. El generador se corrigió para cubrir 2000–2099: su versión inicial generaba solo 10.000 días, hasta 2027-05-18. La versión corregida genera 36.525 fechas y conserva las existentes mediante INSERT IGNORE. El cambio del archivo no actualiza por sí solo la base ya creada.

Una dimensión calendario permite agrupar cargas por día, mes o año. Por sí sola no registra ejecuciones ni cambios: necesita una relación con una fecha y con el lote auditado.

Para este dataset, distinguir:

| Fecha | Significado | Disponible |
|---|---|---|
| fecha_carga | Ingesta del CSV en raw | Sí, metadato técnico |
| fecha_staging | Procesamiento en staging | Sí, metadato técnico |
| fecha_rechazo | Registro del rechazo | Sí, metadato técnico |
| Fecha de abandono o inicio de contrato | Evento de negocio | No viene en el CSV |

El diseño propuesto para auditoría es relacionar el calendario con un registro por lote/ejecución que contenga load_id, etapa, inicio, fin, estado y conteos. Es una propuesta, no una tabla implementada. Permite conservar la auditoría sin cambiar el grano actual de hechos.

La consulta de [auditoría de fechas](../../sql/14_auditoria_fechas_cloud.sql) utiliza LEFT JOIN entre la fecha técnica de cada etapa y el calendario, sin cambiar tablas ni jobs. Mantiene visibles fechas nulas o sin correspondencia. Raw no tiene load_id, por lo que no se inventa una relación por lote. Si la tabla de rechazos está vacía, no genera una fila de esa etapa. Los resultados muestran filas presentes, no ejecuciones fallidas ni un historial de modificaciones.

Documentar la zona horaria de la sesión y acordar si se audita el día de ingesta o el día de procesamiento. Si el equipo decide añadir una clave de fecha a hechos, debe llamarse y documentarse como fecha técnica de carga, actualizar la carga y los validadores, y mantener el grano de un cliente por instantánea. Añadir una clave de fecha no convierte el modelo actual en un historial de múltiples instantáneas. La nueva tabla también debe ingerirse y describirse en OpenMetadata; las capturas previas de siete tablas conservan su fecha y alcance original.

La segmentación actual no depende de esa dimensión y puede ejecutarse mientras el equipo termina su diseño.
