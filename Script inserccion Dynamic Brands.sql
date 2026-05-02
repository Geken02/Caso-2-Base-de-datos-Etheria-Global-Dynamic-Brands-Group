-- ============================================================================
-- DYNAMIC BRANDS - PAQUETE COMPLETO DE CARGA (VERSIÓN FINAL)
-- Autor: Gerald Hernández Gamboa
-- Requisito: Base de datos 'dynamic_brands_db' recién creada y tablas existentes.
-- ============================================================================

USE dynamic_brands_db;

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
    SELECT tipoEventoId INTO vTipoEventoId FROM TiposEvento WHERE nombreEvento = 'SP_CARGA_MASIVA' LIMIT 1; -- Ojo: nombreEvento, no codigo
    
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

-- 2. SP INICIALIZACIÓN DE METADATOS (CON APELLIDOS Y COLUMNAS CORRECTAS)
DROP PROCEDURE IF EXISTS spInicializarMetadatosDynamic;
DELIMITER $$
CREATE PROCEDURE spInicializarMetadatosDynamic()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION 
    BEGIN 
        GET DIAGNOSTICS CONDITION 1 @msg = MESSAGE_TEXT;
        SELECT CONCAT('ERROR: ', @msg) AS ErrorDetalle;
        ROLLBACK; 
    END;

    START TRANSACTION;
    
    INSERT INTO Objetos (nombreObjeto, activo) VALUES ('PROCEDIMIENTO_CARGA_DATA', TRUE) ON DUPLICATE KEY UPDATE activo=TRUE;
    INSERT INTO Sources (nombreSource, activo) VALUES ('SCRIPT_SEED_DYNAMIC', TRUE) ON DUPLICATE KEY UPDATE activo=TRUE;
    
    -- CORRECCIÓN: Usando 'nombreEvento' que es la columna real y UNIQUE
    INSERT INTO TiposEvento (nombreEvento, descripcion, activo) 
    VALUES ('SP_CARGA_MASIVA', 'Carga masiva Dynamic', TRUE) 
    ON DUPLICATE KEY UPDATE descripcion='Carga masiva Dynamic', activo=TRUE;
    
    INSERT INTO Severidades (valorSeveridad, nombreSeveridad, activo) VALUES (2, 'INFORMATIVO', TRUE), (4, 'ERROR', TRUE) ON DUPLICATE KEY UPDATE activo=TRUE;
    
    -- CORRECCIÓN: Agregados apellido1 y apellido2 obligatorios
    INSERT INTO Usuarios (usuarioId, nombreUsuario, apellido1, apellido2, email, contraseña, activo, creadoEn) 
    VALUES (1, 'admin', 'Administrador', 'Sistema', 'admin@dynamic.com', SHA2('admin123', 256), TRUE, NOW()) 
    ON DUPLICATE KEY UPDATE email='admin@dynamic.com', activo=TRUE;
    
    INSERT INTO Roles (nombreRol, descripcion, nivelAcceso, activo) 
    VALUES ('SuperAdmin', 'Administrador total', 100, TRUE), 
           ('GerenteTienda', 'Gerente tienda', 50, TRUE), 
           ('Cliente', 'Usuario final', 10, TRUE) 
    ON DUPLICATE KEY UPDATE activo=TRUE;
    
    INSERT INTO EstadosTienda (nombreEstadoTienda, permiteVentas, descripcion, activo) 
    VALUES ('Activa', TRUE, 'Operando', TRUE), ('Mantenimiento', FALSE, 'Mantenimiento', TRUE) 
    ON DUPLICATE KEY UPDATE activo=TRUE;
    
    INSERT INTO EstadosOrdenesVenta (nombreEstadoOrdenVenta, descripcion, activo) 
    VALUES ('Pendiente', 'Esperando pago', TRUE), ('Pagada', 'Pago confirmado', TRUE), 
           ('Enviada', 'Despachada', TRUE), ('Entregada', 'Recibida', TRUE), ('Cancelada', 'Cancelada', TRUE) 
    ON DUPLICATE KEY UPDATE activo=TRUE;
    
    INSERT INTO EstadosPago (nombreEstadoPago, descripcion, activo) 
    VALUES ('Pendiente', 'Esperando', TRUE), ('Aprobado', 'Exitoso', TRUE), ('Rechazado', 'Fallido', TRUE) 
    ON DUPLICATE KEY UPDATE activo=TRUE;
    
    INSERT INTO EstadosEnvio (nombreEstadoEnvio, descripcion, activo) 
    VALUES ('Por Despachar', 'Listo', TRUE), ('En Tránsito', 'Camino', TRUE), ('Entregado', 'Entregado', TRUE) 
    ON DUPLICATE KEY UPDATE activo=TRUE;
    
    INSERT INTO TiposDescuento (nombreTipoDescuento, descripcion, activo) 
    VALUES ('Porcentaje', '% del subtotal', TRUE), ('MontoFijo', 'Monto fijo', TRUE) 
    ON DUPLICATE KEY UPDATE activo=TRUE;
    
    INSERT INTO MetodosPago (nombreMetodoPago, requiereValidacionAdicional, activo) 
    VALUES ('Tarjeta Crédito', TRUE, TRUE), ('PayPal', FALSE, TRUE), ('Transferencia', TRUE, TRUE) 
    ON DUPLICATE KEY UPDATE activo=TRUE;
    
    INSERT INTO Courier (courierId, nombreCourier, ciudadId, tipoServicioId, tiempoEntregaPromedioDias, activo) 
    VALUES (1, 'Courier Express Global', 1, 1, 3, TRUE) 
    ON DUPLICATE KEY UPDATE activo=TRUE;

    CALL spRegistrarLogCarga('spInicializarMetadatosDynamic', 'Metadatos listos', 'EXITO', NULL);
    
    COMMIT;
    SELECT '✅ Metadatos inicializados correctamente' AS Mensaje;
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
		-- Opción A: Usar MESSAGE_TEXT directamente si está en el scope
		GET DIAGNOSTICS CONDITION 1 @msg = MESSAGE_TEXT;
		ROLLBACK; 
		CALL spRegistrarLogCarga('spCargarSitiosWebArrays', 'Fallo', 'ERROR', @msg); -- ✅ CORRECTO
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
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'País o Moneda no encontrados';
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
		-- Opción A: Usar MESSAGE_TEXT directamente si está en el scope
		GET DIAGNOSTICS CONDITION 1 @msg = MESSAGE_TEXT;
		ROLLBACK; 
		CALL spRegistrarLogCarga('spCargarSitiosWebArrays', 'Fallo', 'ERROR', @msg); -- ✅ CORRECTO
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

-- 5. SP AUXILIAR: TRANSFORMAR Y VENDER (CONTADOR SIMPLE + MAX+1)
DROP PROCEDURE IF EXISTS spTransformarYVenderItem;
DELIMITER $$
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
    
    SELECT paisId INTO vPaisId FROM Paises WHERE codigoIso = p_codigoIsoPais LIMIT 1;
    IF vPaisId IS NULL THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'País no encontrado'; END IF;

    -- Maestros: Buscar por nombre, si no existe crear con MAX(id)+1
    SELECT marcaOriginalId INTO vMarcaOriginalId 
    FROM MarcasOriginales 
    WHERE nombreMarcaOriginal = p_nombreMarca LIMIT 1; 

    IF vMarcaOriginalId IS NULL THEN
        -- Si no existe, calculamos el nuevo ID (MAX + 1)
        SELECT COALESCE(MAX(marcaOriginalId), 0) + 1 INTO vMarcaOriginalId FROM MarcasOriginales;
        
        -- Insertamos usando la columna correcta
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

    -- Producto Base: ID = Contador Directo
    SET vProductoId = p_contadorProductos;
    INSERT IGNORE INTO Productos (
        productoId, skuInterno, nombreTecnicoProducto, nombreComunProducto, 
        marcaOriginalId, tipoProductoId, unidadMedidaProductoId, vidaUtilMeses, 
        activo, fechaSincronizacion
    ) VALUES (
        vProductoId, p_skuInterno, p_nombreTecnico, p_nombreComun, 
        vMarcaOriginalId, vTipoId, vUnidadId, p_vidaUtil, TRUE, NOW()
    );

    -- Marca Blanca (Auto-inc real)
    SELECT marcaBlancaId INTO vMarcaBlancaId FROM MarcasBlancas WHERE tiendaId = p_tiendaId LIMIT 1;
    IF vMarcaBlancaId IS NULL THEN
        INSERT INTO MarcasBlancas (nombreMarcaBlanca, tiendaId, paisId, activo, creadoEn)
        VALUES ('Marca Genérica', p_tiendaId, vPaisId, TRUE, NOW());
        SET vMarcaBlancaId = LAST_INSERT_ID();
    END IF;

    -- Transformación
    SELECT productoMarcaId INTO vProductoMarcaId FROM ProductosMarcasBlancas WHERE productoId = vProductoId AND tiendaId = p_tiendaId LIMIT 1;
    IF vProductoMarcaId IS NULL THEN
        INSERT INTO ProductosMarcasBlancas (productoId, tiendaId, skuComercial, nombreComercial, marcaBlancaId, stockDisponible, activo, creadoEn)
        VALUES (vProductoId, p_tiendaId, CONCAT(p_skuInterno, '-DY'), p_nombreComun, vMarcaBlancaId, 1000, TRUE, NOW());
        SET vProductoMarcaId = LAST_INSERT_ID();
    END IF;

    -- Venta
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
DROP PROCEDURE IF EXISTS spTransformarYVenderItem;
DELIMITER $$
CREATE PROCEDURE spTransformarYVenderItem(
    IN p_ordenVentaId INT, 
    IN p_tiendaId INT, 
    IN p_contadorProductos INT, 
    IN p_skuInterno VARCHAR(20),
    IN p_nombreTecnico VARCHAR(50), -- Parámetro de entrada
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
    
    -- 1. ASEGURAR PAÍS
    SELECT paisId INTO vPaisId FROM Paises WHERE codigoIso = p_codigoIsoPais LIMIT 1;
    IF vPaisId IS NULL THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'País no encontrado'; END IF;

    -- 2. ASEGURAR MARCA ORIGINAL (Usando nombreMarcaOriginal)
    SELECT marcaOriginalId INTO vMarcaOriginalId FROM MarcasOriginales WHERE nombreMarcaOriginal = p_nombreMarca LIMIT 1;
    IF vMarcaOriginalId IS NULL THEN
        SELECT COALESCE(MAX(marcaOriginalId), 0) + 1 INTO vMarcaOriginalId FROM MarcasOriginales;
        INSERT INTO MarcasOriginales (marcaOriginalId, nombreMarcaOriginal, paisId, activo, fechaSincronizacion) 
        VALUES (vMarcaOriginalId, p_nombreMarca, vPaisId, TRUE, NOW());
    END IF;

    -- 3. ASEGURAR TIPO PRODUCTO (Verificar nombre real si falla)
    -- Asumiendo nombreTipoProducto según tu MD, pero verifica si es solo 'nombreTipo'
    SELECT tipoProductoId INTO vTipoId FROM TiposProducto WHERE nombreTipoProducto = p_nombreTipo LIMIT 1;
    IF vTipoId IS NULL THEN
        SELECT COALESCE(MAX(tipoProductoId), 0) + 1 INTO vTipoId FROM TiposProducto;
        INSERT INTO TiposProducto (tipoProductoId, nombreTipoProducto, activo, fechaSincronizacion) 
        VALUES (vTipoId, p_nombreTipo, TRUE, NOW());
    END IF;

    -- 4. ASEGURAR UNIDAD MEDIDA (Verificar nombre real si falla)
    SELECT UnidadMedidaProductoId INTO vUnidadId FROM UnidadesMedidaProducto WHERE nombreUnidadMedidaProducto = p_nombreUnidad LIMIT 1;
    IF vUnidadId IS NULL THEN
        SELECT COALESCE(MAX(UnidadMedidaProductoId), 0) + 1 INTO vUnidadId FROM UnidadesMedidaProducto;
        INSERT INTO UnidadesMedidaProducto (UnidadMedidaProductoId, nombreUnidadMedidaProducto, descripcion, activo, fechaSincronizacion) 
        VALUES (vUnidadId, p_nombreUnidad, p_nombreUnidad, TRUE, NOW());
    END IF;

    -- 5. ASEGURAR PRODUCTO BASE (CORRECCIÓN FINAL: nombreTecnico)
    SELECT productoId INTO vProductoId FROM Productos WHERE skuInterno = p_skuInterno LIMIT 1;
    
    IF vProductoId IS NULL THEN
        SET vProductoId = p_contadorProductos;
        -- CORRECCIÓN: Usar 'nombreTecnico' en lugar de 'nombreTecnicoProducto'
        INSERT INTO Productos (
            productoId, skuInterno, nombreTecnico, nombreComun, 
            marcaOriginalId, tipoProductoId, unidadMedidaProductoId, vidaUtilMeses, 
            activo, fechaSincronizacion
        ) VALUES (
            vProductoId, p_skuInterno, p_nombreTecnico, p_nombreComun, 
            vMarcaOriginalId, vTipoId, vUnidadId, p_vidaUtil, TRUE, NOW()
        );
    END IF;

    -- 6. ASEGURAR MARCA BLANCA
    SELECT marcaBlancaId INTO vMarcaBlancaId FROM MarcasBlancas WHERE tiendaId = p_tiendaId LIMIT 1;
    IF vMarcaBlancaId IS NULL THEN
        INSERT INTO MarcasBlancas (nombreMarcaBlanca, tiendaId, paisId, activo, creadoEn)
        VALUES ('Marca Genérica', p_tiendaId, vPaisId, TRUE, NOW());
        SET vMarcaBlancaId = LAST_INSERT_ID();
    END IF;

    -- 7. TRANSFORMACIÓN
    SELECT productoMarcaId INTO vProductoMarcaId FROM ProductosMarcasBlancas WHERE productoId = vProductoId AND tiendaId = p_tiendaId LIMIT 1;
    IF vProductoMarcaId IS NULL THEN
        INSERT INTO ProductosMarcasBlancas (productoId, tiendaId, skuComercial, nombreComercial, marcaBlancaId, stockDisponible, activo, creadoEn)
        VALUES (vProductoId, p_tiendaId, CONCAT(p_skuInterno, '-DY'), p_nombreComun, vMarcaBlancaId, 1000, TRUE, NOW());
        SET vProductoMarcaId = LAST_INSERT_ID();
    END IF;

    -- 8. DETALLE DE VENTA
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
