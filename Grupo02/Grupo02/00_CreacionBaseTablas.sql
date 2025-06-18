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


create database Com5600G02;
go
use Com5600G02;
go
create schema socio; 
go
create schema actividad;
go
create schema factura;
go
-- Tabla de usuarios del sistema 
CREATE TABLE socio.cuenta (
    id_usuario int identity (1,1) PRIMARY KEY,
    usuario VARCHAR(50) UNIQUE NOT NULL,
    contrasenia VARCHAR(50) NOT NULL,
	saldo NUMERIC(15,2),
    rol VARCHAR(50) NOT NULL,
    fecha_vigencia_contrasenia DATE NOT NULL
);

-- Tabla de formas de pago
CREATE TABLE factura.medio_de_pago (
    id_medio_de_pago int identity (1,1) PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL -- ej: Visa, Mastercard, Mercado Pago, etc
);

-- Tabla de categorías de socio
CREATE TABLE socio.categoria_socio (
    nombre varchar(50) PRIMARY KEY,
    edad_min INT,
    edad_max INT,
	costo int
);

-- Grupo familiar (responsables/tutores)
CREATE TABLE socio.grupo_familiar (
    id_grupo_familiar int identity (1,1) PRIMARY KEY,
    nombre VARCHAR(50),
    apellido VARCHAR(50),
    dni VARCHAR(10) UNIQUE,
    email VARCHAR(50) UNIQUE,
    fecha_nacimiento DATE,
    telefono VARCHAR(20),
    parentesco VARCHAR(50)
);

-- Tabla de socios
CREATE TABLE socio.socio (
    id_socio int identity (1,1) PRIMARY KEY,
	nro_socio VARCHAR(10) unique not null,
	dni VARCHAR(15)  unique NOT NULL,
    nombre VARCHAR(50) NOT NULL,
    apellido VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    fecha_nacimiento DATE NOT NULL,
    telefono_contacto VARCHAR(20),
    telefono_emergencia VARCHAR(20),
    cobertura_medica VARCHAR(100),
    nro_cobertura_medica VARCHAR(50),
    id_medio_de_pago INT REFERENCES factura.medio_de_pago(id_medio_de_pago),
    id_grupo_familiar INT REFERENCES socio.grupo_familiar(id_grupo_familiar),
    id_categoria varchar(50) REFERENCES socio.categoria_socio(nombre)
);

-- Membresía por socio
CREATE TABLE socio.membresia (
    id_membresia int identity PRIMARY KEY,
    id_socio INT REFERENCES socio.socio(id_socio),
    fecha_inicio DATE NOT NULL,
	fecha_renovada date not null,
    fecha_fin DATE NOT NULL,
    costo NUMERIC(15,2)
);

-- Actividades (natación, futsal, etc.)
CREATE TABLE actividad.actividad (
    id_actividad int identity PRIMARY KEY,
    nombre VARCHAR(50) UNIQUE NOT NULL,
    costo_mensual NUMERIC(15,2)
);

-- Actividades extra (colonia, pileta recreativa, etc.)
CREATE TABLE actividad.actividad_extra (
    id_actividad_extra int identity PRIMARY KEY,
    nombre VARCHAR(50) UNIQUE NOT NULL,
    costo_adulto NUMERIC(15,2),
	costo_menor NUMERIC(15,2)
);

-- Inscripción a actividades deportivas regulares
CREATE TABLE actividad.inscripcion_actividad (
    id_socio INT REFERENCES socio.socio(id_socio),
    id_actividad INT REFERENCES actividad.actividad(id_actividad),
    fecha_inscripcion DATE NOT NULL,
    PRIMARY KEY (id_socio, id_actividad)
);

-- Participación en actividades extra
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
    id_factura int identity PRIMARY KEY,
    fecha_emision DATE NOT NULL,
    fecha_vencimiento DATE NOT NULL,
    estado VARCHAR(20) DEFAULT 'Pendiente', -- Pagada / Pendiente / Anulada
    total NUMERIC(15,2)
);

-- Detalle de factura
CREATE TABLE factura.detalle_factura (
    id_detallefactura int identity PRIMARY KEY,
    id_factura INT REFERENCES factura.factura_mensual(id_factura),
    id_membresia INT REFERENCES socio.membresia(id_membresia),
    id_participante INT REFERENCES actividad.participante_actividad_extra(id_participante),
    id_reserva INT REFERENCES actividad.reserva_sum(id_reserva),
    monto NUMERIC(15,2),
	fecha date
);

-- Descuentos
CREATE TABLE factura.descuento (
    id_descuento int identity PRIMARY KEY,
    nombre nvarchar(50) UNIQUE,
    porcentaje NUMERIC(5,2) -- ej: 15.00 para 15%
);

-- Aplicación de descuento
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
    tipo_pago VARCHAR(20) -- Ej: "Pago completo", "Reembolso", "Pago a cuenta"

);
