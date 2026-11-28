USE AquaCallao;
GO

/* =====================================================================
   PRUEBA 1: Usuario Operador (usr_operador)
   ===================================================================== */
EXECUTE AS USER = 'usr_operador';

-- Acción PERMITIDA: Registrar una carga de agua de 500 L en la cisterna 1
INSERT INTO dbo.CargaAgua (CisternaID, ProductoID, Litros)
VALUES (1, 1, 500);

-- Acción DENEGADA (debe lanzar Msg 229: The INSERT permission was denied on the object 'Cliente'):
INSERT INTO dbo.Cliente (Nombre, Documento, Sector, Activo)
VALUES (N'Cliente No Autorizado', '99999999', N'Callao', 1);

REVERT;
GO

/* =====================================================================
   PRUEBA 2: Usuario Gestor (usr_gestor)
   ===================================================================== */
EXECUTE AS USER = 'usr_gestor';

-- Registrar un beneficiario con un documento de prueba disponible.
DECLARE @DocumentoPrueba char(8);
WHILE 1 = 1
BEGIN
    SET @DocumentoPrueba = RIGHT('00000000' + CONVERT(varchar(8),
        ABS(CONVERT(bigint, CHECKSUM(NEWID()))) % 100000000), 8);

    BEGIN TRY
        INSERT INTO dbo.Cliente (Nombre, Documento, Sector, Activo)
        VALUES (N'Beneficiario Pachacútec 02', @DocumentoPrueba, N'Pachacútec', 1);
        BREAK;
    END TRY
    BEGIN CATCH
        IF ERROR_NUMBER() NOT IN (2601, 2627)
            THROW;
        IF NOT EXISTS (SELECT 1 FROM dbo.Cliente WHERE Documento = @DocumentoPrueba)
            THROW;
    END CATCH;
END;

SELECT Nombre, Documento FROM dbo.Cliente WHERE Documento = @DocumentoPrueba;

-- Acción DENEGADA: el gestor no puede eliminar al beneficiario registrado.
DELETE FROM dbo.Cliente WHERE Documento = @DocumentoPrueba;

REVERT;
GO

/* =====================================================================
   PRUEBA 3: Usuario Auditor (usr_auditor)
   ===================================================================== */
EXECUTE AS USER = 'usr_auditor';

-- Acción PERMITIDA: Consultar entregas y cargas
SELECT * FROM dbo.CargaAgua;
SELECT * FROM dbo.Cliente;

-- Acción DENEGADA (debe lanzar Msg 229: The UPDATE permission was denied on the object 'Cisterna'):
UPDATE dbo.Cisterna SET Estado = 'Inactiva' WHERE CisternaID = 1;

REVERT;
GO

/* =====================================================================
   CONSULTA DE AUDITORÍA DE ROLES Y PERMISOS ASIGNADOS
   ===================================================================== */
SELECT 
    r.name AS Rol,
    m.name AS UsuarioMiembro,
    p.permission_name AS Permiso,
    p.state_desc AS Estado,
    OBJECT_NAME(p.major_id) AS Objeto
FROM sys.database_role_members rm
JOIN sys.database_principals r ON rm.role_principal_id = r.principal_id
JOIN sys.database_principals m ON rm.member_principal_id = m.principal_id
JOIN sys.database_permissions p ON p.grantee_principal_id = r.principal_id
WHERE r.name LIKE 'rol_%'
ORDER BY r.name, Objeto, Permiso;
GO