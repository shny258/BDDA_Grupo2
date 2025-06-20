--El archivo .sql con el script debe incluir comentarios donde consten este enunciado, 
--la fecha de entrega,
--número de grupo, nombre de la materia, nombres y DNI de los alumnos. Entregar todo en un zip 
--(observar las pautas para nomenclatura antes expuestas) mediante la sección de prácticas de MIEL. 
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
----------------------------------------------------------
--				GENERACION DE FACTURAS
----------------------------------------------------------

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
		@segunda_fecha_vencimiento DATE,
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
            -- Fecha de emisión = 1° de cada mes
            SET @fecha_emision = DATEFROMPARTS(@anio, @mes, 1);
            -- Fecha de vencimiento = 5 días después
            SET @fecha_vencimiento = DATEADD(DAY, 5, @fecha_emision);
			 -- Segunda Fecha de vencimiento = 5 días después
            SET @segunda_fecha_vencimiento = DATEADD(DAY,10, @fecha_emision);
 
            -- Lógica escalonada de montos por bloques
            SET @total = 
                CASE 
                    WHEN @nro_socio_num <= 4040 THEN 15000
                    WHEN @nro_socio_num <= 4080 THEN 20000
                    ELSE 22000
                END;
 
            INSERT INTO factura.factura_mensual (fecha_emision, fecha_vencimiento,segunda_fecha_vencimiento, estado, total, nro_socio)
            VALUES (@fecha_emision, @fecha_vencimiento, @segunda_fecha_vencimiento ,'Pendiente', @total, @nro_socio);
 
            SET @mes = @mes + 1;
        END
 
        FETCH NEXT FROM cur_socios INTO @nro_socio;
    END
 
    CLOSE cur_socios;
    DEALLOCATE cur_socios;
 
    PRINT 'Facturas generadas para socios del rango SN-4001 a SN-4120.';
END;
EXEC factura.generar_facturas_mensuales @anio = 2024;


--=================================================================
--Importar tabla de OPEN_METEO_BUENOS_AIRES
--=================================================================
EXEC factura.importar_clima_csv @path = '[PATH]\open-meteo-buenosaires_2025.csv'
--select * from factura.clima_anual;

--=================================================================
--Importar tabla de RESPONDABLES DE PAGO
--=================================================================
EXEC socio.importar_socios_excel @ruta = '[PATH]\Datos socios.xlsx';
--	select * from socio.socio_temp

--=================================================================
--IMPORTAR Y INSERTAR A SOCIO.CATEGORIA_SOCIO 
--=================================================================
EXEC socio.importar_categorias_socio @path = '[PATH]\Datos socios.xlsx';
--select * from socio.categoria_socio

--=================================================================
--CARGAR DATOS DE SOCIOS_TEMP A SOCIOS.SOCIOS
--=================================================================
EXEC factura.cargar_medio_de_pago; --Cargar minimamente 3 medios de pagos
EXEC socio.procesar_socios_temp;
--select * from socio.socio

--=================================================================
--Importar tabla de GRUPO FAMILIAR
--=================================================================
EXEC socio.importar_socios_excel2 @ruta = '[PATH]\Datos socios.xlsx';
--select * from socio.socio_temp2

--=================================================================
--CARGAR DATOS DE SOCIOS_TEMP2 A SOCIOS.SOCIOS
--=================================================================
EXEC socio.procesar_socios_temp2;
EXEC factura.generar_facturas_mensuales @anio = 2024; --Generar Facturas?
--select * from socio.socio

--=================================================================
--Importar E INSERTAR tabla de PAGOS CUOTAS
--=================================================================
EXEC factura.importar_excel_a_temporal @ruta = '[PATH]\Datos socios.xlsx';
EXEC factura.procesar_pagos_temporales;
--select * from factura.pago

--=================================================================
--IMPORTAR DE TARIFA E INSERTAR A ACTIVIDAD.ACTIVIDAD 
--=================================================================
EXEC actividad.importar_actividades_regulares @path = '[PATH]\Datos socios.xlsx';

/*
Ejecutar en caso de que sea necesario modificar la actividad de ajedrez

DECLARE @costo NUMERIC(15,2);
DECLARE @fecha DATE;
SELECT 
    @costo = costo_mensual,
    @fecha = fecha_vigencia
FROM actividad.actividad
WHERE id_actividad = 6;

EXEC actividad.modificar_actividad 
    @id = 6, 
    @nombre = 'Ajedrez', 
    @costo_mensual = @costo, 
    @fecha_vigencia = @fecha;

select * from actividad.actividad
*/


--=================================================================
--IMPORTAR TARIFA E INSERTAR A ACTIVIDAD.ACTIVIDAD_EXTRA (Pileta)
--=================================================================
EXEC actividad.importar_tarifas_pileta @path_archivo = '[PATH]\Datos socios.xlsx';
--select * from actividad.actividad_extra

---========================================
--IMPORTAR PRESENTISMO EXCEL
---=========================================
EXEC actividad.importar_presentismo_excel @ruta='[PATH]\Datos socios.xlsx';
--select* from ##PresentismoExcel

---========================================
---INSERTAR EN TABLA PRESENTISMO
---=========================================
EXEC  actividad.procesar_presentismo_excel

--select* from actividad.presentismo
