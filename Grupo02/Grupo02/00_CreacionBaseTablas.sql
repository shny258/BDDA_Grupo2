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

if not exists (select name from sys.databases where name = 'Com5600G02')
	create database Com5600G02 COLLATE Modern_Spanish_CI_AS;

go

use Com5600G02;
go

DROP TABLE IF EXISTS factura.aplica_descuento;
DROP TABLE IF EXISTS factura.pago;
DROP TABLE IF EXISTS factura.detalle_factura;
DROP TABLE IF EXISTS actividad.presentismo;
DROP TABLE IF EXISTS actividad.reserva_sum;
DROP TABLE IF EXISTS actividad.participante_actividad_extra;
DROP TABLE IF EXISTS actividad.inscripcion_actividad;
DROP TABLE IF EXISTS factura.factura_mensual;
DROP TABLE IF EXISTS factura.descuento;
DROP TABLE IF EXISTS socio.membresia;
DROP TABLE IF EXISTS actividad.actividad_extra;
DROP TABLE IF EXISTS actividad.actividad;
DROP TABLE IF EXISTS socio.empleado;
DROP TABLE IF EXISTS socio.socio;
DROP TABLE IF EXISTS socio.grupo_familiar;
DROP TABLE IF EXISTS socio.categoria_socio;
DROP TABLE IF EXISTS factura.medio_de_pago;
DROP TABLE IF EXISTS socio.cuenta;

go

IF NOT EXISTS (SELECT * FROM  sys.schemas WHERE name = 'socio')
    EXEC('CREATE SCHEMA socio');
go

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'actividad')
    EXEC('CREATE SCHEMA actividad');
go

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'factura')
    EXEC('CREATE SCHEMA factura');
go



-- Tabla de formas de pago
CREATE TABLE factura.medio_de_pago (
    id_medio_de_pago int identity (1,1) PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL -- ej: Visa, Mastercard, Mercado Pago, etc
);

-- Tabla de categor�as de socio
CREATE TABLE socio.categoria_socio (
    nombre varchar(50) PRIMARY KEY,
	fecha_vigencia date,
	costo int
);

-- Grupo familiar (responsables/tutores)
CREATE TABLE socio.grupo_familiar (
    id_grupo_familiar INT IDENTITY(1,1) PRIMARY KEY,
    fecha_creacion DATETIME NOT NULL DEFAULT GETDATE()
);

-- Tabla de socios

CREATE TABLE socio.socio (
    id_socio int identity (1,1) PRIMARY KEY,
	nro_socio VARCHAR(10) unique not null,
	dni VARCHAR(15)  unique NOT NULL,
    nombre VARCHAR(50) NOT NULL,
    apellido VARCHAR(50) NOT NULL,
    email VARCHAR(100) NULL,
    fecha_nacimiento DATE NOT NULL,
    telefono_contacto VARCHAR(20),
    telefono_emergencia VARCHAR(20),
    cobertura_medica VARCHAR(100),
    nro_cobertura_medica VARCHAR(50),
	nro_socio_rp VARCHAR(10) NULL,
    id_medio_de_pago INT REFERENCES factura.medio_de_pago(id_medio_de_pago),
    id_grupo_familiar INT REFERENCES socio.grupo_familiar(id_grupo_familiar),
    id_categoria varchar(50) REFERENCES socio.categoria_socio(nombre)
);
-- Tabla de usuarios del sistema 
CREATE TABLE socio.cuenta (
    id_usuario int identity (1,1) PRIMARY KEY,
    usuario VARCHAR(50) UNIQUE NOT NULL,
    contrasenia VARCHAR(50) NOT NULL,
	saldo NUMERIC(15,2),
    rol VARCHAR(50) NOT NULL,
    fecha_vigencia_contrasenia DATE NOT NULL,
	id_socio int CONSTRAINT FK_cuenta FOREIGN KEY (id_socio)
        REFERENCES socio.socio(id_socio),
);
-- Membres�a por socio
CREATE TABLE socio.membresia (
    id_membresia int identity PRIMARY KEY,
    id_socio INT REFERENCES socio.socio(id_socio),
    fecha_inicio DATE NOT NULL,
	fecha_renovada date not null,
    fecha_fin DATE NOT NULL,
    costo NUMERIC(15,2)
);

-- Actividades (nataci�n, futsal, etc.)
CREATE TABLE actividad.actividad (
    id_actividad int identity PRIMARY KEY,
    nombre VARCHAR(50) UNIQUE NOT NULL,
    costo_mensual NUMERIC(15,2),
	fecha_vigencia DATE 
);

-- Actividades extra (colonia, pileta recreativa, etc.)
CREATE TABLE actividad.actividad_extra (
    id_actividad_extra int identity PRIMARY KEY,
    nombre VARCHAR(50) UNIQUE NOT NULL,
    costo_socio NUMERIC(15,2),
	costo_invitado NUMERIC(15,2),
	fecha_vigencia DATE 
);

-- Inscripci�n a actividades deportivas regulares
CREATE TABLE actividad.inscripcion_actividad (
	id_inscripcion_actividad int identity PRIMARY KEY,
    id_socio INT REFERENCES socio.socio(id_socio),
    id_actividad INT REFERENCES actividad.actividad(id_actividad),
    fecha_inscripcion DATE NOT NULL
);


-- Participaci�n en actividades extra
CREATE TABLE actividad.participante_actividad_extra (
    id_participante int identity PRIMARY KEY,
    id_socio INT REFERENCES socio.socio(id_socio),
    id_actividad_extra INT REFERENCES actividad.actividad_extra(id_actividad_extra),
	tipo_participante varchar(1)
);

-- Reservas del SUM
CREATE TABLE actividad.reserva_sum (
    id_reserva int identity PRIMARY KEY,
    id_socio INT REFERENCES socio.socio(id_socio),
    id_actividad_extra INT REFERENCES actividad.actividad_extra(id_actividad_extra),
    fecha_reserva DATE NOT NULL
);

-- Facturas mensuales

CREATE TABLE factura.factura_mensual (
    id_factura INT IDENTITY(1,1) PRIMARY KEY,
    fecha_emision DATE,
    fecha_vencimiento DATE,
	segunda_fecha_vencimiento DATE,
    estado VARCHAR(20) DEFAULT 'Pendiente', -- Pagada / Pendiente / Anulada
    total NUMERIC(15,2),
    nro_socio VARCHAR(10),
	total_bruto NUMERIC(15,2) NULL,
    CONSTRAINT FK_factura_nro_socio FOREIGN KEY (nro_socio)
        REFERENCES socio.socio(nro_socio)
);

-- Detalle de factura
CREATE TABLE factura.detalle_factura (
    id_detallefactura int identity PRIMARY KEY,
    id_factura INT REFERENCES factura.factura_mensual(id_factura),
    id_membresia INT REFERENCES socio.membresia(id_membresia),
    id_participante INT REFERENCES actividad.participante_actividad_extra(id_participante),
    id_reserva INT REFERENCES actividad.reserva_sum(id_reserva),
    monto NUMERIC(15,2),
	fecha date,
	id_socio INT NULL,
    id_actividad INT NULL,
	observacion VARCHAR(100) NULL    
);

-- Descuentos
CREATE TABLE factura.descuento (
    id_descuento int identity PRIMARY KEY,
    nombre nvarchar(50) UNIQUE,
    porcentaje NUMERIC(5,2) -- ej: 15.00 para 15%
);

-- Aplicaci�n de descuento
CREATE TABLE factura.aplica_descuento (
    id_descuento INT REFERENCES factura.descuento(id_descuento),
    id_detallefactura INT REFERENCES factura.detalle_factura(id_detallefactura),
    PRIMARY KEY (id_descuento, id_detallefactura)
);

-- Pagos realizados
CREATE TABLE factura.pago (
    id_pago int identity PRIMARY KEY,
    id_factura INT REFERENCES factura.factura_mensual(id_factura),
    fecha_pago DATE NOT NULL,
	id_medio_de_pago INT REFERENCES factura.medio_de_pago(id_medio_de_pago),
	monto NUMERIC(15,2),
	nro_socio VARCHAR(10),
    tipo_pago VARCHAR(20) -- Ej: "Pago completo", "Reembolso", "Pago a cuenta"

);
CREATE TABLE actividad.presentismo (
    id_socio INT NOT NULL,
    id_actividad INT NOT NULL,
    fecha_asistencia DATE NOT NULL,
    asistencia CHAR(1) NOT NULL,  -- 'P' o 'A'
    profesor VARCHAR(100) NULL,
    -- PK compuesta
    CONSTRAINT PK_presentismo PRIMARY KEY (id_socio, id_actividad, fecha_asistencia),
    -- FK a socio.socio(id_socio)
    CONSTRAINT FK_presentismo_socio FOREIGN KEY (id_socio)
        REFERENCES socio.socio(id_socio),
    -- FK a actividad.actividad(id_actividad)
    CONSTRAINT FK_presentismo_actividad FOREIGN KEY (id_actividad)
        REFERENCES actividad.actividad(id_actividad)
);
CREATE TABLE socio.empleado (
    id_empleado INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARBINARY(MAX) NOT NULL,             -- campo encriptado
    apellido VARBINARY(MAX) NOT NULL,           -- campo encriptado
    dni VARBINARY(MAX) NOT NULL,                -- campo encriptado
    telefono VARBINARY(MAX) NULL,               -- campo encriptado
    area VARCHAR(50) NOT NULL,
    rol VARCHAR(50) NOT NULL,
    fecha_alta DATE NOT NULL DEFAULT GETDATE()
);