use Com5600G02
go

create or alter procedure socio.cargar_categoria
as
begin
	exec socio.insertar_categoria_socio
		@nombre = 'Cadete',
		@edad_min = 13,
		@edad_max = 17,
		@costo = 1500;
	exec socio.insertar_categoria_socio
		@nombre = 'Mayor',
		@edad_min = 18,
		@edad_max = 120,
		@costo = 2000;
	exec socio.insertar_categoria_socio
		@nombre = 'Menor',
		@edad_min = 0,
		@edad_max = 12,
		@costo = 1000;
end
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

exec socio.cargar_categoria;
exec factura.cargar_medio_de_pago;