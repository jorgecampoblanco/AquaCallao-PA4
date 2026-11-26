USE AquaCallao;
GO

/* ---------------------------------------------------------------------
   1. Tabla de auditoria
      Sin FK hacia Entrega: asi la huella de un DELETE se conserva.
   --------------------------------------------------------------------- */
IF OBJECT_ID(N'dbo.AuditoriaEntrega', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.AuditoriaEntrega (
        AuditoriaID     int IDENTITY(1,1) NOT NULL,
        EntregaID       int               NOT NULL,
        Operacion       varchar(6)        NOT NULL,
        ClienteID       int               NOT NULL,
        CisternaID      int               NOT NULL,
        ProductoID      int               NOT NULL,
        LitrosAnterior  int               NULL,      -- NULL en INSERT (deleted vacia)
        LitrosNuevo     int               NULL,      -- NULL en DELETE (inserted vacia)
        FechaAuditoria  datetime2         NOT NULL
            CONSTRAINT DF_AuditoriaEntrega_Fecha DEFAULT (SYSDATETIME()),
        UsuarioSistema  sysname           NOT NULL
            CONSTRAINT DF_AuditoriaEntrega_Usuario DEFAULT (SUSER_SNAME()),
        CONSTRAINT PK_AuditoriaEntrega PRIMARY KEY (AuditoriaID),
        CONSTRAINT CK_AuditoriaEntrega_Operacion
            CHECK (Operacion IN ('INSERT', 'UPDATE', 'DELETE'))
    );
END
GO

/* ---------------------------------------------------------------------
   2. Trigger
      - Una sola sentencia INSERT...SELECT: funciona con 1 o N filas.
      - inserted = filas nuevas / valores nuevos; deleted = filas borradas / valores viejos.
      - UPDATE: inserted y deleted traen la misma fila (EntregaID es IDENTITY, no cambia).
   --------------------------------------------------------------------- */
CREATE OR ALTER TRIGGER dbo.trg_Entrega_Auditoria
ON dbo.Entrega
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM inserted) AND NOT EXISTS (SELECT 1 FROM deleted)
        RETURN;   -- la sentencia no afecto filas

    INSERT INTO dbo.AuditoriaEntrega
        (EntregaID, Operacion, ClienteID, CisternaID, ProductoID,
         LitrosAnterior, LitrosNuevo)
    SELECT  COALESCE(i.EntregaID,  d.EntregaID),
            CASE WHEN d.EntregaID IS NULL THEN 'INSERT'
                 WHEN i.EntregaID IS NULL THEN 'DELETE'
                 ELSE 'UPDATE' END,
            COALESCE(i.ClienteID,  d.ClienteID),
            COALESCE(i.CisternaID, d.CisternaID),
            COALESCE(i.ProductoID, d.ProductoID),
            d.Litros,
            i.Litros
    FROM    inserted AS i
    FULL OUTER JOIN deleted AS d
            ON d.EntregaID = i.EntregaID;
END
GO

/* ---------------------------------------------------------------------
   3. Pruebas  (cada bloque va en transaccion y termina en ROLLBACK:
      no deja datos residuales. 
      Datos iniciales usados: ClienteID=1, CisternaID=1, ProductoID=1.
   --------------------------------------------------------------------- */

-- 3.0 Estado inicial
SELECT 'ANTES' AS Momento, COUNT(*) AS FilasEntrega FROM dbo.Entrega;
SELECT 'ANTES' AS Momento, COUNT(*) AS FilasAuditoria FROM dbo.AuditoriaEntrega;
GO

-- 3.1 INSERT de una fila y de varias filas en una sola sentencia
BEGIN TRAN;
    SELECT 'ANTES 3.1' AS Momento, CisternaID, SaldoLitros FROM dbo.Cisterna WHERE CisternaID = 1;

    INSERT INTO dbo.Entrega (ClienteID, CisternaID, ProductoID, Litros)
    VALUES (1, 1, 1, 100);                               -- 1 fila

    INSERT INTO dbo.Entrega (ClienteID, CisternaID, ProductoID, Litros)
    VALUES (1, 1, 1, 200), (1, 1, 1, 300);               -- 2 filas: un solo disparo

    SELECT 'DESPUES 3.1 - Entrega'   AS Momento, EntregaID, Litros FROM dbo.Entrega ORDER BY EntregaID;
    SELECT 'DESPUES 3.1 - Auditoria' AS Momento, * FROM dbo.AuditoriaEntrega ORDER BY AuditoriaID;

    -- Esperado: 3 filas de auditoria 'INSERT' (LitrosAnterior NULL) y el saldo SIN cambios (el trigger no descuenta).
    SELECT 'DESPUES 3.1' AS Momento, CisternaID, SaldoLitros FROM dbo.Cisterna WHERE CisternaID = 1;
ROLLBACK TRAN;
GO

-- 3.2 UPDATE (inserted = valor nuevo, deleted = valor anterior)
BEGIN TRAN;
    INSERT INTO dbo.Entrega (ClienteID, CisternaID, ProductoID, Litros) VALUES (1, 1, 1, 100);
    DECLARE @id int = SCOPE_IDENTITY();

    UPDATE dbo.Entrega SET Litros = 150 WHERE EntregaID = @id;

    SELECT 'DESPUES 3.2 - Auditoria' AS Momento, * FROM dbo.AuditoriaEntrega ORDER BY AuditoriaID;
    -- Esperado: fila 'INSERT' (NULL->100) y fila 'UPDATE' (LitrosAnterior=100, LitrosNuevo=150).
ROLLBACK TRAN;
GO

-- 3.3 DELETE (la auditoria conserva la huella de la fila borrada)
BEGIN TRAN;
    INSERT INTO dbo.Entrega (ClienteID, CisternaID, ProductoID, Litros) VALUES (1, 1, 1, 120);
    DECLARE @id int = SCOPE_IDENTITY();

    DELETE FROM dbo.Entrega WHERE EntregaID = @id;

    SELECT 'DESPUES 3.3 - Entrega'   AS Momento, COUNT(*) AS Filas FROM dbo.Entrega WHERE EntregaID = @id;  -- 0
    SELECT 'DESPUES 3.3 - Auditoria' AS Momento, * FROM dbo.AuditoriaEntrega ORDER BY AuditoriaID;
    -- Esperado: 'INSERT' y 'DELETE' (LitrosAnterior=120, LitrosNuevo NULL).
ROLLBACK TRAN;
GO



-- 3.4 Estado final: igual que el inicial (sin residuos)
SELECT 'FINAL' AS Momento, COUNT(*) AS FilasEntrega   FROM dbo.Entrega;
SELECT 'FINAL' AS Momento, COUNT(*) AS FilasAuditoria FROM dbo.AuditoriaEntrega;
GO
