USE Com5600G02
GO
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
--CARGAR DATOS DE SOCIOS_TEMP A SOCIOS.SOCIOS
--=================================================================
EXEC factura.cargar_medio_de_pago; --Cargar minimamente 3 medios de pagos
EXEC socio.procesar_socios_temp2;
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
DECLARE @costo NUMERIC(15,2);
DECLARE @fecha DATE;
SELECT 
    @costo = costo_mensual,
    @fecha = fecha_vigencia
FROM actividad.actividad
WHERE id_actividad = 12;

EXEC actividad.modificar_actividad 
    @id = 12, 
    @nombre = 'Ajedrez', 
    @costo_mensual = @costo, 
    @fecha_vigencia = @fecha;

select * from actividad.actividad
*/

--=================================================================
--IMPORTAR Y INSERTAR A SOCIO.CATEGORIA_SOCIO 
--=================================================================
EXEC socio.importar_categorias_socio @path = '[PATH]\Datos socios.xlsx';
--select * from socio.categoria_socio

--=================================================================
--IMPORTAR TARIFA E INSERTAR A ACTIVIDAD.ACTIVIDAD_EXTRA (Pileta)
--=================================================================
EXEC actividad.importar_tarifas_pileta @path_archivo = '[PATH]\Datos socios.xlsx';
--select * from actividad.actividad_extra

---========================================
--IMPORTAR PRESENTISMO EXCEL
---=========================================
EXEC actividad.importar_presentismo_excel @ruta='[PATH]\Datos socios.xlsx';
--select* from ##PresentismoExcel ORDER BY fecha_asistencia where nro_socio='SN-4148'

---========================================
---INSERTAR EN TABLA PRESENTISMO
---=========================================
EXEC  actividad.procesar_presentismo_excel
/*
select* from actividad.presentismo
delete actividad.presentismo
select* from actividad.actividad
select* from actividad.presentismo order by id_actividad

SELECT DISTINCT a.nombre
FROM actividad.presentismo p
JOIN actividad.actividad a ON p.id_actividad = a.id_actividad
WHERE p.asistencia = 'P';

SELECT s.nro_socio
FROM socio.socio s
LEFT JOIN ##PresentismoExcel p ON s.nro_socio = p.nro_socio
WHERE p.nro_socio IS NULL;

SELECT p.nro_socio
FROM ##PresentismoExcel p
LEFT JOIN socio.socio s ON p.nro_socio = s.nro_socio
WHERE s.nro_socio IS NULL;
*/