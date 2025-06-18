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

DROP PROCEDURE importar_socios_excel

CREATE OR ALTER PROCEDURE importar_socios_excel

    @ruta NVARCHAR(255)
AS
BEGIN

		CREATE TABLE #socio_temp (
	    id_socio int identity (1,1) PRIMARY KEY,
		nro_socio VARCHAR (10)  NOT NULL,
		dni VARCHAR(15)  NOT NULL,
		nombre VARCHAR(50) NOT NULL,
		apellido VARCHAR(50) NOT NULL,
		email VARCHAR(100)  NOT NULL,
		fecha_nacimiento DATE NOT NULL,
		telefono_contacto VARCHAR(20),
		telefono_emergencia VARCHAR(20),
		cobertura_medica VARCHAR(100),
		nro_cobertura_medica VARCHAR(50),
	);

    SET NOCOUNT ON;

    DECLARE @sql NVARCHAR(MAX);

    SET @sql = N'
    INSERT INTO #socio_temp(
        dni, nombre, apellido, email, fecha_nacimiento,
        telefono_contacto, telefono_emergencia,
        cobertura_medica, nro_cobertura_medica,
       ,nro_socio
    )
    SELECT 
        LTRIM(RTRIM([ DNI])),
        [Nombre],
        [ apellido],
        [ email personal],
        TRY_CAST([ fecha de nacimiento] AS DATE),
        [ teléfono de contacto],
        COALESCE([ teléfono de contacto emergencia], [teléfono de contacto de emergencia]),
        [ Nombre de la obra social o prepaga],
        [nro# de socio obra social/prepaga ],
        [Nro de Socio] 
    FROM OPENROWSET(
        ''Microsoft.ACE.OLEDB.12.0'',
        ''Excel 12.0 Xml;Database=' + @ruta + ';HDR=YES;IMEX=1'',
        ''SELECT * FROM [Responsables de Pago$]''
    ) AS t
    WHERE 
        LTRIM(RTRIM([ DNI])) IS NOT NULL
        AND LTRIM(RTRIM([ DNI])) <> ''''
        AND TRY_CAST([ fecha de nacimiento] AS DATE) IS NOT NULL
        AND NOT EXISTS (
            SELECT 1 FROM socio.socio s WHERE LTRIM(RTRIM(s.dni)) = LTRIM(RTRIM(t.[ DNI]))
        )
    ';

    EXEC sp_executesql @sql;
END;
GO



EXEC importar_socios_excel @ruta = 'C:\Importar\Datos socios.xlsx';
select* from socio.socio

---------------------------------------------------------------------------------------
SELECT *
FROM OPENROWSET(
    'Microsoft.ACE.OLEDB.12.0',
    'Excel 12.0;Database=C:\Importar\Datos Socios.xlsx;HDR=YES',
    'SELECT * FROM [Responsables de Pago$]'
);


DROP DATABASE Com5600G02


CREATE OR ALTER PROCEDURE importar_socios_excel
    @ruta NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    -- Borrar tabla si ya existe
    IF OBJECT_ID('socio.socio_temp', 'U') IS NOT NULL
        DROP TABLE socio.socio_temp;

    -- Crear tabla temporal persistente
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
        LTRIM(RTRIM([ DNI])),
        [Nombre],
        [ apellido],
        [ email personal],
        TRY_CAST([ fecha de nacimiento] AS DATE),
        CAST([ teléfono de contacto]AS VARCHAR(20)),
        CAST([ teléfono de contacto emergencia] AS VARCHAR(20)),
        [ Nombre de la obra social o prepaga],
        [nro# de socio obra social/prepaga ],
        [Nro de Socio]
    FROM OPENROWSET(
        ''Microsoft.ACE.OLEDB.12.0'',
        ''Excel 12.0;Database=' + @ruta + ';HDR=YES;'',
        ''SELECT * FROM [Responsables de Pago$]''
    ) AS t
    WHERE 
        LTRIM(RTRIM([ DNI])) IS NOT NULL
        AND LTRIM(RTRIM([ DNI])) <> ''''
        AND TRY_CAST([ fecha de nacimiento] AS DATE) IS NOT NULL
        AND NOT EXISTS (
            SELECT 1 FROM socio.socio s WHERE LTRIM(RTRIM(s.dni)) = LTRIM(RTRIM(t.[ DNI]))
        )
    ';

    EXEC sp_executesql @sql;
END;
GO

EXEC importar_socios_excel @ruta = 'C:\Importar\Datos socios.xlsx';

select* from socio.socio_temp

