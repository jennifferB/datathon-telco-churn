# Modelo dimensional desde staging — SingleStore Cloud

## Pipeline maestro en IBM_TELCO_CHURN

El job **job_telco_pipeline_maestro** encadena ingesta del CSV, staging, validación de staging, carga dimensional y validación del modelo. Se detiene si falla un job hijo. En **Run → Basic Run**, seleccionar **Default** y completar host, usuario, contraseña, ruta del CSV y origen de carga. Para reconstruir el modelo usar **modo = carga_inicial**. Con **modo = validar** se consultan los resultados existentes.

Los cuatro destinos dimensionales usan **load_ts DATETIME** para guardar la hora de Ecuador continental y **load_source VARCHAR(100)** para el origen de la carga. El maestro comprueba ese esquema y que las siete tablas de carga están vacías antes de abrir el CSV.

1. Respaldar los datos y coordinar la prueba con el equipo.
2. Si los destinos usan TIMESTAMP, ejecutar el bloque 8 del [script de auditoría](../../sql/15_validar_load_ts_cloud.sql). Revisar y ejecutar cada sentencia generada por separado.
3. Ejecutar el bloque 9. Debe devolver siete sentencias. Ejecutarlas en el orden indicado para vaciar las tablas del flujo. La dimensión de fechas queda fuera de la recarga.
4. Ejecutar el maestro en modo **carga_inicial**. Confirmar código 0, 7.043 hechos, 11 imputaciones y 0 rechazos.
5. Ejecutar el bloque 10 y comprobar que la hora de carga de hechos coincide con la ejecución en Ecuador y que el origen coincide con el contexto.

El maestro terminó con código 0 el 7 de noviembre de 2026 a las 19:04. El bloque 10 confirmó **7.043 hechos**, **0 sin fecha** y **0 sin origen**, con un solo origen **Telco_001**. La primera y la última fecha almacenada coinciden a las **19:04:13 (UTC−05:00)**. [Evidencia de la recarga en Cloud](../analisis/evidencias/2026-11-07_recarga_maestro_auditoria_cloud.png).

## Transferencia a Snowflake

El maestro llama a `job_telco_transferir_snowflake` después de validar el modelo de SingleStore. En `carga_inicial` envía el modelo en modo `cargar`. La carga inicial requiere configurar `snowflake_password` en Run antes de empezar. En `validar`, si se proporciona esa contraseña, también compara el modelo de Snowflake. Si se deja vacía, se ejecutan las validaciones de SingleStore.

El destino es `TELCO_G2.ANALYTICS`. El job conserva las claves, compara filas completas y prepara las cuatro tablas en copias temporales de sesión. En `cargar`, si el destino ya coincide, termina sin escribir en las tablas compartidas. Si difiere, actualiza el conjunto completo en una transacción y comprueba el resultado antes de confirmar.

La ejecución independiente del 7 de noviembre de 2026 terminó con código 0 en modo `comparar`. Las cuatro tablas coincidieron fila por fila. En hechos se verificaron 7.043 registros, 1.869 abandonos, 11 imputaciones y cero huérfanos. La prueba integrada en modo `validar` empezó a las 23:04 y terminó a las 23:05 del 7 de noviembre de 2026 (hora de Ecuador), con código 0. El maestro registró `STAGING VALIDADO`, `MODELO DIMENSIONAL VALIDADO` y `SNOWFLAKE CONCILIADO`, en ese orden. Los conteos de clientes, contratos, servicios y hechos fueron 7.043, 24, 322 y 7.043, respectivamente, con cero diferencias en ambos sentidos. Esta prueba verifica la comparación de Snowflake desde el maestro.

El 7 de noviembre de 2026, la recarga completa en modo `carga_inicial` terminó a las 23:18 (hora de Ecuador) con código 0. El maestro reconstruyó staging y el modelo dimensional en SingleStore Cloud. Después, el job de transferencia detectó diferencias en las cuatro tablas de Snowflake y volvió a compararlas tras escribir. El log registró cero diferencias en ambos sentidos y `SNOWFLAKE CARGADO`, con 7.043 hechos, 1.869 abandonos, 11 imputaciones y cero huérfanos.

## Antecedentes del job dimensional

Para la variante del job en `TELCOM_G2`, `load_ts` registra en UTC la hora de extracción hacia cada destino dimensional y `load_source` toma el origen del contexto Talend. Las conexiones JDBC del job interpretan las fechas en UTC. `source_load_id` sigue identificando el lote de staging en hechos.

El esquema anterior usaba `TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP` y `VARCHAR(100)`. En la base Cloud existente, la inspección del 7 de noviembre de 2026 confirmó ambos campos en hechos y en las tres dimensiones. También mostró `ON UPDATE CURRENT_TIMESTAMP` en las cuatro tablas. Una edición puede cambiar esa fecha, por lo que su presencia por sí sola no acredita la hora de la carga original.

Los bloques 3 y 4 de [la comprobación de auditoría](../../sql/15_validar_load_ts_cloud.sql) miden la cobertura de hechos y muestran los valores por lote y origen. Para completar un dato histórico, contrastar el lote con el log de la carga dimensional. `fecha_staging` corresponde al procesamiento de staging. Si falta evidencia de la fecha original, registrar esa limitación antes de corregir los valores existentes. La carga inicial exige destinos vacíos.

En la comprobación del lote anterior del 7 de noviembre de 2026, el lote histórico conservó 7.043 hechos y 7.043 clientes distintos. Se recuperó `load_source = 'Telco_001'` de staging, donde las 7.043 filas del lote registraban ese mismo origen. La consulta final mostró cero hechos sin origen y 7.043 con `load_ts` en NULL. La hora de carga de hechos quedó sin documentar porque la consola de la ejecución original ya no mostraba ese registro. [Captura de la comprobación en Cloud](../analisis/evidencias/2026-11-07_auditoria_origen_hechos.png).



Preparado el 6 de noviembre de 2026. Estado: jobs nativos preparados y probados parcialmente fuera de Talend. No se ejecutó la carga ni se modificó la base Cloud. La generación y ejecución completas en Studio quedan pendientes.

## Qué importar

Paquete `jobs_modelo_cloud_importar.zip`, con descriptor `talend.project` y dos jobs:

- `job_telco_modelo_dimensional`: comprueba staging, crea los cuatro destinos si no existen y carga dimensiones y hechos en orden.
- `job_telco_validar_modelo`: solo consulta y compara el modelo con staging. Puede repetirse sin cargar ni alterar datos.

No se modifica el job de ingesta ni el de staging. No incluye contraseñas ni contextos compartidos.

## Orden de ejecución

1. Talend → Job Designs → clic derecho → Import Items → Select archive file → elegir el ZIP.
2. Seleccionar únicamente los dos jobs nuevos y finalizar. Deben aparecer en Proyecto_Telco.
3. Abrir `job_telco_modelo_dimensional`. En los parámetros de contexto de Run, comprobar servidor Cloud, puerto 3333, base telco_g2 y usuario. Introducir la contraseña para esta ejecución como en staging; el paquete la deja vacía.
4. Ejecutar una sola vez. No volver a ejecutar ingesta ni staging.
5. Esperar el mensaje `MODELO DIMENSIONAL VALIDADO` y revisar los conteos. Guardar la evidencia de consola como `2026-11-06_modelo_dimensional_cloud.png`.
6. Abrir `job_telco_validar_modelo`, suministrar su contraseña de ejecución y ejecutar. Guardar la validación independiente.
7. Si hay error, detenerse y conservar el primer mensaje y los conteos antes de cualquier reintento. No borrar tablas ni cambiar a Drop/Create.

## Qué hace el job

`Control de staging → clientes → contratos → servicios → comprobar claves → hechos → reconciliar`

Las transformaciones del modelo se expresan en las consultas de tMysqlInput y la escritura la realiza tMysqlOutput. Talend coordina las etapas mediante OnSubjobOk. El tratamiento de blancos y validaciones de origen ya corresponde al tMap del job de staging: este job consume esos resultados y no vuelve a imputar valores.

- Clientes: una fila por customerID; SeniorCitizen 0/1 se representa como No/Yes después de validar staging.
- Contratos: una fila por combinación de Contract, PaperlessBilling y PaymentMethod.
- Servicios: una fila por combinación de los nueve atributos de servicios. Se mantiene el criterio existente del proyecto: Sin Internet cuando InternetService=No; Protegido cuando OnlineSecurity=Yes o TechSupport=Yes; Basico en los demás casos. Este nivel es una regla de segmentación definida para el proyecto, no una etiqueta original del CSV.
- Hechos: un registro por cliente. Busca las tres claves de dimensiones y conserva importes DECIMAL, antigüedad, grupo de antigüedad y churn 1/0.
- Trazabilidad adicional de hechos: total_charges_imputed, imputation_reason y source_load_id proceden de staging. No agrega fecha de negocio inexistente al dataset.
- En este entorno nuevo, las claves de dimensiones y hechos son BIGINT de forma consistente. Las tablas antiguas compartidas no se alteran.

El job crea cuatro tablas usando CREATE TABLE IF NOT EXISTS, sin inferir VARCHAR(0) ni borrar datos. No hace falta crear otra base ni ejecutar el DDL antes del job. El archivo SQL adjunto documenta las definiciones para revisión.

## Controles

Antes de crear/cargar el modelo se ejecutan los controles completos de staging: 7043 clientes, 11 imputaciones, cero rechazos, originales y valores tratados coherentes y raw conservado. Se comprueba que las cuatro tablas del modelo están vacías.

Después de cargar dimensiones se exige una sola combinación de claves para cada uno de los 7043 clientes. Las dimensiones deben tener 7043 clientes, 24 contratos y 322 servicios para este CSV. Solo entonces comienza hechos.

Al terminar se comprueban conteos, clientes perdidos, hechos huérfanos, medidas, antigüedad, churn, asociaciones con dimensiones, nivel de servicio y campos de trazabilidad. Todas las comparaciones deben coincidir con staging.

| Resultado | Esperado para este CSV |
|---|---:|
| dim_customer_telco_g2 | 7043 |
| dim_contract_telco_g2 | 24 |
| dim_service_telco_g2 | 322 |
| fact_contracts_telco_g2 | 7043 |
| Clientes con churn | 1869 |
| Imputaciones en hechos | 11 |
| Hechos huérfanos | 0 |
| Clientes de staging sin hecho | 0 |
| Diferencias del modelo frente a staging | 0 |
| Blancos originales de TotalCharges en raw | 11 |

## Reejecución y alcance

Este es un job de carga inicial del archivo concreto del curso, no un proceso incremental de producción. Sus controles previenen una segunda carga accidental; si el modelo ya contiene filas, falla antes de insertar más. No se implementa actualización automática de hechos existentes.

Ejecutar con una sola persona, sin cambios simultáneos de raw, staging o modelo. Los controles no son un bloqueo de concurrencia. Las salidas usan conexiones propias y el job completo no es una única transacción atómica. Ante un fallo parcial, las filas ya escritas pueden permanecer: se debe revisar y preparar una recuperación específica antes de reintentar. No utilizar TRUNCATE ni DROP para saltarse la protección.

El modelo reside en SingleStore Cloud, base telco_g2. Snowflake aún es otro tramo pendiente. Con los destinos raw, staging, rechazos, tres dimensiones y hechos se utilizan siete tablas del entorno Shared.

## Validación realizada fuera de Studio

- Estructura XML, nombres de componentes y conexiones y ausencia de contraseñas literales en los jobs nuevos.
- Compilación con JDK 21 de los bloques Java exactos de controles previos, comprobación de dimensiones y reconciliación final, sin conexión al servidor.
- Ejecución de las consultas de dimensiones, resolución de claves y reconciliación del modelo con SQLite en memoria y el CSV versionado. Cumplió todos los conteos de la tabla anterior.
- Pruebas de regresión: un importe modificado se detectó como diferencia; una clave de servicio inexistente se detectó como hecho huérfano.

SQLite no verifica la planificación distribuida ni la precisión decimal del motor SingleStore. Estas pruebas tampoco sustituyen generar y compilar los jobs completos en Talend y verificar su ejecución real. Los resultados Cloud deben evidenciarse antes de marcar el entregable completado.
