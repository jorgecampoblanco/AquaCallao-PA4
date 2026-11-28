# A2 · Funciones escalar y de tipo tabla

**Autor:** Andy Alexandre Lescano Espino · **Rama:** `pa4/funciones-andy` · **Script:** `pa4/02_Funciones.sql`

## Objetos creados

| Objeto | Tipo | Entrada | Devuelve |
|---|---|---|---|
| `dbo.fn_PorcentajeDisponibleCisterna` | Escalar | `@CisternaID int` | `decimal(5,2)`: porcentaje del tanque con agua, o `NULL` si la cisterna no existe |
| `dbo.fn_EntregasPorSector` | De tipo tabla en línea | `@Sector nvarchar(60)` | Filas: EntregaID, FechaEntrega, ClienteID, Cliente, Sector, CisternaID, Placa, Producto, Litros |

Las dos funciones **solo leen datos**: no modifican tablas, no tocan el saldo y no reemplazan el procedimiento de reporte de PA3 (`usp_ReporteEntregasPorSector`).

## Decisiones técnicas

**Función escalar**

- **Se evita la división entera.** `SaldoLitros` y `CapacidadLitros` son `int`, y en SQL Server `int / int` descarta los decimales: 667 × 100 / 2000 da 33, no 33.35. Multiplicar por `100.0` convierte la operación a decimal, y el resultado se redondea a 2 decimales.
- **Un ID inexistente devuelve `NULL`, no 0.** Un 0 significaría "tanque vacío", que es un dato real. `NULL` indica "no hay cisterna con ese ID", así que el cliente no puede confundir los dos casos.
- **`NULLIF(CapacidadLitros, 0)`** protege contra la división por cero. La restricción `CK_Cisterna_Capacidad` ya exige capacidad > 0, pero la función no depende de esa regla para funcionar.

**Función de tipo tabla**

- **Es en línea** (`RETURNS TABLE AS RETURN (SELECT ...)`). SQL Server la integra en la consulta que la llama como si fuera una vista con parámetro, así que puede usar índices y filtros. Por eso no se usó una función de varias instrucciones con una variable tabla.
- **Une `Entrega` con `Cliente`**, porque el sector es un dato del cliente. También une `Cisterna` y `Producto` para mostrar la placa y el nombre del producto.
- **Aplica `LTRIM/RTRIM` al parámetro**, así que `'  Ventanilla  '` encuentra el sector igual.
- **Un sector sin entregas devuelve 0 filas, no un error.** Una tabla vacía es un resultado válido.

## Diferencia entre escalar y de tipo tabla

| | Escalar | De tipo tabla |
|---|---|---|
| Devuelve | **Un valor** | **Un conjunto de filas** |
| Dónde se usa | En `SELECT`, `WHERE` o una columna calculada: `dbo.fn_PorcentajeDisponibleCisterna(CisternaID)` | En `FROM` o `JOIN` como si fuera una tabla: `SELECT * FROM dbo.fn_EntregasPorSector(N'Ventanilla')` |
| Ejecución | Se evalúa una vez por cada fila de la consulta | Se integra en el plan de la consulta (en línea) |
| Ejemplo del caso | ¿Cuánto le queda a la cisterna ABC-123? | ¿Qué entregas recibió Ventanilla? |

## Función frente al procedimiento de reporte de PA3

`usp_ReporteEntregasPorSector` devuelve el resumen (cantidad y litros), pero el resultado de un procedimiento no se puede usar dentro de otra consulta. `fn_EntregasPorSector` devuelve el detalle como una tabla, y sobre ese resultado se puede filtrar, agrupar o unir; por ejemplo, la prueba T6 cruza la función de tabla con la escalar. Los dos objetos conviven: el procedimiento sigue siendo el reporte oficial, y la función sirve para reutilizar la consulta.

## Por qué en el servidor

El porcentaje y el listado por sector se calculan igual para cualquier aplicación. Si cada cliente calculara el porcentaje por su cuenta, alguno podría usar división entera y mostrar 33 % en vez de 33.35 %. Al centralizar la fórmula en una función, todos obtienen el mismo resultado y la regla se corrige en un solo lugar.
