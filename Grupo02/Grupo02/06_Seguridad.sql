-- Crear una clave maestra (solo si no existe ya)
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'TuContraseñaFuerte123!';
GO

-- Crear un certificado para la clave simetrica
CREATE CERTIFICATE CertificadoEncriptacion
WITH SUBJECT = 'Certificado para encriptar datos sensibles';
GO

-- Crear clave simetrica
CREATE SYMMETRIC KEY ClaveSimetricaEmpleados
WITH ALGORITHM = AES_256
ENCRYPTION BY CERTIFICATE CertificadoEncriptacion;
GO
-- ==========================================================
--  CREACION DE ROLES
-- ==========================================================
-- Crear roles para cada area
CREATE ROLE Role_Tesoreria;
CREATE ROLE Role_Socios;
CREATE ROLE Role_Autoridades;

-- Asignar permisos basicos a roles
GRANT SELECT, UPDATE ON socio.empleado TO Role_Tesoreria;
GRANT SELECT ON socio.empleado TO Role_Socios;
GRANT SELECT ON socio.empleado TO Role_Autoridades;

-- Asignar permisos para procedimientos de consulta
GRANT EXECUTE ON socio.ver_todos_los_empleados TO Role_Autoridades;


-- ==========================================================
-- 3️ CREACION DE PROCEDIMIENTOS ENCRIPTACION
-- ==========================================================
-- Encriptar todos los empleados
CREATE OR ALTER PROCEDURE socio.encriptar_todos_los_empleados
AS
BEGIN
    SET NOCOUNT ON;

    OPEN SYMMETRIC KEY ClaveSimetricaEmpleados DECRYPTION BY CERTIFICATE CertificadoEncriptacion;

    UPDATE socio.empleado
    SET nombre = ENCRYPTBYKEY(KEY_GUID('ClaveSimetricaEmpleados'), CAST(nombre AS NVARCHAR(100))),
        apellido = ENCRYPTBYKEY(KEY_GUID('ClaveSimetricaEmpleados'), CAST(apellido AS NVARCHAR(100))),
        dni = ENCRYPTBYKEY(KEY_GUID('ClaveSimetricaEmpleados'), CAST(dni AS NVARCHAR(50))),
        telefono = ENCRYPTBYKEY(KEY_GUID('ClaveSimetricaEmpleados'), CAST(telefono AS NVARCHAR(50)));

    CLOSE SYMMETRIC KEY ClaveSimetricaEmpleados;

    PRINT 'Todos los registros fueron encriptados correctamente.';
END;
GO

-- Insertar empleado encriptado
CREATE OR ALTER PROCEDURE socio.insertar_empleado_encriptado
    @nombre NVARCHAR(100),
    @apellido NVARCHAR(100),
    @dni NVARCHAR(50),
    @telefono NVARCHAR(50),
    @area VARCHAR(50),
    @rol VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    OPEN SYMMETRIC KEY ClaveSimetricaEmpleados DECRYPTION BY CERTIFICATE CertificadoEncriptacion;

    INSERT INTO socio.empleado (nombre, apellido, dni, telefono, area, rol, fecha_alta)
    VALUES (
        ENCRYPTBYKEY(KEY_GUID('ClaveSimetricaEmpleados'), @nombre),
        ENCRYPTBYKEY(KEY_GUID('ClaveSimetricaEmpleados'), @apellido),
        ENCRYPTBYKEY(KEY_GUID('ClaveSimetricaEmpleados'), @dni),
        ENCRYPTBYKEY(KEY_GUID('ClaveSimetricaEmpleados'), @telefono),
        @area,
        @rol,
        GETDATE()
    );

    CLOSE SYMMETRIC KEY ClaveSimetricaEmpleados;

    PRINT 'Empleado insertado y encriptado correctamente.';
END;
GO

-- Ver todos los empleados desencriptados
CREATE OR ALTER PROCEDURE socio.ver_todos_los_empleados
AS
BEGIN
    SET NOCOUNT ON;

    OPEN SYMMETRIC KEY ClaveSimetricaEmpleados DECRYPTION BY CERTIFICATE CertificadoEncriptacion;

    SELECT 
        id_empleado,
        CONVERT(NVARCHAR(100), DECRYPTBYKEY(nombre)) AS nombre,
        CONVERT(NVARCHAR(100), DECRYPTBYKEY(apellido)) AS apellido,
        CONVERT(NVARCHAR(50), DECRYPTBYKEY(dni)) AS dni,
        CONVERT(NVARCHAR(50), DECRYPTBYKEY(telefono)) AS telefono,
        area,
        rol,
        fecha_alta
    FROM socio.empleado;

    CLOSE SYMMETRIC KEY ClaveSimetricaEmpleados;
END;
GO

-- ==========================================================
-- 4️ INSERTAR EMPLEADOS ENCRIPTADOS DE PRUEBA
-- ==========================================================
EXEC socio.insertar_empleado_encriptado 
    @nombre = N'Juan', 
    @apellido = N'Pérez', 
    @dni = N'12345678', 
    @telefono = N'1133445566', 
    @area = 'Tesorería', 
    @rol = 'Administrativo de Cobranza';

EXEC socio.insertar_empleado_encriptado 
    @nombre = N'Ana', 
    @apellido = N'Gomez', 
    @dni = N'23456789', 
    @telefono = N'1133445567', 
    @area = 'Tesorería', 
    @rol = 'Administrativo de Morosidad';

EXEC socio.insertar_empleado_encriptado 
    @nombre = N'Carlos', 
    @apellido = N'Ríos', 
    @dni = N'34567890', 
    @telefono = N'1133445568', 
    @area = 'Tesorería', 
    @rol = 'Administrativo de Facturación';

EXEC socio.insertar_empleado_encriptado 
    @nombre = N'María', 
    @apellido = N'Lopez', 
    @dni = N'45678901', 
    @telefono = N'1133445569', 
    @area = 'Socios', 
    @rol = 'Administrativo Socio';

EXEC socio.insertar_empleado_encriptado 
    @nombre = N'Pedro', 
    @apellido = N'Martínez', 
    @dni = N'56789012', 
    @telefono = N'1133445570', 
    @area = 'Socios', 
    @rol = 'Socios Web';

EXEC socio.insertar_empleado_encriptado 
    @nombre = N'Laura', 
    @apellido = N'Díaz', 
    @dni = N'67890123', 
    @telefono = N'1133445571', 
    @area = 'Autoridades', 
    @rol = 'Presidente';

EXEC socio.insertar_empleado_encriptado 
    @nombre = N'Miguel', 
    @apellido = N'Torres', 
    @dni = N'78901234', 
    @telefono = N'1133445572', 
    @area = 'Autoridades', 
    @rol = 'Vicepresidente';

EXEC socio.insertar_empleado_encriptado 
    @nombre = N'Sofía', 
    @apellido = N'Vera', 
    @dni = N'89012345', 
    @telefono = N'1133445573', 
    @area = 'Autoridades', 
    @rol = 'Secretario';

EXEC socio.insertar_empleado_encriptado 
    @nombre = N'Roberto', 
    @apellido = N'Suarez', 
    @dni = N'90123456', 
    @telefono = N'1133445574', 
    @area = 'Autoridades', 
    @rol = 'Vocal';

EXEC socio.insertar_empleado_encriptado 
    @nombre = N'Carla', 
    @apellido = N'Domínguez', 
    @dni = N'01234567', 
    @telefono = N'1133445575', 
    @area = 'Tesorería', 
    @rol = 'Jefe de Tesorería';

	-- ==========================================================
-- 5️ CREACION DE LOGINS Y ASIGNACION DE ROLES
-- ==========================================================
-- TESORERIA
CREATE LOGIN usuario_juan    WITH PASSWORD = 'ContraseñaSegura1!';
CREATE USER usuario_juan      FOR LOGIN usuario_juan;

CREATE LOGIN usuario_ana      WITH PASSWORD = 'ContraseñaSegura2!';
CREATE USER usuario_ana        FOR LOGIN usuario_ana;

CREATE LOGIN usuario_carlos   WITH PASSWORD = 'ContraseñaSegura3!';
CREATE USER usuario_carlos     FOR LOGIN usuario_carlos;

CREATE LOGIN usuario_carla    WITH PASSWORD = 'ContraseñaSegura4!';
CREATE USER usuario_carla       FOR LOGIN usuario_carla;

-- SOCIOS
CREATE LOGIN usuario_maria    WITH PASSWORD = 'ContraseñaSegura5!';
CREATE USER usuario_maria       FOR LOGIN usuario_maria;

CREATE LOGIN usuario_pedro    WITH PASSWORD = 'ContraseñaSegura6!';
CREATE USER usuario_pedro       FOR LOGIN usuario_pedro;

-- AUTORIDADES
CREATE LOGIN usuario_laura    WITH PASSWORD = 'ContraseñaSegura7!';
CREATE USER usuario_laura       FOR LOGIN usuario_laura;

CREATE LOGIN usuario_miguel    WITH PASSWORD = 'ContraseñaSegura8!';
CREATE USER usuario_miguel      FOR LOGIN usuario_miguel;

CREATE LOGIN usuario_sofia     WITH PASSWORD = 'ContraseñaSegura9!';
CREATE USER usuario_sofia        FOR LOGIN usuario_sofia;

CREATE LOGIN usuario_roberto   WITH PASSWORD = 'ContraseñaSegura10!';
CREATE USER usuario_roberto      FOR LOGIN usuario_roberto;

-- Asignacion de Roles
ALTER ROLE Role_Tesoreria ADD MEMBER usuario_juan;
ALTER ROLE Role_Tesoreria ADD MEMBER usuario_ana;
ALTER ROLE Role_Tesoreria ADD MEMBER usuario_carlos;
ALTER ROLE Role_Tesoreria ADD MEMBER usuario_carla;

ALTER ROLE Role_Socios ADD MEMBER usuario_maria;
ALTER ROLE Role_Socios ADD MEMBER usuario_pedro;

ALTER ROLE Role_Autoridades ADD MEMBER usuario_laura;
ALTER ROLE Role_Autoridades ADD MEMBER usuario_miguel;
ALTER ROLE Role_Autoridades ADD MEMBER usuario_sofia;
ALTER ROLE Role_Autoridades ADD MEMBER usuario_roberto;







SELECT 
    u.name AS Usuario,
    r.name AS Rol
FROM sys.database_principals u
LEFT JOIN sys.database_role_members rm ON u.principal_id = rm.member_principal_id
LEFT JOIN sys.database_principals r ON rm.role_principal_id = r.principal_id
WHERE u.type_desc = 'SQL_USER'
ORDER BY u.name, r.name;