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
-- ==========================================
-- Pruebas para cuenta
-- ==========================================
use Com5600G02
go
--  INSERTAR CUENTA - CORRECTO
EXEC socio.insertar_cuenta 
    @usuario = 'jpruebab',
    @contrasenia = 'claveSegura123',
    @rol = 'socio',
    @fecha_vigencia_contrasenia = '2025-12-31';

--  INSERTAR CUENTA - ERROR (rol invalido)
EXEC socio.insertar_cuenta 
    @usuario = 'jprueba2',
    @contrasenia = 'claveSegura123',
    @rol = 'usuario',
    @fecha_vigencia_contrasenia = '2025-12-31';

--  MODIFICAR CUENTA - CORRECTO (usar id_usuario valido, ej: 4)
EXEC socio.modificar_cuenta 
    @id_usuario = 6,
    @contrasenia = 'claveSeguraReforzada33333',
    @rol = 'socio',
    @fecha_vigencia_contrasenia = '2026-01-01';

--  MODIFICAR CUENTA - ERROR (contrasenia demasiado corta para modificacion)
EXEC socio.modificar_cuenta 
    @id_usuario = 1,
    @contrasenia = 'corta',
    @rol = 'socio',
    @fecha_vigencia_contrasenia = '2026-01-01';

--  ELIMINAR CUENTA - CORRECTO (usar id valido, ej: 1)
EXEC socio.eliminar_cuenta @id_usuario = 6;

--  ELIMINAR CUENTA - ERROR (id inexistente)
EXEC socio.eliminar_cuenta @id_usuario = 9999;

-- ==========================================
-- Pruebas para medio_pago
-- ==========================================
--  Caso correcto: Insertar medio_pago
EXEC factura.insertar_medio_de_pago 
    @nombre = 'Transferencia Bancaria';

--  Caso incorrecto: Insertar medio_pago (nombre vacio)
EXEC factura.insertar_medio_de_pago 
    @nombre = '';

--  Caso correcto: Modificar medio_pago
EXEC factura.modificar_medio_de_pago 
    @nombre = 'Tarjeta de Credito',
    @id = 1;

--  Caso incorrecto: Modificar medio_pago (nombre invalido)
EXEC factura.modificar_medio_de_pago 
    @nombre = '', 
    @id = 1;

--  Caso correcto: Eliminar medio_pago
EXEC factura.eliminar_medio_de_pago 
    @id = 1;

--  Caso incorrecto: Eliminar medio_pago (ID invalido)
EXEC factura.eliminar_medio_de_pago 
    @id = -1;

-- ==========================================
-- Pruebas para categoria_socio
-- ==========================================

--  INSERTAR CATEGORIA SOCIO - CORRECTO
EXEC socio.insertar_categoria_socio 
    @nombre = 'mayor',
    @edad_min = 18,
    @edad_max = 60,
    @costo = 3000;

--  INSERTAR CATEGORIA SOCIO - ERROR (edad_max < edad_min)
EXEC socio.insertar_categoria_socio 
    @nombre = 'errorEdad',
    @edad_min = 60,
    @edad_max = 18,
    @costo = 3000;

--  MODIFICAR CATEGORIA SOCIO - CORRECTO (usar nombre existente, ej: 'mayor')
EXEC socio.modificar_categoria_socio 
    @nombre = 'mayor',
    @edad_min = 20,
    @edad_max = 65,
    @costo = 3500;

--  MODIFICAR CATEGORIA SOCIO - ERROR (nombre no existe)
EXEC socio.modificar_categoria_socio 
    @nombre = 'inexistente',
    @edad_min = 20,
    @edad_max = 65,
    @costo = 3500;

--  ELIMINAR CATEGORIA SOCIO - CORRECTO (usar nombre existente, ej: 'mayor')
EXEC socio.eliminar_categoria_socio @nombre = 'mayor';

--  ELIMINAR CATEGORIA SOCIO - ERROR (nombre inexistente)
EXEC socio.eliminar_categoria_socio @nombre = 'noexiste';

-- ==========================================
-- Pruebas para grupo_familiar
-- ==========================================

--  INSERTAR GRUPO FAMILIAR - CORRECTO
EXEC socio.insertar_grupo_familiar 
    @nombre = 'Lucía', 
    @apellido = 'Gómez', 
    @dni = '23156789', 
    @email = 'lucia@example.com', 
    @fecha_nacimiento = '2010-06-15', 
    @telefono = '1144556677', 
    @parentesco = 'Hija';

--  INSERTAR GRUPO FAMILIAR - ERROR (DNI repetido o demasiado corto)
EXEC socio.insertar_grupo_familiar 
    @nombre = 'Lucía', 
    @apellido = 'Gómez', 
    @dni = '1234', 
    @email = 'lucia@example.com', 
    @fecha_nacimiento = '2010-06-15', 
    @telefono = '1144556677', 
    @parentesco = 'Hija';

--  MODIFICAR GRUPO FAMILIAR - CORRECTO (usar id valido, ej: 1)
EXEC socio.modificar_grupo_familiar 
    @id_grupo_familiar = 1,
    @email = 'lucia.actualizada@example.com',
    @telefono = '1166778899',
    @parentesco = 'Hija actualizada';

--  MODIFICAR GRUPO FAMILIAR - ERROR (id inexistente)
EXEC socio.modificar_grupo_familiar 
    @id_grupo_familiar = 9999,
    @email = 'error@example.com',
    @telefono = '0000000000',
    @parentesco = 'Error';

--  ELIMINAR GRUPO FAMILIAR - CORRECTO (usar id valido, ej: 1)
EXEC socio.eliminar_grupo_familiar @id_grupo_familiar = 1;

--  ELIMINAR GRUPO FAMILIAR - ERROR (id inexistente)
EXEC socio.eliminar_grupo_familiar @id_grupo_familiar = 9999;

-- ==========================================
-- Pruebas para actividad
-- ==========================================

--  INSERTAR ACTIVIDAD - CORRECTO
EXEC actividad.insertar_actividad 
    @nombre = 'Futsal',
    @costo_mensual = 2500;

--  INSERTAR ACTIVIDAD - ERROR (costo negativo)
EXEC actividad.insertar_actividad 
    @nombre = 'Spinning',
    @costo_mensual = -100;

--  MODIFICAR ACTIVIDAD - CORRECTO (usar ID existente, por ejemplo: 1)
EXEC actividad.modificar_actividad 
    @id = 1,
    @nombre = 'Baile artistico',
    @costo_mensual = 3000;

--  MODIFICAR ACTIVIDAD - ERROR (ID inexistente)
EXEC actividad.modificar_actividad 
    @id = 999,
    @nombre = 'Aeróbicos',
    @costo_mensual = 2000;

--  BORRAR ACTIVIDAD - CORRECTO (usar ID existente, por ejemplo: 1)
EXEC actividad.borrar_actividad @id = 1;

--  BORRAR ACTIVIDAD - ERROR (ID inexistente)
EXEC actividad.borrar_actividad @id = 999;

-- ==========================================
-- Pruebas para factura_mensual
-- ==========================================
--  INSERTAR FACTURA MENSUAL - CORRECTO
EXEC factura.insertar_factura_mensual 
    @fecha_emision = '2025-05-01', 
    @fecha_vencimiento = '2025-05-31', 
    @estado = 'pendiente', 
    @total = 15000;

--  INSERTAR FACTURA MENSUAL - ERROR (monto negativo)
EXEC factura.insertar_factura_mensual 
    @fecha_emision = '2025-05-01', 
    @fecha_vencimiento = '2025-05-31', 
    @estado = 'pendiente', 
    @total = -100;

--  MODIFICAR FACTURA MENSUAL - CORRECTO (usar ID existente, ej: 1)
EXEC factura.modificar_factura_mensual 
    @id = 1,
    @fecha_emision = '2025-05-02', 
    @fecha_vencimiento = '2025-06-01', 
    @estado = 'pagado', 
    @total = 16000;

--  MODIFICAR FACTURA MENSUAL - ERROR (ID inexistente)
EXEC factura.modificar_factura_mensual 
    @id = 9999,
    @fecha_emision = '2025-05-02', 
    @fecha_vencimiento = '2025-06-01', 
    @estado = 'pagado', 
    @total = 16000;

--  ELIMINAR FACTURA MENSUAL - CORRECTO (usar ID existente, ej: 1)
EXEC factura.eliminicar_factura_mensual @id = 1;

--  ELIMINAR FACTURA MENSUAL - ERROR (ID inexistente)
EXEC factura.eliminicar_factura_mensual @id = 9999;

-- ==========================================
-- Pruebas para descuento
-- ==========================================
--  INSERTAR DESCUENTO - CORRECTO
EXEC factura.insertar_descuento @nombre = 'Promo 10%', @porcentaje = 10;

--  INSERTAR DESCUENTO - ERROR (porcentaje invalido)
EXEC factura.insertar_descuento @nombre = 'Error Porcentaje', @porcentaje = -5;

--  MODIFICAR DESCUENTO - CORRECTO (usar un ID valido existente en tu base, ej: 1)
EXEC factura.modificar_descuento @id_descuento = 2, @nombre = 'Promo 15%', @porcentaje = 15;

--  MODIFICAR DESCUENTO - ERROR (ID no existe)
EXEC factura.modificar_descuento @id_descuento = 9999, @nombre = 'Error', @porcentaje = 20;

--  ELIMINAR DESCUENTO - CORRECTO (usar un ID valido existente, ej: 5)
EXEC factura.eliminar_descuento @id = 5;

--  ELIMINAR DESCUENTO - ERROR (ID inexistente)
EXEC factura.eliminar_descuento @id = 9999;


-- ==========================================
-- Pruebas para socio
-- ==========================================

--  INSERTAR SOCIO - CORRECTO
EXEC socio.insertar_socio 
    @dni = '12345478',
    @nombre = 'Juan',
    @apellido = 'Perez',
    @email = 'juan@example.com',
    @fecha_nacimiento = '2000-01-01',
    @telefono_contacto = '1122334455',
    @telefono_emergencia = '1199887766',
    @cobertura_medica = 'OSDE',
    @nro_cobertura_medica = '12345',
    @id_medio_de_pago = 1,
    @id_grupo_familiar = 1,
    @id_categoria = 'mayor';
	SELECT * FROM  socio.socio
--  INSERTAR SOCIO - ERROR (nombre vacio)
EXEC socio.insertar_socio 
    @dni = '12345679',
    @nombre = '',
    @apellido = 'Perez',
    @email = 'juan@example.com',
    @fecha_nacimiento = '2000-01-01',
    @telefono_contacto = '1122334455',
    @telefono_emergencia = '1199887766',
    @cobertura_medica = 'OSDE',
    @nro_cobertura_medica = '12345',
    @id_medio_de_pago = 1,
    @id_grupo_familiar = 1,
    @id_categoria = 'mayor';

--  MODIFICAR SOCIO - CORRECTO (usar id_socio valido, ej: 1)
EXEC socio.modificar_socio 
    @id_socio = 1,
    @email = 'juan.actualizado@example.com',
    @telefono_contacto = '1133445566',
    @telefono_emergencia = '1199776655',
    @cobertura_medica = 'Galeno',
    @nro_cobertura_medica = '67890',
    @id_medio_de_pago = 1,
    @id_grupo_familiar = 1,
    @id_categoria = 'mayor';

--  MODIFICAR SOCIO - ERROR (socio no existe)
EXEC socio.modificar_socio 
    @id_socio = 9999,
    @email = 'error@example.com',
    @telefono_contacto = '0000000000',
    @telefono_emergencia = '0000000000',
    @cobertura_medica = 'Error',
    @nro_cobertura_medica = '0',
    @id_medio_de_pago = 1,
    @id_grupo_familiar = 1,
    @id_categoria = 'mayor';

--  ELIMINAR SOCIO - CORRECTO (usar id valido, ej: 1)
EXEC socio.eliminar_socio @id_socio = 1;

--  ELIMINAR SOCIO - ERROR (id inexistente)
EXEC socio.eliminar_socio @id_socio = 9999;


-- ==========================================
-- Pruebas para membresia
-- ==========================================

---  INSERTAR MEMBRESIA - CORRECTO
EXEC socio.insertar_membresia 
    @id_socio = 28,
    @fecha_inicio = '2025-05-01',
    @fecha_renovada = '2025-05-10',
    @fecha_fin = '2025-12-31',
    @costo = 12000;
	select * from socio.membresia

-- INSERTAR MEMBRESIA - ERROR (fecha de renovación anterior al inicio)
EXEC socio.insertar_membresia 
    @id_socio = 1,
    @fecha_inicio = '2025-05-10',
    @fecha_renovada = '2025-05-01',
    @fecha_fin = '2025-12-31',
    @costo = 12000;

--  MODIFICAR MEMBRESIA - CORRECTO (usar id_membresia valido, ej: 1)
EXEC socio.modificar_membresia 
    @id_membresia = 3,
    @fecha_renovada = '2025-06-01',
    @fecha_fin = '2025-12-31',
    @costo = 12500;

--  MODIFICAR MEMBRESIA - ERROR (id inexistente)
EXEC socio.modificar_membresia 
    @id_membresia = 9999,
    @fecha_renovada = '2025-06-01',
    @fecha_fin = '2025-12-31',
    @costo = 12500;

--  ELIMINAR MEMBRESIA - CORRECTO (usar id valido, ej: 6)
EXEC socio.eliminar_membresia @id_membresia = 6;

--  ELIMINAR MEMBRESIA - ERROR (id inexistente)
EXEC socio.eliminar_membresia @id_membresia = 9999;

-- ==========================================
-- Pruebas para reserva_sum
-- ==========================================

--  INSERTAR RESERVA SUM - CORRECTO (usar IDs existentes, ej: id_socio = 1, id_actividad_extra = 2)
EXEC actividad.insertar_reserva_sum 
    @id_socio = 28,
    @id_actividad_extra = 2,
    @fecha_reserva = '2025-06-10';

--  INSERTAR RESERVA SUM - ERROR (fecha ya reservada)
EXEC actividad.insertar_reserva_sum 
    @id_socio = 1,
    @id_actividad_extra = 2,
    @fecha_reserva = '2025-06-10';

--  MODIFICAR RESERVA SUM - CORRECTO (usar ID existente, cambiar fecha)
EXEC actividad.modificar_reserva_sum 
    @id_reserva = 1,
    @id_socio = 28,
    @id_actividad_extra = 2,
    @fecha_reserva = '2025-06-15';

--  MODIFICAR RESERVA SUM - ERROR (fecha ya reservada por otra reserva)
EXEC actividad.modificar_reserva_sum 
    @id_reserva = 1,
    @id_socio = 1,
    @id_actividad_extra = 2,
    @fecha_reserva = '2025-06-10';

--  ELIMINAR RESERVA SUM - CORRECTO (usar ID existente)
EXEC actividad.eliminar_reserva_sum @id_reserva = 1;

--  ELIMINAR RESERVA SUM - ERROR (ID inexistente)
EXEC actividad.eliminar_reserva_sum @id_reserva = 999;

-- ==========================================
-- Pruebas para actividad
-- ==========================================

--  INSERTAR ACTIVIDAD - CORRECTO
EXEC actividad.insertar_actividad 
    @nombre = 'Futsal',
    @costo_mensual = 2500;

--  INSERTAR ACTIVIDAD - ERROR (costo negativo)
EXEC actividad.insertar_actividad 
    @nombre = 'Spinning',
    @costo_mensual = -100;

--  MODIFICAR ACTIVIDAD - CORRECTO (usar ID existente, por ejemplo: 1)
EXEC actividad.modificar_actividad 
    @id = 1,
    @nombre = 'Baile artistico',
    @costo_mensual = 3000;

--  MODIFICAR ACTIVIDAD - ERROR (ID inexistente)
EXEC actividad.modificar_actividad 
    @id = 999,
    @nombre = 'Aeróbicos',
    @costo_mensual = 2000;

-- BORRAR ACTIVIDAD - CORRECTO (usar ID existente, por ejemplo: 1)
EXEC actividad.borrar_actividad @id = 1;

--  BORRAR ACTIVIDAD - ERROR (ID inexistente)
EXEC actividad.borrar_actividad @id = 999;


-- ==========================================
-- Pruebas para actividad_extra
-- ==========================================

--  INSERTAR ACTIVIDAD EXTRA - CORRECTO
EXEC actividad.insertar_actividad_extra 
    @nombre = 'Colonia verano',
    @costo_adulto = 1500,
    @costo_menor = 800;

--  INSERTAR ACTIVIDAD EXTRA - ERROR (costo menor negativo)
EXEC actividad.insertar_actividad_extra 
    @nombre = 'Excursión',
    @costo_adulto = 1200,
    @costo_menor = -500;

--  MODIFICAR ACTIVIDAD EXTRA - CORRECTO (usar ID existente, por ejemplo: 1)
EXEC actividad.modificar_actividad_extra 
    @id = 1,
    @nombre = 'Sum',
    @costo_adulto = 1800,
    @costo_menor = 900;

--  MODIFICAR ACTIVIDAD EXTRA - ERROR (ID inexistente)
EXEC actividad.modificar_actividad_extra 
    @id = 999,
    @nombre = 'tenis',
    @costo_adulto = 1000,
    @costo_menor = 500;

--  BORRAR ACTIVIDAD EXTRA - CORRECTO (usar ID existente, por ejemplo: 1)
EXEC actividad.borrar_actividad_extra @id = 1;

--  BORRAR ACTIVIDAD EXTRA - ERROR (ID inexistente)
EXEC actividad.borrar_actividad_extra @id = 999;


-- ==========================================
-- Pruebas para inscripcion_actividad
-- ==========================================

--  INSERTAR INSCRIPCION ACTIVIDAD - CORRECTO (usar IDs existentes, ej: id_socio = 1, id_actividad = 2)
EXEC actividad.insertar_inscripcion_actividad 
    @id_socio = 28,
    @id_actividad = 2,
    @fecha_inscripcion = '2025-05-23';
	

--  INSERTAR INSCRIPCION ACTIVIDAD - ERROR (socio inexistente)
EXEC actividad.insertar_inscripcion_actividad 
    @id_socio = 999,
    @id_actividad = 2,
    @fecha_inscripcion = '2025-05-23';

--  MODIFICAR INSCRIPCION ACTIVIDAD - CORRECTO (usar IDs existentes y cambiar fecha)
EXEC actividad.modificar_inscripcion_actividad 
    @id_socio = 28,
    @id_actividad = 2,
    @fecha_inscripcion = '2025-06-01';

--  MODIFICAR INSCRIPCION ACTIVIDAD - ERROR (fecha igual a la ya registrada)
EXEC actividad.modificar_inscripcion_actividad 
    @id_socio = 1,
    @id_actividad = 2,
    @fecha_inscripcion = '2025-06-01';

--  BORRAR INSCRIPCION ACTIVIDAD - CORRECTO (usar IDs existentes)
EXEC actividad.borrar_inscripcion_actividad 
    @id_socio = 28,
    @id_actividad = 2;

--  BORRAR INSCRIPCION ACTIVIDAD - ERROR (inscripcion inexistente)
EXEC actividad.borrar_inscripcion_actividad 
    @id_socio = 1,
    @id_actividad = 999;


-- ==========================================
-- Pruebas para participante_actividad_extra
-- ==========================================

--  INSERTAR PARTICIPANTE ACTIVIDAD EXTRA - CORRECTO (usar IDs existentes, ej: id_socio = 1, id_actividad_extra = 2)
EXEC actividad.insertar_participante_actividad_extra 
    @id_socio = 28,
    @id_actividad_extra = 2,
    @tipo_participante = 'S';

--  INSERTAR PARTICIPANTE ACTIVIDAD EXTRA - ERROR (tipo invalido)
EXEC actividad.insertar_participante_actividad_extra 
    @id_socio = 1,
    @id_actividad_extra = 2,
    @tipo_participante = 'X';

--  MODIFICAR PARTICIPANTE ACTIVIDAD EXTRA - CORRECTO (usar ID existente, cambiar tipo)
EXEC actividad.modificar_participante_actividad_extra 
    @id_participante = 1,
    @id_socio = 28,
    @id_actividad_extra = 2,
    @tipo_participante = 'I';

--  MODIFICAR PARTICIPANTE ACTIVIDAD EXTRA - ERROR (participante no existe)
EXEC actividad.modificar_participante_actividad_extra 
    @id_participante = 999,
    @id_socio = 1,
    @id_actividad_extra = 2,
    @tipo_participante = 'S';

--  ELIMINAR PARTICIPANTE ACTIVIDAD EXTRA - CORRECTO (usar ID existente)
EXEC actividad.borrar_participante_actividad_extra @id_participante = 1;

--  ELIMINAR PARTICIPANTE ACTIVIDAD EXTRA - ERROR (ID inexistente)
EXEC actividad.borrar_participante_actividad_extra @id_participante = 999;


-- ==========================================
-- Pruebas para detalle_factura
-- ==========================================

-- Caso correcto: Insertar Detalle Factura
EXEC factura.insertar_detalle_factura 
    @id_factura = 1,           
    @id_membresia = 3,         
    @id_participante = NULL,   
    @id_reserva = NULL,        
    @monto = 5000.00, 
    @fecha = '2025-05-01';

	
-- Caso incorrecto: Insertar Detalle Factura (factura y demas datos no existen)
EXEC factura.insertar_detalle_factura 
    @id_factura = -99, 
    @id_membresia = -99, 
    @id_participante = -99, 
    @id_reserva = -99, 
    @monto = -100.00, 
    @fecha = NULL;


-- Caso correcto: Eliminar Detalle Factura
-- Asegurarse que exista un detalle_factura con id 11 antes de ejecutar esto
EXEC factura.eliminar_detalle_factura @id_detallefactura = 11;

-- Caso incorrecto: Eliminar Detalle Factura
EXEC factura.eliminar_detalle_factura @id_detallefactura = -1;

-- ==========================================
-- Pruebas para aplica_descuento
-- ==========================================

EXEC factura.insertar_aplica_descuento 
    @id_descuento = 2, 
    @id_detallefactura = 7;

	--incorrecto id inexistente
	EXEC factura.insertar_aplica_descuento 
    @id_descuento = -1, 
    @id_detallefactura = -1;
	--correcto eliminar
	EXEC factura.eliminar_aplica_descuento 
    @id_descuento = 2, 
    @id_detallefactura = 7;
	--incorrecto
	EXEC factura.eliminar_aplica_descuento 
    @id_descuento = -1, 
    @id_detallefactura = -1;