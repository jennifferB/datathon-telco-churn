# Configuraci?n local compartida de los jobs Telco

Los cinco jobs de `IBM_TELCO_CHURN/Proyecto_Telco` comienzan con **Cargar configuraci?n local**. Ya no solicitan la contrase?a en cada ejecuci?n ni la guardan como valor de contexto en Git.

## Una sola configuraci?n por equipo

Copiar `config/telco-cloud.properties.example` a:

- Windows: `C:/Users/<usuario>/.config/geniuslab/telco-cloud.properties`.
- Otros sistemas: `~/.config/geniuslab/telco-cloud.properties`.

Completar en esa copia local host, puerto, base, usuario, contrase?a y ruta del CSV. La ruta del CSV solo la usa la ingesta. Conservarla como archivo privado del usuario; no compartir ni agregar a Git. Los valores no se imprimen en consola.

En el equipo donde se prepar? este cambio el archivo local ya est? configurado y restringido al usuario y SYSTEM. El repositorio contiene ?nicamente una plantilla con contrase?a vac?a. Cada compa?ero debe preparar su propia copia; clonar el repo no entrega credenciales.

Opcionalmente, `TELCO_CONFIG_FILE` permite indicar otra ruta al archivo y `TELCO_DB_PASSWORD` reemplaza su contrase?a para esa ejecuci?n. Estas variables de entorno deben estar disponibles para el proceso de Studio o para el job exportado. El archivo se lee con Properties y UTF-8: conservar los escapes del formato Java Properties si la contrase?a contiene barras invertidas.

## Qu? ocurre al ejecutar

1. El componente inicial carga la configuraci?n privada.
2. Asigna los valores a las mismas variables `context.singlestore_*` que utilizan los componentes existentes.
3. Solo tras cargarla contin?a el job. Si falta el archivo o la contrase?a, se detiene antes de conectarse.
4. El resto de controles, transformaciones y protecciones contra recargas permanece activo.

Las configuraciones pueden reutilizarse entre los jobs, pero las cargas siguen siendo iniciales: **no repetir ingesta, staging o modelo para probar la contrase?a**, pues ya contienen datos. Para comprobar la nueva configuraci?n usar `job_telco_validar_modelo`, de solo lectura.

Despu?s de actualizar los archivos desde Git, cerrar y reabrir los editores de los jobs en Studio antes de ejecutarlos para que no conserven versiones antiguas en memoria. No guardar encima un editor antiguo que todav?a tenga credenciales incorporadas.

## Verificaci?n de este cambio

Se compil? el bloque Java exacto de carga de configuraci?n con JDK 21 y se comprob? que lee la configuraci?n local existente sin pedir ni mostrar la contrase?a. Se revis? que los cinco jobs tienen una ?nica entrada mediante ese componente y que los contextos incluidos en el commit no contienen valores de contrase?a.

La generaci?n completa de los cinco jobs con este nuevo componente queda por comprobar en Studio. Antes de este ajuste, el equipo ejecut? ingesta, staging y modelo y report? las validaciones aprobadas; la captura raw frente a staging confirma 11 espacios originales, tenure=0, valor tratado=0 y marca de imputaci?n.
