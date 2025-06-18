CREATE PROCEDURE carga_open_meto_buenosAires @path NVARCHAR(255) as
begin
-- CREAR UNA TABLA TEMPORAL
	CREATE TABLE #open_meteo (
		horario date primary key,
		temperatura numeric(3,1),
		lluvia numeric(3,2),
		humedad TINYINT,
		viento numeric(3,1)
	);

-- cargo el csv a la tabla temporal 
	BULK INSERT #open_meteo
	FROM 'C:\Users\lucia\Desktop\archivos\open-meteo-buenosaires_2025.csv' --concateno la ruta entre comillas
	WITH (
	FIELDTERMINATOR = ',',
	ROWTERMINATOR = '\n',
	FIRSTROW = 5, -- EL CSV TRAE ENCABEZADO
	codepage = 'ACP',
	TABLOCK
	);
	select * from #open_meteo
end
go

exec carga_open_meto_buenosAires @path = 'C:\Users\lucia\Desktop\archivos\open-meteo-buenosaires_2025.csv'

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
        nro_cobertura_medica VARCHAR(50)
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
        @edad INT,
        @categoria VARCHAR(50);

    DECLARE cur CURSOR FOR 
        SELECT nro_socio, dni, nombre, apellido, email, fecha_nacimiento, 
               telefono_contacto, telefono_emergencia, cobertura_medica, nro_cobertura_medica
        FROM socio.socio_temp;

    OPEN cur;
    FETCH NEXT FROM cur INTO @nro_socio, @dni, @nombre, @apellido, @email, @fecha_nacimiento, 
                             @telefono_contacto, @telefono_emergencia, @cobertura_medica, @nro_cobertura_medica;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @edad = DATEDIFF(YEAR, @fecha_nacimiento, GETDATE());

        IF @edad <= 12
            SET @categoria = 'Menor';
        ELSE IF @edad BETWEEN 13 AND 17
            SET @categoria = 'Cadete';
        ELSE
            SET @categoria = 'Mayor';

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
            @id_categoria = @categoria;

        FETCH NEXT FROM cur INTO @nro_socio, @dni, @nombre, @apellido, @email, @fecha_nacimiento, 
                                 @telefono_contacto, @telefono_emergencia, @cobertura_medica, @nro_cobertura_medica;
    END

    CLOSE cur;
    DEALLOCATE cur;
END;
GO

EXECUTE socio.procesar_socios_temp;

