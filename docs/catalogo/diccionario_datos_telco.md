# Diccionario de datos — IBM Telco Churn, capa raw

Fecha: 5 de noviembre de 2026. Tabla: `DSADEV.raw_telco_g2`.
Grano: una fila por cliente de la instantánea de la fuente; no es un historial de eventos.
Los dominios se contrastaron con el CSV de 7.043 filas. Los tipos y restricciones físicos se tomaron del SHOW CREATE TABLE proporcionado por el equipo. La tabla tiene 22 columnas: 21 originales y fecha_carga como metadato de ingesta. customerID es NOT NULL, pero no tiene PRIMARY KEY ni restricción UNIQUE en raw; su unicidad se controla mediante DQ.
Raw preserva blancos y categorías originales. Las categorías `No phone service` y `No internet service` no se consideran nulos. No se asigna moneda ni fecha de corte que el archivo no especifica.

## Descripción de la tabla

Tabla raw del Grupo 2 para el reto de segmentación y retención Telco. Fuente: IBM Telco Customer Churn, con 7.043 registros y 21 columnas en el CSV analizado. Cada fila representa un cliente en la instantánea de la fuente. Raw conserva los valores recibidos sin imputación, incluidos los 11 blancos de TotalCharges asociados a tenure = 0. La tabla contiene 22 columnas: 21 de origen y fecha_carga, metadato de ingesta. MonthlyCharges y TotalCharges son VARCHAR(20). Las conversiones numéricas y el tratamiento de faltantes corresponden a una capa posterior. La ejecución DQ del 5 de noviembre de 2026 a las 16:57 (UTC-05:00) mostró seis pruebas exitosas y una fallida por los 11 blancos conocidos; completitud de TotalCharges: 99,84%.

## Columnas: descripciones listas para OpenMetadata

| Columna | Tipo raw de referencia | Dominio o unidad | Descripción |
|---|---|---|---|
| customerID | VARCHAR(20) | Identificador alfanumérico | Identificador del cliente en la fuente. Se utiliza para relacionar las capas y conservar la trazabilidad; debe estar informado, sin blancos y sin duplicados. |
| gender | VARCHAR(10) | Female; Male | Género registrado en la fuente. Valores observados: Female y Male. Se conserva la categoría original en raw. |
| SeniorCitizen | TINYINT(4) | 0; 1 | Indicador de adulto mayor registrado en la fuente: 1 indica que sí y 0 que no. No representa la edad exacta del cliente. |
| Partner | VARCHAR(3) | Yes; No | Indica si el cliente tiene pareja según la fuente. Valores permitidos: Yes y No. |
| Dependents | VARCHAR(3) | Yes; No | Indica si el cliente tiene personas dependientes según la fuente. Valores permitidos: Yes y No. |
| tenure | INT(11) | Entero no negativo; meses | Antigüedad del cliente expresada en meses. El valor 0 identifica clientes sin meses de permanencia acumulados; en este CSV los 11 blancos de TotalCharges tienen tenure = 0. |
| PhoneService | VARCHAR(3) | Yes; No | Indica si el cliente tiene servicio telefónico contratado. Valores permitidos: Yes y No. |
| MultipleLines | VARCHAR(30) | Yes; No; No phone service | Indica si el cliente tiene múltiples líneas telefónicas. No phone service significa que no tiene servicio telefónico y debe conservarse como categoría distinta de No. |
| InternetService | VARCHAR(20) | DSL; Fiber optic; No | Tipo de servicio de Internet registrado. No indica ausencia de Internet. Se usa junto con el contrato para definir segmentos. |
| OnlineSecurity | VARCHAR(30) | Yes; No; No internet service | Indica si el cliente tiene seguridad en línea. No internet service indica que el servicio no aplica por ausencia de Internet; no equivale a un dato faltante. |
| OnlineBackup | VARCHAR(30) | Yes; No; No internet service | Indica si el cliente tiene respaldo en línea. No internet service es una categoría válida por ausencia de Internet. |
| DeviceProtection | VARCHAR(30) | Yes; No; No internet service | Indica si el cliente tiene protección de dispositivos contratada. No internet service es una categoría válida por ausencia de Internet. |
| TechSupport | VARCHAR(30) | Yes; No; No internet service | Indica si el cliente tiene soporte técnico contratado. No internet service es una categoría válida por ausencia de Internet. |
| StreamingTV | VARCHAR(30) | Yes; No; No internet service | Indica si el cliente tiene el servicio de televisión por streaming. No internet service es una categoría válida por ausencia de Internet. |
| StreamingMovies | VARCHAR(30) | Yes; No; No internet service | Indica si el cliente tiene el servicio de películas por streaming. No internet service es una categoría válida por ausencia de Internet. |
| Contract | VARCHAR(20) | Month-to-month; One year; Two year | Duración o modalidad contractual: Month-to-month, One year o Two year. Campo principal para segmentación y comparación de la tasa histórica de churn. |
| PaperlessBilling | VARCHAR(3) | Yes; No | Indica si el cliente utiliza facturación sin papel. Valores permitidos: Yes y No. |
| PaymentMethod | VARCHAR(40) | Electronic check; Mailed check; Bank transfer (automatic); Credit card (automatic) | Método de pago registrado en la fuente. Se conserva el texto original; permite comparar segmentos de pago automático y no automático. |
| MonthlyCharges | VARCHAR(20) | Texto numérico con punto decimal; sin blancos en el CSV analizado | Cargo mensual registrado en la fuente, conservado como texto en raw. Convertir a DECIMAL en la capa depurada tras validar el formato; no comparar cadenas para evaluar el rango. Intervalo del README: 18–120, pendiente de alineación con el SQL. La moneda no se explicita en el archivo. |
| TotalCharges | VARCHAR(20) | Texto numérico o blanco de la fuente | Cargo acumulado registrado en la fuente, conservado como texto en raw. El CSV contiene 11 blancos, todos con tenure = 0; deben preservarse en raw. La imputación a 0.00 y conversión a DECIMAL corresponden a la capa depurada. Blanco, NULL y cero son valores distintos. La moneda no se explicita en el archivo. |
| Churn | VARCHAR(3) | Yes; No | Estado de abandono registrado en la fuente: Yes indica abandono y No indica ausencia de abandono. Es la variable objetivo para calcular la tasa histórica por segmento; no es una predicción de abandono futuro. |

| fecha_carga | DATETIME, DEFAULT CURRENT_TIMESTAMP | Fecha y hora de ingesta | Metadato añadido al cargar el CSV. No pertenece a sus 21 columnas originales y no representa la fecha de abandono ni una fecha de negocio. La zona horaria se determina por la configuración de la sesión/servidor que inserta el valor. |

## Reglas relacionadas

- DQ-01a/b: identificador sin NULL y único. Añadir validación de blancos y espacios.
- DQ-02a/b: distinguir NULL de blanco; en raw se conservan los 11 blancos de esta fuente.
- DQ-03: validar formato y rango de MonthlyCharges numéricamente; raw es texto.
- DQ-04: Contract pertenece a su dominio.
- DQ-05: Churn pertenece a Yes/No. No es un puntaje de riesgo.

## Uso del catálogo

Las descripciones se publican en la tabla y las columnas de OpenMetadata. No se inventan propietarios ni se asigna certificación de calidad global. La documentación no cambia los datos de SingleStore ni los tipos físicos de sus columnas.

Fuente de datos: `data/telco_churn.csv` del repositorio del equipo y CSV local proporcionado.
Repositorio revisado: https://github.com/jennifferB/datathon-telco-churn/tree/d803a89cd6f15a8f3acf284a1b2d5894ed75cf2a

## Estructura real y publicación en el catálogo

Los tipos anteriores corresponden al DDL real facilitado por el equipo. Las 21 descripciones originales ya se guardaron y verificaron en OpenMetadata antes de recibir ese DDL. El catálogo leído entonces tenía metadatos anteriores; debe actualizarse mediante la ingesta de metadatos para mostrar la estructura real de 22 columnas. Este archivo incluye la descripción de fecha_carga para incorporarla tras esa actualización.

## Relaciones del modelo dimensional

| Relación lógica | Clave de dimensión | Clave en hechos |
|---|---|---|
| dim_customer_telco_g2 → fact_contracts_telco_g2 | customer_key BIGINT(11) | customer_key INT(11) |
| dim_contract_telco_g2 → fact_contracts_telco_g2 | contract_key BIGINT(11) | contract_key INT(11) |
| dim_service_telco_g2 → fact_contracts_telco_g2 | service_key BIGINT(11) | service_key INT(11) |

Las relaciones son lógicas: el DDL proporcionado no declara FOREIGN KEY. Las dimensiones usan BIGINT y hechos usa INT; registrar la diferencia y alinear los tipos con el equipo antes de crecimiento o migración. customer_id de la dimensión de clientes es NOT NULL, pero tampoco tiene restricción UNIQUE declarada.

En el conteo SQL compartido, raw contiene 7.043 filas y las cuatro tablas dimensionales/de hechos contienen cero filas. Están creadas; ese resultado no permite declarar que el modelo ya está poblado ni validado. El linaje documentado en GitHub no reemplaza la evidencia de carga.
