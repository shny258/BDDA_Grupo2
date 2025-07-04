--El archivo .sql con el script debe incluir comentarios donde consten este enunciado, 
--la fecha de entrega,
--n�mero de grupo, nombre de la materia, nombres y DNI de los alumnos. Entregar todo en un zip 
--(observar las pautas para nomenclatura antes expuestas) mediante la secci�n de pr�cticas de MIEL. 
--Solo uno de los miembros del grupo debe hacer la entrega
-- Fecha entrega 23/05/2025
--Numero grupo: 02
--Base De Datos Aplicada
--Celso quelle Nicolas DNI:44382822
--Paz Curtet  Facundo DNI:44553403  
--Contti Abel  DNI:394878489  
--Martins Louro  Luciano DNI:42364189  
USE Com5600G02
GO
/*SP_CONFIGURE 'show advanced options', 1; 
RECONFIGURE; 

GO 
SP_CONFIGURE 'Ad Hoc Distributed Queries', 1; 
RECONFIGURE;
GO 
EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1 

EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1 
EXEC master.[sys].[sp_MSset_oledb_prop] N'Microsoft.ACE.OLEDB.12.0', N'DisallowAdHocAccess', 1
EXEC master.[sys].[sp_MSset_oledb_prop] N'Microsoft.ACE.OLEDB.16.0', N'AllowInProcess', 1*/

--=================================================================
--Configuracion para importar archivos excel
--=================================================================
EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
EXEC sp_configure 'Ad Hoc Distributed Queries', 1;
RECONFIGURE;
GO

--=================================================================
--Importar tabla de OPEN_METEO_BUENOS_AIRES
--=================================================================
CREATE OR ALTER PROCEDURE factura.importar_clima_csv @path NVARCHAR(255) as
begin
	SET NOCOUNT ON;
 
    IF OBJECT_ID('factura.clima_anual', 'U') IS NOT NULL
        DROP TABLE factura.clima_anual;
	CREATE TABLE factura.clima_anual (
    FechaHora     varchar(50) primary key,      -- '2025-01-01T00:00'
    Temperatura   numeric(3,1),          -- 24.7
    Precipitacion numeric(4,2),          -- 0.00
    Humedad       int,            -- 70
    Viento        numeric(3,1)           -- 10.2
	);
 
-- CREAR UNA TABLA TEMPORAL
	CREATE TABLE #temporal (
    FechaHora     varchar(50),      -- '2025-01-01T00:00'
    Temperatura   varchar(50),          -- 24.7
    Precipitacion varchar(50),          -- 0.00
    Humedad       varchar(50),            -- 70
    Viento        varchar(50)           -- 10.2
	);
 
 
-- cargo el csv a la tabla temporal 
	DECLARE @sqlQuery NVARCHAR(MAX)
	SET @sqlQuery = '
	BULK INSERT #temporal
	FROM ''' + @path + ''' --concateno la ruta entre comillas
	WITH (
	FIELDTERMINATOR = '','',
	ROWTERMINATOR = ''0x0A'',
	FIRSTROW = 5, -- EL CSV TRAE ENCABEZADO
	CODEPAGE = ''65001''
	)';
	DECLARE @sqlQuery2 NVARCHAR(MAX);
	set @sqlQuery2 = '
	INSERT INTO factura.clima_anual (
        FechaHora, Temperatura, Precipitacion, Humedad, Viento
    )
	SELECT
		FechaHora,
		CAST(LTRIM(RTRIM(Temperatura)) AS numeric(3,1)) AS Temperatura,
		CAST(LTRIM(RTRIM(Precipitacion)) AS numeric(4,2)) AS Precipitacion,
		CAST(LTRIM(RTRIM(Humedad)) AS int) AS Humedad,
		CAST(LTRIM(RTRIM(Viento)) AS numeric(3,1)) AS Viento
	FROM #temporal';
 
	EXEC sp_executesql @sqlQuery; -- ejecuto el procedimiento para que ejecute la query
	EXEC sp_executesql @sqlQuery2;
end
go

--=================================================================
--Importar tabla de RESPONDABLES DE PAGO
--=================================================================
CREATE OR ALTER PROCEDURE socio.importar_socios_excel
    @ruta NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    IF OBJECT_ID('socio.socio_temp', 'U') IS NOT NULL
        DROP TABLE socio.socio_temp;

    CREATE TABLE socio.socio_temp (
        id_socio INT IDENTITY (1,1) PRIMARY KEY,
        nro_socio VARCHAR(10) NOT NULL,
        dni VARCHAR(15) NOT NULL,
        nombre VARCHAR(50) NOT NULL,
        apellido VARCHAR(50) NOT NULL,
        email VARCHAR(100) NOT NULL,
        fecha_nacimiento DATE NOT NULL,
        telefono_contacto VARCHAR(20),
        telefono_emergencia VARCHAR(20),
        cobertura_medica VARCHAR(100),
        nro_cobertura_medica VARCHAR(50),
		nro_socio_rp varchar(10)
    );

    DECLARE @sql NVARCHAR(MAX);

    SET @sql = N'
    INSERT INTO socio.socio_temp (
        dni, nombre, apellido, email, fecha_nacimiento,
        telefono_contacto, telefono_emergencia,
        cobertura_medica, nro_cobertura_medica, nro_socio
    )
    SELECT 
        LTRIM(RTRIM(CAST([ DNI] AS VARCHAR(20)))) AS dni,
        LTRIM(RTRIM([Nombre])) AS nombre,
        LTRIM(RTRIM([ apellido])) AS apellido,
        LTRIM(RTRIM([ email personal])) AS email,
        TRY_CAST([ fecha de nacimiento] AS DATE) AS fecha_nacimiento,
     LTRIM(RTRIM(CAST(CAST([ tel�fono de contacto] AS DECIMAL(20, 0)) AS VARCHAR(20)))) AS telefono_contacto,
LTRIM(RTRIM(CAST(CAST([ tel�fono de contacto emergencia] AS DECIMAL(20, 0)) AS VARCHAR(20)))) AS telefono_emergencia,

        LTRIM(RTRIM([ Nombre de la obra social o prepaga])) AS cobertura_medica,
        LTRIM(RTRIM(CAST([nro# de socio obra social/prepaga ] AS VARCHAR(50)))) AS nro_cobertura_medica,
        LTRIM(RTRIM(CAST([Nro de Socio] AS VARCHAR(10)))) AS nro_socio
    FROM OPENROWSET(
        ''Microsoft.ACE.OLEDB.12.0'',
        ''Excel 12.0;Database=' + @ruta + ';HDR=YES;IMEX=1;'',
        ''SELECT * FROM [Responsables de Pago$]''
    ) AS t
    WHERE 
        [ DNI] IS NOT NULL
        AND TRY_CAST([ fecha de nacimiento] AS DATE) IS NOT NULL
        AND NOT EXISTS (
            SELECT 1 FROM socio.socio s 
            WHERE LTRIM(RTRIM(s.dni)) = LTRIM(RTRIM(CAST(t.[ DNI] AS VARCHAR(20))))
        )
    ';

    EXEC sp_executesql�@sql;
END;
GO

--=================================================================
--CARGAR DATOS DE SOCIOS_TEMP A SOCIOS.SOCIOS
--=================================================================
CREATE OR ALTER PROCEDURE socio.procesar_socios_temp
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE 
        @nro_socio VARCHAR(10),
        @dni VARCHAR(15),
        @nombre VARCHAR(50),
        @apellido VARCHAR(50),
        @email VARCHAR(100),
        @fecha_nacimiento DATE,
        @telefono_contacto VARCHAR(20),
        @telefono_emergencia VARCHAR(20),
        @cobertura_medica VARCHAR(100),
        @nro_cobertura_medica VARCHAR(50),
        @id_medio_de_pago INT = 1,
        @nro_socio_rp VARCHAR(10),
        @categoria_ingresada VARCHAR(50),
        @edad INT;

    DECLARE cur CURSOR FOR 
        SELECT 
            nro_socio, dni, nombre, apellido, email, fecha_nacimiento,
            telefono_contacto, telefono_emergencia, cobertura_medica,
            nro_cobertura_medica, nro_socio_rp
        FROM socio.socio_temp;

    OPEN cur;

    FETCH NEXT FROM cur INTO 
        @nro_socio, @dni, @nombre, @apellido, @email, @fecha_nacimiento,
        @telefono_contacto, @telefono_emergencia, @cobertura_medica,
        @nro_cobertura_medica, @nro_socio_rp;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        BEGIN TRY
            -- Calcular edad
            SET @edad = DATEDIFF(YEAR, @fecha_nacimiento, GETDATE());
            IF DATEADD(YEAR, @edad, @fecha_nacimiento) > GETDATE()
                SET @edad = @edad - 1;

            -- Determinar categor�a autom�ticamente
            IF @edad <= 12
                SET @categoria_ingresada = 'Menor';
            ELSE IF @edad BETWEEN 13 AND 17
                SET @categoria_ingresada = 'Cadete';
            ELSE
                SET @categoria_ingresada = 'Mayor';

            -- Validar categor�a v�lida (opcional, recomendable)
            IF @categoria_ingresada NOT IN ('Menor', 'Cadete', 'Mayor', 'Responsable')
            BEGIN
                RAISERROR('Categor�a no v�lida: %s', 16, 1, @categoria_ingresada);
                RETURN;
            END

            -- Llamar al SP de inserci�n
            EXEC socio.insertar_socio
                @nro_socio = @nro_socio,
                @dni = @dni,
                @nombre = @nombre,
                @apellido = @apellido,
                @email = @email,
                @fecha_nacimiento = @fecha_nacimiento,
                @telefono_contacto = @telefono_contacto,
                @telefono_emergencia = @telefono_emergencia,
                @cobertura_medica = @cobertura_medica,
                @nro_cobertura_medica = @nro_cobertura_medica,
                @id_medio_de_pago = @id_medio_de_pago,
                @nro_socio_rp = @nro_socio_rp,
                @categoria_ingresada = @categoria_ingresada;
        END TRY
        BEGIN CATCH
            PRINT 'Error al insertar socio: ' + ISNULL(@nro_socio, '-') + 
                  ' - ' + ERROR_MESSAGE();
        END CATCH;

        FETCH NEXT FROM cur INTO 
            @nro_socio, @dni, @nombre, @apellido, @email, @fecha_nacimiento,
            @telefono_contacto, @telefono_emergencia, @cobertura_medica,
            @nro_cobertura_medica, @nro_socio_rp;
    END

    CLOSE cur;
    DEALLOCATE cur;
END;
GO
--=================================================================
--Importar tabla de GRUPO FAMILIAR
--=================================================================
CREATE OR ALTER PROCEDURE socio.importar_socios_excel2
    @ruta NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    IF OBJECT_ID('socio.socio_temp2', 'U') IS NOT NULL
        DROP TABLE socio.socio_temp2;

    CREATE TABLE socio.socio_temp2 (
        id_socio INT IDENTITY (1,1) PRIMARY KEY,
        nro_socio VARCHAR(10) NOT NULL,
        nro_socio_rp VARCHAR(10), 
        dni VARCHAR(15) NOT NULL,
        nombre VARCHAR(50) NOT NULL,
        apellido VARCHAR(50) NOT NULL,
        email VARCHAR(100)  NULL,
        fecha_nacimiento DATE NOT NULL,
        telefono_contacto VARCHAR(20),
        telefono_emergencia VARCHAR(20),
        cobertura_medica VARCHAR(100),
        nro_cobertura_medica VARCHAR(50)
    );

    DECLARE @sql NVARCHAR(MAX);

    SET @sql = N'
    INSERT INTO socio.socio_temp2 (
        dni, nombre, apellido, email, fecha_nacimiento,
        telefono_contacto, telefono_emergencia,
        cobertura_medica, nro_cobertura_medica, nro_socio, nro_socio_rp
    )
    SELECT 
LTRIM(RTRIM(CAST(CAST([ DNI] AS BIGINT) AS VARCHAR(20)))) AS dni,
        LTRIM(RTRIM([Nombre])) AS nombre,
        LTRIM(RTRIM([ apellido])) AS apellido,
        LTRIM(RTRIM([ email personal])) AS email,
        TRY_CAST([ fecha de nacimiento] AS DATE) AS fecha_nacimiento,
        LTRIM(RTRIM(CAST(CAST([ tel�fono de contacto] AS DECIMAL(20, 0)) AS VARCHAR(20)))) AS telefono_contacto,
        LTRIM(RTRIM(CAST(CAST([ tel�fono de contacto emergencia] AS DECIMAL(20, 0)) AS VARCHAR(20)))) AS telefono_emergencia,
        LTRIM(RTRIM([ Nombre de la obra social o prepaga])) AS cobertura_medica,
        LTRIM(RTRIM(CAST([nro# de socio obra social/prepaga ] AS VARCHAR(50)))) AS nro_cobertura_medica,
        LTRIM(RTRIM(CAST([Nro de Socio] AS VARCHAR(10)))) AS nro_socio,
        LTRIM(RTRIM(CAST([Nro de socio RP] AS VARCHAR(10)))) AS nro_socio_rp  
    FROM OPENROWSET(
        ''Microsoft.ACE.OLEDB.12.0'',
        ''Excel 12.0;Database=' + @ruta + ';HDR=YES;IMEX=1;'',
        ''SELECT * FROM [Grupo Familiar$]''
    ) AS t
    WHERE 
        [ DNI] IS NOT NULL
        AND TRY_CAST([ fecha de nacimiento] AS DATE) IS NOT NULL
        AND NOT EXISTS (
            SELECT 1 FROM socio.socio s 
            WHERE LTRIM(RTRIM(s.dni)) = LTRIM(RTRIM(CAST(t.[ DNI] AS VARCHAR(20))))
        )
    ';

    EXEC sp_executesql @sql;
END;
GO

--=================================================================
--CARGAR DATOS DE SOCIOS_TEMP2 A SOCIOS.SOCIOS
--=================================================================
CREATE OR ALTER PROCEDURE socio.procesar_socios_temp2
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE 
        @nro_socio           VARCHAR(10),
        @nro_socio_rp        VARCHAR(10),
        @dni                 VARCHAR(15),
        @nombre              VARCHAR(50),
        @apellido            VARCHAR(50),
        @email               VARCHAR(100),
        @fecha_nacimiento    DATE,
        @telefono_contacto   VARCHAR(20),
        @telefono_emergencia VARCHAR(20),
        @cobertura_medica    VARCHAR(100),
        @nro_cobertura_medica VARCHAR(50),
        @id_medio_de_pago    INT = 1,
        @edad                INT,
        @categoria_ingresada VARCHAR(50);

    DECLARE cur CURSOR FOR
        SELECT nro_socio, nro_socio_rp, dni, nombre, apellido, email,
               fecha_nacimiento, telefono_contacto, telefono_emergencia,
               cobertura_medica, nro_cobertura_medica
        FROM socio.socio_temp2
        ORDER BY CASE WHEN nro_socio_rp IS NULL OR nro_socio_rp = '' THEN 0 ELSE 1 END;

    OPEN cur;

    FETCH NEXT FROM cur INTO
        @nro_socio, @nro_socio_rp, @dni, @nombre, @apellido, @email,
        @fecha_nacimiento, @telefono_contacto, @telefono_emergencia,
        @cobertura_medica, @nro_cobertura_medica;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Calcular edad
        SET @edad = DATEDIFF(YEAR, @fecha_nacimiento, GETDATE());
        IF DATEADD(YEAR, @edad, @fecha_nacimiento) > GETDATE()
            SET @edad = @edad - 1;

        -- Determinar categor�a
        IF @edad <= 12
            SET @categoria_ingresada = 'Menor';
        ELSE IF @edad BETWEEN 13 AND 17
            SET @categoria_ingresada = 'Cadete';
        ELSE
            SET @categoria_ingresada = 'Mayor';

        -- Insertar socio
        BEGIN TRY
            EXEC socio.insertar_socio
                @nro_socio = @nro_socio,
                @dni = @dni,
                @nombre = @nombre,
                @apellido = @apellido,
                @email = @email,
                @fecha_nacimiento = @fecha_nacimiento,
                @telefono_contacto = @telefono_contacto,
                @telefono_emergencia = @telefono_emergencia,
                @cobertura_medica = @cobertura_medica,
                @nro_cobertura_medica = @nro_cobertura_medica,
                @id_medio_de_pago = @id_medio_de_pago,
                @nro_socio_rp = @nro_socio_rp,
                @categoria_ingresada = @categoria_ingresada;
        END TRY
        BEGIN CATCH
            PRINT 'Error al insertar socio ' + ISNULL(@nro_socio, '-') + ': ' + ERROR_MESSAGE();
        END CATCH

        FETCH NEXT FROM cur INTO
            @nro_socio, @nro_socio_rp, @dni, @nombre, @apellido, @email,
            @fecha_nacimiento, @telefono_contacto, @telefono_emergencia,
            @cobertura_medica, @nro_cobertura_medica;
    END

    CLOSE cur;
    DEALLOCATE cur;
END;
GO

--=================================================================
--Importar tabla de PAGOS CUOTAS
--=================================================================
CREATE OR ALTER PROCEDURE factura.importar_excel_a_temporal
    @ruta NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    IF OBJECT_ID('tempdb..##PagoExcel') IS NOT NULL
        DROP TABLE ##PagoExcel;

   CREATE TABLE ##PagoExcel (
    id_pago_excel BIGINT,
    fecha_pago date,   -- leer como texto
    responsable_pago NVARCHAR(100),
    monto NUMERIC(15,2),
    medio_de_pago NVARCHAR(50)
);

    DECLARE @sql NVARCHAR(MAX);
    SET @sql = '
    INSERT INTO ##PagoExcel
    SELECT [Id de pago], [fecha], [Responsable de pago], [Valor], [Medio de pago]
    FROM OPENROWSET(
        ''Microsoft.ACE.OLEDB.12.0'',
        ''Excel 12.0;Database=' + @ruta + ';HDR=YES'',
        ''SELECT * FROM [pago cuotas$]''
    )';

    EXEC sp_executesql @sql;
END;
GO

--=================================================================
--PROCESAR PAGOS PARA CARGAR FACTURA.PAGO
--=================================================================
CREATE OR ALTER PROCEDURE factura.procesar_pagos_temporales
AS
BEGIN
    SET NOCOUNT ON;
 
    DECLARE @id_factura INT,
            @id_medio_de_pago INT,
            @tipo_pago VARCHAR(20) = 'Pago completo',
            @fecha_pago DATE,
            @monto NUMERIC(15,2),
            @responsable NVARCHAR(100),
            @medio NVARCHAR(50),
            @msg NVARCHAR(200);
 
    DECLARE pagos_cursor CURSOR FOR
        SELECT fecha_pago, responsable_pago, monto, medio_de_pago
        FROM ##PagoExcel;
 
    OPEN pagos_cursor;
 
    FETCH NEXT FROM pagos_cursor INTO @fecha_pago, @responsable, @monto, @medio;
 
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @id_factura = NULL;
 
        SELECT TOP 1 @id_factura = f.id_factura
        FROM factura.factura_mensual f
        WHERE f.nro_socio = @responsable
          AND f.estado = 'Pendiente'
          AND NOT EXISTS (
              SELECT 1 FROM factura.pago p
              WHERE p.id_factura = f.id_factura
          )
        ORDER BY f.fecha_emision;
 
        IF @id_factura IS NULL
        BEGIN
            PRINT '?? No se encontr� factura v�lida para socio ' + @responsable;
        END
        ELSE
        BEGIN
            PRINT 'Pagando factura ' + CAST(@id_factura AS VARCHAR) + ' para socio ' + @responsable + ' con monto ' + CAST(@monto AS VARCHAR);
 
            SELECT @id_medio_de_pago = id_medio_de_pago
            FROM factura.medio_de_pago
            WHERE LOWER(nombre) = LOWER(@medio);
 
            IF @id_medio_de_pago IS NULL
            BEGIN
                PRINT '? Medio de pago "' + @medio + '" no encontrado para socio ' + @responsable;
            END
            ELSE
            BEGIN
                BEGIN TRY
                    -- Insertar el pago
                    EXEC factura.insertar_pago
                        @id_factura = @id_factura,
                        @id_medio_de_pago = @id_medio_de_pago,
                        @tipo_pago = @tipo_pago,
                        @fecha_pago = @fecha_pago,
                        @monto = @monto,
                        @nro_socio = @responsable;
 
                    -- ? Marcar la factura como 'Pago completado'
                    UPDATE factura.factura_mensual
                    SET estado = 'Pago completado'
                    WHERE id_factura = @id_factura;
 
                END TRY
                BEGIN CATCH
                    SET @msg = ERROR_MESSAGE();
                    PRINT '? Error al insertar pago de ' + @responsable + ': ' + @msg;
                END CATCH
            END
        END
 
        FETCH NEXT FROM pagos_cursor INTO @fecha_pago, @responsable, @monto, @medio;
    END
 
    CLOSE pagos_cursor;
    DEALLOCATE pagos_cursor;
END;
GO

--=================================================================
--IMPORTAR DE TARIFA E INSERTAR A ACTIVIDAD.ACTIVIDAD 
--=================================================================
CREATE OR ALTER PROCEDURE actividad.importar_actividades_regulares
    @path VARCHAR(255)
AS
BEGIN
    DECLARE @sql NVARCHAR(MAX);
    SET @sql = '
        SELECT * INTO #tarifa_mensual
        FROM OPENROWSET(
            ''Microsoft.ACE.OLEDB.12.0'',
            ''Excel 12.0;Database=' + @path + ';HDR=YES;'',
            ''SELECT * FROM [Tarifas$B2:D8]''
        );

        DECLARE @nombre VARCHAR(50), @costo NUMERIC(15,2), @fecha_vigente DATE;
        DECLARE actividades_cursor CURSOR FOR
        SELECT [Actividad], TRY_CAST([Valor por mes] AS NUMERIC(15,2)),[Vigente hasta]
        FROM #tarifa_mensual;

        OPEN actividades_cursor;
        FETCH NEXT FROM actividades_cursor INTO @nombre, @costo,@fecha_vigente;
        WHILE @@FETCH_STATUS = 0
        BEGIN
            EXEC actividad.insertar_actividad @nombre, @costo,@fecha_vigente;
            FETCH NEXT FROM actividades_cursor INTO @nombre, @costo,@fecha_vigente;
        END
        CLOSE actividades_cursor;
        DEALLOCATE actividades_cursor;

        DROP TABLE #tarifa_mensual;
    ';
    EXEC sp_executesql @sql;
END;
GO

--=================================================================
--IMPORTAR Y INSERTAR A SOCIO.CATEGORIA_SOCIO 
--=================================================================
CREATE OR ALTER PROCEDURE socio.importar_categorias_socio
    @path VARCHAR(255)
AS
BEGIN
    DECLARE @sql NVARCHAR(MAX);
    SET @sql = '
        -- Cargar los datos desde el Excel al rango correcto
        SELECT * INTO #categorias_socio
        FROM OPENROWSET(
            ''Microsoft.ACE.OLEDB.12.0'',
            ''Excel 12.0;Database=' + @path + ';HDR=YES;'',
            ''SELECT [Categoria socio], [Valor cuota], [Vigente hasta] FROM [Tarifas$B10:D13]''
        );

        DECLARE @nombre VARCHAR(50), @costo INT, @fecha_vigencia DATE;

        DECLARE cat_cursor CURSOR FOR
        SELECT 
            [Categoria socio], 
            TRY_CAST([Valor cuota] AS INT), 
            TRY_CAST([Vigente hasta] AS DATE)
        FROM #categorias_socio;

        OPEN cat_cursor;
        FETCH NEXT FROM cat_cursor INTO @nombre, @costo, @fecha_vigencia;
        WHILE @@FETCH_STATUS = 0
        BEGIN
            EXEC socio.insertar_categoria_socio @nombre, @costo, @fecha_vigencia;
            FETCH NEXT FROM cat_cursor INTO @nombre, @costo, @fecha_vigencia;
        END
        CLOSE cat_cursor;
        DEALLOCATE cat_cursor;

        DROP TABLE #categorias_socio;
    ';
    EXEC sp_executesql @sql;
END;
GO

--=================================================================
--IMPORTAR TARIFA E INSERTAR A ACTIVIDAD.ACTIVIDAD_EXTRA (Pileta)
--=================================================================
CREATE OR ALTER PROCEDURE actividad.importar_tarifas_pileta
    @path_archivo VARCHAR(255)
AS
BEGIN
    DECLARE @sql NVARCHAR(MAX);
    SET @sql = '
        -- Cargar los datos desde el archivo Excel al rango correcto
        SELECT * INTO #tarifa_pileta
        FROM OPENROWSET(
            ''Microsoft.ACE.OLEDB.12.0'',
            ''Excel 12.0;Database=' + @path_archivo + ';HDR=YES;'',
            ''SELECT * FROM [Tarifas$B16:F22]''
        );

        DECLARE @f1 VARCHAR(50), @tipo_tarifa_actual VARCHAR(50), @categoria VARCHAR(50);
        DECLARE @valor_socios NUMERIC(15,2), @valor_invitados NUMERIC(15,2);
        DECLARE @vigente_hasta DATE;
        DECLARE @nombre_completo VARCHAR(100);

        -- Leer las filas del Excel
        DECLARE c_tarifas CURSOR FOR
        SELECT 
            F1, 
            F2, 
            TRY_CAST(Socios AS NUMERIC(15,2)), 
            TRY_CAST(Invitados AS NUMERIC(15,2)), 
            TRY_CAST([Vigente hasta] AS DATE)
        FROM #tarifa_pileta;

        OPEN c_tarifas;
        FETCH NEXT FROM c_tarifas INTO @f1, @categoria, @valor_socios, @valor_invitados, @vigente_hasta;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            IF @f1 IS NOT NULL
                SET @tipo_tarifa_actual = @f1;

            SET @nombre_completo = ''Pileta - '' + @tipo_tarifa_actual + '' - '' + @categoria;

            EXEC actividad.insertar_actividad_extra 
                @nombre = @nombre_completo, 
                @costo_socio = @valor_socios, 
                @costo_invitado = @valor_invitados, 
                @fecha_vigencia = @vigente_hasta;

            FETCH NEXT FROM c_tarifas INTO @f1, @categoria, @valor_socios, @valor_invitados, @vigente_hasta;
        END

        CLOSE c_tarifas;
        DEALLOCATE c_tarifas;

        DROP TABLE #tarifa_pileta;
    ';
    EXEC sp_executesql @sql;
END;
GO

---========================================
--IMPORTAR PRESENTISMO EXCEL
---=========================================
CREATE OR ALTER PROCEDURE actividad.importar_presentismo_excel
    @ruta NVARCHAR(500)
AS
BEGIN
    SET NOCOUNT ON;

    IF OBJECT_ID('tempdb..##PresentismoExcel') IS NOT NULL
        DROP TABLE ##PresentismoExcel;

    CREATE TABLE ##PresentismoExcel (
        nro_socio VARCHAR(50),
        nombre_actividad VARCHAR(100),
        fecha_asistencia DATE,  -- Cambi� a DATE
        asistencia CHAR(1),
        profesor VARCHAR(100)
    );

    DECLARE @sql NVARCHAR(MAX);
    SET @sql = N'
        INSERT INTO ##PresentismoExcel (nro_socio, nombre_actividad, fecha_asistencia, asistencia, profesor)
        SELECT 
            RTRIM(LTRIM([Nro de Socio])), 
            RTRIM(LTRIM([Actividad])), 
            TRY_CONVERT(DATE, [fecha de asistencia], 0),  -- Convertir ac�
            LEFT(RTRIM(LTRIM([Asistencia])), 1),
            RTRIM(LTRIM([Profesor]))
        FROM OPENROWSET(
            ''Microsoft.ACE.OLEDB.12.0'', 
            ''Excel 12.0;Database=' + @ruta + ';HDR=YES;'',
            ''SELECT [Nro de Socio], [Actividad], [fecha de asistencia], [Asistencia], [Profesor] 
              FROM [presentismo_actividades$]''
        )
        WHERE [Nro de Socio] IS NOT NULL 
          AND RTRIM(LTRIM([Nro de Socio])) <> ''''
          AND [Nro de Socio] LIKE ''SN-%''
          AND TRY_CONVERT(DATE, [fecha de asistencia], 0) IS NOT NULL  -- S�lo filas con fecha v�lida
    ';

    EXEC sp_executesql @sql;
END;
GO

---========================================
---INSERTAR EN TABLA PRESENTISMO
---=========================================
CREATE OR ALTER PROCEDURE actividad.procesar_presentismo_excel
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE 
        @nro_socio VARCHAR(50),
        @nombre_actividad VARCHAR(100),
        @fecha_asistencia DATE,
        @asistencia CHAR(1),
        @profesor VARCHAR(100);

    DECLARE cur CURSOR FOR
        SELECT nro_socio, nombre_actividad, fecha_asistencia, asistencia, profesor
        FROM ##PresentismoExcel;

    OPEN cur;
    FETCH NEXT FROM cur INTO @nro_socio, @nombre_actividad, @fecha_asistencia, @asistencia, @profesor;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Ya no hay que convertir la fecha, porque est� en DATE

        EXEC actividad.insertar_presentismo
            @nro_socio = @nro_socio,
            @nombre_actividad = @nombre_actividad,
            @fecha_asistencia = @fecha_asistencia,
            @asistencia = @asistencia,
            @profesor = @profesor;

        FETCH NEXT FROM cur INTO @nro_socio, @nombre_actividad, @fecha_asistencia, @asistencia, @profesor;
    END
    CLOSE cur;
    DEALLOCATE cur;


END;
GO

---========================================
---INSERTAR EN TABLA PRESENTISMO
---=========================================
CREATE OR ALTER PROCEDURE actividad.procesar_inscripcion_actividad
AS
BEGIN
    SET NOCOUNT ON;

    -- Liberar cursor si ya existe
    IF CURSOR_STATUS('local', 'cur_inscrip') >= -1
    BEGIN
        IF CURSOR_STATUS('local', 'cur_inscrip') = 1
            CLOSE cur_inscrip;
        DEALLOCATE cur_inscrip;
    END

    DECLARE 
        @id_socio INT,
        @id_actividad INT,
        @fecha_inscripcion DATE;

    DECLARE cur_inscrip CURSOR FOR
    SELECT 
        id_socio,
        id_actividad,
        MIN(fecha_asistencia) AS fecha_inscripcion
    FROM actividad.presentismo
    GROUP BY id_socio, id_actividad;

    OPEN cur_inscrip;

    FETCH NEXT FROM cur_inscrip INTO @id_socio, @id_actividad, @fecha_inscripcion;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        EXEC actividad.insertar_inscripcion_actividad
            @id_socio = @id_socio, 
            @id_actividad = @id_actividad, 
            @fecha_inscripcion = @fecha_inscripcion;

        FETCH NEXT FROM cur_inscrip INTO @id_socio, @id_actividad, @fecha_inscripcion;
    END

    CLOSE cur_inscrip;
    DEALLOCATE cur_inscrip;
END
GO


-----------------------Cosas para que funcione el import------------------------
--Carga de medios de pago
create or alter procedure factura.cargar_medio_de_pago
as
begin
	exec factura.insertar_medio_de_pago
		@nombre = 'efectivo';
	exec factura.insertar_medio_de_pago
		@nombre = 'tarjeta credito';
	exec factura.insertar_medio_de_pago
		@nombre = 'transferencia';
end
go

--Generar facturas mensuales
CREATE OR ALTER PROCEDURE factura.generar_facturas_mensuales
    @anio INT = 2024
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE 
        @mes INT = 1,
        @nro_socio VARCHAR(10),
        @fecha_emision DATE,
        @fecha_vencimiento DATE,
        @total NUMERIC(15,2),
        @nro_socio_num INT;
    -- Cursor SOLO para socios con nro_socio entre SN-4001 y SN-4120
    DECLARE cur_socios CURSOR FOR
        SELECT nro_socio
        FROM socio.socio
        WHERE 
            ISNUMERIC(SUBSTRING(nro_socio, 4, 4)) = 1 AND
            CAST(SUBSTRING(nro_socio, 4, 4) AS INT) BETWEEN 4001 AND 4120;
    OPEN cur_socios;
    FETCH NEXT FROM cur_socios INTO @nro_socio;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @mes = 1;
        SET @nro_socio_num = CAST(SUBSTRING(@nro_socio, 4, 4) AS INT);
        WHILE @mes <= 12
        BEGIN
            -- Fecha de emisi�n = 1� de cada mes
            SET @fecha_emision = DATEFROMPARTS(@anio, @mes, 1);
            -- Fecha de vencimiento = 5 d�as despu�s
            SET @fecha_vencimiento = DATEADD(DAY, 5, @fecha_emision);
            -- L�gica escalonada de montos por bloques
            SET @total = 
                CASE 
                    WHEN @nro_socio_num <= 4040 THEN 15000
                    WHEN @nro_socio_num <= 4080 THEN 20000
                    ELSE 22000
                END;
            INSERT INTO factura.factura_mensual (fecha_emision, fecha_vencimiento, estado, total, nro_socio)
            VALUES (@fecha_emision, @fecha_vencimiento, 'Pendiente', @total, @nro_socio);
            SET @mes = @mes + 1;
        END
        FETCH NEXT FROM cur_socios INTO @nro_socio;
    END
    CLOSE cur_socios;
    DEALLOCATE cur_socios;
    PRINT 'Facturas generadas para socios del rango SN-4001 a SN-4120.';
END;