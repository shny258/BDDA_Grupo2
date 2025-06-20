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
-----------------------------------------------------------------------------
-- REPORTE DE LOS SOCIOS MOROSOS (2024)
-----------------------------------------------------------------------------

DECLARE @fecha_inicio DATE = '2024-01-01';
DECLARE @fecha_fin DATE = '2024-12-31';

WITH Morosidades AS (
    SELECT 
        s.nro_socio,
        s.nombre + ' ' + s.apellido AS nombre_apellido,
        FORMAT(fm.fecha_vencimiento, 'yyyy-MM') AS mes_incumplido,
        COUNT(*) OVER (PARTITION BY s.nro_socio) AS total_incumplimientos
    FROM factura.factura_mensual fm
    INNER JOIN socio.socio s ON s.nro_socio = fm.nro_socio
    WHERE fm.estado = 'Pendiente'
      AND fm.fecha_vencimiento BETWEEN @fecha_inicio AND @fecha_fin
)
SELECT DISTINCT
    nro_socio,
    nombre_apellido,
    mes_incumplido,
    total_incumplimientos
FROM Morosidades
WHERE total_incumplimientos > 2
ORDER BY total_incumplimientos DESC;

-----------------------------------------------------------------------------
-- REPORTE DE SOCIOS AUSENTES EN SUS ACTIVIDADES
-----------------------------------------------------------------------------
SELECT 
    soc.nombre,
    soc.apellido,
    DATEDIFF(YEAR, soc.fecha_nacimiento, GETDATE()) AS edad,
    cat.nombre,
    act.nombre
FROM socio.socio soc
JOIN actividad.inscripcion_actividad ins 
    ON soc.id_socio = ins.id_socio
JOIN actividad.actividad act 
    ON ins.id_actividad = act.id_actividad
JOIN socio.categoria_socio cat 
    ON soc.id_categoria = cat.nombre
WHERE EXISTS (
    SELECT 1
    FROM actividad.presentismo p1
    WHERE p1.id_actividad = ins.id_actividad
)
AND NOT EXISTS (
    SELECT 1
    FROM actividad.presentismo p2
    WHERE p2.id_actividad = ins.id_actividad
      AND p2.id_socio = ins.id_socio
      AND p2.asistencia = 'P'
);

-----------------------------------------------------------------------------
-- REPORTE DE INGRESOS DE ACTIVIDADES (DESDE ENERO)
-----------------------------------------------------------------------------

DELETE factura.pago
DELETE factura.factura_mensual

select * from factura.factura_mensual