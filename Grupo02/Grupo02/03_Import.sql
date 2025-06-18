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
    SET NOCOUNT ON;

    DECLARE @sql NVARCHAR(MAX);

    SET @sql = N'
    INSERT INTO socio.socio (
        dni, nombre, apellido, email, fecha_nacimiento,
        telefono_contacto, telefono_emergencia,
        cobertura_medica, nro_cobertura_medica,
        id_medio_de_pago, id_grupo_familiar, id_categoria,nro_socio
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
        NULL, NULL, NULL,[Nro de Socio] 
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

