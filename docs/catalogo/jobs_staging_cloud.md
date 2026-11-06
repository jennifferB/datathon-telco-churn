# Jobs de staging — SingleStore Cloud

> Actualizaci?n de credenciales (6 de noviembre de 2026): los jobs cargan autom?ticamente una configuraci?n privada com?n al arrancar. Las instrucciones anteriores de introducir la contrase?a en cada Run quedan sustituidas por [Configuraci?n local de Telco](../configuracion_local_telco.md). No guardar contrase?as en los contextos versionados. El equipo report? la ejecuci?n y validaci?n de esta etapa antes de incorporar este cargador com?n; su compilaci?n completa en Studio se verifica con el job de solo lectura.


Fecha: 6 de noviembre de 2026.

## Alcance y estado

Se prepararon los archivos nativos de dos jobs para el proyecto `IBM_TELCO_CHURN`, carpeta `Proyecto_Telco`. No se ejecutaron jobs ni SQL contra la base Cloud. Tampoco se modificó el job de ingesta ni se publicaron commits. La apertura, generación y compilación completas dentro de Talend están pendientes; las comprobaciones realizadas fuera de Studio se describen al final.

## 1. job_telco_staging

Flujo:

`Prevalidar y crear destinos → tMysqlInput (raw) → tMap → tMysqlOutput (staging / rechazos) → reconciliar`

- Lee `raw_telco_g2`, no el CSV. No cambia ni elimina filas de raw.
- Requiere el contexto de `telco_g2`, puerto 3333, y 7043 filas con IDs distintos. Los duplicados en raw bloquean todo el job para evitar elegir arbitrariamente una copia.
- Crea `stg_telco_g2` y `rejects_telco_g2` si no existen, con longitudes explícitas. Los destinos deben estar vacíos. No ejecuta DROP, DELETE ni TRUNCATE.
- Mantiene MonthlyCharges y TotalCharges originales en `monthly_charges_raw` y `total_charges_raw`, y escribe los valores tratados como DECIMAL(8,2) y DECIMAL(10,2).
- Acepta importes no negativos, con punto decimal y hasta dos decimales. MonthlyCharges debe estar entre 18 y 120. Valida antigüedad 0–72, los dominios de las 17 categorías y siete relaciones entre servicios.
- Solo imputa TotalCharges a 0.00 cuando su original está vacío o tiene únicamente espacios y tenure=0. Marca `total_charges_imputed=1`, motivo `BLANK_WITH_ZERO_TENURE`. No trata NULL como blanco ni reemplaza importes no numéricos por cero.
- Conserva `No phone service` y `No internet service`, sin convertirlos a NULL.
- Envía filas inválidas a rechazos con los datos originales y uno o varios códigos de motivo.
- Ambos destinos guardan `load_id` y fecha de procesamiento. Staging conserva también fecha_carga del origen.
- Los errores al escribir detienen el proceso. Después de cerrar las salidas comprueba el resultado. Para este CSV se exige cero rechazos; si hay rechazos quedan guardados, pero la comprobación final falla para que se revisen.

La carga es inicial y tiene protección contra una segunda ejecución accidental. **No es una carga incremental ni una recuperación automática**: si falla después de insertar parcialmente, se revisa el estado antes de preparar una recuperación específica. No vaciar tablas para eludir el control. Ejecutar con una sola persona, sin cambiar raw mientras corre.

## 2. job_telco_validar_staging

Solo lectura. Se puede ejecutar de nuevo sin duplicar datos. Comprueba:

- Raw: 7043 filas, 7043 IDs distintos, cero NULL y 11 blancos en TotalCharges.
- Staging: 7043 filas e IDs distintos; cero rechazos.
- 11 imputaciones y sus condiciones correctas.
- Cero clientes perdidos y cero filas sin origen.
- Importes originales conservados y resultados DECIMAL coherentes con el tratamiento.
- Conservación de los demás campos y fecha_carga.
- Cero importes nulos, negativos o fuera del rango acordado.

Imprime los conteos en la consola. Si algún control no coincide, el job termina con error.

## Abrir o importar

Los archivos están escritos en el repositorio local de Talend. Con los editores de estos jobs cerrados, actualizar el árbol de Repositorio y abrir `Proyecto_Telco → job_telco_staging`.

Si Studio sigue mostrando el diseño anterior o no reconoce el segundo job:

1. Clic derecho en Job Designs → Import Items.
2. Seleccionar el ZIP `jobs_staging_cloud_importar_v2.zip` (o la carpeta `importar/IBM_TELCO_CHURN` como root directory).
3. Seleccionar únicamente `job_telco_staging` y `job_telco_validar_staging`.
4. Marcar sobrescribir elementos existentes para staging. Hay una copia del diseño previo en `respaldo_staging_antes` fuera del repo.
5. Finalizar y revisar el diseño antes de ejecutar. No importar un proyecto completo encima del actual.

Referencia de importación: https://help.qlik.com/talend/en-US/studio-user-guide/8.0-R2024-09/importing-items

## Ejecutar

1. Guardar/cerrar cualquier editor anterior de staging y abrir el nuevo diseño.
2. Revisar el contexto incorporado `Default`: host Cloud, puerto 3333, base telco_g2 y usuario del entorno nuevo. Estas variables son propias del job; no dependen del contexto compartido que usa la ingesta.
3. La contraseña viene vacía. Introducirla para la ejecución en los parámetros de contexto de Run, o suministrarla al ejecutar el job exportado. No incorporarla a un commit. Los componentes usan `context.singlestore_password` y SSL REQUIRED.
4. Ejecutar primero **job_telco_staging** una sola vez. El job crea sus dos tablas: no hace falta ejecutar antes el DDL adjunto.
5. Esperado: 7043 filas a staging, cero a rechazos, 11 imputaciones y mensaje `STAGING VALIDADO` en la consola.
6. Si falla la compilación o la ejecución, conservar el primer mensaje de error y revisar antes de reintentar. No repetir ingesta.
7. Ejecutar **job_telco_validar_staging** para obtener otra evidencia independiente. No necesita volver a cargar los datos.
8. Refrescar OpenMetadata cuando los resultados reales sean correctos. El siguiente trabajo del proyecto será cargar dimensiones y hechos desde staging; esos jobs aún no forman parte de este aporte.

## Comprobaciones realizadas sin controlar la pantalla

- XML de los jobs y referencias de componentes/conexiones válidos.
- Esquemas de salida del tMap idénticos en nombre, orden, tipo, longitud y precisión a sus salidas de base de datos.
- Las expresiones Java EXACTAS del tMap se compilaron con JDK 21 y se evaluaron sobre las 7043 filas del CSV versionado: 7043 válidas, 11 imputaciones.
- Se probaron 16 casos inválidos de identidad, formato, precisión, importes, categorías, antigüedad y coherencia de servicios, y un caso válido de imputación. Todos dieron el resultado esperado.
- Los bloques Java de controles previos y posteriores compilaron fuera de Studio. No se conectaron al servidor durante esas pruebas.
- Los dos jobs nuevos no contienen contraseñas literales ni copias de la contraseña cifrada de la ingesta.

Estas comprobaciones no sustituyen la generación completa de código de Talend ni prueban los permisos y resultados reales en SingleStore. No declarar staging cargado hasta ejecutar y guardar la evidencia de la consola.

## Correcci?n del paquete de importaci?n

El ZIP inicial omit?a `IBM_TELCO_CHURN/talend.project`, utilizado para reconocer el proyecto y resolver la referencia del autor. El paquete v2 incluye ese descriptor del proyecto junto con los cuatro archivos nativos de los dos jobs. No incluye contextos compartidos ni contrase?as. La estructura y las referencias XML se contrastaron con el ZIP exportado por Studio disponible en el repositorio. La importaci?n real se verifica al seleccionar v2 en Studio.
