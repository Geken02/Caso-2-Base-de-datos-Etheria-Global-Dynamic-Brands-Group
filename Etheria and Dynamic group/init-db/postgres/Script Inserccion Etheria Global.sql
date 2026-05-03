-- ============================================================================
-- ETHERIA GLOBAL - CARGA DE DATOS 100% 
-- Autor: Gerald Hernández Gamboa
-- ============================================================================

-- 1. METADATOS DE AUDITORÍA
CREATE OR REPLACE PROCEDURE spInicializarMetadatosAuditoria()
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO Objetos (nombreObjeto, activo) VALUES ('PROCEDIMIENTO_CARGA_DATA', TRUE) ON CONFLICT (nombreObjeto) DO NOTHING;
    INSERT INTO Sources (nombreSource, activo) VALUES ('SCRIPT_SEED_INICIAL', TRUE) ON CONFLICT (nombreSource) DO NOTHING;
    INSERT INTO TiposEvento (nombreEvento, descripcion, requierePreguardado, activo) 
    VALUES ('SP_CARGA_MASIVA', 'Ejecución de Stored Procedures para carga masiva', FALSE, TRUE) ON CONFLICT (nombreEvento) DO NOTHING;
    INSERT INTO Severidades (valorSeveridad, nombreSeveridad, activo) 
    VALUES (2, 'INFORMATIVO', TRUE), (4, 'ERROR', TRUE) ON CONFLICT (nombreSeveridad) DO UPDATE SET valorSeveridad = EXCLUDED.valorSeveridad;
    
    INSERT INTO Usuarios (usuarioId, nombreUsuario, email, contraseña, activo, creadoEn)
    VALUES (1, 'admin', 'admin@etheria.com', 'admin123'::bytea, TRUE, NOW()) ON CONFLICT (usuarioId) DO NOTHING;
END;
$$;

-- 2. SP DE LOGS
CREATE OR REPLACE PROCEDURE spRegistrarLogCarga(
    pSpNombre VARCHAR, pPaso VARCHAR, pEstado VARCHAR, pMensaje TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    vObjetoId INT; vSourceId INT; vTipoEventoId INT; vSeveridadId INT; vRef BIGINT;
BEGIN
    SELECT objetoId INTO vObjetoId FROM Objetos WHERE nombreObjeto = 'PROCEDIMIENTO_CARGA_DATA' LIMIT 1;
    SELECT sourceId INTO vSourceId FROM Sources WHERE nombreSource = 'SCRIPT_SEED_INICIAL' LIMIT 1;
    SELECT tipoEventoId INTO vTipoEventoId FROM TiposEvento WHERE nombreEvento = 'SP_CARGA_MASIVA' LIMIT 1;
    
    IF pEstado = 'ERROR' THEN
        SELECT severidadId INTO vSeveridadId FROM Severidades WHERE nombreSeveridad = 'ERROR' LIMIT 1;
    ELSE
        SELECT severidadId INTO vSeveridadId FROM Severidades WHERE nombreSeveridad = 'INFORMATIVO' LIMIT 1;
    END IF;

    vRef := EXTRACT(EPOCH FROM CURRENT_TIMESTAMP)::BIGINT;

    IF vObjetoId IS NOT NULL AND vSourceId IS NOT NULL AND vTipoEventoId IS NOT NULL THEN
        INSERT INTO Logs (tipoEventoId, severidadId, descripcion, sourceId, usuarioId, referenciaId1, objetoId1, datosNuevos, checkSum, creadoEn, activo)
        VALUES (vTipoEventoId, COALESCE(vSeveridadId, 2), CONCAT(pSpNombre, ' - ', pPaso), vSourceId, 1, vRef, vObjetoId,
        jsonb_build_object('estado', pEstado, 'mensaje', pMensaje), encode(sha256(CONCAT(pSpNombre, pPaso, NOW())::bytea), 'hex'), NOW(), TRUE);
    END IF;
EXCEPTION WHEN OTHERS THEN RAISE NOTICE 'Error log: %', SQLERRM; END;
$$;

-- 3. INICIALIZACIÓN DE CATÁLOGOS (CON TASAS COMPLETAS Y TRANSPORTES)
CREATE OR REPLACE PROCEDURE spInicializarCatalogosPuros()
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO Usuarios (usuarioId, nombreUsuario, email, contraseña, activo, creadoEn)
    VALUES (1, 'admin', 'admin@etheria.com', 'admin123'::bytea, TRUE, NOW()) ON CONFLICT (usuarioId) DO NOTHING;
    
    CALL spRegistrarLogCarga('spInicializarCatalogosPuros', 'Iniciando catálogos...', 'INICIO', NULL);


    INSERT INTO Currencies (codigoIso, nombreCurrency, currencysymbol, activo) VALUES
    ('USD', 'Dólar Estadounidense', '$', TRUE), ('EUR', 'Euro', '€', TRUE),
    ('BRL', 'Real Brasileño', '$', TRUE), ('CNY', 'Yuan Chino', '¥', TRUE),
    ('CRC', 'Colón Costarricense', '₡', TRUE)
    ON CONFLICT (codigoIso) DO NOTHING;

    DELETE FROM TasasDeCambio WHERE activo = TRUE; 
    INSERT INTO TasasDeCambio (currencyId1, currencyId2, exchangeRate, activo)
    SELECT c1.currencyId, c2.currencyId, 
        CASE 
            WHEN c1.codigoIso = c2.codigoIso THEN 1.0
            WHEN c1.codigoIso = 'USD' THEN CASE c2.codigoIso WHEN 'EUR' THEN 0.92 WHEN 'BRL' THEN 5.05 WHEN 'CNY' THEN 7.20 WHEN 'CRC' THEN 520.00 ELSE 1.0 END
            WHEN c2.codigoIso = 'USD' THEN CASE c1.codigoIso WHEN 'EUR' THEN 1.09 WHEN 'BRL' THEN 0.198 WHEN 'CNY' THEN 0.139 WHEN 'CRC' THEN 0.00192 ELSE 1.0 END
            ELSE (CASE c1.codigoIso WHEN 'EUR' THEN 1.09 WHEN 'BRL' THEN 0.198 WHEN 'CNY' THEN 0.139 WHEN 'CRC' THEN 0.00192 ELSE 1.0 END) /
                 (CASE c2.codigoIso WHEN 'EUR' THEN 1.09 WHEN 'BRL' THEN 0.198 WHEN 'CNY' THEN 0.139 WHEN 'CRC' THEN 0.00192 ELSE 1.0 END)
        END, TRUE
    FROM Currencies c1 CROSS JOIN Currencies c2 WHERE c1.currencyId != c2.currencyId;

    INSERT INTO TiposProducto (nombreTipoProducto, activo) VALUES 
    ('Suplemento', TRUE), ('Cosmético', TRUE), ('Aceite', TRUE), ('Electrónico', TRUE), 
    ('Alimento', TRUE), ('Bebida', TRUE), ('Accesorio', TRUE), ('Repuesto', TRUE), 
    ('Maquinaria', TRUE), ('Herramienta', TRUE) ON CONFLICT (nombreTipoProducto) DO NOTHING;
    
    INSERT INTO UnidadesMedidaProducto (nombreUnidadMedidaProducto, descripcion, activo) VALUES 
    ('Unidad', 'UND', TRUE), ('Litro', 'L', TRUE), ('Kilogramo', 'KG', TRUE) 
    ON CONFLICT (nombreUnidadMedidaProducto) DO NOTHING;
    
    INSERT INTO EstadosInventario (nombreEstadoInventario, descripcion, activo) VALUES 
    ('Cuarentena', 'Pendiente', TRUE), ('Disponible', 'Listo', TRUE) 
    ON CONFLICT (nombreEstadoInventario) DO NOTHING;
    
    INSERT INTO EstadosOrdenes (nombreEstadoOrden, activo) VALUES 
    ('Borrador', TRUE), ('Aprobada', TRUE), ('En Tránsito', TRUE), ('Recibida', TRUE) 
    ON CONFLICT (nombreEstadoOrden) DO NOTHING;
    
    INSERT INTO EstadosItems (nombreEstadoItem, activo) VALUES 
    ('Pendiente', TRUE), ('Confirmado', TRUE) ON CONFLICT (nombreEstadoItem) DO NOTHING;

    INSERT INTO ConceptosCostos (nombreConceptoCosto, descripcion, activo) VALUES
    ('Flete Internacional', 'Transporte marítimo/aéreo', TRUE), ('Seguro de Carga', 'Póliza', TRUE),
    ('Aranceles Aduana', 'Impuestos', TRUE), ('Gastos Portuarios', 'Manipulación', TRUE),
    ('Flete Nacional', 'Local', TRUE), ('Flete Aéreo', 'Aéreo', TRUE),
    ('Flete Marítimo', 'Marítimo', TRUE), ('Flete Terrestre', 'Terrestre', TRUE)
    ON CONFLICT (nombreConceptoCosto) DO NOTHING;

    INSERT INTO TiposTransporte (nombreTipoTransporte, activo) VALUES
    ('Marítimo',  TRUE),
    ('Aéreo',  TRUE),
    ('Terrestre',  TRUE)
    ON CONFLICT (nombreTipoTransporte) DO NOTHING;

    CALL spRegistrarLogCarga('spInicializarCatalogosPuros', 'Catálogos listos', 'EXITO', NULL);
END;
$$;

-- 4. CARGA DE PAÍSES
CREATE OR REPLACE PROCEDURE spCargarPaisesLote(p_nombresPaises VARCHAR(50)[], p_codigosIso CHAR(3)[])
LANGUAGE plpgsql AS $$
BEGIN
    CALL spRegistrarLogCarga('spCargarPaisesLote', 'Procesando países...', 'INICIO', NULL);
    INSERT INTO Paises (nombrePais, codigoIso, activo)
    SELECT vals.nombre, vals.iso, TRUE FROM UNNEST(p_nombresPaises, p_codigosIso) AS vals(nombre, iso)
    ON CONFLICT (codigoIso) DO UPDATE SET nombrePais = EXCLUDED.nombrePais;
    CALL spRegistrarLogCarga('spCargarPaisesLote', 'Países cargados', 'EXITO', NULL);
EXCEPTION WHEN OTHERS THEN CALL spRegistrarLogCarga('spCargarPaisesLote', 'Fallo', 'ERROR', SQLERRM); RAISE; END;
$$;

-- 5. SP PRINCIPAL DE IMPORTACIÓN 
CREATE OR REPLACE PROCEDURE spEjecutarImportacionMultiOrdenJSON(p_datosJson JSONB)
LANGUAGE plpgsql AS $$
DECLARE
    v_item JSONB; v_currentProveedor VARCHAR(50) := ''; v_currentPedido VARCHAR(20) := '';
    v_proveedorId INT; v_paisId INT; v_ordenCompraId INT := 0; v_estadoOrdenId INT;
    v_productoId INT; v_marcaId INT; v_tipoId INT; v_unidadId INT; v_loteId INT;
    v_nombreProveedor VARCHAR(50); v_isoPaisProv CHAR(3); v_numeroPedido VARCHAR(20);
BEGIN
    CALL spRegistrarLogCarga('spEjecutarImportacionMultiOrdenJSON', 'Iniciando...', 'INICIO', NULL);
    SELECT estadoOrdenId INTO v_estadoOrdenId FROM EstadosOrdenes WHERE nombreEstadoOrden = 'Aprobada' LIMIT 1;
    IF v_estadoOrdenId IS NULL THEN RAISE EXCEPTION 'Estado "Aprobada" no encontrado.'; END IF;

    FOR v_item IN SELECT * FROM jsonb_array_elements(p_datosJson) LOOP
        v_nombreProveedor := v_item->>'nombreProveedor';
        v_isoPaisProv := v_item->>'codigoIsoPaisProveedor';
        v_numeroPedido := v_item->>'numeroPedido';

        IF v_nombreProveedor != v_currentProveedor OR v_numeroPedido != v_currentPedido THEN
            SELECT paisId INTO v_paisId FROM Paises WHERE codigoIso = v_isoPaisProv LIMIT 1;
            IF v_paisId IS NULL THEN RAISE EXCEPTION 'País "%" no encontrado.', v_isoPaisProv; END IF;

            INSERT INTO Proveedores (nombreProveedor, paisId, activo) VALUES (v_nombreProveedor, v_paisId, TRUE) ON CONFLICT (nombreProveedor) DO NOTHING;
            SELECT proveedorId INTO v_proveedorId FROM Proveedores WHERE nombreProveedor = v_nombreProveedor LIMIT 1;

            SELECT ordenCompraId INTO v_ordenCompraId FROM OrdenesCompra WHERE numeroPedido = v_numeroPedido AND proveedorId = v_proveedorId LIMIT 1;

            IF v_ordenCompraId IS NULL THEN
                INSERT INTO OrdenesCompra (proveedorId, numeroPedido, fechaSolicitud, estadoOrdenId, tipoTransporteId, incoterm, comentarios, activo)
                VALUES (v_proveedorId, v_numeroPedido, (v_item->>'fechaSolicitud')::DATE, v_estadoOrdenId, 1, COALESCE(v_item->>'incoterm', 'FOB'), v_item->>'notas', TRUE)
                RETURNING ordenCompraId INTO v_ordenCompraId;
                CALL spRegistrarLogCarga('spEjecutarImportacionMultiOrdenJSON', 'Orden creada: ' || v_numeroPedido, 'EXITO', NULL);
            END IF;
            v_currentProveedor := v_nombreProveedor; v_currentPedido := v_numeroPedido;
        END IF;

        SELECT paisId INTO v_paisId FROM Paises WHERE codigoIso = v_item->>'codigoIsoPais' LIMIT 1;
        IF v_paisId IS NULL THEN RAISE EXCEPTION 'País producto "%" no existe.', v_item->>'codigoIsoPais'; END IF;

        INSERT INTO MarcasOriginales (nombreMarca, paisId, activo) VALUES (v_item->>'nombreMarca', v_paisId, TRUE) ON CONFLICT (nombreMarca) DO NOTHING;
        SELECT marcaOriginalId INTO v_marcaId FROM MarcasOriginales WHERE nombreMarca = v_item->>'nombreMarca' LIMIT 1;

        INSERT INTO TiposProducto (nombreTipoProducto, activo) VALUES (v_item->>'nombreTipoProducto', TRUE) ON CONFLICT (nombreTipoProducto) DO NOTHING;
        SELECT tipoProductoId INTO v_tipoId FROM TiposProducto WHERE nombreTipoProducto = v_item->>'nombreTipoProducto' LIMIT 1;

        INSERT INTO UnidadesMedidaProducto (nombreUnidadMedidaProducto, descripcion, activo) VALUES (v_item->>'nombreUnidadMedidaProducto', v_item->>'nombreUnidadMedidaProducto', TRUE) ON CONFLICT (nombreUnidadMedidaProducto) DO NOTHING;
        SELECT UnidadMedidaProductoId INTO v_unidadId FROM UnidadesMedidaProducto WHERE nombreUnidadMedidaProducto = v_item->>'nombreUnidadMedidaProducto' LIMIT 1;

        INSERT INTO Productos (skuInterno, nombreTecnicoProducto, nombreComunProducto, marcaOriginalId, tipoProductoId, unidadMedidaProductoId, vidaUtilMeses, activo)
        VALUES (v_item->>'skuInterno', v_item->>'nombreTecnicoProducto', v_item->>'nombreComunProducto', v_marcaId, v_tipoId, v_unidadId, (v_item->>'vidaUtilMeses')::INT, TRUE)
        ON CONFLICT (skuInterno) DO UPDATE SET nombreComunProducto = EXCLUDED.nombreComunProducto, ultimaAuditoria = NOW();
        
        SELECT productoId INTO v_productoId FROM Productos WHERE skuInterno = v_item->>'skuInterno' LIMIT 1;

        CALL spRegistrarDetalleImportacion(
            p_ordenCompraId := v_ordenCompraId, p_proveedorId := v_proveedorId, p_numeroPedido := v_numeroPedido,
            p_productoId := v_productoId, p_cantidadSolicitada := (v_item->>'cantidadSolicitada')::NUMERIC,
            p_precioUnitarioAcordado := (v_item->>'precioUnitarioAcordado')::NUMERIC,
            p_codigoIsoMonedaOrigen := v_item->>'codigoIsoMonedaOrigen',
            p_costosJson := COALESCE(v_item->'costos', '[]'::jsonb), p_loteBulkId := v_loteId
        );
    END LOOP;
    CALL spRegistrarLogCarga('spEjecutarImportacionMultiOrdenJSON', 'Finalizado', 'EXITO', NULL);
EXCEPTION WHEN OTHERS THEN CALL spRegistrarLogCarga('spEjecutarImportacionMultiOrdenJSON', 'Fallo critico', 'ERROR', SQLERRM); RAISE; END;
$$;

-- 6. SP AUXILIAR DETALLE
CREATE OR REPLACE PROCEDURE spRegistrarDetalleImportacion(
    p_ordenCompraId INT, p_proveedorId INT, p_numeroPedido VARCHAR(20), p_productoId INT,
    p_cantidadSolicitada NUMERIC(12,2), p_precioUnitarioAcordado NUMERIC(14,2),
    p_codigoIsoMonedaOrigen CHAR(3), OUT p_loteBulkId INT, p_costosJson JSONB DEFAULT '[]'::jsonb
)
LANGUAGE plpgsql AS $$
DECLARE
    v_currencyIdOrigen INT;
    v_currencyIdDestino INT; 
    v_tasaDeCambioId INT;
    v_exchangeRate NUMERIC;
    v_estadoItemId INT;
    v_costoItem JSONB;
    v_conceptoCostoId INT;
    v_montoLocal NUMERIC;
    v_monedaCostoIso CHAR(3);
    v_currencyIdCosto INT;
BEGIN

    SELECT currencyId INTO v_currencyIdDestino FROM Currencies WHERE codigoIso = 'USD' LIMIT 1;
    IF v_currencyIdDestino IS NULL THEN RAISE EXCEPTION 'Moneda base USD no encontrada.'; END IF;

    SELECT currencyId INTO v_currencyIdOrigen FROM Currencies WHERE TRIM(codigoIso) = TRIM(p_codigoIsoMonedaOrigen) LIMIT 1;
    IF v_currencyIdOrigen IS NULL THEN RAISE EXCEPTION 'Moneda origen "%" inválida.', p_codigoIsoMonedaOrigen; END IF;

    IF v_currencyIdOrigen = v_currencyIdDestino THEN

        v_exchangeRate := 1.0;
        v_tasaDeCambioId := NULL;
        SELECT tasaDeCambioId, exchangeRate INTO v_tasaDeCambioId, v_exchangeRate
        FROM TasasDeCambio WHERE currencyId1 = v_currencyIdOrigen AND currencyId2 = v_currencyIdDestino LIMIT 1;
        
        IF v_tasaDeCambioId IS NULL THEN
             
             INSERT INTO TasasDeCambio (currencyId1, currencyId2, exchangeRate, activo)
             VALUES (v_currencyIdOrigen, v_currencyIdDestino, 1.0, TRUE)
             ON CONFLICT (currencyId1, currencyId2) DO UPDATE SET exchangeRate = 1.0
             RETURNING tasaDeCambioId, exchangeRate INTO v_tasaDeCambioId, v_exchangeRate;
        END IF;

    ELSE
      
        SELECT tasaDeCambioId, exchangeRate INTO v_tasaDeCambioId, v_exchangeRate
        FROM TasasDeCambio
        WHERE currencyId1 = v_currencyIdOrigen AND currencyId2 = v_currencyIdDestino AND activo = TRUE LIMIT 1;
        
        IF v_tasaDeCambioId IS NULL THEN 
            RAISE EXCEPTION 'Tasa no disponible para % (ID:%) -> USD (ID:%).', p_codigoIsoMonedaOrigen, v_currencyIdOrigen, v_currencyIdDestino; 
        END IF;
    END IF;

  
    SELECT estadoItemId INTO v_estadoItemId FROM EstadosItems WHERE nombreEstadoItem = 'Confirmado' LIMIT 1;

    INSERT INTO ProductosPorOrden (ordenCompraId, productoId, cantidadSolicitada, currencyId, precioUnitarioAcordado, subtotal, tasaDeCambioAplicada, estadoItemId, activo)
    VALUES (p_ordenCompraId, p_productoId, p_cantidadSolicitada, v_currencyIdOrigen, p_precioUnitarioAcordado, (p_cantidadSolicitada * p_precioUnitarioAcordado), v_exchangeRate, v_estadoItemId, TRUE);

    INSERT INTO LotesBulk (productoId, proveedorId, ordenCompraId, numeroLoteProveedor, fechaVencimiento, cantidadTotal, currencyId, costoLocal, tasaDeCambioId, tasaDeCambioAplicada, costoTotal, estadoInventarioId, activo)
    VALUES (p_productoId, p_proveedorId, p_ordenCompraId, 'LOT-' || p_numeroPedido || '-' || p_productoId::TEXT, CURRENT_DATE + INTERVAL '2 years', p_cantidadSolicitada, v_currencyIdOrigen, (p_cantidadSolicitada * p_precioUnitarioAcordado), v_tasaDeCambioId, v_exchangeRate, (p_cantidadSolicitada * p_precioUnitarioAcordado * v_exchangeRate), 1, TRUE)
    RETURNING loteBulkId INTO p_loteBulkId;

    FOR v_costoItem IN SELECT * FROM jsonb_array_elements(p_costosJson) LOOP
        INSERT INTO ConceptosCostos (nombreConceptoCosto, descripcion, activo) VALUES (v_costoItem->>'nombreConceptoCosto', 'Costo dinámico', TRUE) ON CONFLICT (nombreConceptoCosto) DO NOTHING;
        SELECT conceptoCostoId INTO v_conceptoCostoId FROM ConceptosCostos WHERE nombreConceptoCosto = v_costoItem->>'nombreConceptoCosto' LIMIT 1;
        v_monedaCostoIso := v_costoItem->>'codigoIsoMoneda';
        SELECT currencyId INTO v_currencyIdCosto FROM Currencies WHERE codigoIso = v_monedaCostoIso LIMIT 1;
        IF v_currencyIdCosto IS NULL THEN RAISE EXCEPTION 'Moneda costo "%" inválida.', v_monedaCostoIso; END IF;
        v_montoLocal := (v_costoItem->>'montoLocal')::NUMERIC;
        INSERT INTO CostosOperativos (conceptoCostoId, loteBulkId, currencyId, montoLocal, tasaDeCambioAplicada, montoConvertido, activo)
        VALUES (v_conceptoCostoId, p_loteBulkId, v_currencyIdCosto, v_montoLocal, 1.0, v_montoLocal, TRUE);
    END LOOP;
END;
$$;


-- 7. PROCEDIMIENTO MAESTRO DE CARGA COMPLETA (ORQUESTADOR)
CREATE OR REPLACE PROCEDURE spEjecutarCargaCompletaDesdeJSON(p_rutaArchivoJSON TEXT)
LANGUAGE plpgsql
AS $$
DECLARE
    v_jsonData JSONB;
    v_paises_nombres VARCHAR(50)[];
    v_paises_isos CHAR(3)[];
BEGIN

    CALL spRegistrarLogCarga('spEjecutarCargaCompletaDesdeJSON', '=== INICIANDO CARGA COMPLETA ===', 'INICIO', NULL);
    CALL spInicializarMetadatosAuditoria();
    
    CALL spInicializarCatalogosPuros();
    
    CALL spRegistrarLogCarga('spEjecutarCargaCompletaDesdeJSON', 'Catálogos base inicializados', 'INFO', NULL);

    v_paises_nombres := ARRAY['Costa Rica', 'Estados Unidos', 'Brasil', 'China', 'Alemania'];
    v_paises_isos    := ARRAY['CRC', 'USA', 'BRA', 'CHN', 'DEU'];
    
    CALL spCargarPaisesLote(v_paises_nombres, v_paises_isos);
    
    CALL spRegistrarLogCarga('spEjecutarCargaCompletaDesdeJSON', 'Países semilla cargados', 'INFO', NULL);

    CALL spRegistrarLogCarga('spEjecutarCargaCompletaDesdeJSON', 'Leyendo archivo JSON: ' || p_rutaArchivoJSON, 'INFO', NULL);

    BEGIN
        v_jsonData := pg_read_file(p_rutaArchivoJSON)::text::jsonb;
    EXCEPTION WHEN OTHERS THEN
        CALL spRegistrarLogCarga('spEjecutarCargaCompletaDesdeJSON', 'Fallo al leer archivo', 'ERROR', SQLERRM);
        RAISE EXCEPTION 'Error crítico: No se pudo leer el archivo "%". Verifique ruta y permisos en el contenedor. Detalle: %', p_rutaArchivoJSON, SQLERRM;
    END;

    -- Validar estructura
    IF jsonb_typeof(v_jsonData) != 'array' THEN
        RAISE EXCEPTION 'El archivo JSON debe ser un array de objetos en la raíz.';
    END IF;

    CALL spRegistrarLogCarga('spEjecutarCargaCompletaDesdeJSON', 'Archivo leído correctamente. Iniciando importación masiva...', 'INFO', NULL);

    CALL spEjecutarImportacionMultiOrdenJSON(v_jsonData);

    CALL spRegistrarLogCarga('spEjecutarCargaCompletaDesdeJSON', '=== CARGA COMPLETA EXITOSA ===', 'EXITO', 'Todos los datos han sido insertados.');
    
    RAISE NOTICE 'Carga completada con éxito. Revise la tabla Logs para detalles.';

EXCEPTION WHEN OTHERS THEN
    CALL spRegistrarLogCarga('spEjecutarCargaCompletaDesdeJSON', 'FALLO CRÍTICO EN CARGA COMPLETA', 'ERROR', SQLERRM);
    RAISE;
END;
$$;

CALL spEjecutarCargaCompletaDesdeJSON('/app/data/ProductosImportados.json');