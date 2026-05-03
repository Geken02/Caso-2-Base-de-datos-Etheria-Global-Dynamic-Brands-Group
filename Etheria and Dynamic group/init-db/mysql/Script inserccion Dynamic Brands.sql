-- ============================================================================
-- DYNAMIC BRANDS - PAQUETE COMPLETO DE CARGA (VERSIÓN FINAL)
-- Autor: Gerald Hernández Gamboa
-- ============================================================================

USE dynamicbrands_db;

-- 1. SP AUXILIAR: REGISTRAR LOGS
DROP PROCEDURE IF EXISTS spRegistrarLogCarga;
DELIMITER $$
CREATE PROCEDURE spRegistrarLogCarga(
    IN pSpNombre VARCHAR(100), 
    IN pPaso VARCHAR(255), 
    IN pEstado VARCHAR(20), 
    IN pMensaje TEXT
)
BEGIN
    DECLARE vObjetoId, vSourceId, vTipoEventoId, vSeveridadId, vUsuarioId INT DEFAULT 1;
    DECLARE vRef BIGINT;
    SET vRef = UNIX_TIMESTAMP(NOW());
    
    SELECT objetoId INTO vObjetoId FROM Objetos WHERE nombreObjeto = 'PROCEDIMIENTO_CARGA_DATA' LIMIT 1;
    SELECT sourceId INTO vSourceId FROM Sources WHERE nombreSource = 'SCRIPT_SEED_DYNAMIC' LIMIT 1;
    SELECT tipoEventoId INTO vTipoEventoId FROM TiposEvento WHERE nombreEvento = 'SP_CARGA_MASIVA' LIMIT 1; 
    
    IF pEstado = 'ERROR' THEN
        SELECT severidadId INTO vSeveridadId FROM Severidades WHERE nombreSeveridad = 'ERROR' LIMIT 1;
    ELSE
        SELECT severidadId INTO vSeveridadId FROM Severidades WHERE nombreSeveridad = 'INFORMATIVO' LIMIT 1;
    END IF;

    IF vObjetoId IS NOT NULL AND vSourceId IS NOT NULL AND vTipoEventoId IS NOT NULL THEN
        INSERT INTO Logs (tipoEventoId, severidadId, descripcion, sourceId, usuarioId, referenciaId1, objetoId1, checkSum, creadoEn, activo)
        VALUES (vTipoEventoId, COALESCE(vSeveridadId, 2), CONCAT(pSpNombre, ' - ', pPaso), vSourceId, vUsuarioId, vRef, vObjetoId, SHA2(CONCAT(pSpNombre, NOW()), 256), NOW(), TRUE);
    END IF;
END$$
DELIMITER ;

-- 2. SP INICIALIZACIÓN DE METADATOS (VERSIÓN COMPLETA Y CORREGIDA)
DROP PROCEDURE IF EXISTS spInicializarMetadatosDynamic;
DELIMITER $$

CREATE PROCEDURE spInicializarMetadatosDynamic()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION 
    BEGIN 
        GET DIAGNOSTICS CONDITION 1 @msg = MESSAGE_TEXT;
        SELECT CONCAT('ERROR CRITICO EN METADATOS: ', @msg) AS ErrorDetalle;
        ROLLBACK; 
        RESIGNAL;
    END;

    START TRANSACTION;
    
    -- 1. Objetos y Sources
    INSERT INTO Objetos (nombreObjeto, activo) VALUES ('PROCEDIMIENTO_CARGA_DATA', TRUE) ON DUPLICATE KEY UPDATE activo=TRUE;
    INSERT INTO Sources (nombreSource, activo) VALUES ('SCRIPT_SEED_DYNAMIC', TRUE) ON DUPLICATE KEY UPDATE activo=TRUE;
    
    -- 2. Tipos de Evento y Severidades
    INSERT INTO TiposEvento (nombreEvento, descripcion, activo) VALUES ('SP_CARGA_MASIVA', 'Carga masiva Dynamic', TRUE) ON DUPLICATE KEY UPDATE activo=TRUE;
    INSERT INTO Severidades (valorSeveridad, nombreSeveridad, activo) VALUES (2, 'INFORMATIVO', TRUE), (4, 'ERROR', TRUE) ON DUPLICATE KEY UPDATE activo=TRUE;
    
    -- 3. Usuario Admin
    INSERT INTO Usuarios (usuarioId, nombreUsuario, apellido1, apellido2, email, contrasena, activo, creadoEn) 
    VALUES (1, 'admin', 'Administrador', 'Sistema', 'admin@dynamic.com', SHA2('admin123', 256), TRUE, NOW()) 
    ON DUPLICATE KEY UPDATE activo=TRUE;
    
    -- 4. Roles
    INSERT INTO Roles (nombreRol, descripcion, nivelAcceso, activo) VALUES 
    ('SuperAdmin', 'Admin total', 100, TRUE), ('GerenteTienda', 'Gerente', 50, TRUE), ('Cliente', 'Usuario', 10, TRUE) 
    ON DUPLICATE KEY UPDATE activo=TRUE;
    
    -- 5. Estados
    INSERT INTO EstadosTienda (nombreEstadoTienda, permiteVentas, descripcion, activo) VALUES ('Activa', TRUE, 'Operando', TRUE), ('Mantenimiento', FALSE, 'Mantenimiento', TRUE) ON DUPLICATE KEY UPDATE activo=TRUE;
    INSERT INTO EstadosOrdenesVenta (nombreEstadoOrdenVenta, descripcion, activo) VALUES ('Pendiente', 'Esperando', TRUE), ('Pagada', 'Pagada', TRUE), ('Enviada', 'Enviada', TRUE), ('Entregada', 'Entregada', TRUE), ('Cancelada', 'Cancelada', TRUE) ON DUPLICATE KEY UPDATE activo=TRUE;
    INSERT INTO EstadosPago (nombreEstadoPago, descripcion, activo) VALUES ('Pendiente', 'Pendiente', TRUE), ('Aprobado', 'Aprobado', TRUE), ('Rechazado', 'Rechazado', TRUE) ON DUPLICATE KEY UPDATE activo=TRUE;
    INSERT INTO EstadosEnvio (nombreEstadoEnvio, descripcion, activo) VALUES ('Por Despachar', 'Listo', TRUE), ('En Tránsito', 'Camino', TRUE), ('Entregado', 'Entregado', TRUE) ON DUPLICATE KEY UPDATE activo=TRUE;
    INSERT INTO TiposDescuento (nombreTipoDescuento, descripcion, activo) VALUES ('Porcentaje', '%', TRUE), ('MontoFijo', 'Fijo', TRUE) ON DUPLICATE KEY UPDATE activo=TRUE;
    INSERT INTO MetodosPago (nombreMetodoPago, requiereValidacionAdicional, activo) VALUES ('Tarjeta Crédito', TRUE, TRUE), ('PayPal', FALSE, TRUE), ('Transferencia', TRUE, TRUE) ON DUPLICATE KEY UPDATE activo=TRUE;
    INSERT INTO EnfoquesMarketing (nombreEnfoqueMarketing, descripcion, generadoPorIA, activo) VALUES ('General', 'General', FALSE, TRUE), ('Premium', 'Lujo', FALSE, TRUE), ('EcoFriendly', 'Eco', FALSE, TRUE), ('Tech', 'Tech', FALSE, TRUE) ON DUPLICATE KEY UPDATE activo=TRUE;


    -- 6. Paises
    INSERT INTO Paises (paisId, nombrePais, codigoIso, activo) VALUES 
    (1, 'Costa Rica', 'CRC', TRUE),
    (2, 'Brasil', 'BRA', TRUE),
    (3, 'Estados Unidos', 'USA', TRUE),
    (4, 'China', 'CHN', TRUE),
    (5, 'Alemania', 'DEU', TRUE)
    ON DUPLICATE KEY UPDATE nombrePais = VALUES(nombrePais), codigoIso = VALUES(codigoIso);

    -- 7. Monedas
    INSERT INTO Currencies (currencyId, codigoIso, nombreCurrency, currencySymbol, activo) VALUES 
    (2, 'EUR', 'Euro', '€', TRUE),
    (1, 'USD', 'Dolar Estadounidense', '$', TRUE),
    (3, 'BRL', 'Real Brasileno', 'R$', TRUE),
    (4, 'CNY', 'Yuan Chino', '¥', TRUE),
    (5, 'CRC', 'Colon Costarricense', '₡', TRUE)
    ON DUPLICATE KEY UPDATE nombreCurrency = VALUES(nombreCurrency), currencySymbol = VALUES(currencySymbol);


    -- 8. Provincias y Ciudades
    INSERT INTO Provincias (provinciaId, nombreProvincia, paisId, activo) 
    VALUES (1, 'San Jose', 1, TRUE)
    ON DUPLICATE KEY UPDATE nombreProvincia = VALUES(nombreProvincia), paisId = VALUES(paisId);

    INSERT INTO Ciudades (ciudadId, nombreCiudad, provinciaId, activo) 
    VALUES (1, 'San Jose Centro', 1, TRUE)
    ON DUPLICATE KEY UPDATE nombreCiudad = VALUES(nombreCiudad), provinciaId = VALUES(provinciaId);

    -- 9. Tipos Servicio y Courier
    INSERT INTO TiposServicios (tipoServicioId, nombreTipoServicio, activo) 
    VALUES (1, 'Express', TRUE)
    ON DUPLICATE KEY UPDATE nombreTipoServicio = VALUES(nombreTipoServicio);


    INSERT INTO Courier (courierId, nombreCourier, ciudadId, tipoServicioId, tiempoEntregaPromedioDias, activo) 
    VALUES (1, 'Courier Express Global', 1, 1, 3, TRUE)
    ON DUPLICATE KEY UPDATE nombreCourier = VALUES(nombreCourier), ciudadId = VALUES(ciudadId), tipoServicioId = VALUES(tipoServicioId);

    -- 10. Tasas de cambio
    INSERT IGNORE INTO TasasDeCambio (tasaDeCambioId, currencyId1, currencyId2, exchangeRate, activo) VALUES
    -- EUR (1) a otras
    (1, 1, 2, 0.920000, TRUE), (2, 1, 3, 5.050000, TRUE), (3, 1, 4, 7.200000, TRUE), (4, 1, 5, 520.000000, TRUE),
    -- USD (2) a otras
    (5, 2, 1, 1.090000, TRUE), (6, 2, 3, 5.505051, TRUE), (7, 2, 4, 7.841727, TRUE), (8, 2, 5, 567.708333, TRUE),
    -- BRL (3) a otras
    (9, 3, 1, 0.198000, TRUE), (10, 3, 2, 0.181651, TRUE), (11, 3, 4, 1.424460, TRUE), (12, 3, 5, 103.125000, TRUE),
    -- CNY (4) a otras
    (13, 4, 1, 0.139000, TRUE), (14, 4, 2, 0.127523, TRUE), (15, 4, 3, 0.702020, TRUE), (16, 4, 5, 72.395833, TRUE),
    -- CRC (5) a otras
    (17, 5, 1, 0.001920, TRUE), (18, 5, 2, 0.001761, TRUE), (19, 5, 3, 0.009697, TRUE), (20, 5, 4, 0.013813, TRUE),

    (21, 1, 1, 1.000000, TRUE);

    CALL spRegistrarLogCarga('spInicializarMetadatosDynamic', 'Metadatos completos', 'EXITO', 'Catalogos sincronizados con IDs manuales fijos');
    
    COMMIT;
    SELECT 'Metadatos inicializados con IDs Fijos (Paises, Monedas, Geo y Logística)' AS Mensaje;
END$$
DELIMITER ;

-- 3. SP CARGA DE SITIOS WEB (VÍA JSON, NO ARRAYS)
DROP PROCEDURE IF EXISTS spCargarSitiosWebArrays;
DELIMITER $$
CREATE PROCEDURE spCargarSitiosWebArrays(IN p_datosJson JSON)
BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE vTotal INT;
    DECLARE vNombre, vIsoPais, vIsoMoneda, vEnfoque VARCHAR(100);
    DECLARE vPaisId, vMonedaId, vEstadoId, vEnfoqueId, vTiendaId INT;
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION 
	BEGIN 
		GET DIAGNOSTICS CONDITION 1 @msg = MESSAGE_TEXT;
		ROLLBACK; 
		CALL spRegistrarLogCarga('spCargarSitiosWebArrays', 'Fallo', 'ERROR', @msg); 
	END;

    START TRANSACTION;
    CALL spRegistrarLogCarga('spCargarSitiosWebArrays', 'Iniciando carga sitios...', 'INICIO', NULL);

    SET vTotal = JSON_LENGTH(p_datosJson, '$.nombres');
    SELECT estadoTiendaId INTO vEstadoId FROM EstadosTienda WHERE nombreEstadoTienda = 'Activa' LIMIT 1;

    WHILE i < vTotal DO
        SET vNombre = JSON_UNQUOTE(JSON_EXTRACT(p_datosJson, CONCAT('$.nombres[', i, ']')));
        SET vIsoPais = JSON_UNQUOTE(JSON_EXTRACT(p_datosJson, CONCAT('$.paisesIso[', i, ']')));
        SET vIsoMoneda = JSON_UNQUOTE(JSON_EXTRACT(p_datosJson, CONCAT('$.monedasIso[', i, ']')));
        SET vEnfoque = JSON_UNQUOTE(JSON_EXTRACT(p_datosJson, CONCAT('$.enfoques[', i, ']')));

        SELECT paisId INTO vPaisId FROM Paises WHERE codigoIso = vIsoPais LIMIT 1;
        SELECT currencyId INTO vMonedaId FROM Currencies WHERE codigoIso = vIsoMoneda LIMIT 1;
        
        SELECT enfoqueMarketingId INTO vEnfoqueId FROM EnfoquesMarketing WHERE nombreEnfoqueMarketing = vEnfoque LIMIT 1;
        IF vEnfoqueId IS NULL THEN
            INSERT INTO EnfoquesMarketing (nombreEnfoqueMarketing, descripcion, generadoPorIA, activo) VALUES (vEnfoque, CONCAT('Enfoque ', vNombre), TRUE, TRUE);
            SET vEnfoqueId = LAST_INSERT_ID();
        END IF;

        IF vPaisId IS NOT NULL AND vMonedaId IS NOT NULL THEN
            INSERT INTO TiendasVirtualesGeneradas (nombreTienda, paisId, currencyId, estadoTiendaId, enfoqueMarketingId, fechaApertura, activo, creadoEn)
            VALUES (vNombre, vPaisId, vMonedaId, vEstadoId, vEnfoqueId, CURDATE(), TRUE, NOW());
            
            SET vTiendaId = LAST_INSERT_ID();
            INSERT INTO MarcasBlancas (nombreMarcaBlanca, tiendaId, paisId, activo, creadoEn)
            VALUES (CONCAT('Marca Propia ', vNombre), vTiendaId, vPaisId, TRUE, NOW());
        ELSE
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Pais o Moneda no encontrados';
        END IF;
        SET i = i + 1;
    END WHILE;

    CALL spRegistrarLogCarga('spCargarSitiosWebArrays', 'Sitios cargados', 'EXITO', CONCAT('Total: ', vTotal));
    COMMIT;
END$$
DELIMITER ;

-- 4. SP GENERAR CLIENTES
DROP PROCEDURE IF EXISTS spGenerarClientesPorTienda;
DELIMITER $$
CREATE PROCEDURE spGenerarClientesPorTienda()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE vTiendaId, vPaisId INT;
    DECLARE vNombreTienda VARCHAR(100);
    DECLARE i INT DEFAULT 1;
    DECLARE vEmail, vNombre, vApellido1, vApellido2 VARCHAR(100);
    
    DECLARE curTiendas CURSOR FOR SELECT tiendaId, nombreTienda, paisId FROM TiendasVirtualesGeneradas;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION 
	BEGIN 

		GET DIAGNOSTICS CONDITION 1 @msg = MESSAGE_TEXT;
		ROLLBACK; 
		CALL spRegistrarLogCarga('spCargarSitiosWebArrays', 'Fallo', 'ERROR', @msg); 
	END;

    START TRANSACTION;
    CALL spRegistrarLogCarga('spGenerarClientesPorTienda', 'Generando clientes...', 'INICIO', NULL);
    
    OPEN curTiendas;
    read_loop: LOOP
        FETCH curTiendas INTO vTiendaId, vNombreTienda, vPaisId;
        IF done THEN LEAVE read_loop; END IF;
        
        SET i = 1;
        WHILE i <= 5 DO
            SET vNombre = CONCAT('Cliente', i, ' ', SUBSTRING(vNombreTienda, 1, 3));
            SET vApellido1 = 'Hernández'; SET vApellido2 = 'Gamboa';
            SET vEmail = LOWER(CONCAT('cliente', i, '.', REPLACE(vNombreTienda, ' ', '.'), '@email.com'));
            
            INSERT INTO Clientes (tiendaId, email, nombreCliente, apellidoCliente1, apellidoCliente2, paisId, telefono, fechaRegistro, ultimoAcceso, activo, creadoEn)
            VALUES (vTiendaId, vEmail, vNombre, vApellido1, vApellido2, vPaisId, CONCAT('+506 8888-00', i), NOW(), NOW(), TRUE, NOW());
            SET i = i + 1;
        END WHILE;
    END LOOP;
    CLOSE curTiendas;
    
    CALL spRegistrarLogCarga('spGenerarClientesPorTienda', 'Clientes generados', 'EXITO', '5 clientes por tienda creados');
    COMMIT;
END$$
DELIMITER ;

-- 5. SP AUXILIAR: TRANSFORMAR Y VENDER 
DELIMITER $$

DROP PROCEDURE IF EXISTS spTransformarYVenderItem$$

CREATE PROCEDURE spTransformarYVenderItem(
    IN p_ordenVentaId INT, 
    IN p_tiendaId INT, 
    IN p_contadorProductos INT, 
    IN p_skuInterno VARCHAR(20),
    IN p_nombreTecnico VARCHAR(50), 
    IN p_nombreComun VARCHAR(50),
    IN p_nombreMarca VARCHAR(100),
    IN p_codigoIsoPais CHAR(3),
    IN p_nombreTipo VARCHAR(50),
    IN p_nombreUnidad VARCHAR(50),
    IN p_vidaUtil INT,
    IN p_cantidad INT, 
    IN p_precioUnitario DECIMAL(14,2), 
    OUT p_subtotal DECIMAL(14,2)
)
BEGIN
    DECLARE vProductoId, vMarcaOriginalId, vTipoId, vUnidadId, vPaisId INT;
    DECLARE vMarcaBlancaId, vProductoMarcaId, vMonedaId, vTasaId INT;
    DECLARE vErrorMsg TEXT; 
    

    SELECT paisId INTO vPaisId FROM Paises WHERE codigoIso = p_codigoIsoPais LIMIT 1;
    IF vPaisId IS NULL THEN 
        SET vErrorMsg = CONCAT('País no encontrado: ', p_codigoIsoPais);
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = vErrorMsg; 
    END IF;


    SELECT marcaOriginalId INTO vMarcaOriginalId FROM MarcasOriginales WHERE nombreMarcaOriginal = p_nombreMarca LIMIT 1;
    
    IF vMarcaOriginalId IS NULL THEN
        SELECT COALESCE(MAX(marcaOriginalId), 0) + 1 INTO vMarcaOriginalId FROM MarcasOriginales;
        INSERT INTO MarcasOriginales (marcaOriginalId, nombreMarcaOriginal, paisId, activo, fechaSincronizacion) 
        VALUES (vMarcaOriginalId, p_nombreMarca, vPaisId, TRUE, NOW());
    END IF;


    SELECT tipoProductoId INTO vTipoId FROM TiposProducto WHERE nombreTipoProducto = p_nombreTipo LIMIT 1;
    IF vTipoId IS NULL THEN
        SELECT COALESCE(MAX(tipoProductoId), 0) + 1 INTO vTipoId FROM TiposProducto;
        INSERT INTO TiposProducto (tipoProductoId, nombreTipoProducto, activo, fechaSincronizacion) 
        VALUES (vTipoId, p_nombreTipo, TRUE, NOW());
    END IF;


    SELECT UnidadMedidaProductoId INTO vUnidadId FROM UnidadesMedidaProducto WHERE nombreUnidadMedidaProducto = p_nombreUnidad LIMIT 1;
    IF vUnidadId IS NULL THEN
        SELECT COALESCE(MAX(UnidadMedidaProductoId), 0) + 1 INTO vUnidadId FROM UnidadesMedidaProducto;
        INSERT INTO UnidadesMedidaProducto (UnidadMedidaProductoId, nombreUnidadMedidaProducto, descripcion, activo, fechaSincronizacion) 
        VALUES (vUnidadId, p_nombreUnidad, p_nombreUnidad, TRUE, NOW());
    END IF;


    SELECT productoId INTO vProductoId FROM Productos WHERE skuInterno = p_skuInterno LIMIT 1;
    
    IF vProductoId IS NULL THEN
        SELECT COALESCE(MAX(productoId), 0) + 1 INTO vProductoId FROM Productos;
        INSERT INTO Productos (productoId, skuInterno, nombreTecnico, nombreComun, marcaOriginalId, tipoProductoId, unidadMedidaProductoId, vidaUtilMeses, activo, fechaSincronizacion)
        VALUES (vProductoId, p_skuInterno, p_nombreTecnico, p_nombreComun, vMarcaOriginalId, vTipoId, vUnidadId, p_vidaUtil, TRUE, NOW());
    END IF;


    SELECT marcaBlancaId INTO vMarcaBlancaId FROM MarcasBlancas WHERE tiendaId = p_tiendaId LIMIT 1;
    IF vMarcaBlancaId IS NULL THEN
        SELECT COALESCE(MAX(marcaBlancaId), 0) + 1 INTO vMarcaBlancaId FROM MarcasBlancas;
        INSERT INTO MarcasBlancas (marcaBlancaId, nombreMarcaBlanca, tiendaId, paisId, activo, creadoEn)
        VALUES (vMarcaBlancaId, 'Marca Genérica', p_tiendaId, vPaisId, TRUE, NOW());
    END IF;


    SELECT productoMarcaId INTO vProductoMarcaId FROM ProductosMarcasBlancas WHERE productoId = vProductoId AND tiendaId = p_tiendaId LIMIT 1;
    IF vProductoMarcaId IS NULL THEN
        SELECT COALESCE(MAX(productoMarcaId), 0) + 1 INTO vProductoMarcaId FROM ProductosMarcasBlancas;
        INSERT INTO ProductosMarcasBlancas (productoMarcaId, productoId, tiendaId, skuComercial, nombreComercial, marcaBlancaId, stockDisponible, activo, creadoEn)
        VALUES (vProductoMarcaId, vProductoId, p_tiendaId, CONCAT(p_skuInterno, '-DY'), p_nombreComun, vMarcaBlancaId, 1000, TRUE, NOW());
    END IF;


    SELECT currencyId INTO vMonedaId FROM TiendasVirtualesGeneradas WHERE tiendaId = p_tiendaId LIMIT 1;
    
    SELECT tasaDeCambioId INTO vTasaId FROM TasasDeCambio WHERE currencyId1 = vMonedaId AND currencyId2 = vMonedaId LIMIT 1;
    IF vTasaId IS NULL THEN
        SELECT COALESCE(MAX(tasaDeCambioId), 0) + 1 INTO vTasaId FROM TasasDeCambio;
        INSERT INTO TasasDeCambio (tasaDeCambioId, currencyId1, currencyId2, exchangeRate, activo) 
        VALUES (vTasaId, vMonedaId, vMonedaId, 1.0, TRUE);
    END IF;

    SET p_subtotal = p_cantidad * p_precioUnitario;
    
    INSERT INTO DetallesOrdenesVenta (ordenVentaId, productoMarcaId, cantidad, currencyId, precioUnitarioLocal, subtotalLocal, activo, creadoEn)
    VALUES (p_ordenVentaId, vProductoMarcaId, p_cantidad, vMonedaId, p_precioUnitario, p_subtotal, TRUE, NOW());
END$$

DELIMITER ;

-- 6. SP PRINCIPAL: EJECUTAR VENTAS (CURSOR SIMPLE + JSON_TABLE NESTED)
DROP PROCEDURE IF EXISTS spEjecutarVentasYTransformacionJSON;
DELIMITER $$
CREATE PROCEDURE spEjecutarVentasYTransformacionJSON(IN p_datosJson JSON)
BEGIN
    DECLARE done_flag BOOLEAN DEFAULT FALSE;
    DECLARE v_currentOrden VARCHAR(50) DEFAULT '';
    DECLARE v_ordenVentaId, vTiendaId, vClienteId, vEstadoOrdenId, vEstadoPagoId, vEstadoEnvioId, vMonedaId, vPaisId, vMetodoPagoId, vCourierId INT;
    DECLARE vFechaOrden TIMESTAMP;
    DECLARE vSubtotalGeneral, vMontoEnvio, vTotalGeneral, vSubItem DECIMAL(14,2);
    DECLARE vContadorProductos INT DEFAULT 1;
    
    DECLARE c_numeroPedido VARCHAR(50);
    DECLARE c_tiendaId INT;
    DECLARE c_clienteId INT;
    DECLARE c_fechaOrden TIMESTAMP;
    DECLARE c_skuInterno VARCHAR(20);
    DECLARE c_nombreTecnico VARCHAR(50);
    DECLARE c_nombreComun VARCHAR(50);
    DECLARE c_nombreMarca VARCHAR(100);
    DECLARE c_codigoIsoPais CHAR(3);
    DECLARE c_nombreTipo VARCHAR(50);
    DECLARE c_nombreUnidad VARCHAR(50);
    DECLARE c_vidaUtil INT;
    DECLARE c_cantidad INT;
    DECLARE c_precioUnitario DECIMAL(14,2);


    DECLARE cur_ventas CURSOR FOR 
        SELECT 
            numeroPedido, tiendaId, clienteId, fechaOrden,
            skuInterno, nombreTecnico, nombreComun, nombreMarca, 
            codigoIsoPais, nombreTipo, nombreUnidad, vidaUtil, 
            cantidad, precioUnitario
        FROM JSON_TABLE(p_datosJson, '$[*]' COLUMNS(
            numeroPedido VARCHAR(50) PATH '$.numeroPedido',
            tiendaId INT PATH '$.tiendaId',
            clienteId INT PATH '$.clienteId',
            fechaOrden TIMESTAMP PATH '$.fechaOrden',
            NESTED PATH '$.items[*]' COLUMNS(
                skuInterno VARCHAR(20) PATH '$.skuInterno',
                nombreTecnico VARCHAR(50) PATH '$.nombreTecnicoProducto',
                nombreComun VARCHAR(50) PATH '$.nombreComunProducto',
                nombreMarca VARCHAR(100) PATH '$.nombreMarca',
                codigoIsoPais CHAR(3) PATH '$.codigoIsoPais',
                nombreTipo VARCHAR(50) PATH '$.nombreTipoProducto',
                nombreUnidad VARCHAR(50) PATH '$.nombreUnidadMedidaProducto',
                vidaUtil INT PATH '$.vidaUtilMeses',
                cantidad INT PATH '$.cantidad',
                precioUnitario DECIMAL(14,2) PATH '$.precioUnitario'
            )
        )) AS jt
        ORDER BY numeroPedido;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done_flag = TRUE;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION 
    BEGIN 
        GET DIAGNOSTICS CONDITION 1 @errorMsg = MESSAGE_TEXT;
        ROLLBACK; 
        CALL spRegistrarLogCarga('spEjecutarVentasYTransformacionJSON', 'Fallo Critico', 'ERROR', @errorMsg);
        RESIGNAL; 
    END;

    START TRANSACTION;
    CALL spRegistrarLogCarga('spEjecutarVentasYTransformacionJSON', 'Iniciando...', 'INICIO', NULL);

    SELECT estadoOrdenVentaId INTO vEstadoOrdenId FROM EstadosOrdenesVenta WHERE nombreEstadoOrdenVenta = 'Entregada' LIMIT 1;
    SELECT estadoPagoId INTO vEstadoPagoId FROM EstadosPago WHERE nombreEstadoPago = 'Aprobado' LIMIT 1;
    SELECT estadoEnvioId INTO vEstadoEnvioId FROM EstadosEnvio WHERE nombreEstadoEnvio = 'Entregado' LIMIT 1;
    SELECT metodoPagoId INTO vMetodoPagoId FROM MetodosPago WHERE nombreMetodoPago = 'Tarjeta Crédito' LIMIT 1;
    SELECT courierId INTO vCourierId FROM Courier LIMIT 1;

    OPEN cur_ventas;
    
    read_loop: LOOP
        FETCH cur_ventas INTO 
            c_numeroPedido, c_tiendaId, c_clienteId, c_fechaOrden,
            c_skuInterno, c_nombreTecnico, c_nombreComun, c_nombreMarca, 
            c_codigoIsoPais, c_nombreTipo, c_nombreUnidad, c_vidaUtil, 
            c_cantidad, c_precioUnitario;
            
        IF done_flag THEN LEAVE read_loop; END IF;

        IF c_numeroPedido != v_currentOrden THEN
            IF v_ordenVentaId IS NOT NULL THEN
                SET vTotalGeneral = vSubtotalGeneral + vMontoEnvio;
                UPDATE OrdenesVenta SET montoSubtotal = vSubtotalGeneral, montoTotalLocal = vTotalGeneral, montoPagado = vTotalGeneral WHERE ordenVentaId = v_ordenVentaId;
                INSERT INTO Envios (ordenVentaId, courierId, trackingNumber, fechaDespacho, fechaEntregaReal, costoCourierLocal, currencyId, estadoEnvioId, activo, creadoEn)
                VALUES (v_ordenVentaId, vCourierId, CONCAT('TRACK-', v_ordenVentaId, '-DY'), DATE_ADD(vFechaOrden, INTERVAL 1 DAY), DATE_ADD(vFechaOrden, INTERVAL 5 DAY), vMontoEnvio, vMonedaId, vEstadoEnvioId, TRUE, NOW());
            END IF;

            SET v_currentOrden = c_numeroPedido;
            SET vTiendaId = c_tiendaId;
            SET vClienteId = c_clienteId;
            SET vFechaOrden = COALESCE(c_fechaOrden, NOW());
            SET vSubtotalGeneral = 0;
            SET vMontoEnvio = 10.00;
            
            SELECT currencyId, paisId INTO vMonedaId, vPaisId FROM TiendasVirtualesGeneradas WHERE tiendaId = vTiendaId LIMIT 1;

            INSERT INTO OrdenesVenta (tiendaId, clienteId, fechaOrden, numeroPedido, estadoOrdenVentaId, montoSubtotal, montoEnvio, montoTotalLocal, currencyId, tasaDeCambioId, tasaDeCambioAplicada, montoConvertidoBase, paisId, metodoPagoId, montoPagado, monedaPagoId, fechaPago, estadoPagoId, activo, creadoEn)
            VALUES (vTiendaId, vClienteId, vFechaOrden, v_currentOrden, vEstadoOrdenId, 0, vMontoEnvio, 0, vMonedaId, 1, 1.0, 0, vPaisId, vMetodoPagoId, 0, vMonedaId, vFechaOrden, vEstadoPagoId, TRUE, NOW());
            SET v_ordenVentaId = LAST_INSERT_ID();
        END IF;

        CALL spTransformarYVenderItem(
            v_ordenVentaId, vTiendaId, vContadorProductos,
            c_skuInterno, c_nombreTecnico, c_nombreComun, c_nombreMarca, 
            c_codigoIsoPais, c_nombreTipo, c_nombreUnidad, c_vidaUtil, 
            c_cantidad, c_precioUnitario, vSubItem
        );
        
        SET vSubtotalGeneral = vSubtotalGeneral + vSubItem;
        SET vContadorProductos = vContadorProductos + 1;
    END LOOP;
    
    CLOSE cur_ventas;
    
    IF v_ordenVentaId IS NOT NULL THEN
        SET vTotalGeneral = vSubtotalGeneral + vMontoEnvio;
        UPDATE OrdenesVenta SET montoSubtotal = vSubtotalGeneral, montoTotalLocal = vTotalGeneral, montoPagado = vTotalGeneral WHERE ordenVentaId = v_ordenVentaId;
        INSERT INTO Envios (ordenVentaId, courierId, trackingNumber, fechaDespacho, fechaEntregaReal, costoCourierLocal, currencyId, estadoEnvioId, activo, creadoEn)
        VALUES (v_ordenVentaId, vCourierId, CONCAT('TRACK-', v_ordenVentaId, '-DY'), DATE_ADD(vFechaOrden, INTERVAL 1 DAY), DATE_ADD(vFechaOrden, INTERVAL 5 DAY), vMontoEnvio, vMonedaId, vEstadoEnvioId, TRUE, NOW());
    END IF;

    CALL spRegistrarLogCarga('spEjecutarVentasYTransformacionJSON', 'Ventas procesadas', 'EXITO', 'ordenes generadas');
    COMMIT;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS spCargaAutomaticaCompleta;
DELIMITER $$

CREATE PROCEDURE spCargaAutomaticaCompleta()
BEGIN

        DECLARE v_jsonTiendas LONGTEXT DEFAULT '{
        "nombres": [
            "TechStore San José", 
            "EcoLife Costa Rica", 
            "Moda CRC",
            "EcoLife Brasil", 
            "Tech Río",
            "Fashion NYC", 
            "Gourmet USA",
            "Electrónica China",
            "Estilo Europa"
        ],
        "paisesIso": [
            "CRC", 
            "CRC", 
            "CRC",
            "BRA", 
            "BRA",
            "USA", 
            "USA",
            "CHN",
            "ESP"
        ],
        "monedasIso": [
            "CRC", 
            "CRC", 
            "CRC",
            "BRL", 
            "BRL",
            "USD", 
            "USD",
            "CNY",
            "EUR"
        ],
        "enfoques": [
            "Tech", 
            "EcoFriendly", 
            "Fashion",
            "EcoFriendly", 
            "Tech",
            "Premium", 
            "General",
            "Innovación",
            "General"
        ]
    }';


    DECLARE v_jsonVentas LONGTEXT DEFAULT '[
  {
    "numeroPedido": "ORD-DY-IMPORT-CRC-001",
    "tiendaId": 1,
    "clienteId": 1,
    "fechaOrden": "2026-05-02 08:00:00",
    "items": [
      { "skuInterno": "SKU-CRC-001", "nombreTecnicoProducto": "Extracto Vainilla Pure", "nombreComunProducto": "Vainilla Liquida", "nombreMarca": "Sabores Ticos", "codigoIsoPais": "CRC", "nombreTipoProducto": "Alimento", "nombreUnidadMedidaProducto": "Litro", "vidaUtilMeses": 24, "cantidad": 10, "precioUnitario": 15.50 },
      { "skuInterno": "SKU-CRC-002", "nombreTecnicoProducto": "Cafe Gold Roast", "nombreComunProducto": "Cafe Molido", "nombreMarca": "Cafe Nacional", "codigoIsoPais": "CRC", "nombreTipoProducto": "Bebida", "nombreUnidadMedidaProducto": "Kilogramo", "vidaUtilMeses": 12, "cantidad": 20, "precioUnitario": 8.25 },
      { "skuInterno": "SKU-CRC-003", "nombreTecnicoProducto": "Aceite Coco Orgánico", "nombreComunProducto": "Aceite de Coco", "nombreMarca": "Naturaleza CR", "codigoIsoPais": "CRC", "nombreTipoProducto": "Cosmético", "nombreUnidadMedidaProducto": "Litro", "vidaUtilMeses": 18, "cantidad": 15, "precioUnitario": 12.00 },
      { "skuInterno": "SKU-CRC-004", "nombreTecnicoProducto": "Suplemento Proteina Whey", "nombreComunProducto": "Proteína en Polvo", "nombreMarca": "FitTico", "codigoIsoPais": "CRC", "nombreTipoProducto": "Suplemento", "nombreUnidadMedidaProducto": "Kilogramo", "vidaUtilMeses": 24, "cantidad": 8, "precioUnitario": 25.00 },
      { "skuInterno": "SKU-CRC-005", "nombreTecnicoProducto": "Jugo Maracuya Concentrado", "nombreComunProducto": "Concentrado Maracuyá", "nombreMarca": "Frutas Tropicales", "codigoIsoPais": "CRC", "nombreTipoProducto": "Bebida", "nombreUnidadMedidaProducto": "Litro", "vidaUtilMeses": 12, "cantidad": 30, "precioUnitario": 5.50 },
      { "skuInterno": "SKU-CRC-006", "nombreTecnicoProducto": "Chocolate Amargo 70%", "nombreComunProducto": "Barra Chocolate", "nombreMarca": "Cacao CR", "codigoIsoPais": "CRC", "nombreTipoProducto": "Alimento", "nombreUnidadMedidaProducto": "Unidad", "vidaUtilMeses": 18, "cantidad": 50, "precioUnitario": 3.20 },
      { "skuInterno": "SKU-CRC-007", "nombreTecnicoProducto": "Shampoo Aloe Vera", "nombreComunProducto": "Shampoo Natural", "nombreMarca": "BioCR", "codigoIsoPais": "CRC", "nombreTipoProducto": "Cosmético", "nombreUnidadMedidaProducto": "Litro", "vidaUtilMeses": 24, "cantidad": 20, "precioUnitario": 6.80 },
      { "skuInterno": "SKU-CRC-008", "nombreTecnicoProducto": "Vitamina C Complex", "nombreComunProducto": "Suplemento Vitamínico", "nombreMarca": "SaludTica", "codigoIsoPais": "CRC", "nombreTipoProducto": "Suplemento", "nombreUnidadMedidaProducto": "Unidad", "vidaUtilMeses": 24, "cantidad": 40, "precioUnitario": 9.50 },
      { "skuInterno": "SKU-CRC-009", "nombreTecnicoProducto": "Salsa Lizano Style", "nombreComunProducto": "Salsa Inglesa", "nombreMarca": "Sabores Ticos", "codigoIsoPais": "CRC", "nombreTipoProducto": "Alimento", "nombreUnidadMedidaProducto": "Litro", "vidaUtilMeses": 24, "cantidad": 60, "precioUnitario": 4.10 },
      { "skuInterno": "SKU-CRC-010", "nombreTecnicoProducto": "Crema Dental Menta", "nombreComunProducto": "Pasta Dental", "nombreMarca": "SonrisaCR", "codigoIsoPais": "CRC", "nombreTipoProducto": "Cosmético", "nombreUnidadMedidaProducto": "Unidad", "vidaUtilMeses": 24, "cantidad": 100, "precioUnitario": 1.20 },
      { "skuInterno": "SKU-CRC-011", "nombreTecnicoProducto": "Té Verde Orgánico", "nombreComunProducto": "Té en Hojas", "nombreMarca": "Infusiones CR", "codigoIsoPais": "CRC", "nombreTipoProducto": "Bebida", "nombreUnidadMedidaProducto": "Kilogramo", "vidaUtilMeses": 24, "cantidad": 15, "precioUnitario": 18.00 },
      { "skuInterno": "SKU-CRC-012", "nombreTecnicoProducto": "Miel de Abeja Pure", "nombreComunProducto": "Miel Natural", "nombreMarca": "Colmena Tica", "codigoIsoPais": "CRC", "nombreTipoProducto": "Alimento", "nombreUnidadMedidaProducto": "Kilogramo", "vidaUtilMeses": 36, "cantidad": 25, "precioUnitario": 7.50 },
      { "skuInterno": "SKU-CRC-013", "nombreTecnicoProducto": "Loción Hidratante", "nombreComunProducto": "Crema Corporal", "nombreMarca": "BioCR", "codigoIsoPais": "CRC", "nombreTipoProducto": "Cosmético", "nombreUnidadMedidaProducto": "Litro", "vidaUtilMeses": 24, "cantidad": 30, "precioUnitario": 5.90 },
      { "skuInterno": "SKU-CRC-014", "nombreTecnicoProducto": "Colágeno Hidrolizado", "nombreComunProducto": "Suplemento Colágeno", "nombreMarca": "SaludTica", "codigoIsoPais": "CRC", "nombreTipoProducto": "Suplemento", "nombreUnidadMedidaProducto": "Kilogramo", "vidaUtilMeses": 24, "cantidad": 10, "precioUnitario": 32.00 },
      { "skuInterno": "SKU-CRC-015", "nombreTecnicoProducto": "Galletas Avena", "nombreComunProducto": "Galletas Saludables", "nombreMarca": "SnackCR", "codigoIsoPais": "CRC", "nombreTipoProducto": "Alimento", "nombreUnidadMedidaProducto": "Unidad", "vidaUtilMeses": 12, "cantidad": 80, "precioUnitario": 2.50 },
      { "skuInterno": "SKU-CRC-016", "nombreTecnicoProducto": "Agua de Coco Natural", "nombreComunProducto": "Bebida Isotónica", "nombreMarca": "Frutas Tropicales", "codigoIsoPais": "CRC", "nombreTipoProducto": "Bebida", "nombreUnidadMedidaProducto": "Litro", "vidaUtilMeses": 12, "cantidad": 120, "precioUnitario": 1.80 },
      { "skuInterno": "SKU-CRC-017", "nombreTecnicoProducto": "Jabón Artesanal", "nombreComunProducto": "Jabón Natural", "nombreMarca": "Colmena Tica", "codigoIsoPais": "CRC", "nombreTipoProducto": "Cosmético", "nombreUnidadMedidaProducto": "Unidad", "vidaUtilMeses": 24, "cantidad": 50, "precioUnitario": 3.50 },
      { "skuInterno": "SKU-CRC-018", "nombreTecnicoProducto": "Omega 3 Fish Oil", "nombreComunProducto": "Cápsulas Omega 3", "nombreMarca": "SaludTica", "codigoIsoPais": "CRC", "nombreTipoProducto": "Suplemento", "nombreUnidadMedidaProducto": "Unidad", "vidaUtilMeses": 24, "cantidad": 60, "precioUnitario": 14.00 },
      { "skuInterno": "SKU-CRC-019", "nombreTecnicoProducto": "Salsa Picante Habanero", "nombreComunProducto": "Salsa Extra Picante", "nombreMarca": "FuegoCR", "codigoIsoPais": "CRC", "nombreTipoProducto": "Alimento", "nombreUnidadMedidaProducto": "Litro", "vidaUtilMeses": 24, "cantidad": 40, "precioUnitario": 6.20 },
      { "skuInterno": "SKU-CRC-020", "nombreTecnicoProducto": "Batido Proteico Fresa", "nombreComunProducto": "Polvo Batido", "nombreMarca": "FitTico", "codigoIsoPais": "CRC", "nombreTipoProducto": "Suplemento", "nombreUnidadMedidaProducto": "Kilogramo", "vidaUtilMeses": 18, "cantidad": 25, "precioUnitario": 28.00 }
    ]
  },
  {
    "numeroPedido": "ORD-DY-IMPORT-CHN-001",
    "tiendaId": 3,
    "clienteId": 11,
    "fechaOrden": "2026-05-02 09:30:00",
    "items": [
      { "skuInterno": "SKU-CHN-001", "nombreTecnicoProducto": "Sensor IoT Modelo X", "nombreComunProducto": "Sensor Inteligente", "nombreMarca": "TechAsia", "codigoIsoPais": "CHN", "nombreTipoProducto": "Electrónico", "nombreUnidadMedidaProducto": "Unidad", "vidaUtilMeses": 60, "cantidad": 50, "precioUnitario": 15.50 },
      { "skuInterno": "SKU-CHN-002", "nombreTecnicoProducto": "Cable USB-C Rápido", "nombreComunProducto": "Cable Carga", "nombreMarca": "TechAsia", "codigoIsoPais": "CHN", "nombreTipoProducto": "Accesorio", "nombreUnidadMedidaProducto": "Unidad", "vidaUtilMeses": 120, "cantidad": 100, "precioUnitario": 2.50 },
      { "skuInterno": "SKU-CHN-003", "nombreTecnicoProducto": "Auriculares Bluetooth Pro", "nombreComunProducto": "Audífonos Inalámbricos", "nombreMarca": "SoundChina", "codigoIsoPais": "CHN", "nombreTipoProducto": "Electrónico", "nombreUnidadMedidaProducto": "Unidad", "vidaUtilMeses": 36, "cantidad": 30, "precioUnitario": 22.00 },
      { "skuInterno": "SKU-CHN-004", "nombreTecnicoProducto": "Power Bank 20000mAh", "nombreComunProducto": "Batería Externa", "nombreMarca": "PowerEast", "codigoIsoPais": "CHN", "nombreTipoProducto": "Accesorio", "nombreUnidadMedidaProducto": "Unidad", "vidaUtilMeses": 48, "cantidad": 40, "precioUnitario": 18.50 },
      { "skuInterno": "SKU-CHN-005", "nombreTecnicoProducto": "Soporte Laptop Aluminio", "nombreComunProducto": "Stand Computadora", "nombreMarca": "OfficeChina", "codigoIsoPais": "CHN", "nombreTipoProducto": "Accesorio", "nombreUnidadMedidaProducto": "Unidad", "vidaUtilMeses": 120, "cantidad": 20, "precioUnitario": 12.00 },
      { "skuInterno": "SKU-CHN-006", "nombreTecnicoProducto": "Teclado Mecánico RGB", "nombreComunProducto": "Teclado Gaming", "nombreMarca": "GameTech", "codigoIsoPais": "CHN", "nombreTipoProducto": "Electrónico", "nombreUnidadMedidaProducto": "Unidad", "vidaUtilMeses": 60, "cantidad": 15, "precioUnitario": 45.00 },
      { "skuInterno": "SKU-CHN-007", "nombreTecnicoProducto": "Mouse Ergonómico", "nombreComunProducto": "Ratón PC", "nombreMarca": "GameTech", "codigoIsoPais": "CHN", "nombreTipoProducto": "Accesorio", "nombreUnidadMedidaProducto": "Unidad", "vidaUtilMeses": 48, "cantidad": 35, "precioUnitario": 15.00 },
      { "skuInterno": "SKU-CHN-008", "nombreTecnicoProducto": "Webcam 4K Ultra", "nombreComunProducto": "Cámara Web", "nombreMarca": "VisionChina", "codigoIsoPais": "CHN", "nombreTipoProducto": "Electrónico", "nombreUnidadMedidaProducto": "Unidad", "vidaUtilMeses": 36, "cantidad": 10, "precioUnitario": 55.00 },
      { "skuInterno": "SKU-CHN-009", "nombreTecnicoProducto": "Hub USB 7 Puertos", "nombreComunProducto": "Multipuerto USB", "nombreMarca": "ConnectEast", "codigoIsoPais": "CHN", "nombreTipoProducto": "Accesorio", "nombreUnidadMedidaProducto": "Unidad", "vidaUtilMeses": 60, "cantidad": 25, "precioUnitario": 19.00 },
      { "skuInterno": "SKU-CHN-010", "nombreTecnicoProducto": "Monitor LED 24 Pulgadas", "nombreComunProducto": "Pantalla PC", "nombreMarca": "ViewChina", "codigoIsoPais": "CHN", "nombreTipoProducto": "Electrónico", "nombreUnidadMedidaProducto": "Unidad", "vidaUtilMeses": 60, "cantidad": 8, "precioUnitario": 120.00 },
      { "skuInterno": "SKU-CHN-011", "nombreTecnicoProducto": "Tablet Gráfica Digital", "nombreComunProducto": "Tablet Dibujo", "nombreMarca": "ArtTech", "codigoIsoPais": "CHN", "nombreTipoProducto": "Electrónico", "nombreUnidadMedidaProducto": "Unidad", "vidaUtilMeses": 48, "cantidad": 6, "precioUnitario": 85.00 },
      { "skuInterno": "SKU-CHN-012", "nombreTecnicoProducto": "Micrófono Condensador", "nombreComunProducto": "Micrófono Estudio", "nombreMarca": "AudioEast", "codigoIsoPais": "CHN", "nombreTipoProducto": "Electrónico", "nombreUnidadMedidaProducto": "Unidad", "vidaUtilMeses": 60, "cantidad": 9, "precioUnitario": 65.00 },
      { "skuInterno": "SKU-CHN-013", "nombreTecnicoProducto": "Lámpara Escritorio LED", "nombreComunProducto": "Luz Mesa", "nombreMarca": "LightChina", "codigoIsoPais": "CHN", "nombreTipoProducto": "Accesorio", "nombreUnidadMedidaProducto": "Unidad", "vidaUtilMeses": 60, "cantidad": 30, "precioUnitario": 25.00 },
      { "skuInterno": "SKU-CHN-014", "nombreTecnicoProducto": "Adaptador HDMI a VGA", "nombreComunProducto": "Convertidor Video", "nombreMarca": "ConnectEast", "codigoIsoPais": "CHN", "nombreTipoProducto": "Accesorio", "nombreUnidadMedidaProducto": "Unidad", "vidaUtilMeses": 120, "cantidad": 50, "precioUnitario": 8.00 },
      { "skuInterno": "SKU-CHN-015", "nombreTecnicoProducto": "Disco SSD 500GB", "nombreComunProducto": "Almacenamiento Sólido", "nombreMarca": "DataChina", "codigoIsoPais": "CHN", "nombreTipoProducto": "Electrónico", "nombreUnidadMedidaProducto": "Unidad", "vidaUtilMeses": 60, "cantidad": 20, "precioUnitario": 45.00 },
      { "skuInterno": "SKU-CHN-016", "nombreTecnicoProducto": "Memoria RAM 16GB", "nombreComunProducto": "Memoria PC", "nombreMarca": "MemoryEast", "codigoIsoPais": "CHN", "nombreTipoProducto": "Electrónico", "nombreUnidadMedidaProducto": "Unidad", "vidaUtilMeses": 120, "cantidad": 15, "precioUnitario": 55.00 },
      { "skuInterno": "SKU-CHN-017", "nombreTecnicoProducto": "Ventilador CPU Silencioso", "nombreComunProducto": "Cooler Procesador", "nombreMarca": "CoolTech", "codigoIsoPais": "CHN", "nombreTipoProducto": "Accesorio", "nombreUnidadMedidaProducto": "Unidad", "vidaUtilMeses": 60, "cantidad": 40, "precioUnitario": 18.00 },
      { "skuInterno": "SKU-CHN-018", "nombreTecnicoProducto": "Tarjeta de Red WiFi 6", "nombreComunProducto": "Adaptador Inalámbrico", "nombreMarca": "NetChina", "codigoIsoPais": "CHN", "nombreTipoProducto": "Electrónico", "nombreUnidadMedidaProducto": "Unidad", "vidaUtilMeses": 60, "cantidad": 25, "precioUnitario": 28.00 },
      { "skuInterno": "SKU-CHN-019", "nombreTecnicoProducto": "Cámara Seguridad IP", "nombreComunProducto": "Cámara Vigilancia", "nombreMarca": "SecureEast", "codigoIsoPais": "CHN", "nombreTipoProducto": "Electrónico", "nombreUnidadMedidaProducto": "Unidad", "vidaUtilMeses": 48, "cantidad": 12, "precioUnitario": 75.00 },
      { "skuInterno": "SKU-CHN-020", "nombreTecnicoProducto": "Control Remoto Universal", "nombreComunProducto": "Mando Multi", "nombreMarca": "SmartChina", "codigoIsoPais": "CHN", "nombreTipoProducto": "Accesorio", "nombreUnidadMedidaProducto": "Unidad", "vidaUtilMeses": 60, "cantidad": 60, "precioUnitario": 12.00 }
    ]
  },
  {
    "numeroPedido": "ORD-DY-IMPORT-BRA-001",
    "tiendaId": 2,
    "clienteId": 6,
    "fechaOrden": "2026-05-02 11:00:00",
    "items": [
      { "skuInterno": "SKU-BRA-001", "nombreTecnicoProducto": "Aceite Esencial Lavanda", "nombreComunProducto": "Esencia Lavanda", "nombreMarca": "BrasilBio", "codigoIsoPais": "BRA", "nombreTipoProducto": "Cosmético", "nombreUnidadMedidaProducto": "Litro", "vidaUtilMeses": 24, "cantidad": 10, "precioUnitario": 45.00 },
      { "skuInterno": "SKU-BRA-002", "nombreTecnicoProducto": "Aceite Árbol de Té", "nombreComunProducto": "Esencia Tea Tree", "nombreMarca": "BrasilBio", "codigoIsoPais": "BRA", "nombreTipoProducto": "Cosmético", "nombreUnidadMedidaProducto": "Litro", "vidaUtilMeses": 24, "cantidad": 8, "precioUnitario": 38.00 },
      { "skuInterno": "SKU-BRA-003", "nombreTecnicoProducto": "Crema Hidratante Açaí", "nombreComunProducto": "Loción Corporal", "nombreMarca": "AmazoniaCare", "codigoIsoPais": "BRA", "nombreTipoProducto": "Cosmético", "nombreUnidadMedidaProducto": "Litro", "vidaUtilMeses": 18, "cantidad": 20, "precioUnitario": 12.50 },
      { "skuInterno": "SKU-BRA-004", "nombreTecnicoProducto": "Jabón Exfoliante Café", "nombreComunProducto": "Jabón Artesanal", "nombreMarca": "PurezaBR", "codigoIsoPais": "BRA", "nombreTipoProducto": "Cosmético", "nombreUnidadMedidaProducto": "Unidad", "vidaUtilMeses": 24, "cantidad": 50, "precioUnitario": 4.50 },
      { "skuInterno": "SKU-BRA-005", "nombreTecnicoProducto": "Suplemento Spirulina", "nombreComunProducto": "Alga en Polvo", "nombreMarca": "VidaVerde", "codigoIsoPais": "BRA", "nombreTipoProducto": "Suplemento", "nombreUnidadMedidaProducto": "Kilogramo", "vidaUtilMeses": 24, "cantidad": 15, "precioUnitario": 22.00 },
      { "skuInterno": "SKU-BRA-006", "nombreTecnicoProducto": "Aceite Coconut Virgin", "nombreComunProducto": "Aceite de Coco", "nombreMarca": "CocoBR", "codigoIsoPais": "BRA", "nombreTipoProducto": "Alimento", "nombreUnidadMedidaProducto": "Litro", "vidaUtilMeses": 24, "cantidad": 30, "precioUnitario": 15.00 },
      { "skuInterno": "SKU-BRA-007", "nombreTecnicoProducto": "Té Hibisco Orgánico", "nombreComunProducto": "Infusión Flor", "nombreMarca": "CháNatural", "codigoIsoPais": "BRA", "nombreTipoProducto": "Bebida", "nombreUnidadMedidaProducto": "Kilogramo", "vidaUtilMeses": 24, "cantidad": 25, "precioUnitario": 18.00 },
      { "skuInterno": "SKU-BRA-008", "nombreTecnicoProducto": "Mascarilla Arcilla Verde", "nombreComunProducto": "Tratamiento Facial", "nombreMarca": "AmazoniaCare", "codigoIsoPais": "BRA", "nombreTipoProducto": "Cosmético", "nombreUnidadMedidaProducto": "Kilogramo", "vidaUtilMeses": 24, "cantidad": 18, "precioUnitario": 25.00 },
      { "skuInterno": "SKU-BRA-009", "nombreTecnicoProducto": "Desodorante Cristal", "nombreComunProducto": "Antitranspirante Natural", "nombreMarca": "PurezaBR", "codigoIsoPais": "BRA", "nombreTipoProducto": "Cosmético", "nombreUnidadMedidaProducto": "Unidad", "vidaUtilMeses": 36, "cantidad": 40, "precioUnitario": 6.50 },
      { "skuInterno": "SKU-BRA-010", "nombreTecnicoProducto": "Vitamina E Pura", "nombreComunProducto": "Suplemento Antioxidante", "nombreMarca": "VidaVerde", "codigoIsoPais": "BRA", "nombreTipoProducto": "Suplemento", "nombreUnidadMedidaProducto": "Unidad", "vidaUtilMeses": 24, "cantidad": 30, "precioUnitario": 14.00 },
      { "skuInterno": "SKU-BRA-011", "nombreTecnicoProducto": "Leche Magnesia Cosmetic", "nombreComunProducto": "Loción Calmante", "nombreMarca": "DermaBR", "codigoIsoPais": "BRA", "nombreTipoProducto": "Cosmético", "nombreUnidadMedidaProducto": "Litro", "vidaUtilMeses": 24, "cantidad": 35, "precioUnitario": 8.00 },
      { "skuInterno": "SKU-BRA-012", "nombreTecnicoProducto": "Exfoliante Azúcar Moreno", "nombreComunProducto": "Scrub Corporal", "nombreMarca": "CocoBR", "codigoIsoPais": "BRA", "nombreTipoProducto": "Cosmético", "nombreUnidadMedidaProducto": "Kilogramo", "vidaUtilMeses": 18, "cantidad": 22, "precioUnitario": 11.00 },
      { "skuInterno": "SKU-BRA-013", "nombreTecnicoProducto": "Serum Facial Retinol", "nombreComunProducto": "Tratamiento Anti-edad", "nombreMarca": "AmazoniaCare", "codigoIsoPais": "BRA", "nombreTipoProducto": "Cosmético", "nombreUnidadMedidaProducto": "Litro", "vidaUtilMeses": 12, "cantidad": 10, "precioUnitario": 55.00 },
      { "skuInterno": "SKU-BRA-014", "nombreTecnicoProducto": "Champú Sin Sal", "nombreComunProducto": "Lavado Suave", "nombreMarca": "CabelloSano", "codigoIsoPais": "BRA", "nombreTipoProducto": "Cosmético", "nombreUnidadMedidaProducto": "Litro", "vidaUtilMeses": 24, "cantidad": 45, "precioUnitario": 9.50 },
      { "skuInterno": "SKU-BRA-015", "nombreTecnicoProducto": "Acondicionador Keratina", "nombreComunProducto": "Tratamiento Capilar", "nombreMarca": "CabelloSano", "codigoIsoPais": "BRA", "nombreTipoProducto": "Cosmético", "nombreUnidadMedidaProducto": "Litro", "vidaUtilMeses": 24, "cantidad": 40, "precioUnitario": 13.00 },
      { "skuInterno": "SKU-BRA-016", "nombreTecnicoProducto": "Protector Solar FPS 50", "nombreComunProducto": "Bloqueador Solar", "nombreMarca": "SunBR", "codigoIsoPais": "BRA", "nombreTipoProducto": "Cosmético", "nombreUnidadMedidaProducto": "Litro", "vidaUtilMeses": 24, "cantidad": 60, "precioUnitario": 16.00 },
      { "skuInterno": "SKU-BRA-017", "nombreTecnicoProducto": "After Sun Aloe", "nombreComunProducto": "Gel Post-Solar", "nombreMarca": "SunBR", "codigoIsoPais": "BRA", "nombreTipoProducto": "Cosmético", "nombreUnidadMedidaProducto": "Litro", "vidaUtilMeses": 24, "cantidad": 35, "precioUnitario": 10.00 },
      { "skuInterno": "SKU-BRA-018", "nombreTecnicoProducto": "Repelente Insectos Citronela", "nombreComunProducto": "Spray Antimosquitos", "nombreMarca": "NatureProtect", "codigoIsoPais": "BRA", "nombreTipoProducto": "Cosmético", "nombreUnidadMedidaProducto": "Litro", "vidaUtilMeses": 24, "cantidad": 50, "precioUnitario": 7.50 },
      { "skuInterno": "SKU-BRA-019", "nombreTecnicoProducto": "Bálsamo Labial Cacao", "nombreComunProducto": "Protector Labios", "nombreMarca": "CocoBR", "codigoIsoPais": "BRA", "nombreTipoProducto": "Cosmético", "nombreUnidadMedidaProducto": "Unidad", "vidaUtilMeses": 24, "cantidad": 80, "precioUnitario": 2.50 },
      { "skuInterno": "SKU-BRA-020", "nombreTecnicoProducto": "Sales Baño Relajante", "nombreComunProducto": "Sales Aromáticas", "nombreMarca": "SpaBR", "codigoIsoPais": "BRA", "nombreTipoProducto": "Cosmético", "nombreUnidadMedidaProducto": "Kilogramo", "vidaUtilMeses": 36, "cantidad": 30, "precioUnitario": 9.00 }
    ]
  },
  {
    "numeroPedido": "ORD-DY-IMPORT-DEU-USA-001",
    "tiendaId": 4,
    "clienteId": 16,
    "fechaOrden": "2026-05-02 13:00:00",
    "items": [
      { "skuInterno": "SKU-DEU-001", "nombreTecnicoProducto": "Rodamiento Acero Inox", "nombreComunProducto": "Balero Industrial", "nombreMarca": "PrecisionDE", "codigoIsoPais": "DEU", "nombreTipoProducto": "Repuesto", "nombreUnidadMedidaProducto": "Unidad", "vidaUtilMeses": 120, "cantidad": 20, "precioUnitario": 35.00 },
      { "skuInterno": "SKU-DEU-002", "nombreTecnicoProducto": "Sensor Presión Digital", "nombreComunProducto": "Transductor Presión", "nombreMarca": "AutoSense", "codigoIsoPais": "DEU", "nombreTipoProducto": "Electrónico", "nombreUnidadMedidaProducto": "Unidad", "vidaUtilMeses": 60, "cantidad": 15, "precioUnitario": 85.00 },
      { "skuInterno": "SKU-DEU-003", "nombreTecnicoProducto": "Válvula Solenoide 24V", "nombreComunProducto": "Válvula Control", "nombreMarca": "FluidControl", "codigoIsoPais": "DEU", "nombreTipoProducto": "Repuesto", "nombreUnidadMedidaProducto": "Unidad", "vidaUtilMeses": 84, "cantidad": 10, "precioUnitario": 120.00 },
      { "skuInterno": "SKU-DEU-004", "nombreTecnicoProducto": "Motor Eléctrico 2HP", "nombreComunProducto": "Motor Industrial", "nombreMarca": "PowerDrive", "codigoIsoPais": "DEU", "nombreTipoProducto": "Maquinaria", "nombreUnidadMedidaProducto": "Unidad", "vidaUtilMeses": 120, "cantidad": 5, "precioUnitario": 450.00 },
      { "skuInterno": "SKU-DEU-005", "nombreTecnicoProducto": "Engranaje Helicoidal", "nombreComunProducto": "Piñón Transmisión", "nombreMarca": "GearMaster", "codigoIsoPais": "DEU", "nombreTipoProducto": "Repuesto", "nombreUnidadMedidaProducto": "Unidad", "vidaUtilMeses": 120, "cantidad": 8, "precioUnitario": 65.00 },
      { "skuInterno": "SKU-DEU-006", "nombreTecnicoProducto": "Filtro Hidráulico", "nombreComunProducto": "Elemento Filtrante", "nombreMarca": "PureFlow", "codigoIsoPais": "DEU", "nombreTipoProducto": "Repuesto", "nombreUnidadMedidaProducto": "Unidad", "vidaUtilMeses": 24, "cantidad": 30, "precioUnitario": 28.00 },
      { "skuInterno": "SKU-DEU-007", "nombreTecnicoProducto": "Correa Distribución Kevlar", "nombreComunProducto": "Banda Transmisión", "nombreMarca": "StrongBelt", "codigoIsoPais": "DEU", "nombreTipoProducto": "Repuesto", "nombreUnidadMedidaProducto": "Unidad", "vidaUtilMeses": 60, "cantidad": 25, "precioUnitario": 42.00 },
      { "skuInterno": "SKU-DEU-008", "nombreTecnicoProducto": "Controlador PLC Modular", "nombreComunProducto": "Autómata Programable", "nombreMarca": "AutoLogic", "codigoIsoPais": "DEU", "nombreTipoProducto": "Electrónico", "nombreUnidadMedidaProducto": "Unidad", "vidaUtilMeses": 120, "cantidad": 4, "precioUnitario": 850.00 },
      { "skuInterno": "SKU-DEU-009", "nombreTecnicoProducto": "Panel Táctil HMI", "nombreComunProducto": "Interfaz Operador", "nombreMarca": "TouchTech", "codigoIsoPais": "DEU", "nombreTipoProducto": "Electrónico", "nombreUnidadMedidaProducto": "Unidad", "vidaUtilMeses": 84, "cantidad": 6, "precioUnitario": 620.00 },
      { "skuInterno": "SKU-DEU-010", "nombreTecnicoProducto": "Variador Frecuencia 5kW", "nombreComunProducto": "Inversor Motor", "nombreMarca": "SpeedControl", "codigoIsoPais": "DEU", "nombreTipoProducto": "Electrónico", "nombreUnidadMedidaProducto": "Unidad", "vidaUtilMeses": 120, "cantidad": 7, "precioUnitario": 550.00 },
      { "skuInterno": "SKU-DEU-011", "nombreTecnicoProducto": "Cilindro Neumático", "nombreComunProducto": "Actuador Aire", "nombreMarca": "AirForce", "codigoIsoPais": "DEU", "nombreTipoProducto": "Repuesto", "nombreUnidadMedidaProducto": "Unidad", "vidaUtilMeses": 84, "cantidad": 12, "precioUnitario": 95.00 },
      { "skuInterno": "SKU-DEU-012", "nombreTecnicoProducto": "Regulador Presión Aire", "nombreComunProducto": "Válvula Reguladora", "nombreMarca": "AirForce", "codigoIsoPais": "DEU", "nombreTipoProducto": "Repuesto", "nombreUnidadMedidaProducto": "Unidad", "vidaUtilMeses": 84, "cantidad": 20, "precioUnitario": 45.00 },
      { "skuInterno": "SKU-DEU-013", "nombreTecnicoProducto": "Acoplamiento Elástico", "nombreComunProducto": "Junta Transmisión", "nombreMarca": "FlexCouple", "codigoIsoPais": "DEU", "nombreTipoProducto": "Repuesto", "nombreUnidadMedidaProducto": "Unidad", "vidaUtilMeses": 60, "cantidad": 18, "precioUnitario": 55.00 },
      { "skuInterno": "SKU-DEU-014", "nombreTecnicoProducto": "Interruptor Nivel Flotante", "nombreComunProducto": "Sensor Nivel", "nombreMarca": "LevelDetect", "codigoIsoPais": "DEU", "nombreTipoProducto": "Electrónico", "nombreUnidadMedidaProducto": "Unidad", "vidaUtilMeses": 60, "cantidad": 25, "precioUnitario": 32.00 },
      { "skuInterno": "SKU-DEU-015", "nombreTecnicoProducto": "Termopar Tipo K", "nombreComunProducto": "Sensor Temperatura", "nombreMarca": "TempSense", "codigoIsoPais": "DEU", "nombreTipoProducto": "Repuesto", "nombreUnidadMedidaProducto": "Unidad", "vidaUtilMeses": 60, "cantidad": 40, "precioUnitario": 18.00 },
      { "skuInterno": "SKU-DEU-016", "nombreTecnicoProducto": "Relé Estado Sólido", "nombreComunProducto": "Interruptor Electrónico", "nombreMarca": "SwitchPro", "codigoIsoPais": "DEU", "nombreTipoProducto": "Electrónico", "nombreUnidadMedidaProducto": "Unidad", "vidaUtilMeses": 120, "cantidad": 30, "precioUnitario": 25.00 },
      { "skuInterno": "SKU-DEU-017", "nombreTecnicoProducto": "Fuente Poder 24V 10A", "nombreComunProducto": "Alimentador DC", "nombreMarca": "PowerSupply", "codigoIsoPais": "DEU", "nombreTipoProducto": "Electrónico", "nombreUnidadMedidaProducto": "Unidad", "vidaUtilMeses": 84, "cantidad": 15, "precioUnitario": 75.00 },
      { "skuInterno": "SKU-DEU-018", "nombreTecnicoProducto": "Codificador Rotativo", "nombreComunProducto": "Encoder Posición", "nombreMarca": "PrecisionDE", "codigoIsoPais": "DEU", "nombreTipoProducto": "Electrónico", "nombreUnidadMedidaProducto": "Unidad", "vidaUtilMeses": 84, "cantidad": 9, "precioUnitario": 180.00 },
      { "skuInterno": "SKU-DEU-019", "nombreTecnicoProducto": "Manómetro Glicerina", "nombreComunProducto": "Medidor Presión", "nombreMarca": "GaugeMaster", "codigoIsoPais": "DEU", "nombreTipoProducto": "Repuesto", "nombreUnidadMedidaProducto": "Unidad", "vidaUtilMeses": 60, "cantidad": 22, "precioUnitario": 38.00 },
      { "skuInterno": "SKU-DEU-020", "nombreTecnicoProducto": "Boquilla Neumática", "nombreComunProducto": "Tobera Aire", "nombreMarca": "AirNozzle", "codigoIsoPais": "DEU", "nombreTipoProducto": "Repuesto", "nombreUnidadMedidaProducto": "Unidad", "vidaUtilMeses": 120, "cantidad": 50, "precioUnitario": 12.00 },
      { "skuInterno": "SKU-USA-001", "nombreTecnicoProducto": "Taladro Percutor 800W", "nombreComunProducto": "Taladro Eléctrico", "nombreMarca": "ToolMaster", "codigoIsoPais": "USA", "nombreTipoProducto": "Herramienta", "nombreUnidadMedidaProducto": "Unidad", "vidaUtilMeses": 60, "cantidad": 10, "precioUnitario": 85.00 },
      { "skuInterno": "SKU-USA-002", "nombreTecnicoProducto": "Sierra Circular 1500W", "nombreComunProducto": "Sierra Madera", "nombreMarca": "CutPro", "codigoIsoPais": "USA", "nombreTipoProducto": "Herramienta", "nombreUnidadMedidaProducto": "Unidad", "vidaUtilMeses": 60, "cantidad": 8, "precioUnitario": 120.00 },
      { "skuInterno": "SKU-USA-003", "nombreTecnicoProducto": "Lijadora Orbital", "nombreComunProducto": "Pulidora Superficie", "nombreMarca": "SmoothFinish", "codigoIsoPais": "USA", "nombreTipoProducto": "Herramienta", "nombreUnidadMedidaProducto": "Unidad", "vidaUtilMeses": 48, "cantidad": 15, "precioUnitario": 65.00 },
      { "skuInterno": "SKU-USA-004", "nombreTecnicoProducto": "Compresor Aire 50L", "nombreComunProducto": "Compresor Neumático", "nombreMarca": "AirPower", "codigoIsoPais": "USA", "nombreTipoProducto": "Maquinaria", "nombreUnidadMedidaProducto": "Unidad", "vidaUtilMeses": 120, "cantidad": 4, "precioUnitario": 350.00 },
      { "skuInterno": "SKU-USA-005", "nombreTecnicoProducto": "Juego Llaves Combinadas", "nombreComunProducto": "Set Herramientas", "nombreMarca": "WrenchKing", "codigoIsoPais": "USA", "nombreTipoProducto": "Herramienta", "nombreUnidadMedidaProducto": "Unidad", "vidaUtilMeses": 240, "cantidad": 20, "precioUnitario": 45.00 },
      { "skuInterno": "SKU-USA-006", "nombreTecnicoProducto": "Multímetro Digital", "nombreComunProducto": "Tester Eléctrico", "nombreMarca": "MeasurePro", "codigoIsoPais": "USA", "nombreTipoProducto": "Herramienta", "nombreUnidadMedidaProducto": "Unidad", "vidaUtilMeses": 60, "cantidad": 30, "precioUnitario": 35.00 },
      { "skuInterno": "SKU-USA-007", "nombreTecnicoProducto": "Soldadora Inverter", "nombreComunProducto": "Equipo Soldar", "nombreMarca": "WeldMaster", "codigoIsoPais": "USA", "nombreTipoProducto": "Maquinaria", "nombreUnidadMedidaProducto": "Unidad", "vidaUtilMeses": 120, "cantidad": 5, "precioUnitario": 420.00 },
      { "skuInterno": "SKU-USA-008", "nombreTecnicoProducto": "Amoladora Angular", "nombreComunProducto": "Esmeril Mano", "nombreMarca": "GrindPro", "codigoIsoPais": "USA", "nombreTipoProducto": "Herramienta", "nombreUnidadMedidaProducto": "Unidad", "vidaUtilMeses": 48, "cantidad": 18, "precioUnitario": 75.00 },
      { "skuInterno": "SKU-USA-009", "nombreTecnicoProducto": "Destornillador Impacto", "nombreComunProducto": "Atornillador Eléctrico", "nombreMarca": "ScrewFast", "codigoIsoPais": "USA", "nombreTipoProducto": "Herramienta", "nombreUnidadMedidaProducto": "Unidad", "vidaUtilMeses": 60, "cantidad": 25, "precioUnitario": 95.00 },
      { "skuInterno": "SKU-USA-010", "nombreTecnicoProducto": "Gato Hidráulico 2T", "nombreComunProducto": "Elevador Automotriz", "nombreMarca": "LiftHeavy", "codigoIsoPais": "USA", "nombreTipoProducto": "Herramienta", "nombreUnidadMedidaProducto": "Unidad", "vidaUtilMeses": 120, "cantidad": 10, "precioUnitario": 110.00 },
      { "skuInterno": "SKU-USA-011", "nombreTecnicoProducto": "Extractor Ventilador", "nombreComunProducto": "Ventilador Industrial", "nombreMarca": "AirFlow", "codigoIsoPais": "USA", "nombreTipoProducto": "Maquinaria", "nombreUnidadMedidaProducto": "Unidad", "vidaUtilMeses": 84, "cantidad": 8, "precioUnitario": 280.00 },
      { "skuInterno": "SKU-USA-012", "nombreTecnicoProducto": "Bombas Sumergible 1HP", "nombreComunProducto": "Bomba Agua", "nombreMarca": "WaterPump", "codigoIsoPais": "USA", "nombreTipoProducto": "Maquinaria", "nombreUnidadMedidaProducto": "Unidad", "vidaUtilMeses": 60, "cantidad": 12, "precioUnitario": 190.00 },
      { "skuInterno": "SKU-USA-013", "nombreTecnicoProducto": "Generador Gasolina 5kW", "nombreComunProducto": "Planta Eléctrica", "nombreMarca": "PowerGen", "codigoIsoPais": "USA", "nombreTipoProducto": "Maquinaria", "nombreUnidadMedidaProducto": "Unidad", "vidaUtilMeses": 84, "cantidad": 6, "precioUnitario": 850.00 },
      { "skuInterno": "SKU-USA-014", "nombreTecnicoProducto": "Radial Laser Nivel", "nombreComunProducto": "Nivel Láser", "nombreMarca": "LevelLine", "codigoIsoPais": "USA", "nombreTipoProducto": "Herramienta", "nombreUnidadMedidaProducto": "Unidad", "vidaUtilMeses": 60, "cantidad": 14, "precioUnitario": 150.00 },
      { "skuInterno": "SKU-USA-015", "nombreTecnicoProducto": "Detector Metales", "nombreComunProducto": "Buscador Objetos", "nombreMarca": "FindIt", "codigoIsoPais": "USA", "nombreTipoProducto": "Herramienta", "nombreUnidadMedidaProducto": "Unidad", "vidaUtilMeses": 60, "cantidad": 9, "precioUnitario": 220.00 },
      { "skuInterno": "SKU-USA-016", "nombreTecnicoProducto": "Hidrolavadora 2000PSI", "nombreComunProducto": "Lavadora Presión", "nombreMarca": "CleanBlast", "codigoIsoPais": "USA", "nombreTipoProducto": "Maquinaria", "nombreUnidadMedidaProducto": "Unidad", "vidaUtilMeses": 84, "cantidad": 10, "precioUnitario": 320.00 },
      { "skuInterno": "SKU-USA-017", "nombreTecnicoProducto": "Aspiradora Industrial", "nombreComunProducto": "Succión Polvo", "nombreMarca": "VacuumPro", "codigoIsoPais": "USA", "nombreTipoProducto": "Maquinaria", "nombreUnidadMedidaProducto": "Unidad", "vidaUtilMeses": 84, "cantidad": 11, "precioUnitario": 280.00 },
      { "skuInterno": "SKU-USA-018", "nombreTecnicoProducto": "Calibrador Vernier Digital", "nombreComunProducto": "Pie de Rey", "nombreMarca": "MeasurePro", "codigoIsoPais": "USA", "nombreTipoProducto": "Herramienta", "nombreUnidadMedidaProducto": "Unidad", "vidaUtilMeses": 240, "cantidad": 20, "precioUnitario": 55.00 },
      { "skuInterno": "SKU-USA-019", "nombreTecnicoProducto": "Torquímetro Electrónico", "nombreComunProducto": "Llave Torque", "nombreMarca": "TorqueRight", "codigoIsoPais": "USA", "nombreTipoProducto": "Herramienta", "nombreUnidadMedidaProducto": "Unidad", "vidaUtilMeses": 120, "cantidad": 13, "precioUnitario": 180.00 },
      { "skuInterno": "SKU-USA-020", "nombreTecnicoProducto": "Kit Reparación Pinchaduras", "nombreComunProducto": "Set Parches", "nombreMarca": "FixFast", "codigoIsoPais": "USA", "nombreTipoProducto": "Herramienta", "nombreUnidadMedidaProducto": "Unidad", "vidaUtilMeses": 60, "cantidad": 40, "precioUnitario": 15.00 }
    ]
  }
]';

    DECLARE v_mensaje_error TEXT;
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 v_mensaje_error = MESSAGE_TEXT;
        SELECT CONCAT('ERROR CRITICO EN CARGA AUTOMATICA: ', v_mensaje_error) AS ErrorFinal;
        ROLLBACK;
    END;

    START TRANSACTION;


    CALL spInicializarMetadatosDynamic();


    CALL spCargarSitiosWebArrays(CAST(v_jsonTiendas AS JSON));


    CALL spGenerarClientesPorTienda();


    CALL spEjecutarVentasYTransformacionJSON(CAST(v_jsonVentas AS JSON));

    COMMIT;

END$$
DELIMITER ;

CALL spCargaAutomaticaCompleta();
