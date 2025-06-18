CREATE OR ALTER PROCEDURE factura.importar_clima_csv @path NVARCHAR(255) as
begin
	SET NOCOUNT ON;

    IF OBJECT_ID('factura.clima_anual', 'U') IS NOT NULL
        DROP TABLE factura.open_meteo;
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

exec factura.importar_clima_csv @path = 'C:\Users\lucia\Desktop\archivos\open-meteo-buenosaires_2025.csv'

select * from factura.clima_anual;

drop procedure carga_open_meto_buenosAires

SELECT *
FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
    'Excel 12.0;Database=C:\Importar\Datos socios.xlsx;HDR=YES;IMEX=1',
    'SELECT * FROM [pago cuotas$]');


---------------------------------------------------------------------------------------
SELECT *
FROM OPENROWSET(
    'Microsoft.ACE.OLEDB.12.0',
    'Excel 12.0;Database=C:\Importar\Datos Socios.xlsx;HDR=YES',
    'SELECT * FROM [Responsables de Pago$]'
);


DROP DATABASE Com5600G02
EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
EXEC sp_configure 'Ad Hoc Distributed Queries', 1;
RECONFIGURE;

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

	EXEC socio.importar_socios_excel 
    @ruta = 'C:\Importar\Datos socios.xlsx';

	select* from socio.socio_temp
	DROP TABLE  socio.socio_temp
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
            @id_medio_de_pago = @id_medio_de_pago,
          @id_grupo_familiar = @id_grupo_familiar,
@nro_socio_rp = @nro_socio_rp;

        FETCH NEXT FROM cur INTO @nro_socio, @dni, @nombre, @apellido, @email, @fecha_nacimiento, 
                                 @telefono_contacto, @telefono_emergencia, @cobertura_medica, @nro_cobertura_medica,@nro_socio_rp;
    END

    CLOSE cur;
    DEALLOCATE cur;
END;
GO

EXECUTE socio.procesar_socios_temp;

select* from socio.socio
=====================================================
--DATOS SOCIOS RESPONSABLES EXP GRUPO FAMILIAR
=====================================================
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


	EXEC socio.importar_socios_excel2
    @ruta = 'C:\Importar\Datos socios.xlsx';

	select* from socio.socio_temp2
CREATE OR ALTER PROCEDURE socio.procesar_socios_temp2
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE 
        @nro_socio VARCHAR(10),
        @nro_socio_rp VARCHAR(10),
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
        @id_socio_rp INT,
        @edad INT,
        @categoria VARCHAR(50);


    DECLARE cur CURSOR FOR 
        SELECT nro_socio, nro_socio_rp, dni, nombre, apellido, email, fecha_nacimiento, 
               telefono_contacto, telefono_emergencia, cobertura_medica, nro_cobertura_medica,nro_socio_rp
        FROM socio.socio_temp2;

    OPEN cur;
    FETCH NEXT FROM cur INTO 
        @nro_socio, @nro_socio_rp, @dni, @nombre, @apellido, @email, @fecha_nacimiento, 
        @telefono_contacto, @telefono_emergencia, @cobertura_medica, @nro_cobertura_medica,@nro_socio_rp;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @edad = DATEDIFF(YEAR, @fecha_nacimiento, GETDATE());
        IF DATEADD(YEAR, @edad, @fecha_nacimiento) > GETDATE()
            SET @edad = @edad - 1;

        IF @edad <= 12
            SET @categoria = 'Joven';
        ELSE IF @edad BETWEEN 13 AND 17
            SET @categoria = 'Adulto';
        ELSE
            SET @categoria = 'Mayor';

        SET @id_grupo_familiar = NULL; -- Reset para cada iteración

        -- Si hay Responsable de Pago, buscar su ID
        IF @nro_socio_rp IS NOT NULL AND @nro_socio_rp <> ''
        BEGIN
            SELECT @id_socio_rp = id_socio FROM socio.socio WHERE nro_socio = @nro_socio_rp;

            IF @id_socio_rp IS NOT NULL
            BEGIN
                -- Buscar si el familiar ya existe en grupo_familiar (por DNI)
                SELECT @id_grupo_familiar = id_grupo_familiar 
                FROM socio.grupo_familiar 
                WHERE dni = @dni;

                IF @id_grupo_familiar IS NULL
                BEGIN
                    INSERT INTO socio.grupo_familiar (nombre, apellido, dni, email, fecha_nacimiento, telefono, parentesco)
                    VALUES (@nombre, @apellido, @dni, @email, @fecha_nacimiento, @telefono_contacto, 'Familiar');

                    SET @id_grupo_familiar = SCOPE_IDENTITY();
                END
            END
        END

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
    @id_grupo_familiar = @id_grupo_familiar,
    @nro_socio_rp = @nro_socio_rp; -- <- nuevo parámetro correctamente pasado


        FETCH NEXT FROM cur INTO 
            @nro_socio, @nro_socio_rp, @dni, @nombre, @apellido, @email, @fecha_nacimiento, 
            @telefono_contacto, @telefono_emergencia, @cobertura_medica, @nro_cobertura_medica,@nro_socio_rp;
    END

    CLOSE cur;
    DEALLOCATE cur;
END;
GO

EXECUTE socio.procesar_socios_temp2;
EXECUTE socio.procesar_socios_temp;
select * from socio.socio
truncate table  socio.socio