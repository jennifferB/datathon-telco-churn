# Reglas de tratamiento y acuerdos de datos — Telco

Estado: especificación propuesta para acordar con el equipo; no representa una ejecución de staging.
Fecha: 5 de noviembre de 2026.

## Separación de capas

| Capa | Responsabilidad | TotalCharges |
|---|---|---|
| Raw | Preservar el CSV y sus valores originales | Conservar los 11 blancos, sin imputar |
| Staging / depurada | Validar, tipar y tratar anomalías de forma trazable | Imputar cero solo con blanco y tenure = 0; marcar la imputación |
| Analítica | Modelo dimensional y métricas | Usar importes tratados y trazabilidad al cliente |

El SQL actual del repositorio carga el modelo dimensional directamente desde raw. Si no se crea staging física, el equipo debe identificar explícitamente dónde se realizan las validaciones y guardar las evidencias; este documento no crea una tabla staging.

## Reglas de transformación

1. Mantener `customerID` estable en todas las capas. Rechazar o separar NULL, blancos y duplicados; conservar registros rechazados con motivo.
2. Preservar el valor original de los importes. Validar su formato antes de convertirlos; acordar como formato aceptado números no negativos con punto decimal y hasta dos decimales. No aceptar letras, separadores ambiguos o cadenas parcialmente numéricas mediante una conversión silenciosa.
3. Convertir `MonthlyCharges` a `DECIMAL(8,2)` y `TotalCharges` a `DECIMAL(10,2)`, en línea con el modelo dimensional existente, validando antes límites y precisión. Evitar FLOAT para importes.
4. Cuando `TotalCharges` está en blanco y `tenure = 0`, asignar `0.00` en la capa depurada. Añadir `total_charges_imputed` con verdadero/1 y un motivo como `BLANK_WITH_ZERO_TENURE`.
5. Cuando `TotalCharges` está en blanco con `tenure > 0`, es NULL o no es numérico, enviarlo a revisión/excepciones. No imputar automáticamente cero. Definir una política separada si el equipo decide tratar NULL como faltante.
6. Validar `tenure` entero no negativo y `SeniorCitizen` en 0/1 antes de derivar categorías. No transformar cualquier valor desconocido de SeniorCitizen en No.
7. Conservar los dominios originales de servicios, contrato y pago. En staging pueden recortarse espacios de borde si se documenta; no convertir `No internet service` ni `No phone service` en NULL.
8. Convertir Churn a bandera 1 para Yes y 0 para No solamente después de validar el dominio. Una categoría inválida no debe convertirse silenciosamente en 0.
9. Para cada rechazo conservar customerID, campo, valor original, regla y motivo, junto con el identificador/fecha de carga si se incorpora ese control.

## Criterios de aceptación propuestos

- Raw de esta fuente: 7.043 filas; 7.043 IDs distintos; 11 blancos de TotalCharges. Estos conteos son una referencia de este archivo, no una expectativa universal para futuras fuentes.
- Staging de esta fuente: todos los IDs de origen reconciliados entre aceptados y excepciones, sin pérdidas ni duplicaciones; 11 imputaciones solo si siguen presentes exactamente los 11 casos válidos identificados.
- Importes: sin errores de conversión; blancos y NULL tratados según política; controles de rango calculados sobre valores numéricos.
- Identificadores y dominios críticos: objetivo 100%. La meta global de 99% requiere definir agregación por reglas/filas; no confundir 6/7 pruebas aprobadas con 99,84% de completitud.
- Comparar raw y destino por customerID: no basta contar filas. La tabla de hechos tiene grano de un cliente y los JOIN no deben multiplicarlo ni perderlo.
- Reejecución: acordar una estrategia idempotente; el script de INSERT actual no debe ejecutarse repetidamente sin controlar duplicados. Este documento no autoriza vaciar tablas.

## Diferencias encontradas en el repositorio

Referencia revisada: `d803a89cd6f15a8f3acf284a1b2d5894ed75cf2a`.

| Archivo | Observación | Acción para el equipo |
|---|---|---|
| sql/01_ddl_raw_singlestore.sql | MonthlyCharges figura DECIMAL y la nota dice que se imputan blancos en raw | Actualizar el DDL al tipo real y describir conservación sin tratamiento |
| sql/02_dq_auditoria_calidad.sql | Máximo 125; la prueba y el README usan 120. El comentario espera cero blancos tras Talend | Acordar un límite único y distinguir diagnóstico raw de aceptación de staging |
| sql/04_poblado_modelo_dimensional.sql | COALESCE/NULLIF reemplaza todos los blancos o NULL por cero, sin condicionar tenure | Aplicar el criterio acordado y registrar excepciones y marca de imputación |
| sql/04_poblado_modelo_dimensional.sql | MonthlyCharges se inserta sin conversión explícita validada | Validar formato y convertir explícitamente antes de poblar el importe decimal |
| sql/04_poblado_modelo_dimensional.sql | SeniorCitizen y Churn usan ELSE para convertir cualquier otro valor en No/0 | Validar dominios primero y separar categorías inválidas |

Estas observaciones son sobre archivos versionados. No se verificó ejecución del SQL dimensional ni su resultado en SingleStore/Snowflake, y no se modificaron scripts del equipo.

## Linaje y coordinación

El repositorio contiene `docs/lineage/lineage_report.md` y su captura, aportados por Jeferson. Documentan cinco activos: raw y cuatro tablas dimensionales/de hechos en DSADEV. No duplicar ese trabajo.

El alcance descrito es SingleStore: no demuestra por sí solo el tramo CSV/Talend ni la entrega a Snowflake. Coordinar con su autor la incorporación de esas etapas cuando se implementen. Si se crea staging física, añadirla al grafo; en caso contrario, documentar las transformaciones en los enlaces correspondientes. Registrar también las dependencias de las dimensiones hacia la tabla de hechos, que el SQL consulta mediante JOIN.

## Glosario inicial propuesto

| Término | Definición |
|---|---|
| Churn | Abandono registrado en la fuente; Yes/No. No equivale a una predicción |
| Tasa histórica de churn | Clientes con Churn = Yes / clientes con Churn válido del segmento; informar cobertura y faltantes |
| Antigüedad | Meses de permanencia del cliente, representados por tenure |
| Raw | Capa que conserva la representación recibida, incluidos blancos |
| Staging | Capa de validación, tipado y tratamiento documentado |
| Imputación | Sustitución justificada de un dato faltante, con marca y motivo |
| Completitud | Proporción de registros con valor informado según una definición explícita de faltante |
| Reducción esperada de churn | Proyección basada en supuestos; separada de resultados medidos después de una intervención |

## Cierre para el equipo

- Validar esta especificación con Engineer y Analyst.
- Documentar los supuestos de reducción esperada por segmento; no presentar asociaciones históricas como causalidad.
- Agregar evidencias reales de las validaciones de staging y Snowflake cuando estén disponibles.
- Marcar como completadas solo las tareas ejecutadas y verificadas.


## Estructura física y estado contrastado con el equipo

- SHOW CREATE TABLE de raw: MonthlyCharges y TotalCharges son VARCHAR(20); hay 22 columnas incluyendo fecha_carga DATETIME DEFAULT CURRENT_TIMESTAMP.
- Raw no declara PRIMARY KEY ni UNIQUE. Las comprobaciones de identificador deben detectar posibles duplicados de carga.
- No se encontró una tabla staging de Telco en los scripts y jobs revisados del repositorio; la transformación versionada lee raw y escribe directamente el modelo dimensional.
- El conteo SQL compartido muestra 7.043 filas en raw y cero en dim_customer_telco_g2, dim_contract_telco_g2, dim_service_telco_g2 y fact_contracts_telco_g2. Las reglas posteriores son especificación para implementar y validar, no resultados de una carga dimensional.
- El diccionario documenta las tres relaciones lógicas y la diferencia BIGINT en las dimensiones frente a INT en hechos.
