-- ============================================================================
-- DYNAMIC BRANDS - SCRIPT MAESTRO DE CARGA DE DATOS (SEED)
-- Autor: Gerald Hernández Gamboa
-- Versión: 1.0 (CamelCase Pure - MySQL 8.0+)
-- Descripción: Orquesta la carga completa mediante SPs transaccionales.
--              Nombres de tablas y columnas en CamelCase estricto.
-- ============================================================================


-- ============================================================================
-- 1. SP AUXILIAR: REGISTRAR LOGS (CamelCase)
-- ============================================================================
CREATE PROCEDURE spRegistrarLogCarga(
    IN pSpNombre VARCHAR(100),
    IN pPaso VARCHAR(255),
    IN pEstado VARCHAR(20),
    IN pMensaje TEXT
)
BEGIN
    DECLARE vObjetoId INT;
    DECLARE vSourceId INT;
    DECLARE vTipoEventoId INT;
    DECLARE vSeveridadId INT;
    DECLARE vRefEjecucion BIGINT;
    
    -- Obtener IDs de catálogos
    SELECT objetoId INTO vObjetoId FROM Objetos WHERE nombreObjeto = 'PROCEDIMIENTO_CARGA_DATA' LIMIT 1;
    SELECT sourceId INTO vSourceId FROM Sources WHERE nombreSource = 'SCRIPT_SEED_INICIAL' LIMIT 1;
    SELECT tipoEventoId INTO vTipoEventoId FROM TiposEvento WHERE codigoEvento = 'SP_EXECUTION' LIMIT 1;
    
    IF pEstado = 'ERROR' THEN
        SELECT severidadId INTO vSeveridadId FROM Severidades WHERE nombreSeveridad = 'ERROR' LIMIT 1;
    ELSE
        SELECT severidadId INTO vSeveridadId FROM Severidades WHERE nombreSeveridad = 'INFORMATIVO' LIMIT 1;
    END IF;

    SET vRefEjecucion = UNIX_TIMESTAMP(NOW());

    -- Insertar solo si los IDs existen
    IF vObjetoId IS NOT NULL AND vSourceId IS NOT NULL AND vTipoEventoId IS NOT NULL THEN
        INSERT INTO Logs (
            tipoEventoId, severidadId, descripcion, sourceId, usuarioId, referenciaId1, objetoId1,
            datosNuevos, checkSum, creadoEn, activo
        ) VALUES (
            vTipoEventoId, 
            IFNULL(vSeveridadId, 2), 
            CONCAT(pSpNombre, ' - ', pPaso), 
            vSourceId,
            1, -- Usuario Admin por defecto
            vRefEjecucion,
            vObjetoId,
            JSON_OBJECT('estado', pEstado, 'mensaje', pMensaje, 'pasoDetalle', pPaso),
            SHA2(CONCAT(pSpNombre, pPaso, NOW()), 256),
            NOW(),
            1
        );
    END IF;
END //

-- ============================================================================
-- 2. SP AUXILIAR: INICIALIZAR METADATOS DE AUDITORÍA (FASE 0)
-- ============================================================================
CREATE PROCEDURE spInicializarMetadatosAuditoria()
BEGIN
    -- Asegurar Objeto
    INSERT IGNORE INTO Objetos (nombreObjeto, activo) VALUES ('PROCEDIMIENTO_CARGA_DATA', 1);
    -- Asegurar Source
    INSERT IGNORE INTO Sources (nombreSource, activo) VALUES ('SCRIPT_SEED_INICIAL', 1);
    -- Asegurar Tipo Evento
    INSERT IGNORE INTO TiposEvento (codigoEvento, descripcion, requierePreguardado, activo) 
    VALUES ('SP_EXECUTION', 'Ejecución de Stored Procedure de Carga Masiva', 0, 1);
    -- Asegurar Severidades
    INSERT IGNORE INTO Severidades (valorSeveridad, nombreSeveridad, activo) VALUES (2, 'INFORMATIVO', 1), (4, 'ERROR', 1);
END //

-- ============================================================================
-- 3. SP FASE 1: CARGA DE MAESTROS (Geografía, Monedas, Usuarios, Tipos)
-- ============================================================================
CREATE PROCEDURE spCargarMaestrosDynamic()
BEGIN
    DECLARE vUsuarioId INT;
    DECLARE vRolId INT;
    
    -- 1. Roles y Usuarios
    INSERT INTO Roles (nombreRol, descripcion, nivelAcceso, activo) VALUES ('Admin Dynamic', 'Administrador de tiendas', 100, 1);
    SET vRolId = LAST_INSERT_ID();
    
    INSERT INTO Usuarios (nombreUsuario, email, contraseña, activo) VALUES ('admin_dyn', 'admin@dynamic.com', SHA2('admin123', 256), 1);
    SET vUsuarioId = LAST_INSERT_ID();
    
    INSERT INTO UsuarioRol (usuarioId, rolId, asignadoPor, activo) VALUES (vUsuarioId, vRolId, vUsuarioId, 1);

    -- 2. Monedas (Sincronizadas con Etheria)
    INSERT IGNORE INTO Currencies (currencyId, codigoIso, nombreCurrency, currencySymbol, activo) VALUES
    (1, 'USD', 'Dólar Estadounidense', '$', 1),
    (2, 'EUR', 'Euro', '€', 1),
    (3, 'BRL', 'Real Brasileño', 'R$', 1),
    (4, 'CNY', 'Yuan Chino', '¥', 1),
    (5, 'CRC', 'Colón Costarricense', '₡', 1);

    -- 3. Tipos y Estados Base Locales
    INSERT IGNORE INTO TiposProducto (tipoProductoId, nombreTipoProducto, activo) VALUES 
    (1, 'Suplemento', 1), (2, 'Cosmético', 1), (3, 'Aceite', 1);
    
    INSERT IGNORE INTO UnidadesMedidaProducto (UnidadMedidaProductoId, nombreUnidadMedidaProducto, descripcion, activo) 
    VALUES (1, 'Litro', 'L', 1), (2, 'Kilogramo', 'KG', 1), (3, 'Unidad', 'UND', 1);
    
    INSERT IGNORE INTO EstadosTienda (nombreEstadoTienda, codigo, permiteVentas, descripcion, activo) VALUES
    ('Activa', 'ACT', 1, 'Operando', 1), ('Mantenimiento', 'MNT', 0, 'Offline', 1);
    
    INSERT IGNORE INTO EstadosOrdenesVenta (nombreEstadoOrdenVenta, descripcion, activo) VALUES
    ('Creada', 'Orden iniciada', 1), ('Pagada', 'Pago confirmado', 1), ('Enviada', 'En envío', 1);
    
    INSERT IGNORE INTO EstadosPago (nombreEstadoPago, descripcion, activo) VALUES
    ('Pendiente', 'Esperando pago', 1), ('Aprobado', 'Pago exitoso', 1);

    -- 4. Tipos de Descuento y Precio
    INSERT IGNORE INTO TiposDescuento (nombreTipoDescuento, descripcion, activo) VALUES
    ('Porcentaje', '% sobre total', 1), ('Monto Fijo', 'Monto fijo', 1);
    
    INSERT IGNORE INTO TiposPrecios (nombreTipoPrecio, descripcion, activo) VALUES
    ('PVP', 'Precio Venta Público', 1), ('Oferta', 'Promocional', 1);

    CALL spRegistrarLogCarga('spCargarMaestrosDynamic', 'Maestros cargados (Usuarios, Monedas, Tipos)', 'EXITO', NULL);
END //

-- ============================================================================
-- 4. SP FASE 2: CARGA DE NEGOCIO (Países, 9 Tiendas, 100 Productos Réplica, Ventas)
-- ============================================================================
CREATE PROCEDURE spCargarNegocioDynamic()
BEGIN
    DECLARE vPaisId INT;
    DECLARE vProdId INT;
    DECLARE vTiendaId INT;
    DECLARE vClienteId INT;
    DECLARE vOrdenId INT;
    DECLARE vContador INT DEFAULT 0;
    DECLARE vI INT DEFAULT 1;
    
    -- Nombres de países para iterar
    DECLARE vNombresPais TEXT[]; -- Nota: MySQL no soporta arrays nativos simples en SPs antiguos, usaremos lógica modular
    
    -- 1. Asegurar Países (Los mismos 5 de Etheria)
    INSERT IGNORE INTO Paises (paisId, nombrePais, codigoIso, activo) VALUES
    (1, 'Costa Rica', 'CRC', 1), (2, 'Estados Unidos', 'USA', 1),
    (3, 'Brasil', 'BRA', 1), (4, 'China', 'CHN', 1), (5, 'Alemania', 'DEU', 1);
    
    CALL spRegistrarLogCarga('spCargarNegocioDynamic', '5 Paises sincronizados', 'EXITO', NULL);

    -- 2. Crear 9 Sitios Web Dinámicos (Tiendas)
    WHILE vI <= 9 DO
        SET vPaisId = ((vI - 1) % 5) + 1; -- Ciclar entre 1 y 5
        
        INSERT INTO TiendasVirtualesGeneradas (
            nombreTienda, paisObjetivoId, monedaLocalId, estadoTiendaId, activo
        ) VALUES (
            CONCAT('Tienda Online País ', vPaisId, ' - Sitio ', vI), 
            vPaisId, 1, 1, 1
        );
        SET vI = vI + 1;
    END WHILE;
    CALL spRegistrarLogCarga('spCargarNegocioDynamic', '9 Tiendas Virtuales creadas', 'EXITO', NULL);

    -- 3. Cargar 100 Productos Réplica y Generar Ventas Simuladas
    SET vI = 1;
    WHILE vI <= 100 DO
        SET vProdId = vI; -- Asumimos ID igual a Etheria
        SET vPaisId = ((vI - 1) % 5) + 1;
        
        -- Insertar Producto Réplica (Base)
        INSERT IGNORE INTO Productos (productoId, skuInterno, nombreTecnico, activo)
        VALUES (vProdId, CONCAT('SKU-ETH-', LPAD(vI, 4, '0')), CONCAT('Prod Tech ', vI), 1);

        -- Crear Marca Blanca (una cada 10 productos aprox)
        IF vI % 10 = 1 THEN 
             INSERT INTO MarcasBlancas (nombreMarcaBlanca, tiendaId, paisId, activo)
             VALUES (CONCAT('Marca Blanca Región ', vPaisId), 1, vPaisId, 1);
        END IF;
        
        -- Insertar Producto de Marca Blanca
        INSERT IGNORE INTO ProductosMarcasBlancas (productoId, tiendaId, skuComercial, nombreComercial, marcaBlancaId, stockDisponible, activo)
        VALUES (vProdId, 1, CONCAT('SKU-DYN-', LPAD(vI, 4, '0')), CONCAT('Producto Venta ', vI), 1, 100.00, 1);

        -- Cada 10 productos, generamos una orden de venta completa
        IF (vI % 10 = 0) THEN
            -- Crear Cliente
            INSERT INTO Clientes (email, nombreCliente, apellidoCliente1, paisResidenciaId, activo)
            VALUES (CONCAT('cliente', vI, '@test.com'), CONCAT('Cliente ', vI), 'Apellido', vPaisId, 1);
            SET vClienteId = LAST_INSERT_ID();

            -- Crear Orden de Venta
            INSERT INTO OrdenesVenta (
                tiendaId, clienteId, fechaOrden, numeroPedido, estadoOrdenVentaId, 
                montoSubtotal, montoEnvio, montoTotalLocal, currencyId, tasaDeCambioAplicada, 
                montoConvertidoBase, activo
            ) VALUES (
                1, vClienteId, NOW(), CONCAT('PED-DYN-', vI), 1, 
                150.00, 10.00, 160.00, 1, 1.0, 160.00, 1
            );
            SET vOrdenId = LAST_INSERT_ID();

            -- Detalle de Orden
            INSERT INTO DetallesOrdenesVenta (
                ordenVentaId, productoMarcaId, cantidad, currencyId, precioUnitarioLocal, subtotalLocal
            ) VALUES (vOrdenId, vProdId, 2, 1, 75.00, 150.00);

            -- Registrar Transformación (Retiro de stock desde Etheria)
            INSERT INTO TransformacionesProductos (
                loteBulkId, productoMarcaId, productoBaseId, puntoRetiroId, 
                cantidadTransformada, cantidadMerma, fechaTransformacion, estadoTransformacionId, activo
            ) VALUES (
                vProdId, vProdId, vProdId, 1, 2.00, 0.00, NOW(), 1, 1
            );

            SET vContador = vContador + 1;
        END IF;
        
        SET vI = vI + 1;
    END WHILE;

    CALL spRegistrarLogCarga('spCargarNegocioDynamic', CONCAT('100 Productos réplica y ', vContador, ' Órdenes creadas'), 'EXITO', NULL);
END //

-- ============================================================================
-- 5. SP ORQUESTADOR MAESTRO (LLAMADA PRINCIPAL)
-- ============================================================================
CREATE PROCEDURE spOrquestarCargaCompletaDynamic()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 @msg = MESSAGE_TEXT;
        CALL spRegistrarLogCarga('spOrquestarCargaCompletaDynamic', 'FALLO CRITICO', 'ERROR', @msg);
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    -- FASE 0: Inicializar Auditoría
    CALL spInicializarMetadatosAuditoria();
    CALL spRegistrarLogCarga('spOrquestarCargaCompletaDynamic', 'Fase 0: Metadatos de auditoria listos', 'EXITO', NULL);

    -- FASE 1: Maestros
    CALL spCargarMaestrosDynamic();
    CALL spRegistrarLogCarga('spOrquestarCargaCompletaDynamic', 'Fase 1: Maestros completados', 'EXITO', NULL);

    -- FASE 2: Negocio (Tiendas, Productos, Ventas)
    CALL spCargarNegocioDynamic();
    CALL spRegistrarLogCarga('spOrquestarCargaCompletaDynamic', 'Fase 2: Negocio completado', 'EXITO', NULL);

    -- Validación Final
    IF (SELECT COUNT(*) FROM TiendasVirtualesGeneradas) < 9 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Validacion fallida: Menos de 9 tiendas.';
    END IF;
    
    IF (SELECT COUNT(*) FROM Productos) < 100 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Validacion fallida: Menos de 100 productos.';
    END IF;

    CALL spRegistrarLogCarga('spOrquestarCargaCompletaDynamic', 'PROCESO FINALIZADO CON EXITO', 'EXITO', 'Datos verificados correctamente');

    COMMIT;
END //

DELIMITER ;


CALL spOrquestarCargaCompletaDynamic();

