--El archivo .sql con el script debe incluir comentarios donde consten este enunciado, 
--la fecha de entrega,
--número de grupo, nombre de la materia, nombres y DNI de los alumnos. Entregar todo en un zip 
--(observar las pautas para nomenclatura antes expuestas) mediante la sección de prácticas de MIEL. 
--Solo uno de los miembros del grupo debe hacer la entrega

--

--Procedure insertar, modificar, eliminar factura.medio_De_pago
Create procedure factura.insertar_medio_de_pago (@nombre varchar(50)) as
BEGIN
	IF @nombre is NULL or ltrim(rtrim(@nombre)) = ''
		begin
			raiserror('Nombre invalido',16,1);
			return
		end
	insert into factura.medio_de_pago (nombre)
	values (@nombre)
END;
go
Create procedure factura.modificar_medio_de_pago (@nombre varchar(50), @id int) as
BEGIN
	IF @nombre is NULL or ltrim(rtrim(@nombre)) = ''
		begin
			raiserror('Nombre invalido',16,1);
			return
		end
	update factura.medio_de_pago 
	set nombre = @nombre 
	where id_medio_de_pago = @id
END;
go
Create procedure factura.eliminar_medio_de_pago (@id int) as
BEGIN
	IF @id is NULL
		begin
			raiserror('Id invalida',16,1);
			return
		end
	delete factura.medio_de_pago where id_medio_de_pago = @id
END;