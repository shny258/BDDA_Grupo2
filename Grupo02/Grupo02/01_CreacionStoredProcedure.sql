--El archivo .sql con el script debe incluir comentarios donde consten este enunciado, 
--la fecha de entrega,
--n�mero de grupo, nombre de la materia, nombres y DNI de los alumnos. Entregar todo en un zip 
--(observar las pautas para nomenclatura antes expuestas) mediante la secci�n de pr�cticas de MIEL. 
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
	@id_actividad int,
	@id_socio_d int
)
AS
BEGIN
    SET NOCOUNT ON;

    -- Validar existencia de la factura
    IF (NOT EXISTS (SELECT 1 FROM factura.factura_mensual WHERE id_factura = @id_factura)
		AND NOT EXISTS (SELECT 1 FROM socio.socio WHERE id_socio = @id_socio_d)) 
    OR
    (
        NOT EXISTS (SELECT 1 FROM actividad.participante_actividad_extra WHERE id_participante = @id_participante)
        AND NOT EXISTS (SELECT 1 FROM socio.membresia WHERE id_membresia = @id_membresia)
        AND NOT EXISTS (SELECT 1 FROM actividad.reserva_sum WHERE id_reserva = @id_reserva)
		AND NOT EXISTS (SELECT 1 FROM actividad.actividad WHERE id_actividad = @id_actividad)
    )
    BEGIN
        RAISERROR('Factura o alguno de los IDs (participante, membres�a, reserva, actividad) no existe', 16, 1);
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
    INSERT INTO factura.detalle_factura (id_factura, id_membresia, id_participante, id_reserva, monto, fecha, id_actividad, id_socio)
    VALUES (@id_factura, @id_membresia, @id_participante, @id_reserva, @monto, @fecha, @id_actividad, @id_socio_d);
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
    DECLARE @total_bruto NUMERIC(15,2) = 0;
    DECLARE @id_factura INT;
    DECLARE @id_grupo INT;
    DECLARE @fecha_emision DATE = DATEFROMPARTS(@anio, @mes, 1);
    DECLARE @fecha_facturacion DATE = @fecha_emision;
    DECLARE @ultimo_dia_mes INT = DAY(EOMONTH(@fecha_facturacion));
    DECLARE @nro_socio_facturar VARCHAR(10);
    DECLARE @es_familiar BIT = 0;

    -- aca tengo al socio responsable
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

    -- Validar factura duplicada
    IF EXISTS (
        SELECT 1 FROM factura.factura_mensual
        WHERE MONTH(fecha_emision) = @mes AND YEAR(fecha_emision) = @anio AND nro_socio = @nro_socio_facturar
    )
    BEGIN
        RAISERROR('Ya existe factura para ese socio responsable en ese mes/a�o.', 16, 1);
        RETURN;
    END

    -- Verificar si es familiar
    SELECT @id_grupo = id_grupo_familiar FROM socio.socio WHERE nro_socio = @nro_socio_facturar;
    IF @id_grupo IS NOT NULL
        SET @es_familiar = 1;

    -- Tabla temporal de socios
    DECLARE @socios TABLE (id_socio INT);
    IF @es_familiar = 1
    BEGIN
        INSERT INTO @socios (id_socio)
        SELECT id_socio FROM socio.socio WHERE id_grupo_familiar = @id_grupo;
    END
    ELSE
    BEGIN
        INSERT INTO @socios (id_socio)
        SELECT id_socio FROM socio.socio WHERE nro_socio = @nro_socio_facturar;
    END

    -- Crear factura
    INSERT INTO factura.factura_mensual (
        fecha_emision, fecha_vencimiento, segunda_fecha_vencimiento,
        estado, total, total_bruto, nro_socio
    )
    VALUES (
        @fecha_emision,
        DATEFROMPARTS(@anio, @mes, 5),
        DATEFROMPARTS(@anio, @mes, 10),
        'Pendiente',
        0,
        0,
        @nro_socio_facturar
    );

    SET @id_factura = SCOPE_IDENTITY();

    --  Insertar membresias 
    INSERT INTO factura.detalle_factura (
        id_factura, id_membresia, id_participante, id_reserva,
        monto, fecha, id_socio, id_actividad, observacion
    )
    SELECT
        @id_factura,
        NULL, NULL, NULL,
        CASE 
            WHEN @es_familiar = 1 THEN cs.costo * 0.85
            ELSE cs.costo
        END,
        @fecha_facturacion,
        s.id_socio,
        NULL,
        CASE 
            WHEN @es_familiar = 1 THEN 'Descuento 15% grupo familiar'
            ELSE NULL
        END
    FROM @socios s
    JOIN socio.socio so ON s.id_socio = so.id_socio
    JOIN socio.categoria_socio cs ON so.id_categoria = cs.nombre;

    --  Insertar actividades 
    INSERT INTO factura.detalle_factura (
        id_factura, id_membresia, id_participante, id_reserva,
        monto, fecha, id_socio, id_actividad, observacion
    )
    SELECT
        @id_factura,
        NULL, NULL, NULL,
        CASE 
            WHEN (
                SELECT COUNT(*) 
                FROM actividad.inscripcion_actividad ia2
                WHERE ia2.id_socio = s.id_socio 
                  AND ia2.fecha_inscripcion <= @fecha_facturacion
            ) > 1
            THEN a.costo_mensual * 0.9
            ELSE a.costo_mensual
        END,
        @fecha_facturacion,
        s.id_socio,
        a.id_actividad,
        CASE 
            WHEN @es_familiar = 1 AND (
                SELECT COUNT(*) 
                FROM actividad.inscripcion_actividad ia2
                WHERE ia2.id_socio = s.id_socio 
                  AND ia2.fecha_inscripcion <= @fecha_facturacion
            ) > 1
                THEN 'Descuento 15% grupo familiar y 10% por m�ltiples actividades'
            WHEN (
                SELECT COUNT(*) 
                FROM actividad.inscripcion_actividad ia2
                WHERE ia2.id_socio = s.id_socio 
                  AND ia2.fecha_inscripcion <= @fecha_facturacion
            ) > 1
                THEN 'Descuento 10% por m�ltiples actividades'
            ELSE NULL
        END
    FROM @socios s
    JOIN actividad.inscripcion_actividad ia ON s.id_socio = ia.id_socio
    JOIN actividad.actividad a ON ia.id_actividad = a.id_actividad
    WHERE ia.fecha_inscripcion <= @fecha_facturacion;

    -- Calcular total con descuentos
    SELECT @total = SUM(monto)
    FROM factura.detalle_factura
    WHERE id_factura = @id_factura;

    -- Calcular total sin descuentos (bruto)
    SELECT @total_bruto = SUM(
        CASE 
            WHEN observacion LIKE '%15%' THEN monto / 0.85
            WHEN observacion LIKE '%10%' THEN monto / 0.9
            ELSE monto
        END
    )
    FROM factura.detalle_factura
    WHERE id_factura = @id_factura;

    -- Actualizar totales en factura
    UPDATE factura.factura_mensual
    SET total = @total,
        total_bruto = @total_bruto
    WHERE id_factura = @id_factura;

    -- Obtener id_socio del socio responsable
    DECLARE @id_socio_responsable INT;
    SELECT @id_socio_responsable = id_socio
    FROM socio.socio
    WHERE nro_socio = @nro_socio_facturar;

    -- Si tiene cuenta descontar el total
    IF EXISTS (
        SELECT 1 FROM socio.cuenta WHERE id_socio = @id_socio_responsable
    )
    BEGIN
        UPDATE socio.cuenta
        SET saldo = ISNULL(saldo, 0) - @total
        WHERE id_socio = @id_socio_responsable;
    END
    ELSE
    BEGIN
        -- Si no tiene cuenta crearla con saldo negativo
        DECLARE @nombre_socio VARCHAR(50);
        DECLARE @apellido_socio VARCHAR(50);
        DECLARE @dni_socio VARCHAR(15);
        DECLARE @nuevo_usuario VARCHAR(100);

        SELECT @nombre_socio = nombre, @apellido_socio = apellido, @dni_socio = dni
        FROM socio.socio
        WHERE id_socio = @id_socio_responsable;

        SET @nuevo_usuario = LOWER(@nombre_socio + '.' + @apellido_socio + @dni_socio);

        INSERT INTO socio.cuenta (
            usuario,
            contrasenia,
            saldo,
            rol,
            fecha_vigencia_contrasenia,
            id_socio
        )
        VALUES (
            @nuevo_usuario,
            'temporal123', -- contrase�a por defecto
            -@total,
            'Socio',
            GETDATE(),
            @id_socio_responsable
        );
    END

END;
GO

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
        RAISERROR('id_factura es NULL: no se encontr� factura v�lida', 16, 1);
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
        RAISERROR('Fecha inv�lida', 16, 1);
        RETURN;
    END

    IF @tipo_pago IS NULL OR LTRIM(RTRIM(@tipo_pago)) = ''
    BEGIN
        RAISERROR('tipo_pago inv�lido', 16, 1);
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
        RAISERROR('ID pago inv�lido', 16, 1);
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
(
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
    @id_medio_de_pago INT = 1,  -- Valor por defecto 1
    @nro_socio_rp VARCHAR(10),
	  @categoria_ingresada VARCHAR(50)
)
AS
BEGIN
    SET NOCOUNT ON;
 
    DECLARE @edad INT;
    DECLARE @categoria VARCHAR(50);
    DECLARE @id_grupo_familiar INT = NULL;
    DECLARE @id_socio INT;
    DECLARE @fecha_inicio DATE = CAST(GETDATE() AS DATE);
    DECLARE @fecha_renovada DATE = @fecha_inicio;
    DECLARE @fecha_fin DATE = DATEADD(YEAR, 1, @fecha_inicio);
    DECLARE @costo_categoria NUMERIC(15,2);
    DECLARE @id_factura INT;
    DECLARE @mes INT = MONTH(@fecha_inicio);
    DECLARE @anio INT = YEAR(@fecha_inicio);
 
    SET @categoria = @categoria_ingresada;
 
    -- Validar responsable si es Menor o Cadete
    IF @categoria IN ('Menor', 'Cadete')
    BEGIN
        IF @nro_socio_rp IS NULL OR @nro_socio_rp = ''
        BEGIN
            RAISERROR('Socios Menores o Cadetes deben tener un socio responsable.', 16, 1);
            RETURN;
        END
 
        -- Validar que el socio responsable exista y sea Mayor o Responsable
        IF NOT EXISTS (
            SELECT 1 FROM socio.socio s
            WHERE s.nro_socio = @nro_socio_rp
              AND s.id_categoria IN ('Mayor', 'Responsable')  
        )
        BEGIN
            RAISERROR('El socio responsable no existe o no es mayor o responsable.', 16, 1);
            RETURN;
        END
 
        -- Obtener grupo familiar del responsable
        SELECT @id_grupo_familiar = id_grupo_familiar
        FROM socio.socio
        WHERE nro_socio = @nro_socio_rp;
 
        -- Si responsable no tiene grupo familiar crear uno nuevo
        IF @id_grupo_familiar IS NULL
        BEGIN
            INSERT INTO socio.grupo_familiar (fecha_creacion)
            VALUES (GETDATE());
 
            SET @id_grupo_familiar = SCOPE_IDENTITY();
 
            -- Actualizar grupo familiar del responsable
            UPDATE socio.socio
            SET id_grupo_familiar = @id_grupo_familiar
            WHERE nro_socio = @nro_socio_rp;
        END
    END
    ELSE
    BEGIN
        -- Para mayores, responsable y grupo familiar nulos
        SET @nro_socio_rp = NULL;
        SET @id_grupo_familiar = NULL;
    END
 
    -- Insertar socio
    INSERT INTO socio.socio (
        nro_socio, dni, nombre, apellido, email, fecha_nacimiento,
        telefono_contacto, telefono_emergencia, cobertura_medica,
        nro_cobertura_medica, id_medio_de_pago, id_grupo_familiar,
        id_categoria, nro_socio_rp
    )
    VALUES (
        @nro_socio, @dni, @nombre, @apellido, @email, @fecha_nacimiento,
        @telefono_contacto, @telefono_emergencia, @cobertura_medica,
        @nro_cobertura_medica, @id_medio_de_pago, @id_grupo_familiar,
        @categoria, @nro_socio_rp
    );
 
    SET @id_socio = SCOPE_IDENTITY();
 
    -- Obtener costo categoria 
    SELECT @costo_categoria = costo 
    FROM socio.categoria_socio 
    WHERE nombre COLLATE Modern_Spanish_CI_AS = @categoria COLLATE Modern_Spanish_CI_AS;
 
    IF @costo_categoria IS NULL
    BEGIN
        RAISERROR('No se encontr� costo para la categor�a.', 16, 1);
        RETURN;
    END
 
    -- Insertar membresia
    EXEC socio.insertar_membresia
        @id_socio = @id_socio,
        @fecha_inicio = @fecha_inicio,
        @fecha_renovada = @fecha_renovada,
        @fecha_fin = @fecha_fin,
        @costo = @costo_categoria;
 
    -- Si es Mayor o Responsable, generar factura propia
    IF @categoria IN ('Mayor', 'Responsable')
    BEGIN
        EXEC factura.generar_factura_mensual
            @mes = @mes,
            @anio = @anio,
            @nro_socio = @nro_socio;
    END
 
    -- Si es Menor o Cadete, agregar detalle a la factura del socio responsable
    IF @categoria IN ('Menor', 'Cadete') AND @nro_socio_rp IS NOT NULL
    BEGIN

        -- Buscar factura del responsable para mes y a�o actuales
        SELECT TOP 1 @id_factura = f.id_factura
        FROM factura.factura_mensual f
        WHERE f.nro_socio = @nro_socio_rp
          AND MONTH(f.fecha_emision) = @mes
          AND YEAR(f.fecha_emision) = @anio;
 
        IF @id_factura IS NULL
        BEGIN
            RAISERROR('No se encontr� factura para el responsable del menor en este mes/a�o.', 16, 1);
            RETURN;
        END
 
        -- Insertar detalle de membres�a en factura del responsable
        INSERT INTO factura.detalle_factura (
            id_factura, id_membresia, id_participante, id_reserva,
            monto, fecha, id_socio, id_actividad
        )
        VALUES (
            @id_factura, NULL, NULL, NULL,
            @costo_categoria, @fecha_inicio, @id_socio, NULL
        );
    END
 
END;
GO
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
        RAISERROR ('la contrase�a debe tener al menos 10 caracteres', 16, 1);
        RETURN;
    END
    IF @rol NOT IN ('administrador', 'empleado', 'socio') BEGIN
        RAISERROR ('Rol inv�lido. Debe ser "administrador", "empleado" o "socio"', 16, 1);
        RETURN;
    END
    IF @fecha_vigencia_contrasenia IS NULL BEGIN
        RAISERROR ('Debe especificar la fecha de vigencia de la contrase�a', 16, 1);
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
        RAISERROR ('la contrase�a debe tener al menos 10 caracteres', 16, 1);
        RETURN;
    END
    IF @rol NOT IN ('administrador', 'empleado', 'socio') BEGIN
        RAISERROR ('Rol invalido. Debe ser "administrador", "empleado" o "socio"', 16, 1);
        RETURN;
    END
    IF @fecha_vigencia_contrasenia IS NULL BEGIN
        RAISERROR ('Debe especificar la fecha de vigencia de la contrase�a', 16, 1);
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
-- Insertar membresia
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
        RAISERROR('La fecha de renovaci�n no puede ser anterior a la fecha de inicio', 16, 1);
        RETURN;
    END
    IF @fecha_fin < @fecha_renovada BEGIN
        RAISERROR('La fecha de fin no puede ser anterior a la fecha de renovaci�n', 16, 1);
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
-- Modificar membresia
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
        RAISERROR('La fecha de renovaci�n no puede ser anterior a la fecha de inicio', 16, 1);
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
-- Eliminar membresia
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
-- Insertar categoria de socio
-- ==========================================
CREATE or alter PROCEDURE socio.insertar_categoria_socio
    @nombre VARCHAR(50),
    @costo INT,
	@fecha_vigencia date
AS
BEGIN
	
    IF @costo < 0 BEGIN
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
-- Modificar categoria de socio
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
-- Eliminar categoria de socio
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
CREATE OR ALTER PROCEDURE actividad.insertar_inscripcion_actividad
    @id_socio INT,
    @id_actividad INT,
    @fecha_inscripcion DATE
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE
        @nro_socio_insc VARCHAR(10),
        @nro_socio_rp VARCHAR(10),
        @id_factura_insc INT,
        @monto_insc NUMERIC(15,2);

    -- Validar que la fecha no sea nula
    IF @fecha_inscripcion IS NULL
    BEGIN
        RAISERROR('Debe especificar una fecha de inscripci�n', 16, 1);
        RETURN;
    END

    -- Validar existencia del socio
    SELECT @nro_socio_insc = nro_socio,
           @nro_socio_rp = nro_socio_rp
    FROM socio.socio 
    WHERE id_socio = @id_socio;
    
    IF @nro_socio_insc IS NULL
    BEGIN
        RAISERROR('Socio no encontrado', 16, 1);
        RETURN;
    END

    IF @nro_socio_rp IS NOT NULL
    BEGIN
        SET @nro_socio_insc = @nro_socio_rp;
    END

    -- Validar existencia de la actividad
    SELECT @monto_insc = costo_mensual
    FROM actividad.actividad
    WHERE id_actividad = @id_actividad;
    
    IF @monto_insc IS NULL
    BEGIN
        RAISERROR('Actividad no encontrada', 16, 1);
        RETURN;
    END

    -- Validar si ya est� inscripto
    IF EXISTS (
        SELECT 1 FROM actividad.inscripcion_actividad
        WHERE id_socio = @id_socio AND id_actividad = @id_actividad AND fecha_inscripcion = @fecha_inscripcion
    )
    BEGIN
        RAISERROR('El socio ya est� inscripto en la actividad', 16, 1);
        RETURN;
    END

    -- Buscar ultima factura del socio (o rp)
    SELECT TOP 1 @id_factura_insc = id_factura
    FROM factura.factura_mensual
    WHERE nro_socio = @nro_socio_insc
    ORDER BY fecha_emision DESC;

    -- Si no existe factura, crear una nueva
    IF @id_factura_insc IS NULL
    BEGIN
        INSERT INTO factura.factura_mensual (nro_socio, fecha_emision, total)
        VALUES (@nro_socio_insc, @fecha_inscripcion, @monto_insc);

        -- Obtener el id de la factura recien creada
        SET @id_factura_insc = SCOPE_IDENTITY();
    END

    -- Insertar la inscripcion
    INSERT INTO actividad.inscripcion_actividad (id_socio, id_actividad, fecha_inscripcion)
    VALUES (@id_socio, @id_actividad, @fecha_inscripcion);

    -- Insertar en detalle_factura
    EXEC factura.insertar_detalle_factura
        @id_factura = @id_factura_insc,
        @id_membresia = NULL,
        @id_participante = NULL,
        @id_reserva = NULL,
        @monto = @monto_insc,
        @fecha = @fecha_inscripcion,
        @id_actividad = @id_actividad,
        @id_socio_d = @id_socio;
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
    -- Validar existencia de la inscripcion
    IF NOT EXISTS (
        SELECT 1 FROM actividad.inscripcion_actividad
        WHERE id_socio = @id_socio AND id_actividad = @id_actividad
    )
    BEGIN
        RAISERROR('Inscripci�n no encontrada', 16, 1);
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

    -- Validar existencia
    IF NOT EXISTS (SELECT 1 FROM factura.factura_mensual WHERE id_factura = @id_factura)
    BEGIN
        RAISERROR('Factura no encontrada.', 16, 1);
        RETURN;
    END

    -- Mostrar total y total bruto
    SELECT 
        id_factura, 
        nro_socio, 
        fecha_emision, 
        total_bruto, 
        total
    FROM factura.factura_mensual 
    WHERE id_factura = @id_factura;

    -- Mostrar detalle con observacion y descuento aplicado
    SELECT
        s.nro_socio,
        s.nombre + ' ' + s.apellido AS socio,
        cs.nombre AS categoria,
        a.nombre AS actividad,
        df.monto,
        df.fecha,
        df.observacion,
        -- Descuento aplicado (calculado seg�n observaci�n)
        CAST(
            CASE 
                WHEN df.observacion LIKE '%15% y 10%' THEN df.monto / (0.85 * 0.9) - df.monto
                WHEN df.observacion LIKE '%15%' THEN df.monto / 0.85 - df.monto
                WHEN df.observacion LIKE '%10%' THEN df.monto / 0.9 - df.monto
                ELSE 0
            END AS NUMERIC(10,2)
        ) AS descuento_aplicado
    FROM factura.detalle_factura df
    LEFT JOIN socio.socio s ON df.id_socio = s.id_socio
    LEFT JOIN socio.categoria_socio cs ON s.id_categoria = cs.nombre
    LEFT JOIN actividad.actividad a ON df.id_actividad = a.id_actividad
    WHERE df.id_factura = @id_factura
    ORDER BY s.nro_socio, s.nombre + ' ' + s.apellido, cs.nombre, a.nombre;
END;
GO
---------INSCRIBIR PARTICIPANTE EXTRA
---====================================
CREATE OR ALTER PROCEDURE actividad.inscribir_participante
    @id_socio INT,
    @id_actividad_extra INT,
    @tipo_participante VARCHAR(1) -- 'S' = Socio, otro = Invitado
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Insertar participante
        INSERT INTO actividad.participante_actividad_extra (id_socio, id_actividad_extra, tipo_participante)
        VALUES (@id_socio, @id_actividad_extra, @tipo_participante);

        DECLARE @id_participante INT = SCOPE_IDENTITY();

        -- Obtener nro_socio
        DECLARE @nro_socio VARCHAR(10);
        SELECT @nro_socio = nro_socio FROM socio.socio WHERE id_socio = @id_socio;

        IF @nro_socio IS NULL
        BEGIN
            RAISERROR('No se encontr� el nro_socio para el id_socio %d.', 16, 1, @id_socio);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Obtener membresia activa
        DECLARE @id_membresia INT;

        SELECT TOP 1 @id_membresia = id_membresia
        FROM socio.membresia
        WHERE id_socio = @id_socio
          AND GETDATE() BETWEEN fecha_inicio AND fecha_fin
        ORDER BY fecha_inicio DESC;

        IF @id_membresia IS NULL
        BEGIN
            RAISERROR('No se encontr� una membres�a activa para el socio %d.', 16, 1, @id_socio);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Obtener monto segun tipo de participante
        DECLARE @monto NUMERIC(15,2);

        SELECT @monto = 
            CASE 
                WHEN @tipo_participante = 'S' THEN costo_socio
                ELSE costo_invitado
            END
        FROM actividad.actividad_extra
        WHERE id_actividad_extra = @id_actividad_extra;

        -- Insertar en factura_mensual
        DECLARE @fecha DATE = GETDATE();
        DECLARE @id_factura INT;

        INSERT INTO factura.factura_mensual (
            fecha_emision, 
            fecha_vencimiento,
            segunda_fecha_vencimiento,
            estado, 
            total, 
            nro_socio,
            total_bruto
        )
        VALUES (
            @fecha, 
            DATEADD(DAY, 15, @fecha),
            DATEADD(DAY, 30, @fecha),
            'Pendiente', 
            @monto, 
            @nro_socio,
            @monto
        );

        SET @id_factura = SCOPE_IDENTITY();

        -- Insertar detalle_factura con observacion "DIA DE PILETA"
        INSERT INTO factura.detalle_factura (
            id_factura,
            id_membresia,
            id_participante,
            monto,
            fecha,
            id_socio,
            id_actividad,
            observacion
        )
        VALUES (
            @id_factura,
            @id_membresia,
            @id_participante,
            @monto,
            @fecha,
            @id_socio,
            @id_actividad_extra,
            'DIA DE PILETA'
        );

        -- Actualizar o crear cuenta del socio usando id_socio
        IF EXISTS (SELECT 1 FROM socio.cuenta WHERE id_socio = @id_socio)
        BEGIN
            UPDATE socio.cuenta
            SET saldo = ISNULL(saldo, 0) - @monto
            WHERE id_socio = @id_socio;
        END
        ELSE
        BEGIN
            -- Si no existe, obtener datos para crear el usuario
            DECLARE @nombre VARCHAR(50);
            DECLARE @apellido VARCHAR(50);
            DECLARE @dni VARCHAR(15);
            DECLARE @nuevo_usuario VARCHAR(100);

            SELECT @nombre = nombre, @apellido = apellido, @dni = dni
            FROM socio.socio
            WHERE id_socio = @id_socio;

            SET @nuevo_usuario = LOWER(@nombre + '.' + @apellido + @dni);

            INSERT INTO socio.cuenta (
                usuario,
                contrasenia,
                saldo,
                rol,
                fecha_vigencia_contrasenia,
                id_socio
            )
            VALUES (
                @nuevo_usuario,
                'temporal123',
                -@monto,
                'Socio',
                GETDATE(),
                @id_socio
            );
        END

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        DECLARE @msg NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@msg, 16, 1);
    END CATCH
END;
go





---=======================================
---eliminar factura
---=======================================

	CREATE OR ALTER PROCEDURE factura.eliminar_factura
    @id_factura INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar que la factura existe
        IF NOT EXISTS (
            SELECT 1 FROM factura.factura_mensual WHERE id_factura = @id_factura
        )
        BEGIN
            RAISERROR('La factura con id %d no existe.', 16, 1, @id_factura);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Verificar si ya est� anulada
        IF EXISTS (
            SELECT 1 
            FROM factura.factura_mensual 
            WHERE id_factura = @id_factura AND estado = 'Anulada'
        )
        BEGIN
            RAISERROR('La factura con id %d ya fue anulada previamente.', 16, 1, @id_factura);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        DECLARE @monto NUMERIC(15,2);
        DECLARE @nro_socio VARCHAR(10);

        SELECT 
            @monto = total,
            @nro_socio = nro_socio
        FROM factura.factura_mensual
        WHERE id_factura = @id_factura;

        -- Actualizar estado de la factura
        UPDATE factura.factura_mensual
        SET estado = 'Anulada'
        WHERE id_factura = @id_factura;

        -- Marcar los detalles como anulados
        UPDATE factura.detalle_factura
        SET observacion = 'DETALLE ANULADO'
        WHERE id_factura = @id_factura;

        -- Acreditar el monto como saldo a favor en la cuenta del socio (usando id_socio)
        DECLARE @id_socio INT;

        SELECT @id_socio = id_socio
        FROM socio.socio
        WHERE nro_socio = @nro_socio;

        IF EXISTS (SELECT 1 FROM socio.cuenta WHERE id_socio = @id_socio)
        BEGIN
            -- Revertir la deuda restando el monto
            UPDATE socio.cuenta
            SET saldo = ISNULL(saldo, 0) - @monto
            WHERE id_socio = @id_socio;
        END
        ELSE
        BEGIN
            -- Crear cuenta con deuda revertida si no exist�a
            DECLARE @nombre VARCHAR(50);
            DECLARE @apellido VARCHAR(50);
            DECLARE @dni VARCHAR(15);
            DECLARE @nuevo_usuario VARCHAR(100);

            SELECT 
                @nombre = nombre,
                @apellido = apellido,
                @dni = dni
            FROM socio.socio
            WHERE id_socio = @id_socio;

            SET @nuevo_usuario = LOWER(@nombre + '.' + @apellido + @dni); -- Ej: juan.perez12345678

            INSERT INTO socio.cuenta (
                usuario,
                contrasenia,
                saldo,
                rol,
                fecha_vigencia_contrasenia,
                id_socio
            )
            VALUES (
                @nuevo_usuario,
                'temporal123',
                -@monto, -- saldo negativo para revertir deuda
                'Socio',
                GETDATE(),
                @id_socio
            );
        END

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        DECLARE @msg NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@msg, 16, 1);
    END CATCH
END;
GO

---=========================================
----dia de lluvia 
---===========
CREATE OR ALTER PROCEDURE factura.reintegrar_dias_lluvia
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Reintegros por lluvia: 60% del monto en actividades extra, observaci�n 'DIA DE PILETA'
        INSERT INTO socio.cuenta (usuario, contrasenia, saldo, rol, fecha_vigencia_contrasenia, id_socio)
        SELECT
            LOWER(s.nombre + '.' + s.apellido + s.dni), -- usuario generado
            'temporal123',
            ROUND(SUM(df.monto * 0.6), 2), -- suma de reintegros
            'Socio',
            GETDATE(),
            df.id_socio
        FROM factura.detalle_factura df
        INNER JOIN actividad.participante_actividad_extra pa ON df.id_participante = pa.id_participante
        INNER JOIN socio.socio s ON df.id_socio = s.id_socio
        WHERE 
            df.observacion = 'DIA DE PILETA'
            AND EXISTS (
                SELECT 1
                FROM factura.clima_anual ca
                WHERE CAST(LEFT(ca.FechaHora, 10) AS DATE) = CAST(df.fecha AS DATE)
                  AND ca.Precipitacion > 0
            )
            AND NOT EXISTS (
                SELECT 1
                FROM socio.cuenta c
                WHERE c.id_socio = df.id_socio
            )
        GROUP BY s.nombre, s.apellido, s.dni, df.id_socio;

        -- Si ya tiene cuenta, solo actualizamos el saldo
        UPDATE c
        SET c.saldo = ISNULL(c.saldo, 0) + r.total_reintegro
        FROM socio.cuenta c
        INNER JOIN (
            SELECT
                df.id_socio,
                ROUND(SUM(df.monto * 0.6), 2) AS total_reintegro
            FROM factura.detalle_factura df
            INNER JOIN actividad.participante_actividad_extra pa ON df.id_participante = pa.id_participante
            WHERE 
                df.observacion = 'DIA DE PILETA'
                AND EXISTS (
                    SELECT 1
                    FROM factura.clima_anual ca
                    WHERE CAST(LEFT(ca.FechaHora, 10) AS DATE) = CAST(df.fecha AS DATE)
                      AND ca.Precipitacion > 0
                )
            GROUP BY df.id_socio
        ) r ON c.id_socio = r.id_socio;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        DECLARE @msg NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@msg, 16, 1);
    END CATCH
END;
go

/*INSERT INTO factura.clima_anual (FechaHora, Temperatura, Precipitacion, Humedad, Viento)
VALUES (FORMAT(GETDATE(), 'yyyy-MM-ddTHH:00'), 22.5, 4.50, 85, 10.0);


EXEC actividad.inscribir_participante
    @id_socio = 125,
    @id_actividad_extra = 1,
    @tipo_participante = 'S';  -- Socio

	SELECT s.nombre, s.apellido, c.saldo
FROM socio.cuenta c
JOIN socio.socio s ON c.id_socio = s.id_socio
WHERE c.id_socio = 125; -- Cambi� el ID seg�n tu prueba

EXEC factura.reintegrar_dias_lluvia;

EXEC actividad.inscribir_participante 
    @id_socio = 140, 
    @id_actividad_extra = 1, 
    @tipo_participante = 'I';

select* from socio.cuenta
select* from factura.detalle_factura
select* from actividad.inscripcion_actividad
EXEC socio.ver_perfil_socio @id_socio = 150;
select* from factura.factura_mensual
delete factura.detalle_factura
delete factura.factura_mensual
delete factura.*/

--exec factura.eliminar_factura @id_factura=129

CREATE OR ALTER PROCEDURE socio.ver_perfil_socio
    @id_socio INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT *
    FROM (
        -- 1. Cuotas mensuales
        SELECT
            f.id_factura AS Id,
            'Cuota' AS Tipo,
            f.total AS Monto,
            f.fecha_vencimiento AS Fecha_vencimiento,
            f.estado AS Estado,
            'Cuota mensual' AS NombreActividad
        FROM factura.factura_mensual f
        INNER JOIN socio.socio s ON s.nro_socio = f.nro_socio
        WHERE s.id_socio = @id_socio

        UNION ALL

        -- 2. Actividades Extra
        SELECT
            df.id_detallefactura AS Id,
            'Actividad Extra' AS Tipo,
            df.monto AS Monto,
            f.fecha_vencimiento AS Fecha_vencimiento,
            f.estado AS Estado,
            a.nombre AS NombreActividad
        FROM factura.detalle_factura df
        INNER JOIN factura.factura_mensual f ON df.id_factura = f.id_factura
        INNER JOIN actividad.actividad a ON df.id_actividad = a.id_actividad
        WHERE df.id_socio = @id_socio
          AND df.id_participante IS NOT NULL

        UNION ALL

        -- 3. Actividades Regulares (inscripciones)
        SELECT
            ia.id_inscripcion_actividad AS Id,
            'Actividad Regular' AS Tipo,
            a.costo_mensual AS Monto,
            NULL AS Fecha_vencimiento,
            CASE 
                WHEN EXISTS (
                    SELECT 1
                    FROM factura.detalle_factura df
                    INNER JOIN factura.factura_mensual fm ON df.id_factura = fm.id_factura
                    WHERE df.id_socio = @id_socio
                      AND df.id_actividad = ia.id_actividad
                      AND fm.estado = 'Pagada'
                ) THEN 'Pagada'
                ELSE 'Pendiente'
            END AS Estado,
            a.nombre AS NombreActividad
        FROM actividad.inscripcion_actividad ia
        INNER JOIN actividad.actividad a ON ia.id_actividad = a.id_actividad
        WHERE ia.id_socio = @id_socio

        UNION ALL

        -- 4. Saldo a favor
        SELECT
            NULL AS Id,
            'Saldo a favor' AS Tipo,
            ISNULL(c.saldo, 0) AS Monto,
            NULL AS Fecha_vencimiento,
            CASE WHEN ISNULL(c.saldo, 0) > 0 THEN 'Disponible' ELSE 'Sin saldo' END AS Estado,
            'Cuenta' AS NombreActividad
        FROM socio.cuenta c
        WHERE c.id_socio = @id_socio
    ) AS Todo
    ORDER BY 
        CASE Tipo 
            WHEN 'Saldo a favor' THEN 4
            WHEN 'Actividad Regular' THEN 3
            WHEN 'Actividad Extra' THEN 2
            ELSE 1
        END,
        Fecha_vencimiento
END

GO

CREATE OR ALTER PROCEDURE socio.asignar_medio_pago_random
AS
BEGIN
    SET NOCOUNT ON;
 
    DECLARE 
        @id_socio INT,
        @id_medio_random INT;
 
    DECLARE cursor_socios CURSOR FOR
        SELECT id_socio FROM socio.socio;
 
    OPEN cursor_socios;
    FETCH NEXT FROM cursor_socios INTO @id_socio;
 
    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Obtener un medio de pago aleatorio
        SELECT TOP 1 @id_medio_random = id_medio_de_pago
        FROM factura.medio_de_pago
        ORDER BY NEWID();
 
        -- Asignar el medio de pago al socio
        UPDATE socio.socio
        SET id_medio_de_pago = @id_medio_random
        WHERE id_socio = @id_socio;
 
        FETCH NEXT FROM cursor_socios INTO @id_socio;
    END
 
    CLOSE cursor_socios;
    DEALLOCATE cursor_socios;
END;
GO