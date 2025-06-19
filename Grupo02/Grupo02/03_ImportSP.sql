USE Com5600G02
GO
--=================================================================
--Configuracion para importar archivos excel
--=================================================================
EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
EXEC sp_configure 'Ad Hoc Distributed Queries', 1;
RECONFIGURE;
GO
--=================================================================
--PROCEDURES PARA iMPORTAR LOS DATOS
--=================================================================

--=================================================================
--Importar tabla de PRESENTISMO_ACTIVIDADES
--=================================================================
CREATE OR ALTER PROCEDURE actividad.importar_excel_Presentismo
    @ruta NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    IF OBJECT_ID('actividad.presentismo','U') IS NOT NULL
        DROP TABLE actividad.presentismo;

   CREATE TABLE actividad.presentismo (
	id_presentismo int identity(1,1) primary key,
    nro_socio varchar(20),
    activudad varchar(50), 
    fecha_asistencia date,
    asistencia varchar(1),
	profesor varchar(50)
);

    DECLARE @sql NVARCHAR(MAX);
    SET @sql = '
    INSERT INTO actividad.presentismo
    SELECT [Nro de Socio], [Actividad], [fecha de asistencia], [Asistencia], [Profesor]
    FROM OPENROWSET(
        ''Microsoft.ACE.OLEDB.12.0'',
        ''Excel 12.0;Database=' + @ruta + ';HDR=YES;IMEX=1'',
        ''SELECT * FROM [presentismo_actividades$]''
    )';

    EXEC sp_executesql @sql;
END;
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
     LTRIM(RTRIM(CAST(CAST([ teléfono de contacto] AS DECIMAL(20, 0)) AS VARCHAR(20)))) AS telefono_contacto,
LTRIM(RTRIM(CAST(CAST([ teléfono de contacto emergencia] AS DECIMAL(20, 0)) AS VARCHAR(20)))) AS telefono_emergencia,

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

    EXEC sp_executesql @sql;
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
        LTRIM(RTRIM(CAST(CAST([ teléfono de contacto] AS DECIMAL(20, 0)) AS VARCHAR(20)))) AS telefono_contacto,
        LTRIM(RTRIM(CAST(CAST([ teléfono de contacto emergencia] AS DECIMAL(20, 0)) AS VARCHAR(20)))) AS telefono_emergencia,
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
--PROCEDURES PARA PROCESAR LOS DATOS
--=================================================================

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
        @id_grupo_familiar INT = NULL,
		@nro_socio_rp varchar(10);

    DECLARE cur CURSOR FOR 
        SELECT nro_socio, dni, nombre, apellido, email, fecha_nacimiento, 
               telefono_contacto, telefono_emergencia, cobertura_medica, nro_cobertura_medica,nro_socio_rp
        FROM socio.socio_temp;

    OPEN cur;
    FETCH NEXT FROM cur INTO @nro_socio, @dni, @nombre, @apellido, @email, @fecha_nacimiento, 
                             @telefono_contacto, @telefono_emergencia, @cobertura_medica, @nro_cobertura_medica,@nro_socio_rp;

    WHILE @@FETCH_STATUS = 0
    BEGIN
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
            @id_medio_de_pago = 1,
          @id_grupo_familiar = @id_grupo_familiar,
			@nro_socio_rp = @nro_socio_rp;

        FETCH NEXT FROM cur INTO @nro_socio, @dni, @nombre, @apellido, @email, @fecha_nacimiento, 
                                 @telefono_contacto, @telefono_emergencia, @cobertura_medica, @nro_cobertura_medica,@nro_socio_rp;
    END

    CLOSE cur;
    DEALLOCATE cur;
END;
GO

--=================================================================
--CARGAR DATOS DE SOCIOS_TEMP2 A SOCIOS.SOCIOS
--=================================================================
CREATE OR ALTER PROCEDURE socio.procesar_socios_temp2
AS
BEGIN
    SET NOCOUNT ON;

    ------------------------------------------------------------------
    -- 1.  Declaro variables de trabajo
    ------------------------------------------------------------------
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
        @id_medio_de_pago    INT   = 1,   -- 1 = Débito, por ejemplo
        @id_grupo_familiar   INT,
        @id_socio_rp         INT,
        @edad                INT,
        @categoria           VARCHAR(50);

    ------------------------------------------------------------------
    -- 2.  Cursor: primero los RPs, luego los familiares
    ------------------------------------------------------------------
    DECLARE cur CURSOR FOR
        SELECT  nro_socio, nro_socio_rp, dni, nombre, apellido, email,
                fecha_nacimiento, telefono_contacto, telefono_emergencia,
                cobertura_medica, nro_cobertura_medica
        FROM    socio.socio_temp2
        ORDER BY
            CASE WHEN nro_socio_rp IS NULL OR nro_socio_rp = '' THEN 0 ELSE 1 END; 
            -- 0 = RPs; 1 = familiares.

    OPEN cur;

    FETCH NEXT FROM cur INTO
        @nro_socio, @nro_socio_rp, @dni, @nombre, @apellido, @email,
        @fecha_nacimiento, @telefono_contacto, @telefono_emergencia,
        @cobertura_medica, @nro_cobertura_medica;

    ------------------------------------------------------------------
    -- 3.  Recorro todos los registros
    ------------------------------------------------------------------
    WHILE @@FETCH_STATUS = 0
    BEGIN
        ------------------------------------------------------------------
        -- 3.1  Calculo edad y categoría (opcional)
        ------------------------------------------------------------------
        SET @edad = DATEDIFF(YEAR, @fecha_nacimiento, GETDATE());
        IF DATEADD(YEAR, @edad, @fecha_nacimiento) > GETDATE()
            SET @edad = @edad - 1;

        IF @edad <= 12
            SET @categoria = 'Menor';
        ELSE IF @edad BETWEEN 13 AND 17
            SET @categoria = 'Cadete';
        ELSE
            SET @categoria = 'Mayor';

        ------------------------------------------------------------------
        -- 3.2  Reseteo id_grupo_familiar antes de cada ciclo
        ------------------------------------------------------------------
        SET @id_grupo_familiar = NULL;

        ------------------------------------------------------------------
        -- 3.3  Si TIENE Responsable de Pago ..............................
        ------------------------------------------------------------------
        IF @nro_socio_rp IS NOT NULL AND @nro_socio_rp <> ''
        BEGIN
            --------------------------------------------------------------
            -- Localizo al RP y su grupo (si ya existe)
            --------------------------------------------------------------
            SELECT @id_socio_rp       = id_socio,
                   @id_grupo_familiar = id_grupo_familiar
            FROM   socio.socio
            WHERE  nro_socio = @nro_socio_rp;

            --------------------------------------------------------------
            -- Si el RP ya estaba en la tabla socio, pero aún NO tenía
            -- grupo, se lo creo y lo vinculo.
            --------------------------------------------------------------
            IF @id_socio_rp IS NOT NULL AND @id_grupo_familiar IS NULL
            BEGIN
                -- Creo fila “Responsable” en grupo_familiar
                INSERT INTO socio.grupo_familiar
                       (nombre, apellido, dni, email, fecha_nacimiento,
                        telefono, parentesco)
                SELECT  nombre, apellido, dni, email, fecha_nacimiento,
                        telefono_contacto, 'Familiar'
                FROM    socio.socio
                WHERE   id_socio = @id_socio_rp;

                -- Nuevo id del grupo
                SET @id_grupo_familiar = SCOPE_IDENTITY();

                -- Actualizo al RP con su propio grupo
                UPDATE socio.socio
                SET    id_grupo_familiar = @id_grupo_familiar
                WHERE  id_socio = @id_socio_rp;
            END

            --------------------------------------------------------------
            -- Si el RP TODAVÍA no existe (p.ej. se va a importar luego),
            -- dejamos @id_grupo_familiar en NULL; más tarde se podrá
            -- actualizar mediante un proceso de reconciliación.
            --------------------------------------------------------------
        END

        ------------------------------------------------------------------
        -- 3.4  Si NO tiene Responsable (es RP) ..........................
        ------------------------------------------------------------------
        IF @nro_socio_rp IS NULL OR @nro_socio_rp = ''
        BEGIN
            --------------------------------------------------------------
            -- Cada RP debe tener su PROPIO registro en grupo_familiar
            -- con parentesco = 'Responsable'
            --------------------------------------------------------------
            INSERT INTO socio.grupo_familiar
                   (nombre, apellido, dni, email, fecha_nacimiento,
                    telefono, parentesco)
            VALUES (@nombre, @apellido, @dni, @email, @fecha_nacimiento,
                    @telefono_contacto, 'Familiar');

            SET @id_grupo_familiar = SCOPE_IDENTITY();
        END

        ------------------------------------------------------------------
        -- 3.5  Inserto el socio, apuntando al grupo correcto
        ------------------------------------------------------------------
        EXEC  socio.insertar_socio
              @nro_socio            = @nro_socio,
              @dni                  = @dni,
              @nombre               = @nombre,
              @apellido             = @apellido,
              @email                = @email,
              @fecha_nacimiento     = @fecha_nacimiento,
              @telefono_contacto    = @telefono_contacto,
              @telefono_emergencia  = @telefono_emergencia,
              @cobertura_medica     = @cobertura_medica,
              @nro_cobertura_medica = @nro_cobertura_medica,
              @id_medio_de_pago     = @id_medio_de_pago,
              @id_grupo_familiar    = @id_grupo_familiar,  -- <-- MISMO grupo que el RP
              @nro_socio_rp         = @nro_socio_rp;

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
        SET @id_factura = NULL;  -- Resetear antes de buscar factura nueva

        
        SELECT TOP 1 @id_factura = f.id_factura
        FROM factura.factura_mensual f
        WHERE f.nro_socio = @responsable
          
          AND NOT EXISTS (
              SELECT 1 FROM factura.pago p
              WHERE p.id_factura = f.id_factura
          )
        ORDER BY f.fecha_emision;

        IF @id_factura IS NULL
        BEGIN
            PRINT '?? No se encontró factura válida para socio ' + @responsable;
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
                    EXEC factura.insertar_pago
                        @id_factura = @id_factura,
                        @id_medio_de_pago = @id_medio_de_pago,
                        @tipo_pago = @tipo_pago,
                        @fecha_pago = @fecha_pago,
                        @monto = @monto,
						 @nro_socio =@responsable;
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