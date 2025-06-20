use Com5600G02
go

create or alter procedure factura.cargar_medio_de_pago
as
begin
	exec factura.insertar_medio_de_pago
		@nombre = 'efectivo';
	exec factura.insertar_medio_de_pago
		@nombre = 'tarjeta credito';
	exec factura.insertar_medio_de_pago
		@nombre = 'transferencia';
end

go



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
 
            -- Lógica escalonada de montos por bloques
            SET @total = 
                CASE 
                    WHEN @nro_socio_num <= 4040 THEN 15000
                    WHEN @nro_socio_num <= 4080 THEN 20000
                    ELSE 22000
                END;
 
            INSERT INTO factura.factura_mensual (fecha_emision, fecha_vencimiento, estado, total, nro_socio)
            VALUES (@fecha_emision, @fecha_vencimiento, 'Pendiente', @total, @nro_socio);
 
            SET @mes = @mes + 1;
        END
 
        FETCH NEXT FROM cur_socios INTO @nro_socio;
    END
 
    CLOSE cur_socios;
    DEALLOCATE cur_socios;
 
    PRINT 'Facturas generadas para socios del rango SN-4001 a SN-4120.';
END;

go

exec socio.cargar_categoria;
exec factura.cargar_medio_de_pago;
EXEC factura.generar_facturas_mensuales @anio = 2024;