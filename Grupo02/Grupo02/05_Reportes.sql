
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
-- REPORTE DE INGRESOS DE ACTIVIDADES (DESDE ENERO)
-----------------------------------------------------------------------------

DELETE factura.pago
DELETE factura.factura_mensual

select * from factura.factura_mensual