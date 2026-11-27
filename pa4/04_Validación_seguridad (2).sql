USE master;
GO

-- 1. Creación de Logins a nivel de servidor (Autenticación SQL Server)
-- Nota: Cambia las contraseñas por valores seguros y no subas credenciales reales a GitHub
CREATE LOGIN login_operador WITH PASSWORD = N'Op3r@dor_Aqua2026!', CHECK_POLICY = ON;
CREATE LOGIN login_gestor   WITH PASSWORD = N'G3st0r_Aqua2026!',   CHECK_POLICY = ON;
CREATE LOGIN login_auditor  WITH PASSWORD = N'Aud1t0r_Aqua2026!',  CHECK_POLICY = ON;
GO

USE AquaCallao;
GO

-- 2. Creación de Usuarios de base de datos vinculados a cada Login
CREATE USER usr_operador FOR LOGIN login_operador;
CREATE USER usr_gestor   FOR LOGIN login_gestor;
CREATE USER usr_auditor  FOR LOGIN login_auditor;
GO

-- 3. Creación de Roles personalizados de base de datos
CREATE ROLE rol_operador_agua;
CREATE ROLE rol_gestor_catalogo;
CREATE ROLE rol_auditor_reportes;
GO

-- 4. Asignación de permisos granulares a cada Rol
-- 4.1 Permisos para rol_operador_agua (solo operación diaria de carga y entrega)
GRANT SELECT ON dbo.Cliente   TO rol_operador_agua;
GRANT SELECT ON dbo.Producto  TO rol_operador_agua;
GRANT SELECT ON dbo.Cisterna  TO rol_operador_agua;
GRANT SELECT, INSERT ON dbo.CargaAgua TO rol_operador_agua;
GRANT SELECT, INSERT ON dbo.Entrega   TO rol_operador_agua;
GRANT UPDATE (SaldoLitros) ON dbo.Cisterna TO rol_operador_agua;
GO

-- 4.2 Permisos para rol_gestor_catalogo (mantenimiento de maestros, lectura de movimientos)
GRANT SELECT, INSERT, UPDATE ON dbo.Cliente  TO rol_gestor_catalogo;
GRANT SELECT, INSERT, UPDATE ON dbo.Producto TO rol_gestor_catalogo;
GRANT SELECT, INSERT, UPDATE ON dbo.Cisterna TO rol_gestor_catalogo;
GRANT SELECT ON dbo.CargaAgua TO rol_gestor_catalogo;
GRANT SELECT ON dbo.Entrega   TO rol_gestor_catalogo;
GO

-- 4.3 Permisos para rol_auditor_reportes (solo lectura en todo el esquema dbo)
GRANT SELECT ON SCHEMA::dbo TO rol_auditor_reportes;
GO

-- 5. Incorporación de los usuarios a sus respectivos roles
ALTER ROLE rol_operador_agua   ADD MEMBER usr_operador;
ALTER ROLE rol_gestor_catalogo ADD MEMBER usr_gestor;
ALTER ROLE rol_auditor_reportes ADD MEMBER usr_auditor;
GO