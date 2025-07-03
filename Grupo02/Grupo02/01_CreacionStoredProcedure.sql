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
use Com5600G02;
go
-- ==========================================
-- Insertar Detalle Factura
-- ==========================================
CREATE or alter PROCEDURE factura.insertar_detalle_factura
(
    @id_factura INT,
    @id_membresia INT,
    @id_participante INT,
    @id_reserva INT,
    @monto NUMERIC(15,2),
    @fecha DATE,
	@id_actividad int
)
AS
BEGIN
    SET NOCOUNT ON;

    -- Validar existencia de la factura
    IF NOT EXISTS (SELECT 1 FROM factura.factura_mensual WHERE id_factura = @id_factura)
    OR
    (
        NOT EXISTS (SELECT 1 FROM actividad.participante_actividad_extra WHERE id_participante = @id_participante)
        AND NOT EXISTS (SELECT 1 FROM socio.membresia WHERE id_membresia = @id_membresia)
        AND NOT EXISTS (SELECT 1 FROM actividad.reserva_sum WHERE id_reserva = @id_reserva)
		AND NOT EXISTS (SELECT 1 FROM actividad.actividad WHERE id_actividad = @id_actividad)
    )
    BEGIN
        RAISERROR('Factura o alguno de los IDs (participante, membresía, reserva, actividad) no existe', 16, 1);
        RETURN;
    END

    -- Validar monto positivo
    IF @monto <= 0 
    BEGIN
        RAISERROR('El monto debe ser mayor que cero', 16, 1);
        RETURN;
    END

    -- Validar fecha no nula
    IF @fecha IS NULL 
    BEGIN
        RAISERROR('La fecha es nula', 16, 1);
        RETURN;
    END

    -- Insertar el detalle
    INSERT INTO factura.detalle_factura (id_factura, id_membresia, id_participante, id_reserva, monto, fecha, id_actividad)
    VALUES (@id_factura, @id_membresia, @id_participante, @id_reserva, @monto, @fecha, @id_actividad);
END;
GO


-- ==========================================
-- Eliminar Detalle Factura
-- ==========================================
Create or alter procedure factura.eliminar_detalle_factura (@id_detallefactura int) as
BEGIN
	--validaciones
	IF NOT EXISTS (SELECT 1 FROM factura.detalle_factura WHERE id_detallefactura = @id_detallefactura) BEGIN
        RAISERROR ('id no existe', 16, 1);
        RETURN;
    END
	--termina validacion
	delete factura.detalle_factura where id_detallefactura = @id_detallefactura
END;
go

-- ==========================================
-- Insertar Aplica Descuento
-- ==========================================
Create or alter procedure factura.insertar_aplica_descuento
(@id_descuento int, @id_detallefactura int) as
BEGIN
	--validaciones
	IF NOT EXISTS (SELECT 1 FROM factura.descuento WHERE id_descuento = @id_descuento) BEGIN
        RAISERROR ('id no existe', 16, 1);
        RETURN;
    END
	IF NOT EXISTS (SELECT 1 FROM factura.detalle_factura WHERE id_detallefactura = @id_detallefactura) BEGIN
        RAISERROR ('id no existe', 16, 1);
        RETURN;
    END
	--termina validacion
	insert into factura.aplica_descuento(id_descuento, id_detallefactura)
	values (@id_descuento, @id_detallefactura)
END;
go

-- ==========================================
-- Eliminar Aplica Descuento
-- ==========================================
Create or alter procedure factura.eliminar_aplica_descuento (@id_descuento int, @id_detallefactura int) as
BEGIN
	--validaciones
	IF NOT EXISTS (SELECT 1 FROM factura.descuento WHERE id_descuento = @id_descuento) or
	NOT EXISTS (SELECT 1 FROM factura.detalle_factura WHERE id_detallefactura = @id_detallefactura) BEGIN
        RAISERROR ('id no existe', 16, 1);
        RETURN;
    END
	--termina validacion
	delete factura.aplica_descuento where id_descuento = @id_descuento and id_detallefactura = @id_detallefactura
END;
go

-- ==========================================
-- Insertar Medio de Pago
-- ==========================================
Create or alter procedure factura.insertar_medio_de_pago (@nombre varchar(50)) as
BEGIN
	--validaciones
	IF @nombre is NULL or ltrim(rtrim(@nombre)) = ''
		begin
			raiserror('Nombre invalido',16,1);
			return
		end
	--termina validacion
	insert into factura.medio_de_pago (nombre)
	values (@nombre)
END;
go

-- ==========================================
-- Modificar Medio de Pago
-- ==========================================
Create or alter procedure factura.modificar_medio_de_pago (@nombre varchar(50), @id int) as
BEGIN
	--validaciones
	IF @nombre is NULL or ltrim(rtrim(@nombre)) = ''
		begin
			raiserror('Nombre invalido',16,1);
			return
		end
	--termina validacion
	update factura.medio_de_pago 
	set nombre = @nombre 
	where id_medio_de_pago = @id
END;
go

-- ==========================================
-- Elimianr Medio de Pago
-- ==========================================
Create or alter procedure factura.eliminar_medio_de_pago (@id int) as
BEGIN
	--validaciones
	IF @id is NULL
		begin
			raiserror('Id invalida',16,1);
			return
		end
	--termina validacion
	IF @id <= 0 
    BEGIN
        RAISERROR('El id debe ser mayor que cero', 16, 1);
        RETURN;
    END
	delete factura.medio_de_pago where id_medio_de_pago = @id
END;
go

-- ==========================================
-- Insertar Descuento
-- ==========================================
Create or alter procedure factura.insertar_descuento
(@nombre nvarchar(50), @porcentaje numeric(5,2)) as
BEGIN
	--validaciones
	IF @nombre is NULL or ltrim(rtrim(@nombre)) = ''
	begin
		raiserror('nombre invalido',16,1);
		return
	end
	IF @porcentaje is NULL or @porcentaje <= 0
	begin
		raiserror('porcentaje invalido',16,1);
		return
	end
	--termina validacion
	insert into factura.descuento (nombre, porcentaje)
	values (@nombre, @porcentaje)
END;
go

-- ==========================================
-- Modificar Descuento
-- ==========================================
Create or alter procedure factura.modificar_descuento
(@id_descuento int, @nombre nvarchar(50), @porcentaje numeric(5,2)) as
BEGIN
	--validaciones
	IF @id_descuento is NULL
	begin
		raiserror('id invalido.',16,1);
		return
	end
	IF NOT EXISTS (SELECT 1 FROM factura.descuento WHERE id_descuento = @id_descuento) BEGIN
        RAISERROR ('id no existe', 16, 1);
        RETURN;
    END
	IF @porcentaje is NULL or @porcentaje <= 0
	begin
		raiserror('porcentaje invalido',16,1);
		return
	end
	IF @nombre is NULL or ltrim(rtrim(@nombre)) = ''
	begin
		raiserror('nombre invalido',16,1);
		return
	end
	--termina validacion
	update factura.descuento
	set nombre = @nombre, porcentaje = @porcentaje
	where id_descuento = @id_descuento
END;
go

-- ==========================================
-- Eliminar Descuento
-- ==========================================
Create or alter procedure factura.eliminar_descuento (@id int) as
BEGIN
	--validaciones
	IF @id is NULL
		begin
			raiserror('Id invalida',16,1);
			return
		end
	IF NOT EXISTS (SELECT 1 FROM factura.descuento WHERE id_descuento = @id) BEGIN
        RAISERROR ('id no existe', 16, 1);
        RETURN;
    END
	--termina validacion
	delete factura.descuento where id_descuento = @id
END;
go

-- ==========================================
-- Insertar Factura Mensual
-- ==========================================
CREATE OR ALTER PROCEDURE factura.generar_factura_mensual
    (@mes INT,
    @anio INT,
    @nro_socio VARCHAR(10))
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @total NUMERIC(15,2) = 0;
    DECLARE @id_factura INT;
    DECLARE @id_grupo INT;
    DECLARE @fecha_emision DATE = GETDATE();

    -- Obtener socio real para facturar (si tiene responsable, usar responsable)
    DECLARE @nro_socio_facturar VARCHAR(10);

    SELECT @nro_socio_facturar = 
        CASE WHEN nro_socio_rp IS NOT NULL AND nro_socio_rp <> ''
             THEN nro_socio_rp
             ELSE nro_socio
        END
    FROM socio.socio
    WHERE nro_socio = @nro_socio;

    IF @nro_socio_facturar IS NULL
    BEGIN
        RAISERROR('Socio no encontrado.', 16, 1);
        RETURN;
    END

    -- Validar existencia previa de factura para socio responsable
    IF EXISTS (
        SELECT 1 FROM factura.factura_mensual
        WHERE MONTH(fecha_emision) = @mes AND YEAR(fecha_emision) = @anio AND nro_socio = @nro_socio_facturar
    )
    BEGIN
        RAISERROR('Ya existe factura para ese socio responsable en ese mes/año.', 16, 1);
        RETURN;
    END

			-- Obtener grupo familiar del socio responsable (puede ser NULL)
		SELECT @id_grupo = id_grupo_familiar FROM socio.socio WHERE nro_socio = @nro_socio_facturar;
 
		-- Crear tabla de socios a facturar
		DECLARE @socios TABLE (id_socio INT);
 
		IF @id_grupo IS NOT NULL
		BEGIN
			-- Facturar a todos los del grupo
			INSERT INTO @socios (id_socio)
			SELECT id_socio FROM socio.socio WHERE id_grupo_familiar = @id_grupo;
		END
		ELSE
		BEGIN
			-- Facturar solo al socio individual
			INSERT INTO @socios (id_socio)
			SELECT id_socio FROM socio.socio WHERE nro_socio = @nro_socio_facturar;
		END

    -- Insertar factura a nombre del socio responsable
    INSERT INTO factura.factura_mensual (
        fecha_emision, fecha_vencimiento, segunda_fecha_vencimiento,
        estado, total, nro_socio
    )
    VALUES (
        @fecha_emision,
        DATEFROMPARTS(@anio, @mes, 10),
        DATEFROMPARTS(@anio, @mes, 20),
        'Pendiente',
        0,
        @nro_socio_facturar
    );

    SET @id_factura = SCOPE_IDENTITY();

    -- Insertar detalles por categoría y actividades para todo el grupo familiar
    -- ... (el resto del SP sigue igual, usando @socios y @id_factura)
    -- (usa la misma lógica que ya tenías para insertar detalles y calcular total)
    
    -- Insertar detalles por categoría
    INSERT INTO factura.detalle_factura (
        id_factura, id_membresia, id_participante, id_reserva, monto, fecha, id_socio, id_actividad
    )
    SELECT
        @id_factura,
        NULL, NULL, NULL,
        cs.costo,
        @fecha_emision,
        s.id_socio,
        NULL
    FROM @socios s
    JOIN socio.socio so ON s.id_socio = so.id_socio
    JOIN socio.categoria_socio cs ON so.id_categoria = cs.nombre;

    -- Insertar detalles por actividades
    INSERT INTO factura.detalle_factura (
        id_factura, id_membresia, id_participante, id_reserva, monto, fecha, id_socio, id_actividad
    )
    SELECT
        @id_factura,
        NULL, NULL, NULL,
        a.costo_mensual,
        @fecha_emision,
        s.id_socio,
        a.id_actividad
    FROM @socios s
    JOIN actividad.inscripcion_actividad ia ON s.id_socio = ia.id_socio
    JOIN actividad.actividad a ON ia.id_actividad = a.id_actividad
    WHERE ia.fecha_inscripcion <= DATEFROMPARTS(@anio, @mes, 31);

    -- Calcular total
    SELECT @total = SUM(monto)
    FROM factura.detalle_factura
    WHERE id_factura = @id_factura;

    UPDATE factura.factura_mensual
    SET total = @total
    WHERE id_factura = @id_factura;
END;
go
/*
EXEC factura.generar_factura_mensual @mes = 5, @anio = 2025, @nro_socio = 'SN-4153';
select * from socio.socio
SELECT * 
FROM factura.factura_mensual 
WHERE nro_socio = 'SN-4046' 
  AND MONTH(fecha_emision) = 6 
  AND YEAR(fecha_emision) = 2025;
  SELECT * 
FROM factura.detalle_factura 
WHERE id_factura = 1;
*/
-- ==========================================
-- Modificar Factura Mensual
-- ==========================================
Create or alter procedure factura.modificar_factura_mensual 
(@id int, @fecha_emision date, @fecha_vencimiento date, @estado varchar(20), @total numeric(15,2)) as
BEGIN
	--validaciones
	IF @id is NULL
	begin
		raiserror('id invalido.',16,1);
		return
	end
	IF NOT EXISTS (SELECT 1 FROM factura.factura_mensual WHERE id_factura = @id) BEGIN
        RAISERROR ('id no existe', 16, 1);
        RETURN;
    END
	--termina validacion
	update factura.factura_mensual
	set fecha_emision = @fecha_emision, fecha_vencimiento = @fecha_vencimiento, estado = @estado, total = @total
	where id_factura = @id
END;
go

-- ==========================================
-- Eliminar Factura Mensual
-- ==========================================
Create or alter procedure factura.eliminicar_factura_mensual (@id int) as
BEGIN
	--validaciones
	IF @id is NULL
		begin
			raiserror('Id invalida',16,1);
			return
		end
	IF NOT EXISTS (SELECT 1 FROM factura.factura_mensual WHERE id_factura = @id) BEGIN
        RAISERROR ('id no existe', 16, 1);
        RETURN;
    END
	--termina validacion
	delete factura.medio_de_pago where id_medio_de_pago = @id
END;
go

-- ==========================================
-- Insertar Pago
-- ==========================================
CREATE OR ALTER PROCEDURE factura.insertar_pago
(
    @id_factura INT,
    @id_medio_de_pago INT,
    @tipo_pago VARCHAR(20),
    @fecha_pago DATE,
    @monto NUMERIC(15,2),
    @nro_socio VARCHAR(10) 
)
AS
BEGIN
    SET NOCOUNT ON;

    

    IF @id_factura IS NULL
    BEGIN
        RAISERROR('id_factura es NULL: no se encontró factura válida', 16, 1);
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM factura.factura_mensual WHERE id_factura = @id_factura)
    BEGIN
        RAISERROR('id_factura no existe', 16, 1);
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM factura.medio_de_pago WHERE id_medio_de_pago = @id_medio_de_pago)
    BEGIN
        RAISERROR('id_medio_de_pago no existe', 16, 1);
        RETURN;
    END

    IF @fecha_pago IS NULL
    BEGIN
        RAISERROR('Fecha inválida', 16, 1);
        RETURN;
    END

    IF @tipo_pago IS NULL OR LTRIM(RTRIM(@tipo_pago)) = ''
    BEGIN
        RAISERROR('tipo_pago inválido', 16, 1);
        RETURN;
    END

    IF @monto <= 0
    BEGIN
        RAISERROR('Monto debe ser mayor que cero', 16, 1);
        RETURN;
    END

    -- Validar duplicado
    IF EXISTS (
        SELECT 1
        FROM factura.pago
        WHERE id_factura = @id_factura
          AND id_medio_de_pago = @id_medio_de_pago
          AND tipo_pago = @tipo_pago
          AND fecha_pago = @fecha_pago
          AND monto = @monto
    )
    BEGIN
        RAISERROR('Pago duplicado detectado, no se inserta.', 16, 1);
        RETURN;
    END

    -- Finalmente insertamos incluyendo nro_socio
    INSERT INTO factura.pago (id_factura, id_medio_de_pago, tipo_pago, fecha_pago, monto, nro_socio)
    VALUES (@id_factura, @id_medio_de_pago, @tipo_pago, @fecha_pago, @monto, @nro_socio);
END;
GO


-- ==========================================
-- Modificar Pago
-- ==========================================
CREATE or alter PROCEDURE factura.modificar_pago 
(
    @id_pago INT,
    @id_factura INT,
    @id_medio_de_pago INT,
    @tipo_pago VARCHAR(20),
    @fecha_pago DATE
)
AS
BEGIN
    SET NOCOUNT ON;

    -- Validar id_pago
    IF @id_pago IS NULL OR @id_pago <= 0
    BEGIN
        RAISERROR('ID pago inválido', 16, 1);
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM factura.pago WHERE id_pago = @id_pago)
    BEGIN
        RAISERROR('ID pago no existe', 16, 1);
        RETURN;
    END

    -- Validar existencia factura
    IF NOT EXISTS (SELECT 1 FROM factura.factura_mensual WHERE id_factura = @id_factura)
    BEGIN
        RAISERROR('ID factura no existe', 16, 1);
        RETURN;
    END

    -- Validar existencia medio de pago
    IF NOT EXISTS (SELECT 1 FROM factura.medio_de_pago WHERE id_medio_de_pago = @id_medio_de_pago)
    BEGIN
        RAISERROR('ID medio de pago no existe', 16, 1);
        RETURN;
    END

    -- Validar fecha
    IF @fecha_pago IS NULL
    BEGIN
        RAISERROR('Fecha invalido', 16, 1);
        RETURN;
    END

    -- Validar tipo_pago
    IF @tipo_pago IS NULL OR LTRIM(RTRIM(@tipo_pago)) = ''
    BEGIN
        RAISERROR('Tipo de pago invalido', 16, 1);
        RETURN;
    END

    -- Actualizar registro
    UPDATE factura.pago
    SET id_factura = @id_factura,
        id_medio_de_pago = @id_medio_de_pago,
        tipo_pago = @tipo_pago,
        fecha_pago = @fecha_pago
    WHERE id_pago = @id_pago;
END;
GO


-- ==========================================
-- Eliminar Pago
-- ==========================================
Create or alter procedure factura.eliminicar_pago (@id int) as
BEGIN
	
	IF @id is NULL
		begin
			raiserror('Id invalida',16,1);
			return
		end
	IF NOT EXISTS (SELECT 1 FROM factura.pago WHERE id_pago = @id) BEGIN
        RAISERROR ('id no existe', 16, 1);
        RETURN;
    END
	
	delete factura.pago where id_pago = @id
END;
go

-- ==========================================
-- Insertar Socio
-- ==========================================
CREATE OR ALTER PROCEDURE socio.insertar_socio
    @nro_socio VARCHAR(10),
    @dni VARCHAR(15),
    @nombre VARCHAR(50),
    @apellido VARCHAR(50),
    @email VARCHAR(100),
    @fecha_nacimiento DATE,
    @telefono_contacto VARCHAR(20),
    @telefono_emergencia VARCHAR(20),
    @cobertura_medica VARCHAR(100),
    @nro_cobertura_medica VARCHAR(50),
    @id_medio_de_pago INT,
    @id_grupo_familiar INT = NULL,
    @nro_socio_rp VARCHAR(10),
    @categoria_ingresada VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @edad INT;
    DECLARE @categoria_rp VARCHAR(50);
    DECLARE @id_grupo_responsable INT;

    -- Validar categoría exactamente con capitalización esperada
    IF @categoria_ingresada NOT IN ('Menor', 'Cadete', 'Mayor', 'Responsable')
    BEGIN
        RAISERROR('La categoria ingresada no es valida', 16, 1);
        RETURN;
    END

    -- Calcular edad exacta
    SET @edad = DATEDIFF(YEAR, @fecha_nacimiento, GETDATE());
    IF DATEADD(YEAR, @edad, @fecha_nacimiento) > GETDATE()
        SET @edad = @edad - 1;

    -- Validaciones de edad según categoría
    IF @categoria_ingresada = 'Menor' AND @edad > 12
    BEGIN
        RAISERROR('La edad no corresponde a la categoría Menor', 16, 1);
        RETURN;
    END
    ELSE IF @categoria_ingresada = 'Cadete' AND (@edad < 13 OR @edad > 17)
    BEGIN
        RAISERROR('La edad no corresponde a la categoría Cadete', 16, 1);
        RETURN;
    END
    ELSE IF @categoria_ingresada = 'Mayor' AND @edad < 18
    BEGIN
        RAISERROR('La edad no corresponde a la categoría Mayor', 16, 1);
        RETURN;
    END
    ELSE IF @categoria_ingresada = 'Responsable' AND @edad < 18
    BEGIN
        RAISERROR('Un socio Responsable debe tener al menos 18 años', 16, 1);
        RETURN;
    END

    -- Validación si el socio es Menor o Cadete
    IF @categoria_ingresada IN ('Menor', 'Cadete')
    BEGIN
        IF @nro_socio_rp IS NULL OR LTRIM(RTRIM(@nro_socio_rp)) = ''
        BEGIN
            RAISERROR('El socio Menor o Cadete debe tener un socio responsable asignado', 16, 1);
            RETURN;
        END

        -- Buscar datos del responsable
        SELECT 
            @categoria_rp = id_categoria,
            @id_grupo_responsable = id_grupo_familiar
        FROM socio.socio
        WHERE nro_socio = @nro_socio_rp;

        IF @categoria_rp IS NULL
        BEGIN
            RAISERROR('El socio responsable indicado no existe', 16, 1);
            RETURN;
        END

        IF @categoria_rp NOT IN ('Mayor', 'Responsable')
        BEGIN
            RAISERROR('El socio responsable debe ser de categoría Mayor o Responsable', 16, 1);
            RETURN;
        END

        -- Obtener edad del responsable para asegurarse que tiene 18+
        DECLARE @edad_resp INT;
        SELECT @edad_resp = DATEDIFF(YEAR, fecha_nacimiento, GETDATE())
        FROM socio.socio
        WHERE nro_socio = @nro_socio_rp;

        IF DATEADD(YEAR, @edad_resp, (SELECT fecha_nacimiento FROM socio.socio WHERE nro_socio = @nro_socio_rp)) > GETDATE()
            SET @edad_resp = @edad_resp - 1;

        IF @edad_resp < 18
        BEGIN
            RAISERROR('El socio responsable debe tener al menos 18 años', 16, 1);
            RETURN;
        END

        -- Si el responsable no tiene grupo, crear uno y asignarlo
        IF @id_grupo_responsable IS NULL
        BEGIN
            INSERT INTO socio.grupo_familiar (fecha_creacion)
            VALUES (GETDATE());

            SET @id_grupo_responsable = SCOPE_IDENTITY();

            UPDATE socio.socio
            SET id_grupo_familiar = @id_grupo_responsable
            WHERE nro_socio = @nro_socio_rp;
        END

        -- Asignar al nuevo socio el grupo del responsable
        SET @id_grupo_familiar = @id_grupo_responsable;
    END

    -- Insertar el nuevo socio
    INSERT INTO socio.socio (
        nro_socio, dni, nombre, apellido, email, fecha_nacimiento, 
        telefono_contacto, telefono_emergencia, cobertura_medica, 
        nro_cobertura_medica, id_medio_de_pago, id_grupo_familiar, id_categoria, nro_socio_rp
    )
    VALUES (
        @nro_socio, @dni, @nombre, @apellido, @email, @fecha_nacimiento, 
        @telefono_contacto, @telefono_emergencia, @cobertura_medica, 
        @nro_cobertura_medica, @id_medio_de_pago, @id_grupo_familiar, @categoria_ingresada, @nro_socio_rp
    );
END;

go
-- ==========================================
-- Modificar Socio
-- ==========================================
CREATE or alter PROCEDURE socio.modificar_socio
    @id_socio INT,
    @email VARCHAR(100),
    @telefono_contacto VARCHAR(20),
    @telefono_emergencia VARCHAR(20),
    @cobertura_medica VARCHAR(100),
    @nro_cobertura_medica VARCHAR(50),
    @id_medio_de_pago INT,
    @id_grupo_familiar INT,
    @id_categoria VARCHAR(50)
AS
BEGIN
	--validaciones
    IF NOT EXISTS (SELECT 1 FROM socio.socio WHERE id_socio = @id_socio) BEGIN
        RAISERROR ('El socio no existe', 16, 1);
        RETURN;
    END
	--termina validacion
    UPDATE socio.socio
    SET email = @email,
        telefono_contacto = @telefono_contacto,
        telefono_emergencia = @telefono_emergencia,
        cobertura_medica = @cobertura_medica,
        nro_cobertura_medica = @nro_cobertura_medica,
        id_medio_de_pago = @id_medio_de_pago,
        id_grupo_familiar = @id_grupo_familiar,
        id_categoria = @id_categoria
    WHERE id_socio = @id_socio;
END;
GO

-- ==========================================
-- Eliminar Socio
-- ==========================================
CREATE or alter PROCEDURE socio.eliminar_socio
    @id_socio INT
AS
BEGIN
	--validaciones
    IF NOT EXISTS (SELECT 1 FROM socio.socio WHERE id_socio = @id_socio) BEGIN
        RAISERROR ('El socio no existe', 16, 1);
        RETURN;
    END
	--termina validacion
    DELETE FROM socio.socio WHERE id_socio = @id_socio;
END;
GO

-- ==========================================
-- Insertar Cuenta
-- ==========================================
CREATE or alter PROCEDURE socio.insertar_cuenta
    @usuario VARCHAR(50),
    @contrasenia VARCHAR(50),
    @rol VARCHAR(50),
    @fecha_vigencia_contrasenia DATE
AS
BEGIN
	--validaciones
    IF LEN(@usuario) = 0 BEGIN
        RAISERROR ('El nombre de usuario no puede estar vacio', 16, 1);
        RETURN;
    END
    IF LEN(@contrasenia) < 10 BEGIN
        RAISERROR ('la contraseña debe tener al menos 10 caracteres', 16, 1);
        RETURN;
    END
    IF @rol NOT IN ('administrador', 'empleado', 'socio') BEGIN
        RAISERROR ('Rol inválido. Debe ser "administrador", "empleado" o "socio"', 16, 1);
        RETURN;
    END
    IF @fecha_vigencia_contrasenia IS NULL BEGIN
        RAISERROR ('Debe especificar la fecha de vigencia de la contraseña', 16, 1);
        RETURN;
    END
	--termina validacion
    INSERT INTO socio.cuenta (usuario, contrasenia, rol, fecha_vigencia_contrasenia)
    VALUES (@usuario, @contrasenia, @rol, @fecha_vigencia_contrasenia);
END;
GO

-- ==========================================
-- Modificar Cuenta
-- ==========================================
CREATE or alter PROCEDURE socio.modificar_cuenta
    @id_usuario INT,
    @contrasenia VARCHAR(255),
    @rol VARCHAR(50),
    @fecha_vigencia_contrasenia DATE
AS
BEGIN
	--validaciones
    IF NOT EXISTS (SELECT 1 FROM socio.cuenta WHERE id_usuario = @id_usuario) BEGIN
        RAISERROR ('La cuenta no existe', 16, 1);
        RETURN;
    END
    IF LEN(@contrasenia) < 10 BEGIN
        RAISERROR ('la contraseña debe tener al menos 10 caracteres', 16, 1);
        RETURN;
    END
    IF @rol NOT IN ('administrador', 'empleado', 'socio') BEGIN
        RAISERROR ('Rol invalido. Debe ser "administrador", "empleado" o "socio"', 16, 1);
        RETURN;
    END
    IF @fecha_vigencia_contrasenia IS NULL BEGIN
        RAISERROR ('Debe especificar la fecha de vigencia de la contraseña', 16, 1);
        RETURN;
    END
	--termina validacion
    UPDATE socio.cuenta
    SET contrasenia = @contrasenia,
        rol = @rol,
        fecha_vigencia_contrasenia = @fecha_vigencia_contrasenia
    WHERE id_usuario = @id_usuario;
END;
GO

-- ==========================================
-- Eliminar Cuenta
-- ==========================================
CREATE or alter PROCEDURE socio.eliminar_cuenta
    @id_usuario INT
AS
BEGIN
	--validaciones
    IF NOT EXISTS (SELECT 1 FROM socio.cuenta WHERE id_usuario = @id_usuario) BEGIN
        RAISERROR ('La cuenta no existe', 16, 1);
        RETURN;
    END
	--termina validacion
    DELETE FROM socio.cuenta WHERE id_usuario = @id_usuario;
END;
GO

-- ==========================================
-- Insertar Grupo Familiar
-- ==========================================
CREATE or alter PROCEDURE socio.insertar_grupo_familiar
    @nombre VARCHAR(50),
    @apellido VARCHAR(50),
    @dni VARCHAR(10),
    @email VARCHAR(50),
    @fecha_nacimiento DATE,
    @telefono VARCHAR(20),
    @parentesco VARCHAR(50)
AS
BEGIN
	--validaciones
    IF LEN(@dni) < 7 BEGIN
        RAISERROR('El DNI debe tener al menos 7 caracteres', 16, 1);
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM socio.grupo_familiar WHERE dni = @dni) BEGIN
        RAISERROR('El DNI ya está registrado', 16, 1);
        RETURN;
    END
	--termina validacion
    INSERT INTO socio.grupo_familiar (
        nombre, apellido, dni, email, fecha_nacimiento, telefono, parentesco
    )
    VALUES (
        @nombre, @apellido, @dni, @email, @fecha_nacimiento, @telefono, @parentesco
    );
END;
GO

-- ==========================================
-- Modificar grupo familiar
-- ==========================================
CREATE or alter PROCEDURE socio.modificar_grupo_familiar
    @id_grupo_familiar INT,
    @email VARCHAR(50),
    @telefono VARCHAR(20),
    @parentesco VARCHAR(50)
AS
BEGIN
	
    IF NOT EXISTS (SELECT 1 FROM socio.grupo_familiar WHERE id_grupo_familiar = @id_grupo_familiar) BEGIN
        RAISERROR('El grupo familiar no existe', 16, 1);
        RETURN;
    END
	
    UPDATE socio.grupo_familiar
    SET email = @email,
        telefono = @telefono,
        parentesco = @parentesco
    WHERE id_grupo_familiar = @id_grupo_familiar;
END;
GO

-- ==========================================
-- Eliminar grupo familiar
-- ==========================================
CREATE or alter PROCEDURE socio.eliminar_grupo_familiar
    @id_grupo_familiar INT
AS
BEGIN
	
    IF NOT EXISTS (SELECT 1 FROM socio.grupo_familiar WHERE id_grupo_familiar = @id_grupo_familiar) BEGIN
        RAISERROR('El grupo familiar no existe', 16, 1);
        RETURN;
    END

    DELETE FROM socio.grupo_familiar
    WHERE id_grupo_familiar = @id_grupo_familiar;
END;
GO

-- ==========================================
-- Insertar membresía
-- ==========================================
CREATE or alter PROCEDURE socio.insertar_membresia
    @id_socio INT,
    @fecha_inicio DATE,
    @fecha_renovada DATE,
    @fecha_fin DATE,
    @costo NUMERIC(15,2)
AS
BEGIN
  
    IF NOT EXISTS (SELECT 1 FROM socio.socio WHERE id_socio = @id_socio) BEGIN
        RAISERROR('El socio no existe', 16, 1);
        RETURN;
    END
    IF @fecha_renovada < @fecha_inicio BEGIN
        RAISERROR('La fecha de renovación no puede ser anterior a la fecha de inicio', 16, 1);
        RETURN;
    END
    IF @fecha_fin < @fecha_renovada BEGIN
        RAISERROR('La fecha de fin no puede ser anterior a la fecha de renovación', 16, 1);
        RETURN;
    END
    IF @costo <= 0 BEGIN
        RAISERROR('El costo debe ser mayor a cero', 16, 1);
        RETURN;
    END
	--termina validacion
    INSERT INTO socio.membresia (id_socio, fecha_inicio, fecha_renovada, fecha_fin, costo)
    VALUES (@id_socio, @fecha_inicio, @fecha_renovada, @fecha_fin, @costo);
END;
GO

-- ==========================================
-- Modificar membresía
-- ==========================================
CREATE or alter PROCEDURE socio.modificar_membresia
    @id_membresia INT,
    @fecha_renovada DATE,
    @fecha_fin DATE,
    @costo NUMERIC(15,2)
AS
BEGIN
   
    IF NOT EXISTS (SELECT 1 FROM socio.membresia WHERE id_membresia = @id_membresia) BEGIN
        RAISERROR('La membresia no existe', 16, 1);
        RETURN;
    END

    DECLARE @fecha_inicio DATE;
    SELECT @fecha_inicio = fecha_inicio FROM socio.membresia WHERE id_membresia = @id_membresia;

    IF @fecha_renovada < @fecha_inicio BEGIN
        RAISERROR('La fecha de renovación no puede ser anterior a la fecha de inicio', 16, 1);
        RETURN;
    END
    IF @fecha_fin < @fecha_renovada BEGIN
        RAISERROR('La fecha de fin no puede ser anterior a la fecha de renovacion', 16, 1);
        RETURN;
    END
    IF @costo <= 0 BEGIN
        RAISERROR('El costo debe ser mayor a cero', 16, 1);
        RETURN;
    END
	
    UPDATE socio.membresia
    SET fecha_renovada = @fecha_renovada,
        fecha_fin = @fecha_fin,
        costo = @costo
    WHERE id_membresia = @id_membresia;
END;
GO

-- ==========================================
-- Eliminar membresía
-- ==========================================
CREATE or alter PROCEDURE socio.eliminar_membresia
    @id_membresia INT
AS
BEGIN
	
    IF NOT EXISTS (SELECT 1 FROM socio.membresia WHERE id_membresia = @id_membresia) BEGIN
        RAISERROR('La membresia no existe', 16, 1);
        RETURN;
    END
	
    DELETE FROM socio.membresia WHERE id_membresia = @id_membresia;
END;
GO

-- ==========================================
-- Insertar categoría de socio
-- ==========================================
CREATE or alter PROCEDURE socio.insertar_categoria_socio
    @nombre VARCHAR(50),
    @costo INT,
	@fecha_vigencia date
AS
BEGIN
	
    IF @costo <= 0 BEGIN
        RAISERROR('El costo debe ser mayor a cero', 16, 1);
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM socio.categoria_socio WHERE nombre = @nombre) BEGIN
        RAISERROR('La categoria ya existe', 16, 1);
        RETURN;
    END
	
    INSERT INTO socio.categoria_socio (nombre, fecha_vigencia, costo)
    VALUES (@nombre, @fecha_vigencia, @costo);
END;
GO

-- ==========================================
-- Modificar categoría de socio
-- ==========================================
CREATE or alter PROCEDURE socio.modificar_categoria_socio
    @nombre VARCHAR(50),
	@fecha_vigencia date,
    @costo INT
AS
BEGIN
	
    IF @costo <= 0 BEGIN
        RAISERROR('El costo debe ser mayor a cero', 16, 1);
        RETURN;
    END
	
    UPDATE socio.categoria_socio
    SET fecha_vigencia = @fecha_vigencia,
        costo = @costo
    WHERE nombre = @nombre;
END;
GO

-- ==========================================
-- Eliminar categoría de socio
-- ==========================================
CREATE or alter PROCEDURE socio.eliminar_categoria_socio
    @nombre VARCHAR(50)
AS
BEGIN
	
    IF NOT EXISTS (SELECT 1 FROM socio.categoria_socio WHERE nombre = @nombre) BEGIN
        RAISERROR('La categoria no existe', 16, 1);
        RETURN;
    END
	
    DELETE FROM socio.categoria_socio WHERE nombre = @nombre;
END;
GO


-- ==========================================
--   INSERTAR ACTIVIDAD
-- ==========================================
CREATE or alter PROCEDURE actividad.insertar_actividad
    @nombre VARCHAR(50),
    @costo_mensual NUMERIC(15,2),
	@fecha_vigencia date
AS
BEGIN
	
	IF @costo_mensual is NULL or @costo_mensual < 0
	begin
		raiserror('Costo invalido',16,1);
		return
	end
	
    INSERT INTO actividad.actividad (nombre, costo_mensual, fecha_vigencia)
    VALUES (@nombre, @costo_mensual, @fecha_vigencia);
END;
GO

-- ==========================================
--  MODIFICAR ACTIVIDAD
-- ==========================================
CREATE or alter PROCEDURE actividad.modificar_actividad
    @id INT,
    @nombre VARCHAR(50),
    @costo_mensual NUMERIC(15,2),
	@fecha_vigencia DATE
AS
BEGIN
	
    IF NOT EXISTS (SELECT 1 FROM actividad.actividad WHERE id_actividad = @id)
    BEGIN
        RAISERROR('Actividad no encontrada', 16, 1);
        RETURN;
    END
	IF @costo_mensual is NULL or @costo_mensual < 0
	begin
		raiserror('Costo invalido',16,1);
		return
	end
	
    UPDATE actividad.actividad
    SET nombre = @nombre, costo_mensual = @costo_mensual, fecha_vigencia = @fecha_vigencia
    WHERE id_actividad = @id;
END;
GO
-- ==========================================
--  ELIMINAR ACTIVIDAD
-- ==========================================
CREATE or alter PROCEDURE actividad.eliminar_actividad
    @id INT
AS
BEGIN
	
    IF NOT EXISTS (SELECT 1 FROM actividad.actividad WHERE id_actividad = @id)
    BEGIN
        RAISERROR('Actividad no encontrada', 16, 1);
        RETURN;
    END
	
    DELETE FROM actividad.actividad WHERE id_actividad = @id;
END;
GO
-- ==========================================
-- INSERTAR ACTIVIDAD EXTRA
-- ==========================================
CREATE or alter PROCEDURE actividad.insertar_actividad_extra
    @nombre VARCHAR(50),
    @costo_socio NUMERIC(15,2),
    @costo_invitado NUMERIC(15,2),
	@fecha_vigencia date
AS
BEGIN
	
    IF  @costo_socio < 0
    BEGIN
        RAISERROR('Costo de socio invalido', 16, 1);
        RETURN;
    END

    IF @costo_invitado < 0
    BEGIN
        RAISERROR('Costo de invitado invalido', 16, 1);
        RETURN;
    END

    INSERT INTO actividad.actividad_extra (nombre, costo_socio, costo_invitado, fecha_vigencia)
    VALUES (@nombre, @costo_socio, @costo_invitado, @fecha_vigencia);
END;
GO
-- ==========================================
--MODIFICAR ACTIVIDAD EXTRA
-- ==========================================
CREATE or alter PROCEDURE actividad.modificar_actividad_extra
    @id INT,
    @nombre VARCHAR(50),
    @costo_socio NUMERIC(15,2),
    @costo_invitado NUMERIC(15,2),
	@fecha_vigencia date
AS
BEGIN
	
    IF NOT EXISTS (SELECT 1 FROM actividad.actividad_extra WHERE id_actividad_extra = @id)
    BEGIN
        RAISERROR('Actividad extra no encontrada', 16, 1);
        RETURN;
    END

    IF  @costo_socio < 0
    BEGIN
        RAISERROR('Costo de socio invalido', 16, 1);
        RETURN;
    END

    IF @costo_invitado < 0
    BEGIN
        RAISERROR('Costo de invitado invalido', 16, 1);
        REturn
	end
	
    UPDATE actividad.actividad_extra
    SET nombre = @nombre,
        costo_socio = @costo_socio,
        costo_invitado = @costo_invitado,
		fecha_vigencia = @fecha_vigencia
    WHERE id_actividad_extra = @id;
END;
GO
-- ==========================================
-- ELIMINAR ACTIVIDAD EXTRA
-- ==========================================
CREATE or alter PROCEDURE actividad.eliminar_actividad_extra
    @id INT
AS
BEGIN
	
    IF NOT EXISTS (SELECT 1 FROM actividad.actividad_extra WHERE id_actividad_extra = @id)
    BEGIN
        RAISERROR('Actividad extra no encontrada', 16, 1);
        RETURN;
    END
	
    DELETE FROM actividad.actividad_extra
    WHERE id_actividad_extra = @id;
END;
GO

-- ==========================================
-- INSERTAR INSCRIPCION ACTIVIDAD
-- ==========================================
CREATE or alter PROCEDURE actividad.insertar_inscripcion_actividad
    @id_socio INT,
    @id_actividad INT,
    @fecha_inscripcion DATE
AS
BEGIN
    SET NOCOUNT ON;
	DECLARE
		@nro_socio_insc varchar(10),
		@id_factura_insc INT,
		@monto_insc NUMERIC(15,2);



    -- Validar que la fecha no sea nula
    IF @fecha_inscripcion IS NULL
    BEGIN
        RAISERROR('Debe especificar una fecha de inscripción', 16, 1);
        RETURN;
    END

    -- Validar existencia del socio
	SELECT @nro_socio_insc = nro_socio
	from socio.socio 
	where id_socio = @id_socio;
    
	IF @nro_socio_insc is NULL
    BEGIN
        RAISERROR('Socio no encontrado', 16, 1);
        RETURN;
    END

    -- Validar existencia de la actividad
	SELECT @monto_insc = costo_mensual
	from actividad.actividad
	where id_actividad = @id_actividad;
	
    IF @monto_insc IS NULL
    BEGIN
        RAISERROR('Actividad no encontrada', 16, 1);
        RETURN;
    END

    -- Validar si ya esta inscripto
    IF EXISTS (
        SELECT 1 FROM actividad.inscripcion_actividad
        WHERE id_socio = @id_socio AND id_actividad = @id_actividad AND fecha_inscripcion = @fecha_inscripcion
    )
    BEGIN
        RAISERROR('El socio ya está inscripto en la actividad', 16, 1);
        RETURN;
    END

	--Validar si existe la factura
	SELECT TOP 1 @id_factura_insc = id_factura
	from factura.factura_mensual
	where nro_socio = @nro_socio_insc
	ORDER BY fecha_emision DESC;

	if @id_factura_insc IS NULL
	begin
		Raiserror('No existe factura_mensual del socio inscripto',16,1);
		return;
	end;

    -- Insertar la inscripcion con fecha
    INSERT INTO actividad.inscripcion_actividad (id_socio, id_actividad, fecha_inscripcion)
    VALUES (@id_socio, @id_actividad, @fecha_inscripcion);
	--Insertar detalle_factura
	EXEC factura.insertar_detalle_factura
		@id_factura = @id_factura_insc,
		@id_membresia = NULL,
		@id_participante = NULL,
		@id_reserva = NULL,
		@monto = @monto_insc,
		@fecha = @fecha_inscripcion,
		@id_actividad = @id_actividad;
END;
GO



-- ==========================================
-- ELIMINAR INSCRIPCION ACTIVIDAD
-- ==========================================
CREATE or alter PROCEDURE actividad.eliminar_inscripcion_actividad
    @id_inscripcion_actividad INT
AS
BEGIN
	SET NOCOUNT ON;
    
	DECLARE 
		@id_socio INT,
        @id_actividad INT,
        @fecha_inscripcion DATE,
        @id_detalle_factura_insc INT;

	SELECT
		@id_socio = id_socio,
        @id_actividad = id_actividad,
        @fecha_inscripcion = fecha_inscripcion
	FROM actividad.inscripcion_actividad
	WHERE id_inscripcion_actividad = @id_inscripcion_actividad;

	IF @id_socio IS NULL 
    BEGIN
        RAISERROR('Inscripcion no encontrada', 16, 1);
        RETURN;
    END

	SELECT @id_detalle_factura_insc = id_detallefactura 
    FROM factura.detalle_factura 
    WHERE id_socio = @id_socio
		AND id_actividad = @id_actividad
		AND fecha = @fecha_inscripcion;

	IF @id_detalle_factura_insc IS NOT NULL
    BEGIN
        EXEC factura.eliminar_detalle_factura @id_detallefactura = @id_detalle_factura_insc;
    END

    DELETE FROM actividad.inscripcion_actividad
    WHERE id_inscripcion_actividad = @id_inscripcion_actividad
END;
GO


-- ==========================================
-- MODIFICAR INSCRIPCION ACTIVIDAD
-- ==========================================
CREATE or alter PROCEDURE actividad.modificar_inscripcion_actividad
    @id_socio INT,
    @id_actividad INT,
    @fecha_inscripcion DATE
AS
BEGIN
    -- Validar existencia de la inscripción
    IF NOT EXISTS (
        SELECT 1 FROM actividad.inscripcion_actividad
        WHERE id_socio = @id_socio AND id_actividad = @id_actividad
    )
    BEGIN
        RAISERROR('Inscripción no encontrada', 16, 1);
        RETURN;
    END

    -- Validar que se haya proporcionado una fecha
    IF  @fecha_inscripcion IS NULL
    BEGIN
        RAISERROR('Error con la fecha ingresada', 16, 1);
        RETURN;
    END

    --  Validar que no sea la misma fecha que ya esta registrada
    IF EXISTS (
        SELECT 1 FROM actividad.inscripcion_actividad
        WHERE id_socio = @id_socio AND id_actividad = @id_actividad AND fecha_inscripcion =  @fecha_inscripcion
    )
    BEGIN
        RAISERROR('La nueva fecha es igual a la actual.', 16, 1);
        RETURN;
    END

    -- Actualizar la inscripcion con la nueva fecha
    UPDATE actividad.inscripcion_actividad
    SET fecha_inscripcion =  @fecha_inscripcion
    WHERE id_socio = @id_socio AND id_actividad = @id_actividad;
END;
GO

-- ==========================================
-- INSERTAR PRESENTISMO
-- ==========================================
CREATE OR ALTER PROCEDURE actividad.insertar_presentismo
(
    @nro_socio VARCHAR(10),
    @nombre_actividad VARCHAR(50),
    @fecha_asistencia DATE,
    @asistencia CHAR(1),
    @profesor VARCHAR(100) = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    -- Validar nro_socio
    IF @nro_socio IS NULL OR LTRIM(RTRIM(@nro_socio)) = ''
    BEGIN
        RAISERROR('nro_socio es obligatorio', 16, 1);
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM socio.socio WHERE nro_socio = @nro_socio)
    BEGIN
        RAISERROR('nro_socio no existe en socio.socio', 16, 1);
        RETURN;
    END

    -- Validar nombre_actividad
    IF @nombre_actividad IS NULL OR LTRIM(RTRIM(@nombre_actividad)) = ''
    BEGIN
        RAISERROR('nombre_actividad es obligatorio', 16, 1);
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM actividad.actividad WHERE nombre = @nombre_actividad)
    BEGIN
        RAISERROR('nombre_actividad no existe en actividad.actividad', 16, 1);
        RETURN;
    END

    -- Validar fecha_asistencia
    IF @fecha_asistencia IS NULL
    BEGIN
        RAISERROR('fecha_asistencia es obligatorio', 16, 1);
        RETURN;
    END

    -- Validar asistencia
    IF @asistencia NOT IN ('P', 'A', 'J')
    BEGIN
        RAISERROR('asistencia solo puede ser J o P o A', 16, 1);
        RETURN;
    END

    -- Tomar los IDs
    DECLARE @id_socio INT, @id_actividad INT;
    SELECT @id_socio = id_socio FROM socio.socio WHERE nro_socio = @nro_socio;
    SELECT @id_actividad = id_actividad FROM actividad.actividad WHERE nombre = @nombre_actividad;

    -- Validar duplicado
    IF EXISTS (
        SELECT 1
        FROM actividad.presentismo
        WHERE id_socio = @id_socio
          AND id_actividad = @id_actividad
          AND fecha_asistencia = @fecha_asistencia
    )
    BEGIN
        RAISERROR('Ya existe un registro para ese socio, actividad y fecha', 16, 1);
        RETURN;
    END

    -- Insertar
    INSERT INTO actividad.presentismo (id_socio, id_actividad, fecha_asistencia, asistencia, profesor)
    VALUES (@id_socio, @id_actividad, @fecha_asistencia, @asistencia, @profesor);

END;
GO

-- ==========================================
-- MODIFICAR PRESENTISMO
-- ==========================================
CREATE OR ALTER PROCEDURE actividad.modificar_presentismo
(
	@id_socio int,
    @id_actividad int,
    @fecha_asistencia DATE,
    @asistencia CHAR(1),
    @profesor VARCHAR(100)
)
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM actividad.presentismo
        WHERE id_socio = @id_socio
          AND id_actividad = @id_actividad
          AND fecha_asistencia = @fecha_asistencia)
    BEGIN
        RAISERROR('No existe este presentismo', 16, 1);
        RETURN;
    END
    -- Validar asistencia
    IF @asistencia NOT IN ('P', 'A')
    BEGIN
        RAISERROR('asistencia solo puede ser P o A', 16, 1);
        RETURN;
    END
	--Modificar
	UPDATE actividad.presentismo
    SET @asistencia = @asistencia,
        @profesor = @profesor
    WHERE id_socio = @id_socio
          AND id_actividad = @id_actividad
          AND fecha_asistencia = @fecha_asistencia
END;
GO

-- ==========================================
-- ELIMINAR PRESENTISMO
-- ==========================================
CREATE OR ALTER PROCEDURE actividad.eliminar_presentismo
(
	@id_socio int,
    @id_actividad int,
    @fecha_asistencia DATE
)
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM actividad.presentismo
        WHERE id_socio = @id_socio
          AND id_actividad = @id_actividad
          AND fecha_asistencia = @fecha_asistencia)
    BEGIN
        RAISERROR('No existe este presentismo', 16, 1);
        RETURN;
    END
	--Eliminar
	DELETE FROM actividad.presentismo WHERE id_socio = @id_socio
          AND id_actividad = @id_actividad
          AND fecha_asistencia = @fecha_asistencia;
END;
GO

-- ==========================================
-- INSERTAR RESERVA DE SUM
-- ==========================================
CREATE or alter PROCEDURE actividad.insertar_reserva_sum
    @id_socio INT,
    @id_actividad_extra INT,
    @fecha_reserva DATE
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM socio.socio WHERE id_socio = @id_socio)
    BEGIN
        RAISERROR('Socio no encontrado', 16, 1);
        RETURN;
    END

    
    IF NOT EXISTS (SELECT 1 FROM actividad.actividad_extra WHERE id_actividad_extra = @id_actividad_extra)
    BEGIN
        RAISERROR('Actividad extra no encontrada', 16, 1);
        RETURN;
    END


    IF @fecha_reserva IS NULL
    BEGIN
        RAISERROR('Debe especificar una fecha de reserva', 16, 1);
        RETURN;
    END

	 IF EXISTS (SELECT 1 FROM actividad.reserva_sum WHERE fecha_reserva = @fecha_reserva)
    BEGIN
        RAISERROR('Ya existe una reserva para ese dia', 16, 1);
        RETURN;
    END

    INSERT INTO actividad.reserva_sum (id_socio, id_actividad_extra, fecha_reserva)
    VALUES (@id_socio, @id_actividad_extra, @fecha_reserva);
END;
GO

-- ==========================================
-- MODFICAR RESERVA DE SUM
-- ==========================================
CREATE or alter PROCEDURE actividad.modificar_reserva_sum
    @id_reserva INT,
    @id_socio INT,
    @id_actividad_extra INT,
    @fecha_reserva DATE
AS
BEGIN

    IF NOT EXISTS (SELECT 1 FROM actividad.reserva_sum WHERE id_reserva = @id_reserva)
    BEGIN
        RAISERROR('Reserva no encontrada', 16, 1);
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM socio.socio WHERE id_socio = @id_socio)
    BEGIN
        RAISERROR('Socio no encontrado', 16, 1);
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM actividad.actividad_extra WHERE id_actividad_extra = @id_actividad_extra)
    BEGIN
        RAISERROR('Actividad extra no encontrada', 16, 1);
        RETURN;
    END

    IF @fecha_reserva IS NULL
    BEGIN
        RAISERROR('Debe especificar una fecha de reserva', 16, 1);
        RETURN;
    END

    IF EXISTS (
        SELECT 1 FROM actividad.reserva_sum 
        WHERE fecha_reserva = @fecha_reserva AND id_reserva <> @id_reserva
    )
    BEGIN
        RAISERROR('Ya existe una reserva para ese dia', 16, 1);
        RETURN;
    END

    UPDATE actividad.reserva_sum
    SET id_socio = @id_socio,
        id_actividad_extra = @id_actividad_extra,
        fecha_reserva = @fecha_reserva
    WHERE id_reserva = @id_reserva;
END;
GO

-- ==========================================
-- ELIMINAR RESERVA DE SUM
-- ==========================================
CREATE or alter PROCEDURE actividad.eliminar_reserva_sum
    @id_reserva INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM actividad.reserva_sum WHERE id_reserva = @id_reserva)
    BEGIN
        RAISERROR('Reserva no encontrada', 16, 1);
        RETURN;
    END

    DELETE FROM actividad.reserva_sum WHERE id_reserva = @id_reserva;
END;
GO

-- ==========================================
--  INSERTAR PARTICIPANTE
-- ==========================================
CREATE or alter PROCEDURE actividad.insertar_participante_actividad_extra
    @id_socio INT,
    @id_actividad_extra INT,
    @tipo_participante VARCHAR(1)
AS
BEGIN
 
    IF NOT EXISTS (SELECT 1 FROM socio.socio WHERE id_socio = @id_socio)
    BEGIN
        RAISERROR('Socio no encontrado', 16, 1);
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM actividad.actividad_extra WHERE id_actividad_extra = @id_actividad_extra)
    BEGIN
        RAISERROR('Actividad extra no encontrada', 16, 1);
        RETURN;
    END

    IF @tipo_participante NOT IN ('S', 'I') -- Socio o Invitado
    BEGIN
        RAISERROR('Tipo de participante erroneo.Ingrese S (socio) o I (invitado)', 16, 1);
        RETURN;
    END

    INSERT INTO actividad.participante_actividad_extra (id_socio, id_actividad_extra, tipo_participante)
    VALUES (@id_socio, @id_actividad_extra, @tipo_participante);
END;
GO

-- ==========================================
--  MODIFICAR PARTICIPANTE
-- ==========================================
CREATE or alter PROCEDURE actividad.modificar_participante_actividad_extra
    @id_participante INT,
    @id_socio INT,
    @id_actividad_extra INT,
    @tipo_participante VARCHAR(1)
AS
BEGIN
    
    IF NOT EXISTS (SELECT 1 FROM actividad.participante_actividad_extra WHERE id_participante = @id_participante)
    BEGIN
        RAISERROR('Participante no encontrado', 16, 1);
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM socio.socio WHERE id_socio = @id_socio)
    BEGIN
        RAISERROR('Socio no encontrado', 16, 1);
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM actividad.actividad_extra WHERE id_actividad_extra = @id_actividad_extra)
    BEGIN
        RAISERROR('Actividad extra no encontrada', 16, 1);
        RETURN;
    END

    IF @tipo_participante NOT IN ('S', 'I')
    BEGIN
        RAISERROR('Tipo de participante invalido.Ingrese S (socio) o I (invitado)', 16, 1);
        RETURN;
    END

    UPDATE actividad.participante_actividad_extra
    SET id_socio = @id_socio,
        id_actividad_extra = @id_actividad_extra,
        tipo_participante = @tipo_participante
    WHERE id_participante = @id_participante;
END;
GO

-- ==========================================
--  ELIMINAR PARTICIPANTE
-- ==========================================
CREATE or alter PROCEDURE actividad.eliminar_participante_actividad_extra
    @id_participante INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM actividad.participante_actividad_extra WHERE id_participante = @id_participante)
    BEGIN
        RAISERROR('Participante no encontrado', 16, 1);
        RETURN;
    END

    DELETE FROM actividad.participante_actividad_extra
    WHERE id_participante = @id_participante;
END;
GO
--=======================================
--DETALLE FACTURA
--===================
CREATE OR ALTER PROCEDURE factura.ver_detalle_factura
    @id_factura INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Validar factura
    IF NOT EXISTS (SELECT 1 FROM factura.factura_mensual WHERE id_factura = @id_factura)
    BEGIN
        RAISERROR('Factura no encontrada.', 16, 1);
        RETURN;
    END

    -- Obtener nro_socio responsable de la factura
    DECLARE @nro_socio VARCHAR(10);
    SELECT @nro_socio = nro_socio FROM factura.factura_mensual WHERE id_factura = @id_factura;

    -- Obtener grupo familiar asociado al socio responsable
    DECLARE @id_grupo INT;
    SELECT @id_grupo = id_grupo_familiar FROM socio.socio WHERE nro_socio = @nro_socio;

    -- Mostrar encabezado factura
    SELECT * FROM factura.factura_mensual WHERE id_factura = @id_factura;

    -- Mostrar detalle de cargos con socio, categoría y actividad
    SELECT
        s.nro_socio,
        s.nombre + ' ' + s.apellido AS socio,
        cs.nombre AS categoria,
        a.nombre AS actividad,
        df.monto,
        df.fecha
    FROM factura.detalle_factura df
    LEFT JOIN socio.socio s ON df.id_socio = s.id_socio
    LEFT JOIN socio.categoria_socio cs ON s.id_categoria = cs.nombre
    LEFT JOIN actividad.actividad a ON df.id_actividad = a.id_actividad
    WHERE df.id_factura = @id_factura
    ORDER BY s.nro_socio, socio, categoria, actividad;
END;


EXEC factura.ver_detalle_factura @id_factura = 7;
SELECT 
    s.nro_socio,
    s.nombre,
    s.apellido,
    a.id_actividad,
    a.nombre AS actividad,
    a.costo_mensual,
    ia.fecha_inscripcion
FROM socio.socio s
JOIN actividad.inscripcion_actividad ia ON s.id_socio = ia.id_socio
JOIN actividad.actividad a ON ia.id_actividad = a.id_actividad
ORDER BY s.nro_socio, s.apellido, s.nombre, ia.fecha_inscripcion;
select * from socio.socio
