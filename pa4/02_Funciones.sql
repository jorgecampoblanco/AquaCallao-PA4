-- AquaCallao PA4 | A2: Funciones escalar y de tipo tabla
-- Autor: Andy Alexandre Lescano Espino (rama pa4/funciones-andy)
-- Sesiones 11-12: funciones definidas por el usuario.
-- Requisitos: base AquaCallao creada con pa3_base/01_CrearTablas.sql y procedimientos de
--             pa3_base/sql (usp_RegistrarCliente, usp_RegistrarCarga, Sp_RegistrarEntrega).
-- Las funciones SOLO LEEN datos: no modifican tablas ni reemplazan el reporte de PA3.
-- Las pruebas corren dentro de BEGIN TRAN ... ROLLBACK: no dejan datos residuales.

USE AquaCallao;
GO

/* =====================================================================
   1. Funcion ESCALAR: devuelve UN valor
      Porcentaje del tanque que aun tiene agua: SaldoLitros / CapacidadLitros * 100
   ===================================================================== */
CREATE OR ALTER FUNCTION dbo.fn_PorcentajeDisponibleCisterna (@CisternaID int)
RETURNS decimal(5,2)
AS
BEGIN
    DECLARE @Porcentaje decimal(5,2);   -- queda NULL si la cisterna no existe

    SELECT @Porcentaje = CAST(ROUND(SaldoLitros * 100.0       -- 100.0 evita la division entera
                                    / NULLIF(CapacidadLitros, 0), 2) AS decimal(5,2))
    FROM dbo.Cisterna
    WHERE CisternaID = @CisternaID;

    RETURN @Porcentaje;   -- ID inexistente o NULL -> NULL (no es 0: 0 significaria tanque vacio)
END;
GO

/* =====================================================================
   2. Funcion de TIPO TABLA (en linea): devuelve FILAS
      Entregas de un sector, uniendo Entrega con Cliente (y Cisterna/Producto para detalle).
      Se puede usar en FROM, filtrar, agrupar o unir, cosa que un procedimiento no permite.
   ===================================================================== */
CREATE OR ALTER FUNCTION dbo.fn_EntregasPorSector (@Sector nvarchar(60))
RETURNS TABLE
AS
RETURN
(
    SELECT e.EntregaID,
           e.FechaEntrega,
           c.ClienteID,
           c.Nombre      AS Cliente,
           c.Sector,
           e.CisternaID,
           ci.Placa,
           p.Nombre      AS Producto,
           e.Litros
    FROM dbo.Entrega   AS e
    JOIN dbo.Cliente   AS c  ON c.ClienteID   = e.ClienteID
    JOIN dbo.Cisterna  AS ci ON ci.CisternaID = e.CisternaID
    JOIN dbo.Producto  AS p  ON p.ProductoID  = e.ProductoID
    WHERE c.Sector = LTRIM(RTRIM(@Sector))     -- tolera espacios al inicio o al final
);
GO

/* =====================================================================
   3. Pruebas (base recien inicializada: cisterna 1 de 2 000 L con saldo 0,
      cliente 1 de Ventanilla, sin cargas ni entregas)
   ===================================================================== */
SET NOCOUNT ON;
BEGIN TRAN;   -- todo lo que sigue se revierte al final

    DECLARE @idMiPeru int, @idE1 int, @idE2 int, @ret int;

    -- F1. Estado inicial: saldo 0 -> 0.00 %
    SELECT 'F1 saldo inicial' AS Caso, CisternaID, SaldoLitros, CapacidadLitros,
           dbo.fn_PorcentajeDisponibleCisterna(CisternaID) AS PorcentajeDisponible   -- esperado 0.00
    FROM dbo.Cisterna WHERE CisternaID = 1;

    -- Preparar datos usando los procedimientos reales de PA3
    EXEC @ret = dbo.usp_RegistrarCliente @Nombre = N'Beneficiario Mi Peru 01', @Documento = '04567890',
                                         @Sector = N'Mi Perú', @ClienteID = @idMiPeru OUTPUT;   -- sector SIN entregas
    EXEC dbo.usp_RegistrarCarga   @CisternaID = 1, @ProductoID = 1, @Litros = 1000;
    EXEC dbo.Sp_RegistrarEntrega  @ClienteID = 1, @CisternaID = 1, @ProductoID = 1, @Litros = 300, @EntregaID = @idE1 OUTPUT;
    EXEC dbo.Sp_RegistrarEntrega  @ClienteID = 1, @CisternaID = 1, @ProductoID = 1, @Litros = 33,  @EntregaID = @idE2 OUTPUT;

    -- F2. Tras cargar 1 000 L y entregar 333 L: saldo 667 -> 33.35 %
    --     La division entera (667 * 100 / 2000) daria 33: por eso se usa 100.0
    SELECT 'F2 saldo 667 L' AS Caso, SaldoLitros, CapacidadLitros,
           SaldoLitros * 100 / CapacidadLitros              AS DivisionEntera_Incorrecta,  -- 33
           dbo.fn_PorcentajeDisponibleCisterna(CisternaID)  AS PorcentajeDisponible       -- 33.35
    FROM dbo.Cisterna WHERE CisternaID = 1;

    -- F3. Cisterna inexistente y parametro NULL -> NULL (no 0)
    SELECT 'F3 ID 999 inexistente' AS Caso, dbo.fn_PorcentajeDisponibleCisterna(999)  AS PorcentajeDisponible
    UNION ALL
    SELECT 'F3 ID NULL',                    dbo.fn_PorcentajeDisponibleCisterna(NULL);

    -- F4. Escalar usada fila por fila dentro de una consulta (un valor por cisterna)
    SELECT 'F4 todas las cisternas' AS Caso, Placa, Estado, SaldoLitros,
           dbo.fn_PorcentajeDisponibleCisterna(CisternaID) AS PorcentajeDisponible
    FROM dbo.Cisterna;

    -- T1. Funcion de tabla: Ventanilla -> 2 filas (300 L y 33 L)
    SELECT 'T1 Ventanilla' AS Caso, * FROM dbo.fn_EntregasPorSector(N'Ventanilla') ORDER BY EntregaID;

    -- T2. Sector que existe pero sin entregas -> 0 filas (no es error)
    SELECT 'T2 Mi Peru sin entregas' AS Caso, COUNT(*) AS Filas FROM dbo.fn_EntregasPorSector(N'Mi Perú');

    -- T3. Sector inexistente -> 0 filas
    SELECT 'T3 sector inexistente' AS Caso, COUNT(*) AS Filas FROM dbo.fn_EntregasPorSector(N'Sector X');

    -- T4. Espacios en el parametro -> igual encuentra Ventanilla (2 filas)
    SELECT 'T4 con espacios' AS Caso, COUNT(*) AS Filas FROM dbo.fn_EntregasPorSector(N'  Ventanilla  ');

    -- T5. La funcion de tabla se combina como cualquier tabla: agregar sobre su resultado
    SELECT 'T5 resumen Ventanilla' AS Caso, COUNT(*) AS TotalEntregas, ISNULL(SUM(Litros), 0) AS TotalLitros
    FROM dbo.fn_EntregasPorSector(N'Ventanilla');                                        -- 2 y 333

    -- T6. Escalar + tabla juntas: porcentaje disponible de la cisterna de cada entrega
    SELECT 'T6 escalar + tabla' AS Caso, f.EntregaID, f.Placa, f.Litros,
           dbo.fn_PorcentajeDisponibleCisterna(f.CisternaID) AS PorcentajeActualCisterna
    FROM dbo.fn_EntregasPorSector(N'Ventanilla') AS f;

    -- C1. Conciliacion: saldo = cargado - entregado (las funciones no cambian datos)
    SELECT 'C1 conciliacion' AS Caso,
           (SELECT ISNULL(SUM(Litros), 0) FROM dbo.CargaAgua WHERE CisternaID = 1) AS Cargado,
           (SELECT ISNULL(SUM(Litros), 0) FROM dbo.Entrega   WHERE CisternaID = 1) AS Entregado,
           (SELECT SaldoLitros FROM dbo.Cisterna WHERE CisternaID = 1)            AS Saldo;   -- 1000 / 333 / 667

ROLLBACK TRAN;
GO

-- Estado final: igual al inicial (saldo 0, sin entregas)
SELECT 'FINAL' AS Momento, SaldoLitros,
       dbo.fn_PorcentajeDisponibleCisterna(CisternaID) AS PorcentajeDisponible,
       (SELECT COUNT(*) FROM dbo.Entrega) AS FilasEntrega
FROM dbo.Cisterna WHERE CisternaID = 1;
GO
