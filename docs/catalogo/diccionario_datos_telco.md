# Diccionario de datos — IBM Telco Churn

Actualizado: 6 de noviembre de 2026. Entorno actual: SingleStore Cloud, base `telco_g2`.
Servicio del catálogo: `SingleStore_Cloud_Telco_G2`.

Este diccionario describe las siete tablas del pipeline actual. Los tipos de staging, rechazos y modelo proceden de los DDL del repositorio y las transformaciones de los jobs Talend. Las descripciones pueden copiarse a las columnas de OpenMetadata; actualizar este archivo no las publica automáticamente.

El análisis del 5 de noviembre en DSADEV se conserva como evidencia histórica en [el reporte inicial](../data_quality/2026-11-05_reporte_dq_inicial.md). No constituye una ejecución nueva sobre Cloud. El CSV contiene 7.043 clientes, 21 campos originales y 11 blancos en TotalCharges. No especifica moneda ni fecha de corte.

## Tablas y grano

| Tabla | Columnas | Una fila representa | Origen |
|---|---:|---|---|
| raw_telco_g2 | 22 | Un cliente de la instantánea recibida, más fecha de ingesta | CSV; job_telco_ingesta |
| stg_telco_g2 | 28 | Un cliente aceptado tras validación y tratamiento | raw; job_telco_staging |
| rejects_telco_g2 | 25 | Un registro rechazado con sus motivos y lote | raw; job_telco_staging |
| dim_customer_telco_g2 | 6 | Un cliente de la instantánea | staging; job_telco_modelo_dimensional |
| dim_contract_telco_g2 | 4 | Una combinación distinta de contrato, facturación y pago | staging; job_telco_modelo_dimensional |
| dim_service_telco_g2 | 11 | Una combinación distinta de nueve atributos de servicios | staging; job_telco_modelo_dimensional |
| fact_contracts_telco_g2 | 11 | Un cliente de la instantánea con claves y medidas | staging y tres dimensiones; job_telco_modelo_dimensional |

La tabla de hechos no almacena un historial de contratos ni eventos. Las claves sustitutas no deben interpretarse como identificadores estables entre reconstrucciones completas del modelo.

## raw_telco_g2 — valores originales

Conserva los 11 blancos de TotalCharges. MonthlyCharges y TotalCharges son texto. customerID tiene NOT NULL, sin PRIMARY KEY ni UNIQUE; la unicidad se controla mediante validaciones. Las demás columnas de origen admiten NULL físicamente. fecha_carga admite NULL y tiene DEFAULT CURRENT_TIMESTAMP. No phone service y No internet service son categorías válidas, no datos faltantes.

| Columna | Tipo | Dominio o unidad | Descripción para el catálogo |
|---|---|---|---|
| customerID | VARCHAR(20) | Identificador alfanumérico | Identificador del cliente en la fuente. Se utiliza para relacionar las capas y conservar la trazabilidad; debe estar informado, sin blancos y sin duplicados. |
| gender | VARCHAR(10) | Female; Male | Género registrado en la fuente. Valores observados: Female y Male. Se conserva la categoría original en raw. |
| SeniorCitizen | TINYINT | 0; 1 | Indicador de adulto mayor registrado en la fuente: 1 indica que sí y 0 que no. No representa la edad exacta del cliente. |
| Partner | VARCHAR(3) | Yes; No | Indica si el cliente tiene pareja según la fuente. Valores permitidos: Yes y No. |
| Dependents | VARCHAR(3) | Yes; No | Indica si el cliente tiene personas dependientes según la fuente. Valores permitidos: Yes y No. |
| tenure | INT | Entero no negativo; meses | Antigüedad en meses. El job de staging acepta enteros entre 0 y 72; los 11 blancos de TotalCharges de este CSV corresponden a tenure = 0. |
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
| MonthlyCharges | VARCHAR(20) | Texto decimal; staging acepta 18–120 | Cargo mensual original conservado como texto, sin conversión ni imputación en raw. El job de staging valida formato decimal y rango inclusivo 18–120 antes de convertirlo a DECIMAL(8,2). La moneda no está especificada en el CSV. |
| TotalCharges | VARCHAR(20) | Texto numérico o blanco de la fuente | Cargo acumulado original conservado como texto. Los 11 blancos de la fuente se mantienen en raw; todos corresponden a tenure = 0. Blanco, NULL y cero son distintos. La moneda no está especificada en el CSV. |
| Churn | VARCHAR(3) | Yes; No | Estado de abandono registrado en la fuente: Yes indica abandono y No indica ausencia de abandono. Es la variable objetivo para calcular la tasa histórica por segmento; no es una predicción de abandono futuro. |
| fecha_carga | DATETIME, DEFAULT CURRENT_TIMESTAMP | Fecha y hora de ingesta | Fecha y hora de ingesta añadida por la base con DEFAULT CURRENT_TIMESTAMP. No es la fecha del abandono ni una fecha de corte de negocio; su zona horaria depende de la sesión/servidor. |

## stg_telco_g2

Datos aceptados. PK y SHARD KEY: customerID. La nulabilidad física no reemplaza las reglas DQ del job: varios campos permiten NULL en el DDL, aunque la validación del pipeline los exige informados y válidos.

| Columna | Tipo | Admite NULL | Descripción y transformación |
|---|---|---|---|
| customerID | VARCHAR(20) | No | Procede de raw.customerID. Identificador del cliente en la fuente. Se utiliza para relacionar las capas y conservar la trazabilidad; debe estar informado, sin blancos y sin duplicados. |
| gender | VARCHAR(10) | Sí | Procede de raw.gender. Género registrado en la fuente. Valores observados: Female y Male. Se conserva la categoría original en raw. |
| SeniorCitizen | INT | Sí | Procede de raw.SeniorCitizen. Indicador de adulto mayor registrado en la fuente: 1 indica que sí y 0 que no. No representa la edad exacta del cliente. |
| Partner | VARCHAR(3) | Sí | Procede de raw.Partner. Indica si el cliente tiene pareja según la fuente. Valores permitidos: Yes y No. |
| Dependents | VARCHAR(3) | Sí | Procede de raw.Dependents. Indica si el cliente tiene personas dependientes según la fuente. Valores permitidos: Yes y No. |
| tenure | INT | Sí | Procede de raw.tenure. Antigüedad en meses. El job de staging acepta enteros entre 0 y 72; los 11 blancos de TotalCharges de este CSV corresponden a tenure = 0. |
| PhoneService | VARCHAR(3) | Sí | Procede de raw.PhoneService. Indica si el cliente tiene servicio telefónico contratado. Valores permitidos: Yes y No. |
| MultipleLines | VARCHAR(30) | Sí | Procede de raw.MultipleLines. Indica si el cliente tiene múltiples líneas telefónicas. No phone service significa que no tiene servicio telefónico y debe conservarse como categoría distinta de No. |
| InternetService | VARCHAR(20) | Sí | Procede de raw.InternetService. Tipo de servicio de Internet registrado. No indica ausencia de Internet. Se usa junto con el contrato para definir segmentos. |
| OnlineSecurity | VARCHAR(30) | Sí | Procede de raw.OnlineSecurity. Indica si el cliente tiene seguridad en línea. No internet service indica que el servicio no aplica por ausencia de Internet; no equivale a un dato faltante. |
| OnlineBackup | VARCHAR(30) | Sí | Procede de raw.OnlineBackup. Indica si el cliente tiene respaldo en línea. No internet service es una categoría válida por ausencia de Internet. |
| DeviceProtection | VARCHAR(30) | Sí | Procede de raw.DeviceProtection. Indica si el cliente tiene protección de dispositivos contratada. No internet service es una categoría válida por ausencia de Internet. |
| TechSupport | VARCHAR(30) | Sí | Procede de raw.TechSupport. Indica si el cliente tiene soporte técnico contratado. No internet service es una categoría válida por ausencia de Internet. |
| StreamingTV | VARCHAR(30) | Sí | Procede de raw.StreamingTV. Indica si el cliente tiene el servicio de televisión por streaming. No internet service es una categoría válida por ausencia de Internet. |
| StreamingMovies | VARCHAR(30) | Sí | Procede de raw.StreamingMovies. Indica si el cliente tiene el servicio de películas por streaming. No internet service es una categoría válida por ausencia de Internet. |
| Contract | VARCHAR(20) | Sí | Procede de raw.Contract. Duración o modalidad contractual: Month-to-month, One year o Two year. Campo principal para segmentación y comparación de la tasa histórica de churn. |
| PaperlessBilling | VARCHAR(3) | Sí | Procede de raw.PaperlessBilling. Indica si el cliente utiliza facturación sin papel. Valores permitidos: Yes y No. |
| PaymentMethod | VARCHAR(40) | Sí | Procede de raw.PaymentMethod. Método de pago registrado en la fuente. Se conserva el texto original; permite comparar segmentos de pago automático y no automático. |
| MonthlyCharges | DECIMAL(8,2) | No | Cargo mensual convertido a DECIMAL(8,2), después de validar formato decimal y rango inclusivo 18–120. Texto original en monthly_charges_raw. |
| TotalCharges | DECIMAL(10,2) | No | Cargo acumulado convertido a DECIMAL(10,2). Solo se imputa 0.00 si el original es blanco y tenure = 0; el texto, indicador y motivo se conservan en campos de auditoría. |
| Churn | VARCHAR(3) | Sí | Procede de raw.Churn. Estado de abandono registrado en la fuente: Yes indica abandono y No indica ausencia de abandono. Es la variable objetivo para calcular la tasa histórica por segmento; no es una predicción de abandono futuro. |
| fecha_carga | DATETIME | Sí | Fecha de ingesta copiada de raw.fecha_carga, sin sustituirla por la fecha de staging. |
| monthly_charges_raw | VARCHAR(20) | Sí | Texto original de raw.MonthlyCharges conservado para auditoría de la conversión numérica. |
| total_charges_raw | VARCHAR(20) | Sí | Texto original de raw.TotalCharges conservado para auditar los blancos y su imputación. |
| total_charges_imputed | INT | No | Indicador de imputación: 1 cuando TotalCharges original era blanco y tenure = 0; 0 cuando no se imputó. |
| imputation_reason | VARCHAR(64) | Sí | Motivo de imputación: BLANK_WITH_ZERO_TENURE para el blanco con tenure = 0; NULL cuando no hubo imputación. |
| load_id | VARCHAR(36) | No | Identificador UUID del lote de ejecución del job de staging. Permite relacionar aceptados y rechazados del mismo lote. |
| fecha_staging | DATETIME | No | Fecha y hora de procesamiento añadida por el job de staging; no es una fecha de negocio. |

## rejects_telco_g2

Registros rechazados conservando los valores recibidos y su trazabilidad. No tiene PRIMARY KEY. Que una categoría está fuera de dominio aquí explica el rechazo; no implica que el registro haya pasado las reglas de staging.

| Columna | Tipo | Admite NULL | Descripción y transformación |
|---|---|---|---|
| customerID | VARCHAR(20) | Sí | Valor original de raw, sin imputación. Identificador del cliente en la fuente. Se utiliza para relacionar las capas y conservar la trazabilidad; debe estar informado, sin blancos y sin duplicados. |
| gender | VARCHAR(10) | Sí | Valor original de raw, sin imputación. Género registrado en la fuente. Valores observados: Female y Male. Se conserva la categoría original en raw. |
| SeniorCitizen | INT | Sí | Valor original de raw, sin imputación. Indicador de adulto mayor registrado en la fuente: 1 indica que sí y 0 que no. No representa la edad exacta del cliente. |
| Partner | VARCHAR(3) | Sí | Valor original de raw, sin imputación. Indica si el cliente tiene pareja según la fuente. Valores permitidos: Yes y No. |
| Dependents | VARCHAR(3) | Sí | Valor original de raw, sin imputación. Indica si el cliente tiene personas dependientes según la fuente. Valores permitidos: Yes y No. |
| tenure | INT | Sí | Valor original de raw, sin imputación. Antigüedad en meses. El job de staging acepta enteros entre 0 y 72; los 11 blancos de TotalCharges de este CSV corresponden a tenure = 0. |
| PhoneService | VARCHAR(3) | Sí | Valor original de raw, sin imputación. Indica si el cliente tiene servicio telefónico contratado. Valores permitidos: Yes y No. |
| MultipleLines | VARCHAR(30) | Sí | Valor original de raw, sin imputación. Indica si el cliente tiene múltiples líneas telefónicas. No phone service significa que no tiene servicio telefónico y debe conservarse como categoría distinta de No. |
| InternetService | VARCHAR(20) | Sí | Valor original de raw, sin imputación. Tipo de servicio de Internet registrado. No indica ausencia de Internet. Se usa junto con el contrato para definir segmentos. |
| OnlineSecurity | VARCHAR(30) | Sí | Valor original de raw, sin imputación. Indica si el cliente tiene seguridad en línea. No internet service indica que el servicio no aplica por ausencia de Internet; no equivale a un dato faltante. |
| OnlineBackup | VARCHAR(30) | Sí | Valor original de raw, sin imputación. Indica si el cliente tiene respaldo en línea. No internet service es una categoría válida por ausencia de Internet. |
| DeviceProtection | VARCHAR(30) | Sí | Valor original de raw, sin imputación. Indica si el cliente tiene protección de dispositivos contratada. No internet service es una categoría válida por ausencia de Internet. |
| TechSupport | VARCHAR(30) | Sí | Valor original de raw, sin imputación. Indica si el cliente tiene soporte técnico contratado. No internet service es una categoría válida por ausencia de Internet. |
| StreamingTV | VARCHAR(30) | Sí | Valor original de raw, sin imputación. Indica si el cliente tiene el servicio de televisión por streaming. No internet service es una categoría válida por ausencia de Internet. |
| StreamingMovies | VARCHAR(30) | Sí | Valor original de raw, sin imputación. Indica si el cliente tiene el servicio de películas por streaming. No internet service es una categoría válida por ausencia de Internet. |
| Contract | VARCHAR(20) | Sí | Valor original de raw, sin imputación. Duración o modalidad contractual: Month-to-month, One year o Two year. Campo principal para segmentación y comparación de la tasa histórica de churn. |
| PaperlessBilling | VARCHAR(3) | Sí | Valor original de raw, sin imputación. Indica si el cliente utiliza facturación sin papel. Valores permitidos: Yes y No. |
| PaymentMethod | VARCHAR(40) | Sí | Valor original de raw, sin imputación. Método de pago registrado en la fuente. Se conserva el texto original; permite comparar segmentos de pago automático y no automático. |
| MonthlyCharges | VARCHAR(20) | Sí | Valor original de raw, sin imputación. Cargo mensual original conservado como texto, sin conversión ni imputación en raw. El job de staging valida formato decimal y rango inclusivo 18–120 antes de convertirlo a DECIMAL(8,2). La moneda no está especificada en el CSV. |
| TotalCharges | VARCHAR(20) | Sí | Valor original de raw, sin imputación. Cargo acumulado original conservado como texto. Los 11 blancos de la fuente se mantienen en raw; todos corresponden a tenure = 0. Blanco, NULL y cero son distintos. La moneda no está especificada en el CSV. |
| Churn | VARCHAR(3) | Sí | Valor original de raw, sin imputación. Estado de abandono registrado en la fuente: Yes indica abandono y No indica ausencia de abandono. Es la variable objetivo para calcular la tasa histórica por segmento; no es una predicción de abandono futuro. |
| fecha_carga | DATETIME | Sí | Fecha de ingesta copiada de raw.fecha_carga. |
| reject_reason | VARCHAR(1024) | No | Códigos de las reglas incumplidas, separados por punto y coma. Conserva la explicación del rechazo sin corregir los valores originales. |
| load_id | VARCHAR(36) | No | Identificador UUID del lote de ejecución del job de staging. Permite relacionar aceptados y rechazados del mismo lote. |
| fecha_rechazo | DATETIME | No | Fecha y hora en que el job registró el rechazo. |

## dim_customer_telco_g2

PK y SHARD KEY: customer_key. Se genera una clave por cliente aceptado; customer_id conserva el identificador de negocio.

| Columna | Tipo | Admite NULL | Descripción y transformación |
|---|---|---|---|
| customer_key | BIGINT AUTO_INCREMENT | No | Clave sustituta BIGINT generada con AUTO_INCREMENT; identifica al cliente en el modelo. No es el customerID original. |
| customer_id | VARCHAR(20) | No | Identificador original de stg_telco_g2.customerID; permite enlazar el modelo con raw y staging. NOT NULL; sin restricción UNIQUE física en esta dimensión. |
| gender | VARCHAR(10) | Sí | Género registrado en la fuente. Valores observados: Female y Male. Se conserva la categoría original en raw. |
| senior_citizen | VARCHAR(3) | Sí | Categoría derivada de SeniorCitizen: 1 → Yes y 0 → No. No representa la edad exacta. |
| partner | VARCHAR(3) | Sí | Indica si el cliente tiene pareja según la fuente. Valores permitidos: Yes y No. |
| dependents | VARCHAR(3) | Sí | Indica si el cliente tiene personas dependientes según la fuente. Valores permitidos: Yes y No. |

## dim_contract_telco_g2

PK y SHARD KEY: contract_key. El job selecciona combinaciones DISTINCT de los tres atributos del contrato.

| Columna | Tipo | Admite NULL | Descripción y transformación |
|---|---|---|---|
| contract_key | BIGINT AUTO_INCREMENT | No | Clave sustituta BIGINT generada con AUTO_INCREMENT para una combinación de modalidad contractual, facturación y método de pago. |
| contract_type | VARCHAR(20) | No | Modalidad de stg.Contract: Month-to-month, One year o Two year. |
| paperless_billing | VARCHAR(3) | Sí | Indica si el cliente utiliza facturación sin papel. Valores permitidos: Yes y No. |
| payment_method | VARCHAR(40) | Sí | Método de pago registrado en la fuente. Se conserva el texto original; permite comparar segmentos de pago automático y no automático. |

## dim_service_telco_g2

PK y SHARD KEY: service_key. El job selecciona combinaciones DISTINCT de los nueve atributos de servicios y calcula service_level.

| Columna | Tipo | Admite NULL | Descripción y transformación |
|---|---|---|---|
| service_key | BIGINT AUTO_INCREMENT | No | Clave sustituta BIGINT generada con AUTO_INCREMENT para una combinación de los nueve atributos de servicios. |
| phone_service | VARCHAR(3) | Sí | Procede de stg.PhoneService. Indica si el cliente tiene servicio telefónico contratado. Valores permitidos: Yes y No. |
| multiple_lines | VARCHAR(30) | Sí | Procede de stg.MultipleLines. Indica si el cliente tiene múltiples líneas telefónicas. No phone service significa que no tiene servicio telefónico y debe conservarse como categoría distinta de No. |
| internet_service | VARCHAR(20) | Sí | Procede de stg.InternetService. Tipo de servicio de Internet registrado. No indica ausencia de Internet. Se usa junto con el contrato para definir segmentos. |
| online_security | VARCHAR(30) | Sí | Procede de stg.OnlineSecurity. Indica si el cliente tiene seguridad en línea. No internet service indica que el servicio no aplica por ausencia de Internet; no equivale a un dato faltante. |
| online_backup | VARCHAR(30) | Sí | Procede de stg.OnlineBackup. Indica si el cliente tiene respaldo en línea. No internet service es una categoría válida por ausencia de Internet. |
| device_protection | VARCHAR(30) | Sí | Procede de stg.DeviceProtection. Indica si el cliente tiene protección de dispositivos contratada. No internet service es una categoría válida por ausencia de Internet. |
| tech_support | VARCHAR(30) | Sí | Procede de stg.TechSupport. Indica si el cliente tiene soporte técnico contratado. No internet service es una categoría válida por ausencia de Internet. |
| streaming_tv | VARCHAR(30) | Sí | Procede de stg.StreamingTV. Indica si el cliente tiene el servicio de televisión por streaming. No internet service es una categoría válida por ausencia de Internet. |
| streaming_movies | VARCHAR(30) | Sí | Procede de stg.StreamingMovies. Indica si el cliente tiene el servicio de películas por streaming. No internet service es una categoría válida por ausencia de Internet. |
| service_level | VARCHAR(30) | Sí | Categoría derivada, en este orden: InternetService = No → Sin Internet; con Internet y OnlineSecurity = Yes o TechSupport = Yes → Protegido; demás casos → Basico. No es velocidad ni plan comercial. |

## fact_contracts_telco_g2

PK y SHARD KEY: customer_key. Las tres claves son BIGINT en Cloud. Las relaciones con dimensiones son lógicas; el DDL no declara FOREIGN KEY.

| Columna | Tipo | Admite NULL | Descripción y transformación |
|---|---|---|---|
| customer_key | BIGINT | No | Clave lógica hacia dim_customer_telco_g2.customer_key; también es la PRIMARY KEY de hechos: una fila por cliente de la instantánea. |
| contract_key | BIGINT | No | Clave lógica hacia dim_contract_telco_g2.contract_key, resuelta por Contract, PaperlessBilling y PaymentMethod. |
| service_key | BIGINT | No | Clave lógica hacia dim_service_telco_g2.service_key, resuelta mediante los nueve atributos de servicios. |
| tenure_months | INT | No | Antigüedad en meses copiada de stg.tenure; rango validado por staging: 0–72. |
| tenure_group | VARCHAR(10) | No | Grupo derivado de tenure: 0–12 → 0-12m; 13–24 → 13-24m; 25–48 → 25-48m; 49–72 → >48m. |
| monthly_charges | DECIMAL(8,2) | No | Cargo mensual numérico copiado de stg.MonthlyCharges, DECIMAL(8,2); rango inclusivo 18–120. |
| total_charges | DECIMAL(10,2) | No | Cargo acumulado numérico copiado de stg.TotalCharges, DECIMAL(10,2), incluida la imputación documentada a cero. |
| churn_flag | INT | No | Indicador derivado de stg.Churn: Yes → 1, No → 0. Describe abandono registrado en la fuente; no es probabilidad ni predicción. |
| total_charges_imputed | INT | No | Indicador de imputación: 1 cuando TotalCharges original era blanco y tenure = 0; 0 cuando no se imputó. |
| imputation_reason | VARCHAR(64) | Sí | Motivo de imputación: BLANK_WITH_ZERO_TENURE para el blanco con tenure = 0; NULL cuando no hubo imputación. |
| source_load_id | VARCHAR(36) | No | Identificador del lote de origen, copiado de stg.load_id; permite rastrear la fila al procesamiento de staging. |

## Reglas de tratamiento y trazabilidad

- **Raw:** conserva el texto original, incluidos espacios. No se reemplazan los blancos por cero en la ingesta.
- **Staging:** valida identificador, antigüedad 0–72, importes, dominios de 17 campos categóricos y coherencia de siete relaciones entre servicios. Los importes informados deben tener formato decimal con punto y hasta dos decimales; MonthlyCharges debe estar entre 18 y 120 inclusive.
- **Imputación:** TotalCharges blanco con tenure = 0 se convierte a 0.00, total_charges_imputed = 1 e imputation_reason = BLANK_WITH_ZERO_TENURE. Los demás registros aceptados llevan indicador 0 y motivo NULL. Un TotalCharges NULL, con formato inválido o blanco sin tenure = 0 se rechaza.
- **Rechazos:** reject_reason acumula los códigos DQ_ID_INVALIDO, DQ_TENURE_RANGO, DQ_MONTHLY_FORMATO_O_RANGO, DQ_TOTAL_NULO_FORMATO_O_BLANCO_NO_IMPUTABLE, DQ_CATEGORIA_INVALIDA y DQ_SERVICIOS_INCONSISTENTES, separados por punto y coma. La detección previa de identificadores duplicados detiene el job; no realiza una deduplicación silenciosa.
- **Auditoría:** load_id relaciona staging y rechazos del mismo procesamiento. source_load_id conserva ese lote en hechos; fecha_carga, fecha_staging y fecha_rechazo describen etapas técnicas, no fechas de abandono.

## Segmentación y nivel de servicio

La segmentación analítica combina contract_type con service_level. InternetService identifica la tecnología de acceso (DSL, Fiber optic o No); service_level es una agrupación derivada distinta:

| Condición, evaluada en este orden | service_level |
|---|---|
| InternetService = No | Sin Internet |
| Tiene Internet y OnlineSecurity = Yes o TechSupport = Yes | Protegido |
| Tiene Internet y no cumple la condición anterior | Basico |

El churn histórico del segmento se calcula como SUM(churn_flag) / COUNT(*) × 100 sobre hechos unidos a sus dimensiones. Las acciones de retención y su reducción esperada requieren supuestos explícitos; este diccionario no demuestra un efecto causal ni crea un recomendador.

## Relaciones lógicas y linaje

| Origen | Destino | Relación |
|---|---|---|
| raw_telco_g2 | stg_telco_g2 | Validación, conversión e imputación documentada |
| raw_telco_g2 | rejects_telco_g2 | Separación de registros que incumplen reglas |
| stg_telco_g2 | dim_customer_telco_g2 | customerID → customer_id y atributos del cliente |
| stg_telco_g2 | dim_contract_telco_g2 | Combinaciones distintas de contrato, facturación y pago |
| stg_telco_g2 | dim_service_telco_g2 | Combinaciones distintas de servicios y nivel derivado |
| stg_telco_g2 | fact_contracts_telco_g2 | Medidas, indicadores y lote de origen |
| dim_customer_telco_g2 | fact_contracts_telco_g2 | customer_key BIGINT → customer_key BIGINT |
| dim_contract_telco_g2 | fact_contracts_telco_g2 | contract_key BIGINT → contract_key BIGINT |
| dim_service_telco_g2 | fact_contracts_telco_g2 | service_key BIGINT → service_key BIGINT |

En OpenMetadata las conexiones se registraron manualmente. El linaje muestra dependencias; no demuestra por sí solo que las tablas están cargadas o que todas las reglas pasen. La evidencia de las cinco pruebas de staging se conserva en [el reporte Cloud](../data_quality/2026-11-06_reporte_dq_staging_cloud.md).

## Fuentes y mantenimiento

- [CSV del equipo](../../data/telco_churn.csv): campos y categorías de origen.
- [DDL de staging y rechazos](../../sql/10_ddl_staging_cloud.sql): tipos y restricciones.
- [DDL del modelo Cloud](../../sql/11_ddl_modelo_cloud.sql): dimensiones y hechos.
- [Jobs Talend](../../IBM_TELCO_CHURN/process/Proyecto_Telco/): transformaciones implementadas.
- [Linaje Cloud](../lineage/2026-11-06_linaje_singlestore_cloud.md): relaciones y evidencia gráfica.

Este documento corresponde a SingleStore Cloud. No traslada automáticamente los nombres, tipos o restricciones a Snowflake. Al modificar un esquema o regla del job, actualizar este diccionario y volver a ingerir los metadatos; después publicar las descripciones de las columnas en el catálogo. No se asignan propietarios ni certificaciones globales sin el acuerdo y la evidencia del equipo.
