# AquaCallao — PA4
**ISIL | Programación Avanzada de Base de Datos (30627) | Grupo 02 | Periodo 202620**

## Scripts de la PA4

La carpeta [pa4](pa4/) de la rama principal reúne los cinco módulos. El proyecto utiliza las tablas y procedimientos de [PA3](pa3_base/).

| Responsable | Archivo | Uso |
|---|---|---|
| Lucero Helen Corrales Granda | [01_Triggers.sql](pa4/01_Triggers.sql) | Auditoría de entregas |
| Andy Alexandre Lescano Espino | [02_Funciones.sql](pa4/02_Funciones.sql) | Porcentaje disponible y entregas por sector. [Justificación](docs/A2_Funciones.md) |
| Fernando Álvaro Quispe Trigos | [03_Cursores.sql](pa4/03_Cursores.sql) | Resumen de cisternas con cursor y consulta equivalente |
| Farid Alessandro Mori Barrientos | [Seguridad (2)](pa4/04_Validación_seguridad%20%282%29.sql) y [Seguridad (1)](pa4/04_Validación_seguridad%20%281%29.sql) | Ejecutar primero (2) para crear usuarios y roles. (1) prueba sus permisos. |
| Jorge Raúl Campoblanco Noriega | [05_PruebasIntegracion.sql](pa4/05_PruebasIntegracion.sql) | Carga, entregas, auditoría, saldo y permisos en una transacción de prueba |

## Ejecución en SQL Server

1. Abrir AquaCallao en SQL Server Management Studio (SSMS). Si se parte de una instancia de práctica vacía, ejecutar `pa3_base/01_CrearTablas.sql` una vez. Conservar la base existente cuando ya contiene las tablas de PA3.
2. Instalar las definiciones de los procedimientos de `pa3_base/sql/02_RegistrarCliente.sql`, `03_RegistrarCarga.sql` y `04_RegistrarEntrega.sql`. Seleccionar la definición de cada procedimiento hasta su GO final. Los bloques de demostración se ejecutan por separado.
3. En `01_Triggers.sql` ejecutar desde USE AquaCallao hasta el GO anterior a la sección 3. Hacer lo mismo en `02_Funciones.sql`. Así quedan disponibles la auditoría y las dos funciones.
4. En una instancia de práctica con permisos de administración, configurar los usuarios y roles una vez con el archivo de seguridad (2). Las pruebas individuales del archivo (1) incluyen operaciones denegadas y escrituras que permanecen en esa copia.
5. Abrir `05_PruebasIntegracion.sql` en una ventana nueva. Debe haber un cliente y un producto activos, y la placa PA4-JORGE debe estar libre. Ejecutar el archivo completo con F5. El cursor se incluye en la misma transacción.

## Pruebas y criterios de diseño

- **Auditoría.** El trigger une inserted y deleted por EntregaID para registrar altas, cambios y bajas, incluso cuando una sentencia afecta varias entregas. La tabla de auditoría conserva los litros anteriores y nuevos.
- **Funciones.** La función escalar devuelve el porcentaje de una cisterna. La función de tabla devuelve las entregas de un sector y permite filtrarlas o agruparlas en otra consulta.
- **Cursores.** El cursor imprime una línea por cisterna. Para un reporte tabular preferimos el SELECT equivalente porque devuelve todas las filas en una consulta y evita recorrerlas explícitamente.
- **Seguridad.** El operador registra movimientos, el gestor mantiene los catálogos y el auditor consulta los datos. Los usuarios reciben permisos a través de sus roles. Una contraseña autentica el inicio de sesión. Un certificado puede usarse para firmar un módulo y autorizar operaciones específicas mediante esa firma. El proyecto implementa autenticación y roles.
- **Integración.** Sobre una cisterna de 2000 L, una carga de 1000 L y entregas de 300 y 33 L deben dejar 667 L (33,35 %). Se contrastan ambos registros de auditoría, el resumen del cursor y los permisos del auditor. Tras ROLLBACK, los cuatro conteos de filas de prueba deben ser cero.

## Entregables

**Video de YouTube**

