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

--=================================================================
--Importar tabla de OPEN_METEO_BUENOS_AIRES
--=================================================================
EXEC factura.importar_clima_csv @path = 'C:\Importar\open-meteo-buenosaires_2025.csv'
--select * from factura.clima_anual;

--=================================================================
--Importar tabla de RESPONDABLES DE PAGO
--=================================================================
EXEC socio.importar_socios_excel @ruta = 'C:\Importar\Datos socios.xlsx';
--	select * from socio.socio_temp

--=================================================================
--IMPORTAR Y INSERTAR A SOCIO.CATEGORIA_SOCIO 
--=================================================================
EXEC socio.importar_categorias_socio @path = 'C:\Importar\Datos socios.xlsx';
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
EXEC socio.importar_socios_excel2 @ruta = 'C:\Importar\Datos socios.xlsx';
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
select * from factura.factura_mensual
delete factura.pago
delete factura.factura_mensual

--=================================================================
--IMPORTAR DE TARIFA E INSERTAR A ACTIVIDAD.ACTIVIDAD 
--=================================================================
EXEC actividad.importar_actividades_regulares @path = 'C:\Importar\Datos socios.xlsx';

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
EXEC actividad.importar_tarifas_pileta @path_archivo = 'C:\Importar\Datos socios.xlsx';
--select * from actividad.actividad_extra

---========================================
--IMPORTAR PRESENTISMO EXCEL
---=========================================
EXEC actividad.importar_presentismo_excel @ruta='C:\Importar\Datos socios.xlsx';
--select* from ##PresentismoExcel

---========================================
---INSERTAR EN TABLA PRESENTISMO
---=========================================
EXEC  actividad.procesar_presentismo_excel
--select* from actividad.presentismo

---========================================
---INSERTAR EN TABLA INSCRIPCION_ACTIVIDAD
---=========================================
EXEC actividad.procesar_inscripcion_actividad
--select * from actividad.inscripcion_actividad
