# 📐 Diseño y Justificación del Modelo Dimensional (Estrella) - IBM Telco Churn

> **Documento Técnico de Arquitectura de Datos**
>
> **Datatón Genius Lab IV** 
>
> **Infraestructura Destino:** Snowflake (`telco_g2.analytics`)  Y SingleStore (`DSADEV`)

## 🖼 1. Diagrama del Modelo Estrella (ERD)

### Grafo de Relaciones (Sintaxis Mermaid)

```
erDiagram
    dim_contract_telco_g2 ||--o{ fact_contracts_telco_g2 : "contract_key"
    dim_customer_telco_g2 ||--o{ fact_contracts_telco_g2 : "customer_key"
    dim_service_telco_g2  ||--o{ fact_contracts_telco_g2 : "service_key"

    dim_contract_telco_g2 {
        bigint contract_key PK
        varchar contract_type
        varchar paperless_billing
        varchar payment_method
    }
    dim_customer_telco_g2 {
        bigint customer_key PK
        varchar customer_id
        varchar gender
        varchar senior_citizen
        varchar partner
        varchar dependents
    }
    dim_service_telco_g2 {
        bigint service_key PK
        varchar phone_service
        varchar multiple_lines
        varchar internet_service
        varchar online_security
        varchar online_backup
        varchar device_protection
        varchar tech_support
        varchar streaming_tv
        varchar streaming_movies
        varchar service_level
    }
    fact_contracts_telco_g2 {
        bigint customer_key PK_FK
        bigint contract_key FK
        bigint service_key FK
        int tenure_months
        varchar tenure_group
        decimal monthly_charges
        decimal total_charges
        int churn_flag
        int total_charges_imputed
        varchar imputation_reason
        varchar source_load_id
    }

```

## 🎯 2. Justificación de Negocio y Arquitectura

De acuerdo con las especificaciones de **IBM Telco Churn** expuestas en la Sesión 17 del Datatón, el objetivo principal es responder a las siguientes preguntas clave:

1. **¿Qué segmentos de clientes tienen mayor propensión al abandono?**

2. **¿Qué acción de retención personalizada conviene aplicar a cada segmento?**

Para dar respuesta analítica eficiente, desacoplar el origen transaccional plano (CSV de 21 columnas) y permitir consultas OLAP de alto rendimiento en **Snowflake** y **SingleStore**, se modeló la información bajo el paradigma Kimball en un **Modelo en Estrella** .

## 🧩 3. Descripción y Razón de Elección de cada Tabla

### 3.1. Tabla de Hechos: `fact_contracts_telco_g2`

* **Propósito:** Es el núcleo del modelo analítico. Contiene los eventos medibles, métricas financieras y el indicador clave de desbalance de la empresa (`churn_flag`).

* **¿Por qué se eligió esta estructura?**

  * **Granularidad:** Un registro por cada contrato activo de un cliente (`customer_key`).

  * **Métricas acumuladas y transaccionales:** Concentra `tenure_months`, `monthly_charges` y `total_charges`.

  * **Soporte de Gobernanza y Calidad:** Incluye banderas de trazabilidad como `total_charges_imputed`, `imputation_reason` (para auditoría de los 11 casos con `tenure = 0`) y `source_load_id` para linaje en OpenMetadata.

  * **Conexión:** Enlaza las dimensiones a través de llaves foráneas sintéticas (`contract_key`, `service_key`, `customer_key`).

### 3.2. Dimensión Cliente: `dim_customer_telco_g2`

* **Propósito:** Contener los atributos demográficos y sociales del usuario.

* **¿Por qué se aisló en una dimensión propia?**

  * Responde a la segmentación según la composición del hogar (`Partner`, `Dependents`), género (`gender`) y condición de adulto mayor (`senior_citizen`).

  * Desacopla el identificador natural de negocio (`customer_id`, ej: `7590-VHVEG`) de la llave primaria sintética del Data Warehouse (`customer_key`), permitiendo una administración limpia de identidades.

### 3.3. Dimensión Contrato: `dim_contract_telco_g2`

* **Propósito:** Agrupar los términos comerciales y de facturación bajo los cuales opera el cliente.

* **¿Por qué se aisló en una dimensión propia?**

  * El tipo de contrato (`Contract`: *Month-to-month*, *One year*, *Two year*) es la variable con **mayor correlación de churn** en la industria (tasa de abandono proyectada del \~26.5%).

  * Permite analizar la propensión según el método de pago (`payment_method`) y la facturación electrónica (`paperless_billing`) de forma independiente a los servicios contratados.

### 3.4. Dimensión Servicios: `dim_service_telco_g2`

* **Propósito:** Agrupar el catálogo de productos y servicios digitales adicionales adscritos al cliente.

* **¿Por qué se aisló en una dimensión propia?**

  * Centraliza la conectividad principal (`phone_service`, `internet_service`: *DSL*, *Fiber optic*, *No*) y la matriz de valor agregado (`online_security`, `tech_support`, `streaming_tv`, `streaming_movies`, etc.).

  * Permite calcular el nivel global de servicio (`service_level`) para evaluar si clientes con ofertas de Fibra Óptica sin soporte técnico presentan mayor tasa de abandono.

## 🛠 4. Capas Intermedias: Staging y Rechazos

Para asegurar que los datos que llegan a este modelo estrella cumplan con el **umbral de calidad** $\ge 99\%$ exigido por las reglas del Datatón:

* **`"raw_telco_g2"`:** Mantiene los 7.043 registros brutos sin alterar (incluyendo los 11 valores en blanco de `TotalCharges`).

* **`"rejects_telco_g2"`:** Almacena los registros que violan reglas críticas de negocio (IDs nulos, tipos de datos incompatibles) especificando la columna `reject_reason`.

* **`"stg_telco_g2"`:** Capa intermedia limpia donde se aplican las reglas de tipado (conversión de textos a `NUMBER(8,2)`) e imputación (`TotalCharges = 0.00` cuando `tenure = 0`), alimentando de manera limpia las 3 dimensiones y la tabla de hechos.

## 📊 5. Cumplimiento de Criterios del Datatón

1. **Pipeline Funcional:** El modelo estrella simplifica la carga ELT desde SingleStore/Talend hacia Snowflake.

2. **Calidad de Datos:** Separación explícita de llaves primarias `IDENTITY(1,1)` y atributos de auditoría (`source_load_id`, `imputation_reason`).

3. **Dashboard & Análisis:** Estructura optimizada para consultas en Tableau (joins eficientes en estrella de 1 a N).