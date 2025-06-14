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

