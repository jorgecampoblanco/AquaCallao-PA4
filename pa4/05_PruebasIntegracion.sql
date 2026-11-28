-- AquaCallao PA4 | Jorge Campoblanco | Ejecutar completo en una ventana nueva de SSMS.
USE AquaCallao;
GO
SET NOCOUNT ON;
IF @@TRANCOUNT <> 0 THROW 51000, 'Abra una ventana sin transacciones pendientes.', 1;

DECLARE @cisterna int, @cliente int, @producto int, @primera int, @segunda int;
DECLARE @sector nvarchar(60), @saldo int, @porcentaje decimal(5,2);
DECLARE @lectura int, @edicion int;

BEGIN TRY
    BEGIN TRAN;

    -- Una cisterna de prueba permite repetir el caso aunque ya haya movimientos de PA3.
    INSERT dbo.Cisterna (Placa, CapacidadLitros, SaldoLitros, Estado)
    VALUES ('PA4-JORGE', 2000, 0, 'Operativa');
    SET @cisterna = SCOPE_IDENTITY();
    SELECT TOP (1) @cliente = ClienteID, @sector = Sector FROM dbo.Cliente WHERE Activo = 1 ORDER BY ClienteID;
    SELECT TOP (1) @producto = ProductoID FROM dbo.Producto WHERE Activo = 1 ORDER BY ProductoID;
    IF @cliente IS NULL OR @producto IS NULL THROW 51001, 'Se necesita un cliente y un producto activos.', 1;

    -- Los procedimientos de PA3 registran los movimientos y actualizan el saldo.
    EXEC dbo.usp_RegistrarCarga @cisterna, @producto, 1000;
    EXEC dbo.Sp_RegistrarEntrega @cliente, @cisterna, @producto, 300, @primera OUTPUT;
    EXEC dbo.Sp_RegistrarEntrega @cliente, @cisterna, @producto, 33, @segunda OUTPUT;

    -- Andy: porcentaje disponible y entregas del sector correspondientes a esta prueba.
    SELECT @saldo = SaldoLitros FROM dbo.Cisterna WHERE CisternaID = @cisterna;
    SET @porcentaje = dbo.fn_PorcentajeDisponibleCisterna(@cisterna);
    SELECT @saldo AS SaldoLitros, @porcentaje AS PorcentajeDisponible;
    SELECT EntregaID, Sector, Placa, Litros FROM dbo.fn_EntregasPorSector(@sector)
    WHERE CisternaID = @cisterna ORDER BY EntregaID;
    IF ISNULL(@saldo,-1) <> 667 OR ISNULL(@porcentaje,-1) <> 33.35
       OR (SELECT COUNT(*) FROM dbo.fn_EntregasPorSector(@sector)
           WHERE CisternaID = @cisterna AND ((EntregaID = @primera AND Litros = 300)
              OR (EntregaID = @segunda AND Litros = 33))) <> 2
        THROW 51002, 'Revisar saldo, porcentaje o entregas por sector.', 1;

    -- Helen: cada entrega debe tener su propio registro de auditoría.
    SELECT EntregaID, Operacion, LitrosAnterior, LitrosNuevo FROM dbo.AuditoriaEntrega
    WHERE CisternaID = @cisterna ORDER BY EntregaID;
    IF (SELECT COUNT(DISTINCT EntregaID) FROM dbo.AuditoriaEntrega
        WHERE CisternaID = @cisterna AND Operacion = 'INSERT' AND LitrosAnterior IS NULL
          AND ((EntregaID = @primera AND LitrosNuevo = 300) OR (EntregaID = @segunda AND LitrosNuevo = 33))) <> 2
        THROW 51003, 'Revisar la auditoría de las dos entregas.', 1;

    -- Fernando: el cursor muestra el saldo en Mensajes. La consulta lo muestra en Resultados.
DECLARE @Placa       VARCHAR(10),
        @SaldoLitros INT,
        @Capacidad   INT,
        @Estado      VARCHAR(12);

DECLARE cur_ResumenCisternas CURSOR LOCAL FAST_FORWARD FOR
    SELECT 
        Placa, 
        SaldoLitros,
        CapacidadLitros,
        Estado
    FROM dbo.Cisterna
    ORDER BY CisternaID ASC;

OPEN cur_ResumenCisternas;

FETCH NEXT FROM cur_ResumenCisternas 
INTO @Placa, @SaldoLitros, @Capacidad, @Estado;

WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT CONCAT(
        'Cisterna Placa: ', @Placa, 
        ' | Saldo Actual: ', @SaldoLitros, ' L',
        ' / ', @Capacidad, ' L',
        ' | Estado: ', @Estado
    );

    FETCH NEXT FROM cur_ResumenCisternas 
    INTO @Placa, @SaldoLitros, @Capacidad, @Estado;
END;

CLOSE cur_ResumenCisternas;
DEALLOCATE cur_ResumenCisternas;
    SELECT Placa, SaldoLitros, CapacidadLitros, Estado FROM dbo.Cisterna WHERE CisternaID = @cisterna;

    -- Farid: comprobar los permisos efectivos del auditor sobre la misma cisterna.
    EXECUTE AS USER = 'usr_auditor';
    BEGIN TRY
        SELECT @lectura = HAS_PERMS_BY_NAME('dbo.Cisterna','OBJECT','SELECT'),
               @edicion = HAS_PERMS_BY_NAME('dbo.Cisterna','OBJECT','UPDATE');
        SELECT USER_NAME() AS Usuario, @lectura AS PuedeConsultar, @edicion AS PuedeActualizar;
        SELECT Placa, SaldoLitros FROM dbo.Cisterna WHERE CisternaID = @cisterna;
    END TRY
    BEGIN CATCH
        REVERT;
        THROW;
    END CATCH;
    REVERT;
    IF ISNULL(@lectura,-1) <> 1 OR ISNULL(@edicion,-1) <> 0 THROW 51004, 'Revisar permisos del auditor.', 1;

    -- Revertir los movimientos y comprobar que desaparecieron las filas de prueba.
    ROLLBACK;
    SELECT (SELECT COUNT(*) FROM dbo.Cisterna WHERE CisternaID = @cisterna) AS CisternasDePrueba,
           (SELECT COUNT(*) FROM dbo.CargaAgua WHERE CisternaID = @cisterna) AS CargasDePrueba,
           (SELECT COUNT(*) FROM dbo.Entrega WHERE CisternaID = @cisterna) AS EntregasDePrueba,
           (SELECT COUNT(*) FROM dbo.AuditoriaEntrega WHERE CisternaID = @cisterna) AS AuditoriasDePrueba;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK;
    THROW;
END CATCH;
