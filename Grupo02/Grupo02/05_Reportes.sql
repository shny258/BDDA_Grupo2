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
use Com5600G02
go

CREATE OR ALTER PROCEDURE factura.morosos_recurrentes
(
    @fecha_inicio DATE,
    @fecha_fin DATE
)
AS
BEGIN
    SET NOCOUNT ON;

    WITH facturas_filtradas AS (
        SELECT 
            f.nro_socio,
            s.nombre,
            s.apellido,
            FORMAT(f.fecha_emision, 'yyyy-MM') AS mes_incumplido,
            ROW_NUMBER() OVER (PARTITION BY f.nro_socio, FORMAT(f.fecha_emision, 'yyyy-MM') ORDER BY f.fecha_emision) AS rn
        FROM factura.factura_mensual f
        JOIN socio.socio s ON f.nro_socio = s.nro_socio
        WHERE f.fecha_emision BETWEEN @fecha_inicio AND @fecha_fin
          AND f.estado IN ('Pendiente', 'Anulada')
    ),
    incumplimientos_mes AS (
        -- Una fila por socio y mes
        SELECT 
            nro_socio,
            nombre,
            apellido,
            mes_incumplido
        FROM facturas_filtradas
        WHERE rn = 1
    ),
    incumplimientos_totales AS (
        -- Total incumplimientos y ranking por socio
        SELECT
            nro_socio,
            COUNT(*) AS total_incumplimientos,
            RANK() OVER (ORDER BY COUNT(*) DESC) AS ranking_morosidad
        FROM incumplimientos_mes
        GROUP BY nro_socio
        HAVING COUNT(*) >= 2
    )
    SELECT 
        im.nro_socio,
        im.nombre,
        im.apellido,
        im.mes_incumplido,
        it.total_incumplimientos,
        it.ranking_morosidad
    FROM incumplimientos_mes im
    INNER JOIN incumplimientos_totales it ON im.nro_socio = it.nro_socio
    ORDER BY it.ranking_morosidad, im.nro_socio, im.mes_incumplido;
END;

	/*delete factura.pago
	delete factura.detalle_factura
	delete factura.factura_mensual

	EXEC factura.generar_factura_mensual @mes = 1, @anio = 2025, @nro_socio = 'SN-4131';
	EXEC factura.generar_factura_mensual @mes = 7, @anio = 2025, @nro_socio = 'SN-4031';
	EXEC factura.generar_factura_mensual @mes = 8, @anio = 2025, @nro_socio = 'SN-4031';

	EXEC factura.generar_factura_mensual @mes = 7, @anio = 2026, @nro_socio = 'SN-4022';
	EXEC factura.generar_factura_mensual @mes = 8, @anio = 2026, @nro_socio = 'SN-4022';	
	*/
--Exec factura.morosos_recurrentes @fecha_inicio = '2026-01-01',  @fecha_fin = '2026-12-01'
GO
-----------------------------------------------------------------------------
-- REPORTE DE INGRESOS DE ACTIVIDADES (DESDE ENERO)
-----------------------------------------------------------------------------
SELECT 
    a.nombre AS actividad,
    fm.fecha_emision AS mes,
    SUM(df.monto) AS ingreso_mes,
    SUM(SUM(df.monto)) OVER (
        PARTITION BY a.nombre 
        ORDER BY fm.fecha_emision
        ROWS UNBOUNDED PRECEDING
    ) AS ingreso_acumulado
FROM factura.detalle_factura df
JOIN factura.factura_mensual fm ON df.id_factura = fm.id_factura
JOIN actividad.actividad a ON df.id_actividad = a.id_actividad
WHERE df.id_actividad IS NOT NULL
GROUP BY a.nombre, fm.fecha_emision
ORDER BY a.nombre, mes;
-----------------------------------------------------------------------------
-- REPORTE DE SOCIOS AUSENTES EN SUS ACTIVIDADES
-----------------------------------------------------------------------------
SELECT 
    cat.nombre AS categoria,
    act.nombre AS actividad,
    COUNT(*) AS cantidad_inasistencias
FROM actividad.presentismo p
JOIN socio.socio s ON p.id_socio = s.id_socio
JOIN socio.categoria_socio cat ON s.id_categoria = cat.nombre
JOIN actividad.actividad act ON p.id_actividad = act.id_actividad
WHERE p.asistencia = 'A'
GROUP BY cat.nombre, act.nombre
ORDER BY cantidad_inasistencias DESC;

-----------------------------------------------------------------------------
-- REPORTE 4
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


/*SELECT
    a.nombre,
    SUM(CASE WHEN MONTH(df.fecha) = 1 THEN df.monto ELSE 0 END) AS Enero,
    SUM(CASE WHEN MONTH(df.fecha) = 2 THEN df.monto ELSE 0 END) AS Febrero,
    SUM(CASE WHEN MONTH(df.fecha) = 3 THEN df.monto ELSE 0 END) AS Marzo,
    SUM(CASE WHEN MONTH(df.fecha) = 4 THEN df.monto ELSE 0 END) AS Abril,
    SUM(CASE WHEN MONTH(df.fecha) = 5 THEN df.monto ELSE 0 END) AS Mayo,
    SUM(CASE WHEN MONTH(df.fecha) = 6 THEN df.monto ELSE 0 END) AS Junio,
    SUM(CASE WHEN MONTH(df.fecha) = 7 THEN df.monto ELSE 0 END) AS Julio,
  
    SUM(df.monto) AS Total_Anual
FROM factura.detalle_factura df
JOIN actividad.actividad a ON a.id_actividad = df.id_actividad
WHERE YEAR(df.fecha) = '2025' -- año actual
GROUP BY a.nombre
ORDER BY a.nombre;
*/


