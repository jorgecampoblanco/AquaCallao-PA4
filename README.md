# AquaCallao · PA4

Proyecto del curso Programación Avanzada de Base de Datos.

## El reparto de agua en el Callao

AquaCallao registra el agua que ingresa a cada cisterna y las entregas a clientes de distintos sectores. Cuando se corrige una entrega, el valor actual por sí solo no permite saber cuántos litros figuraban antes. Además, el personal que revisa el reparto necesita consultar los movimientos con permisos distintos de los que utiliza quien los registra.

El objetivo de esta etapa es conservar el historial de las entregas, consultar el agua disponible y el reparto por sector, y asignar a cada usuario los permisos que corresponden a su trabajo. Se reutilizan las tablas y los procedimientos de la [PA3](pa3_base/).

## Integrantes y aportes

| Responsable | Archivo | Uso |
|---|---|---|
| Lucero Helen Corrales Granda | [01_Triggers.sql](pa4/01_Triggers.sql) | Auditoría de entregas |
| Andy Alexandre Lescano Espino | [02_Funciones.sql](pa4/02_Funciones.sql) | Porcentaje disponible y entregas por sector. [Justificación](docs/A2_Funciones.md) |
| Fernando Álvaro Quispe Trigos | [03_Cursores.sql](pa4/03_Cursores.sql) | Resumen de cisternas con cursor y consulta equivalente |
| Farid Alessandro Mori Barrientos | [Seguridad (2)](pa4/04_Validación_seguridad%20%282%29.sql) y [Seguridad (1)](pa4/04_Validación_seguridad%20%281%29.sql) | Ejecutar primero (2) para crear usuarios y roles. (1) prueba sus permisos. |
| Jorge Raúl Campoblanco Noriega | [05_PruebasIntegracion.sql](pa4/05_PruebasIntegracion.sql) | Carga, entregas, auditoría, saldo y permisos en una transacción de prueba |

## Desarrollo de la solución

- **Auditoría de entregas.** El trigger compara las filas de `inserted` y `deleted` por `EntregaID`. Así registra el valor anterior y el nuevo al insertar, corregir o eliminar una entrega, incluso cuando una sentencia afecta varias filas. Al situar la auditoría en la tabla, cada cambio queda registrado en la misma operación que lo originó.
- **Consultas del reparto.** La función escalar devuelve un solo dato por cisterna: el porcentaje disponible sobre su capacidad total. La función de tabla devuelve una fila por entrega del sector consultado. Esas filas permiten tanto revisar el detalle como sumar los litros repartidos.
- **Recorrido de cisternas.** El cursor recorre las cisternas e imprime la placa, el saldo, la capacidad y el estado de cada una. Ese recorrido permite tratar cada cisterna por separado. Para comparar saldos entre varias cisternas se usa el `SELECT` del mismo archivo, que devuelve los datos en una cuadrícula y evita el procesamiento fila por fila.
- **Control de acceso.** Se utiliza autenticación de SQL Server. Cada login tiene una contraseña y se vincula con un usuario de AquaCallao. Los permisos se asignan al rol y cada usuario se incorpora al rol de su perfil. Las claves criptográficas permiten proteger datos o generar firmas. Un certificado permite verificar, por ejemplo, la firma de un procedimiento. En AquaCallao el acceso se implementa mediante logins, usuarios y roles.

### Matriz de perfiles

| Perfil | Operaciones autorizadas | Restricción que se prueba |
|---|---|---|
| Operador | Consulta los catálogos, registra cargas y entregas y actualiza el saldo en litros de la cisterna. | No puede registrar clientes. |
| Gestor de catálogo | Consulta, registra y actualiza clientes, productos y cisternas. Puede consultar las cargas y entregas. | No puede eliminar clientes. |
| Auditor | Consulta los datos del esquema `dbo`. | No puede modificar el estado de una cisterna. |

## Cómo ejecutar el proyecto

1. Abrir SQL Server Management Studio (SSMS). Para una instalación nueva, ejecutar [01_CrearTablas.sql](pa3_base/01_CrearTablas.sql) una sola vez. Si AquaCallao ya tiene las tablas de PA3, continuar con esa base.
2. Instalar las definiciones de los procedimientos [RegistrarCliente](pa3_base/sql/02_RegistrarCliente.sql), [RegistrarCarga](pa3_base/sql/03_RegistrarCarga.sql) y [RegistrarEntrega](pa3_base/sql/04_RegistrarEntrega.sql), hasta el `GO` que cierra cada definición. Los ejemplos de esos archivos se ejecutan por separado.
3. En los archivos de triggers y funciones, ejecutar desde `USE AquaCallao` hasta el `GO` anterior a la sección 3. La sección 3 contiene las pruebas de cada módulo. El archivo de cursores se puede ejecutar completo para comparar las pestañas **Mensajes** y **Resultados**.
4. Configurar los logins, usuarios y roles una sola vez con **Seguridad (2)** en la instancia de práctica. Si ya están configurados, pasar a **Seguridad (1)**. Ejecutar cada prueba desde `EXECUTE AS USER` hasta `REVERT` y `GO`. Las operaciones de escritura autorizadas de este archivo permanecen en la copia de práctica.
5. Abrir **05_PruebasIntegracion.sql** en una ventana nueva. Se necesita al menos un cliente activo, un producto activo, la placa `PA4-JORGE` disponible y una cuenta que pueda ejecutar la prueba como `usr_auditor`. Pulsar **F5** con el archivo completo. La prueba incluye el recorrido de cisternas y termina con `ROLLBACK`.

## Evidencias y resultados de las pruebas

**Permisos del auditor.** En la prueba 3, las consultas a `CargaAgua` y `Cliente` devolvieron una fila cada una. Al intentar cambiar el estado de la cisterna 1 a `Inactiva`, SQL Server devolvió el error 229 en la sentencia `UPDATE`. El auditor pudo leer los registros y el cambio de estado quedó bloqueado. [Consultar la prueba de permisos](pa4/04_Validación_seguridad%20%281%29.sql).

**Comprobaciones de la prueba integrada.** La placa `PA4-JORGE` identifica la cisterna temporal. Estos son los resultados que se deben obtener al ejecutar el [script de integración](pa4/05_PruebasIntegracion.sql).

| Comprobación | Resultado esperado |
|---|---|
| Saldo disponible | De una carga de 1000 L se entregan 300 L y 33 L. Quedan 667 L, equivalentes al 33,35 % de los 2000 L de capacidad. |
| Entregas y auditoría | Los mismos dos `EntregaID` aparecen en la consulta por sector y en la auditoría. Cada alta registra `INSERT`, valor anterior `NULL` y valor nuevo de 300 o 33 L. |
| Cursor | En Mensajes aparece la placa de prueba con 667 L y estado operativo. La consulta tabular permite contrastar el saldo. |
| Permisos | Para `usr_auditor` se obtiene `PuedeConsultar = 1` y `PuedeActualizar = 0`. |
| Reversión | Después de `ROLLBACK`, los conteos de cisternas, cargas, entregas y auditorías de la prueba deben quedar en cero. |

## Conclusiones

El identificador de entrega permite relacionar el reparto por sector con su historial de cambios. El saldo en litros y el porcentaje responden preguntas distintas: el primero indica cuánto queda para repartir y el segundo cuánto representa ese volumen respecto de la capacidad de la cisterna.

La prueba del auditor confirmó la separación entre consulta y modificación. El uso de una transacción en la prueba integrada permite revisar una operación completa y retirar luego sus registros para repetirla sobre la misma base.

**Video público de YouTube:** [PEGAR AQUÍ EL ENLACE]
