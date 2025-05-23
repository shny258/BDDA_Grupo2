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
------------SOCIO----------------------
CREATE PROCEDURE socio.insertar_socio
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
    @id_grupo_familiar INT,
    @id_categoria VARCHAR(50)
AS
BEGIN
    -- Validaciones básicas
    IF @dni IS NULL OR LEN(@dni) = 0 BEGIN
        RAISERROR ('El DNI no puede estar vacío.', 16, 1);
        RETURN;
    END
    IF @nombre IS NULL OR LEN(@nombre) = 0 BEGIN
        RAISERROR ('El nombre no puede estar vacío.', 16, 1);
        RETURN;
    END
    IF @apellido IS NULL OR LEN(@apellido) = 0 BEGIN
        RAISERROR ('El apellido no puede estar vacío.', 16, 1);
        RETURN;
    END

    INSERT INTO socio.socio (dni, nombre, apellido, email, fecha_nacimiento, telefono_contacto, telefono_emergencia, cobertura_medica, nro_cobertura_medica, id_medio_de_pago, id_grupo_familiar, id_categoria)
    VALUES (@dni, @nombre, @apellido, @email, @fecha_nacimiento, @telefono_contacto, @telefono_emergencia, @cobertura_medica, @nro_cobertura_medica, @id_medio_de_pago, @id_grupo_familiar, @id_categoria);
END;
GO

-- Modificar un socio existente
CREATE PROCEDURE socio.modificar_socio
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
    IF NOT EXISTS (SELECT 1 FROM socio.socio WHERE id_socio = @id_socio) BEGIN
        RAISERROR ('El socio no existe.', 16, 1);
        RETURN;
    END

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

-- Eliminar un socio (borrado lógico no requerido explícitamente, así que se realiza físico)
CREATE PROCEDURE socio.eliminar_socio
    @id_socio INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM socio.socio WHERE id_socio = @id_socio) BEGIN
        RAISERROR ('El socio no existe.', 16, 1);
        RETURN;
    END

    DELETE FROM socio.socio WHERE id_socio = @id_socio;
END;
GO

-- Insertar membresía
CREATE PROCEDURE socio.insertar_membresia
    @id_socio INT,
    @fecha_inicio DATE,
    @fecha_renovada DATE,
    @fecha_fin DATE,
    @costo NUMERIC(15,2)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM socio.socio WHERE id_socio = @id_socio)
    BEGIN
        RAISERROR('El socio no existe.', 16, 1);
        RETURN;
    END

    IF @fecha_inicio IS NULL OR @fecha_renovada IS NULL OR @fecha_fin IS NULL
        OR @fecha_inicio > @fecha_fin
        OR @fecha_renovada < @fecha_inicio OR @fecha_renovada > @fecha_fin
    BEGIN
        RAISERROR('Fechas inválidas.', 16, 1);
        RETURN;
    END

    IF @costo <= 0
    BEGIN
        RAISERROR('El costo debe ser mayor a cero.', 16, 1);
        RETURN;
    END

    INSERT INTO socio.membresia (id_socio, fecha_inicio, fecha_renovada, fecha_fin, costo)
    VALUES (@id_socio, @fecha_inicio, @fecha_renovada, @fecha_fin, @costo);
END;
 --modificar
 CREATE PROCEDURE socio.modificar_membresia
    @id_membresia INT,
    @fecha_renovada DATE,
    @fecha_fin DATE,
    @costo NUMERIC(15,2)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM socio.membresia WHERE id_membresia = @id_membresia)
    BEGIN
        RAISERROR('No existe la membresía.', 16, 1);
        RETURN;
    END

    DECLARE @fecha_inicio DATE;
    SELECT @fecha_inicio = fecha_inicio FROM socio.membresia WHERE id_membresia = @id_membresia;

    IF @fecha_renovada IS NULL OR @fecha_fin IS NULL
        OR @fecha_renovada < @fecha_inicio OR @fecha_renovada > @fecha_fin
    BEGIN
        RAISERROR('Fechas inválidas.', 16, 1);
        RETURN;
    END

    IF @costo <= 0
    BEGIN
        RAISERROR('El costo debe ser mayor a cero.', 16, 1);
        RETURN;
    END

    UPDATE socio.membresia
    SET fecha_renovada = @fecha_renovada,
        fecha_fin = @fecha_fin,
        costo = @costo
    WHERE id_membresia = @id_membresia;
END;
-------eliminar
CREATE PROCEDURE socio.borrar_membresia
    @id_membresia INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM socio.membresia WHERE id_membresia = @id_membresia)
    BEGIN
        RAISERROR('No existe la membresía.', 16, 1);
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM factura.detalle_factura WHERE id_membresia = @id_membresia)
    BEGIN
        RAISERROR('No se puede eliminar la membresía: tiene facturas asociadas.', 16, 1);
        RETURN;
    END

    DELETE FROM socio.membresia
    WHERE id_membresia = @id_membresia;
END;

CREATE PROCEDURE socio.insertar_cuenta
    @usuario VARCHAR(50),
    @contrasenia VARCHAR(50),
    @rol VARCHAR(50),
    @fecha_vigencia_contraseña DATE
AS
BEGIN
    -- Validaciones básicas
    IF LEN(@usuario) = 0 BEGIN
        RAISERROR ('El nombre de usuario no puede estar vacío.', 16, 1);
        RETURN;
    END
    IF LEN(@contrasenia) < 10 BEGIN
        RAISERROR ('la contraseña debe tener al menos 10 caracteres.', 16, 1);
        RETURN;
    END
    IF @rol NOT IN ('administrador', 'empleado', 'socio') BEGIN
        RAISERROR ('Rol inválido. Debe ser "administrador", "empleado" o "socio".', 16, 1);
        RETURN;
    END
    IF @fecha_vigencia_contrasenia IS NULL BEGIN
        RAISERROR ('Debe especificar la fecha de vigencia de la contraseña.', 16, 1);
        RETURN;
    END

    INSERT INTO socio.cuenta (usuario, contrasenia, rol, fecha_vigencia_contrasenia)
    VALUES (@usuario, @contrasenia, @rol, @fecha_vigencia_contrasenia);
END;
GO

CREATE PROCEDURE socio.modificar_cuenta
    @id_usuario INT,
    @contrasenia VARCHAR(255),
    @rol VARCHAR(50),
    @fecha_vigencia_contrasenia DATE
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM socio.cuenta WHERE id_usuario = @id_usuario) BEGIN
        RAISERROR ('La cuenta no existe.', 16, 1);
        RETURN;
    END
    IF LEN(@contrasenia) < 60 BEGIN
        RAISERROR ('la contraseña debe tener al menos 10 caracteres.', 16, 1);
        RETURN;
    END
    IF @rol NOT IN ('administrador', 'empleado', 'socio') BEGIN
        RAISERROR ('Rol inválido. Debe ser "administrador", "empleado" o "socio".', 16, 1);
        RETURN;
    END
    IF @fecha_vigencia_contrasenia IS NULL BEGIN
        RAISERROR ('Debe especificar la fecha de vigencia de la contraseña.', 16, 1);
        RETURN;
    END

    UPDATE socio.cuenta
    SET contrasenia = @contrasenia,
        rol = @rol,
        fecha_vigencia_contrasenia = @fecha_vigencia_contrasenia
    WHERE id_usuario = @id_usuario;
END;
GO

CREATE PROCEDURE socio.eliminar_cuenta
    @id_usuario INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM socio.cuenta WHERE id_usuario = @id_usuario) BEGIN
        RAISERROR ('La cuenta no existe.', 16, 1);
        RETURN;
    END

    DELETE FROM socio.cuenta WHERE id_usuario = @id_usuario;
END;
GO

CREATE PROCEDURE socio.insertar_grupo_familiar
    @nombre VARCHAR(50),
    @apellido VARCHAR(50),
    @dni VARCHAR(10),
    @email VARCHAR(50),
    @fecha_nacimiento DATE,
    @telefono VARCHAR(20),
    @parentesco VARCHAR(50)
AS
BEGIN
    -- Validaciones básicas
    IF LEN(@dni) < 7 BEGIN
        RAISERROR('El DNI debe tener al menos 7 caracteres.', 16, 1);
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM socio.grupo_familiar WHERE dni = @dni) BEGIN
        RAISERROR('El DNI ya está registrado.', 16, 1);
        RETURN;
    END

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
CREATE PROCEDURE socio.modificar_grupo_familiar
    @id_grupo_familiar INT,
    @email VARCHAR(50),
    @telefono VARCHAR(20),
    @parentesco VARCHAR(50)
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM socio.grupo_familiar WHERE id_grupo_familiar = @id_grupo_familiar) BEGIN
        RAISERROR('El grupo familiar no existe.', 16, 1);
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
CREATE PROCEDURE socio.eliminar_grupo_familiar
    @id_grupo_familiar INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM socio.grupo_familiar WHERE id_grupo_familiar = @id_grupo_familiar) BEGIN
        RAISERROR('El grupo familiar no existe.', 16, 1);
        RETURN;
    END

    DELETE FROM socio.grupo_familiar
    WHERE id_grupo_familiar = @id_grupo_familiar;
END;
GO

-- ==========================================
-- Insertar membresía
-- ==========================================
CREATE PROCEDURE socio.insertar_membresia
    @id_socio INT,
    @fecha_inicio DATE,
    @fecha_renovada DATE,
    @fecha_fin DATE,
    @costo NUMERIC(15,2)
AS
BEGIN
    -- Validaciones
    IF NOT EXISTS (SELECT 1 FROM socio.socio WHERE id_socio = @id_socio) BEGIN
        RAISERROR('El socio no existe.', 16, 1);
        RETURN;
    END
    IF @fecha_renovada < @fecha_inicio BEGIN
        RAISERROR('La fecha de renovación no puede ser anterior a la fecha de inicio.', 16, 1);
        RETURN;
    END
    IF @fecha_fin < @fecha_renovada BEGIN
        RAISERROR('La fecha de fin no puede ser anterior a la fecha de renovación.', 16, 1);
        RETURN;
    END
    IF @costo <= 0 BEGIN
        RAISERROR('El costo debe ser mayor a cero.', 16, 1);
        RETURN;
    END

    INSERT INTO socio.membresia (id_socio, fecha_inicio, fecha_renovada, fecha_fin, costo)
    VALUES (@id_socio, @fecha_inicio, @fecha_renovada, @fecha_fin, @costo);
END;
GO

-- ==========================================
-- Modificar membresía
-- ==========================================
CREATE PROCEDURE socio.modificar_membresia
    @id_membresia INT,
    @fecha_renovada DATE,
    @fecha_fin DATE,
    @costo NUMERIC(15,2)
AS
BEGIN
    -- Validaciones
    IF NOT EXISTS (SELECT 1 FROM socio.membresia WHERE id_membresia = @id_membresia) BEGIN
        RAISERROR('La membresía no existe.', 16, 1);
        RETURN;
    END

    DECLARE @fecha_inicio DATE;
    SELECT @fecha_inicio = fecha_inicio FROM socio.membresia WHERE id_membresia = @id_membresia;

    IF @fecha_renovada < @fecha_inicio BEGIN
        RAISERROR('La fecha de renovación no puede ser anterior a la fecha de inicio.', 16, 1);
        RETURN;
    END
    IF @fecha_fin < @fecha_renovada BEGIN
        RAISERROR('La fecha de fin no puede ser anterior a la fecha de renovación.', 16, 1);
        RETURN;
    END
    IF @costo <= 0 BEGIN
        RAISERROR('El costo debe ser mayor a cero.', 16, 1);
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
CREATE PROCEDURE socio.eliminar_membresia
    @id_membresia INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM socio.membresia WHERE id_membresia = @id_membresia) BEGIN
        RAISERROR('La membresía no existe.', 16, 1);
        RETURN;
    END

    DELETE FROM socio.membresia WHERE id_membresia = @id_membresia;
END;
GO

-- ==========================================
-- Insertar categoría de socio
-- ==========================================
CREATE PROCEDURE socio.insertar_categoria_socio
    @nombre VARCHAR(50),
    @edad_min INT,
    @edad_max INT,
    @costo INT
AS
BEGIN
    IF @edad_min < 0 OR @edad_max < 0 BEGIN
        RAISERROR('Las edades no pueden ser negativas.', 16, 1);
        RETURN;
    END
    IF @edad_max < @edad_min BEGIN
        RAISERROR('La edad máxima no puede ser menor que la mínima.', 16, 1);
        RETURN;
    END
    IF @costo <= 0 BEGIN
        RAISERROR('El costo debe ser mayor a cero.', 16, 1);
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM socio.categoria_socio WHERE nombre = @nombre) BEGIN
        RAISERROR('La categoría ya existe.', 16, 1);
        RETURN;
    END

    INSERT INTO socio.categoria_socio (nombre, edad_min, edad_max, costo)
    VALUES (@nombre, @edad_min, @edad_max, @costo);
END;
GO

-- ==========================================
-- Modificar categoría de socio
-- ==========================================
CREATE PROCEDURE socio.modificar_categoria_socio
    @nombre VARCHAR(50),
    @edad_min INT,
    @edad_max INT,
    @costo INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM socio.categoria_socio WHERE nombre = @nombre) BEGIN
        RAISERROR('La categoría no existe.', 16, 1);
        RETURN;
    END
    IF @edad_min < 0 OR @edad_max < 0 BEGIN
        RAISERROR('Las edades no pueden ser negativas.', 16, 1);
        RETURN;
    END
    IF @edad_max < @edad_min BEGIN
        RAISERROR('La edad máxima no puede ser menor que la mínima.', 16, 1);
        RETURN;
    END
    IF @costo <= 0 BEGIN
        RAISERROR('El costo debe ser mayor a cero.', 16, 1);
        RETURN;
    END

    UPDATE socio.categoria_socio
    SET edad_min = @edad_min,
        edad_max = @edad_max,
        costo = @costo
    WHERE nombre = @nombre;
END;
GO

-- ==========================================
-- Eliminar categoría de socio
-- ==========================================
CREATE PROCEDURE socio.eliminar_categoria_socio
    @nombre VARCHAR(50)
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM socio.categoria_socio WHERE nombre = @nombre) BEGIN
        RAISERROR('La categoría no existe.', 16, 1);
        RETURN;
    END

    DELETE FROM socio.categoria_socio WHERE nombre = @nombre;
END;
GO
