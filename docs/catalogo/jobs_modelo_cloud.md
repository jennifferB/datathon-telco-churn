# Modelo dimensional desde staging ? SingleStore Cloud



Preparado el 6 de noviembre de 2026. Estado: jobs nativos preparados y probados parcialmente fuera de Talend. No se ejecut? la carga ni se modific? la base Cloud. La generaci?n y ejecuci?n completas en Studio quedan pendientes.

## Qu? importar

Paquete `jobs_modelo_cloud_importar.zip`, con descriptor `talend.project` y dos jobs:

- `job_telco_modelo_dimensional`: comprueba staging, crea los cuatro destinos si no existen y carga dimensiones y hechos en orden.
- `job_telco_validar_modelo`: solo consulta y compara el modelo con staging. Puede repetirse sin cargar ni alterar datos.

No se modifica el job de ingesta ni el de staging. No incluye contrase?as ni contextos compartidos.

## Orden de ejecuci?n

1. Talend ? Job Designs ? clic derecho ? Import Items ? Select archive file ? elegir el ZIP.
2. Seleccionar ?nicamente los dos jobs nuevos y finalizar. Deben aparecer en Proyecto_Telco.
3. Abrir `job_telco_modelo_dimensional`. En los par?metros de contexto de Run, comprobar servidor Cloud, puerto 3333, base telco_g2 y usuario. Introducir la contrase?a para esta ejecuci?n como en staging; el paquete la deja vac?a.
4. Ejecutar una sola vez. No volver a ejecutar ingesta ni staging.
5. Esperar el mensaje `MODELO DIMENSIONAL VALIDADO` y revisar los conteos. Guardar la evidencia de consola como `2026-11-06_modelo_dimensional_cloud.png`.
6. Abrir `job_telco_validar_modelo`, suministrar su contrase?a de ejecuci?n y ejecutar. Guardar la validaci?n independiente.
7. Si hay error, detenerse y conservar el primer mensaje y los conteos antes de cualquier reintento. No borrar tablas ni cambiar a Drop/Create.

## Qu? hace el job

`Control de staging ? clientes ? contratos ? servicios ? comprobar claves ? hechos ? reconciliar`

Las transformaciones del modelo se expresan en las consultas de tMysqlInput y la escritura la realiza tMysqlOutput. Talend coordina las etapas mediante OnSubjobOk. El tratamiento de blancos y validaciones de origen ya corresponde al tMap del job de staging: este job consume esos resultados y no vuelve a imputar valores.

- Clientes: una fila por customerID; SeniorCitizen 0/1 se representa como No/Yes despu?s de validar staging.
- Contratos: una fila por combinaci?n de Contract, PaperlessBilling y PaymentMethod.
- Servicios: una fila por combinaci?n de los nueve atributos de servicios. Se mantiene el criterio existente del proyecto: Sin Internet cuando InternetService=No; Protegido cuando OnlineSecurity=Yes o TechSupport=Yes; Basico en los dem?s casos. Este nivel es una regla de segmentaci?n definida para el proyecto, no una etiqueta original del CSV.
- Hechos: un registro por cliente. Busca las tres claves de dimensiones y conserva importes DECIMAL, antig?edad, grupo de antig?edad y churn 1/0.
- Trazabilidad adicional de hechos: total_charges_imputed, imputation_reason y source_load_id proceden de staging. No agrega fecha de negocio inexistente al dataset.
- En este entorno nuevo, las claves de dimensiones y hechos son BIGINT de forma consistente. Las tablas antiguas compartidas no se alteran.

El job crea cuatro tablas usando CREATE TABLE IF NOT EXISTS, sin inferir VARCHAR(0) ni borrar datos. No hace falta crear otra base ni ejecutar el DDL antes del job. El archivo SQL adjunto documenta las definiciones para revisi?n.

## Controles

Antes de crear/cargar el modelo se ejecutan los controles completos de staging: 7043 clientes, 11 imputaciones, cero rechazos, originales y valores tratados coherentes y raw conservado. Se comprueba que las cuatro tablas del modelo est?n vac?as.

Despu?s de cargar dimensiones se exige una sola combinaci?n de claves para cada uno de los 7043 clientes. Las dimensiones deben tener 7043 clientes, 24 contratos y 322 servicios para este CSV. Solo entonces comienza hechos.

Al terminar se comprueban conteos, clientes perdidos, hechos hu?rfanos, medidas, antig?edad, churn, asociaciones con dimensiones, nivel de servicio y campos de trazabilidad. Todas las comparaciones deben coincidir con staging.

| Resultado | Esperado para este CSV |
|---|---:|
| dim_customer_telco_g2 | 7043 |
| dim_contract_telco_g2 | 24 |
| dim_service_telco_g2 | 322 |
| fact_contracts_telco_g2 | 7043 |
| Clientes con churn | 1869 |
| Imputaciones en hechos | 11 |
| Hechos hu?rfanos | 0 |
| Clientes de staging sin hecho | 0 |
| Diferencias del modelo frente a staging | 0 |
| Blancos originales de TotalCharges en raw | 11 |

## Reejecuci?n y alcance

Este es un job de carga inicial del archivo concreto del curso, no un proceso incremental de producci?n. Sus controles previenen una segunda carga accidental; si el modelo ya contiene filas, falla antes de insertar m?s. No se implementa actualizaci?n autom?tica de hechos existentes.

Ejecutar con una sola persona, sin cambios simult?neos de raw, staging o modelo. Los controles no son un bloqueo de concurrencia. Las salidas usan conexiones propias y el job completo no es una ?nica transacci?n at?mica. Ante un fallo parcial, las filas ya escritas pueden permanecer: se debe revisar y preparar una recuperaci?n espec?fica antes de reintentar. No utilizar TRUNCATE ni DROP para saltarse la protecci?n.

El modelo reside en SingleStore Cloud, base telco_g2. Snowflake a?n es otro tramo pendiente. Con los destinos raw, staging, rechazos, tres dimensiones y hechos se utilizan siete tablas del entorno Shared.

## Validaci?n realizada fuera de Studio

- Estructura XML, nombres de componentes y conexiones y ausencia de contrase?as literales en los jobs nuevos.
- Compilaci?n con JDK 21 de los bloques Java exactos de controles previos, comprobaci?n de dimensiones y reconciliaci?n final, sin conexi?n al servidor.
- Ejecuci?n de las consultas de dimensiones, resoluci?n de claves y reconciliaci?n del modelo con SQLite en memoria y el CSV versionado. Cumpli? todos los conteos de la tabla anterior.
- Pruebas de regresi?n: un importe modificado se detect? como diferencia; una clave de servicio inexistente se detect? como hecho hu?rfano.

SQLite no verifica la planificaci?n distribuida ni la precisi?n decimal del motor SingleStore. Estas pruebas tampoco sustituyen generar y compilar los jobs completos en Talend y verificar su ejecuci?n real. Los resultados Cloud deben evidenciarse antes de marcar el entregable completado.
