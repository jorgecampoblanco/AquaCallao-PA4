
USE AquaCallao;
GO

PRINT 'PARTE 1: PROCESAMIENTO FILA A FILA CON CURSOR (cur_ResumenCisternas)';
PRINT '';

-- Variables receptoras para cada iteración del cursor
DECLARE @Placa       VARCHAR(10),
        @SaldoLitros INT,
        @Capacidad   INT,
        @Estado      VARCHAR(12);

-- 1. DECLARACIÓN DEL CURSOR
-- LOCAL: El alcance del cursor se restringe únicamente a este lote/sesión.
-- FAST_FORWARD: Optimización de solo lectura (READ_ONLY) y avance único (FORWARD_ONLY).
DECLARE cur_ResumenCisternas CURSOR LOCAL FAST_FORWARD FOR
    SELECT 
        Placa, 
        SaldoLitros,
        CapacidadLitros,
        Estado
    FROM dbo.Cisterna
    ORDER BY CisternaID ASC;

-- 2. APERTURA DEL CURSOR
OPEN cur_ResumenCisternas;

-- 3. PRIMERA LECTURA (FETCH NEXT)
FETCH NEXT FROM cur_ResumenCisternas 
INTO @Placa, @SaldoLitros, @Capacidad, @Estado;

-- 4. BUCLE DE RECORRIDO (WHILE @@FETCH_STATUS = 0)
WHILE @@FETCH_STATUS = 0
BEGIN
    -- Procesamiento individual por fila (solo lectura / visualización)
    PRINT CONCAT(
        'Cisterna Placa: ', @Placa, 
        ' | Saldo Actual: ', @SaldoLitros, ' L',
        ' / ', @Capacidad, ' L',
        ' | Estado: ', @Estado
    );

    -- Siguiente fila
    FETCH NEXT FROM cur_ResumenCisternas 
    INTO @Placa, @SaldoLitros, @Capacidad, @Estado;
END;

-- 5. CIERRE Y LIBERACIÓN DE RECURSOS EN MEMORIA
CLOSE cur_ResumenCisternas;
DEALLOCATE cur_ResumenCisternas;
GO

PRINT '';

PRINT 'PARTE 2: ALTERNATIVA BASADA EN CONJUNTOS (CONSULTA SELECT EQUIVALENTE)';


-- Consulta declarativa que resuelve exactamente el mismo requerimiento en una sola operación
SELECT 
    Placa,
    SaldoLitros,
    CapacidadLitros,
    Estado,
    CONCAT(SaldoLitros, ' L / ', CapacidadLitros, ' L') AS ResumenVolumetrico
FROM dbo.Cisterna
ORDER BY CisternaID ASC;
GO