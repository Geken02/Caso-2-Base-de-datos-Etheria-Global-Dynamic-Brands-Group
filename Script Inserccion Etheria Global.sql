-- ============================================================================
-- ETHERIA GLOBAL - SCRIPT MAESTRO DE CARGA DE DATOS (SEED)
-- Autor: Gerald Hernández Gamboa
-- Versión: 1.0 (CamelCase Pure)
-- Descripción: Orquesta la carga completa mediante SPs transaccionales.
--              Nombres de tablas y columnas en CamelCase estricto.
-- ============================================================================

-- ============================================================================
-- 1. SP AUXILIAR: REGISTRAR LOGS (CamelCase)
-- ============================================================================
CREATE OR REPLACE PROCEDURE spRegistrarLogCarga(
    pSpNombre VARCHAR,
    pPaso VARCHAR,
    pEstado VARCHAR,
    pMensaje TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    vObjetoId INT;
    vSourceId INT;
    vTipoEventoId INT;
    vSeveridadId INT;
    vRefEjecucion BIGINT;
BEGIN
    -- Obtener IDs de catálogos
    SELECT objetoId INTO vObjetoId FROM Objetos WHERE nombreObjeto = 'Procedimiento carga data' LIMIT 1;
    SELECT sourceId INTO vSourceId FROM Sources WHERE nombreSource = 'Script inicial' LIMIT 1;
    SELECT tipoEventoId INTO vTipoEventoId FROM TiposEvento WHERE codigoEvento = 'SP EXECUTION' LIMIT 1;
    
    IF pEstado = 'Error' THEN
        SELECT severidadId INTO vSeveridadId FROM Severidades WHERE nombreSeveridad = 'Error' LIMIT 1;
    ELSE
        SELECT severidadId INTO vSeveridadId FROM Severidades WHERE nombreSeveridad = 'Informativo' LIMIT 1;
    END IF;

    vRefEjecucion := EXTRACT(EPOCH FROM CURRENT_TIMESTAMP)::BIGINT;

    -- Insertar solo si los IDs existen
    IF vObjetoId IS NOT NULL AND vSourceId IS NOT NULL AND vTipoEventoId IS NOT NULL THEN
        INSERT INTO Logs (
            tipoEventoId, severidadId, descripcion, sourceId, usuarioId, referenciaId1, objetoId1,
            datosNuevos, checkSum, creadoEn, activo
        ) VALUES (
            vTipoEventoId, 
            COALESCE(vSeveridadId, 2), 
            CONCAT(pSpNombre, ' - ', pPaso), 
            vSourceId,
            1, 
            vRefEjecucion,
            vObjetoId,
            jsonb_build_object('estado', pEstado, 'mensaje', pMensaje, 'pasoDetalle', pPaso),
            encode(sha256(CONCAT(pSpNombre, pPaso, CURRENT_TIMESTAMP)::bytea), 'hex'),
            CURRENT_TIMESTAMP,
            TRUE
        );
    END IF;
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Error al registrar log: %', SQLERRM;
END;
$$;

-- ============================================================================
-- 2. SP AUXILIAR: INICIALIZAR METADATOS DE AUDITORÍA (FASE 0)
-- ============================================================================
CREATE OR REPLACE PROCEDURE spInicializarMetadatosAuditoria()
LANGUAGE plpgsql
AS $$
BEGIN
   
    INSERT INTO Objetos (nombreObjeto, activo) VALUES ('Procedimiento carga data', TRUE) ON CONFLICT (nombreObjeto) DO NOTHING;

    INSERT INTO Sources (nombreSource, activo) VALUES ('Script inicial', TRUE) ON CONFLICT (nombreSource) DO NOTHING;

    INSERT INTO TiposEvento (codigoEvento, descripcion, requierePreguardado, activo) 
    VALUES ('SP EXECUTION', 'Ejecución de Stored Procedure de Carga Masiva', FALSE, TRUE) ON CONFLICT (codigoEvento) DO NOTHING;
    -- Asegurar Severidades
    INSERT INTO Severidades (valorSeveridad, nombreSeveridad, activo) VALUES (2, 'Informativo', TRUE), (4, 'Error', TRUE) ON CONFLICT (nombreSeveridad) DO NOTHING;
END;
$$;

-- ============================================================================
-- 3. SP FASE 1: CARGA DE MAESTROS (Geografía, Monedas, Usuarios, Tipos)
-- ============================================================================
CREATE OR REPLACE PROCEDURE spCargarMaestrosEtheria()
LANGUAGE plpgsql
AS $$
DECLARE
    vUsuarioId INT;
    vRolId INT;
    vCurrencyId INT;
BEGIN
    -- 1. Roles y Usuarios
    INSERT INTO Roles (nombreRol, descripcion, nivelAcceso, activo) 
    VALUES ('Admin Sistema', 'Administrador global', 100, TRUE) RETURNING rolId INTO vRolId;
    
    INSERT INTO Usuarios (nombreUsuario, email, contraseña, activo) 
    VALUES ('admin', 'admin@etheria.com', encode('admin123', 'utf8'), TRUE) RETURNING usuarioId INTO vUsuarioId;
    
    INSERT INTO UsuarioRol (usuarioId, rolId, asignadoPor, asignadoEn, activo) 
    VALUES (vUsuarioId, vRolId, vUsuarioId, CURRENT_TIMESTAMP, TRUE);

    -- 2. Monedas
    INSERT INTO Currencies (codigoIso, nombreCurrency, currencySymbol, activo) VALUES
    ('USD', 'Dólar Estadounidense', '$', TRUE),
    ('EUR', 'Euro', '€', TRUE),
    ('BRL', 'Real Brasileño', 'R$', TRUE),
    ('CNY', 'Yuan Chino', '¥', TRUE),
    ('CRC', 'Colón Costarricense', '₡', TRUE)
    ON CONFLICT (codigoIso) DO NOTHING;
    
    SELECT currencyId INTO vCurrencyId FROM Currencies WHERE codigoIso = 'USD';

    -- 3. Tasas de Cambio (Referencia USD)
    INSERT INTO TasasDeCambio (currencyId1, currencyId2, exchangeRate, activo)
    SELECT c1.currencyId, c2.currencyId, 
           CASE c2.codigoIso WHEN 'USD' THEN 1.0 WHEN 'EUR' THEN 0.92 WHEN 'BRL' THEN 5.05 WHEN 'CNY' THEN 7.20 WHEN 'CRC' THEN 520.00 ELSE 1.0 END, TRUE
    FROM Currencies c1, Currencies c2 WHERE c1.codigoIso = 'USD' ON CONFLICT DO NOTHING;

    -- 4. Tipos y Estados Base
    INSERT INTO TiposProducto (nombre, activo) VALUES ('Suplemento', TRUE), ('Cosmético', TRUE), ('Aceite', TRUE) ON CONFLICT DO NOTHING;
    
    INSERT INTO UnidadesMedidaProducto (nombreUnidadMedidaProducto, descripcion, activo) 
    VALUES ('Litro', 'L', TRUE), ('Kilogramo', 'KG', TRUE), ('Unidad', 'UND', TRUE) ON CONFLICT DO NOTHING;
    
    INSERT INTO EstadosInventario (nombre, permiteVenta, requiereInspeccion, descripcion, activo) VALUES
    ('Recepcionado', FALSE, TRUE, 'En cuarentena', TRUE), 
    ('Disponible', TRUE, FALSE, 'Listo venta', TRUE), 
    ('Reservado', FALSE, FALSE, 'Reservado', TRUE) ON CONFLICT DO NOTHING;
    
    INSERT INTO EstadosOrdenes (nombreEstadoOrden, activo) VALUES ('Borrador', TRUE), ('Aprobada', TRUE), ('En Tránsito', TRUE), ('Recibida', TRUE) ON CONFLICT DO NOTHING;
    
    INSERT INTO EstadosItems (nombreEstadoItem, activo) VALUES ('Pendiente', TRUE), ('Confirmado', TRUE) ON CONFLICT DO NOTHING;

    -- 5. Tipos de Características
    INSERT INTO TiposCaracteristica (nombreTipoCaracteristica, descripcion, activo) VALUES
    ('Apto Ingesta', 'Consumible', TRUE), 
    ('Apto Piel', 'Tópico', TRUE), 
    ('Refrigera', 'Temp control', TRUE) ON CONFLICT DO NOTHING;
    
    CALL spRegistrarLogCarga('spCargarMaestrosEtheria', 'Maestros cargados (Usuarios, Monedas, Tipos)', 'EXITO', NULL);
END;
$$;

-- ============================================================================
-- 4. SP FASE 2: CARGA DE NEGOCIO (Países, Proveedores, 100 Productos, Lotes)
-- ============================================================================
CREATE OR REPLACE PROCEDURE spCargarNegocioEtheria()
LANGUAGE plpgsql
AS $$
DECLARE
    vPaisId INT;
    vProdId INT;
    vLoteId INT;
    vProvId INT;
    vCurrencyId INT;
    vTipoCaractId INT;
    vContador INT := 0;
    vNombresPais TEXT[] := ARRAY['Costa Rica', 'Estados Unidos', 'Brasil', 'China', 'Alemania'];
    vCodigosIso TEXT[] := ARRAY['CRC', 'USA', 'BRA', 'CHN', 'DEU'];
    i INT;
BEGIN
    SELECT currencyId INTO vCurrencyId FROM Currencies WHERE codigoIso = 'USD' LIMIT 1;
    
    -- 1. Proveedores
    INSERT INTO Proveedores (nombreProveedor, paisOrigenId, activo) VALUES ('Global Imports SA', 1, TRUE) ON CONFLICT DO NOTHING;
    SELECT proveedorId INTO vProvId FROM Proveedores WHERE nombreProveedor = 'Global Imports SA' LIMIT 1;

    -- 2. Países (5)
    FOR i IN 1..5 LOOP
        INSERT INTO Paises (nombrePais, codigoIso, activo) VALUES (vNombresPais[i], vCodigosIso[i], TRUE) ON CONFLICT (codigoIso) DO UPDATE SET nombrePais = EXCLUDED.nombrePais;
    END LOOP;
    CALL spRegistrarLogCarga('spCargarNegocioEtheria', '5 Paises creados', 'EXITO', NULL);
        -- ... (Código previo de Países) ...
    -- Aseguramos que Nicaragua esté en la lista de los 5 países
    -- Si tu loop anterior ya lo incluye, perfecto. Si no, forzamos su creación aquí:
    INSERT INTO Paises (nombrePais, codigoIso, activo) 
    VALUES ('Nicaragua', 'NIC', TRUE) 
    ON CONFLICT (codigoIso) DO NOTHING;


    DECLARE vPaisNicaraguaId INT;
    SELECT paisId INTO vPaisNicaraguaId FROM Paises WHERE codigoIso = 'NIC' LIMIT 1;


    DECLARE vCiudadManaguaId INT;

    INSERT INTO Provincias (nombreProvincia, paisId, activo) 
    VALUES ('Managua', vPaisNicaraguaId, TRUE) 
    ON CONFLICT DO NOTHING;
    
    DECLARE vProvinciaManaguaId INT;
    SELECT provinciaId INTO vProvinciaManaguaId FROM Provincias WHERE nombreProvincia = 'Managua' AND paisId = vPaisNicaraguaId LIMIT 1;

    INSERT INTO Ciudades (nombreCiudad, provinciaId, activo) 
    VALUES ('Managua', vProvinciaManaguaId, TRUE) 
    ON CONFLICT DO NOTHING;
    
    SELECT ciudadId INTO vCiudadManaguaId FROM Ciudades WHERE nombreCiudad = 'Managua' AND provinciaId = vProvinciaManaguaId LIMIT 1;

    -- 2. Crear el Tipo de Ubicación "Hub Logístico" si no existe
    DECLARE vTipoHubId INT;
    INSERT INTO TiposUbicacion (nombreTipoUbicacion, descripcion, esInterno, requiereInspeccionEntrada, requiereInspeccionSalida, activo) 
    VALUES ('Hub Logístico Central', 'Centro de consolidación y distribución principal en Nicaragua', TRUE, TRUE, TRUE, TRUE)
    ON CONFLICT (nombreTipoUbicacion) DO NOTHING;
    
    SELECT tipoUbicacionId INTO vTipoHubId FROM TiposUbicacion WHERE nombreTipoUbicacion = 'Hub Logístico Central' LIMIT 1;

    -- 3. Crear la Ubicación Física del Hub en Nicaragua
    INSERT INTO Ubicaciones (
        nombreUbicacion, 
        tipoUbicacionId, 
        ciudadId, 
        direccion, 
        coordenadasLatitud, 
        coordenadasLongitud, 
        operadorLogistico, 
        activo
    ) VALUES (
        'Etheria Hub Nicaragua - Managua', -- Nombre claro
        vTipoHubId,                        -- Tipo: Hub
        vCiudadManaguaId,                  -- Ciudad: Managua
        'Km 12.5 Carretera Norte, Zona Franca, Managua', -- Dirección realista
        12.1360,                           -- Latitud aprox Managua
        -86.2510,                          -- Longitud aprox Managua
        'Etheria Global SA',               -- Operador
        TRUE
    ) ON CONFLICT DO NOTHING;

    
    CALL spRegistrarLogCarga('spCargarMaestrosEtheria', 'Hub Logístico Central en Nicaragua creado exitosamente', 'EXITO', 'Ubicación: Managua, NIC');

    FOR i IN 1..100 LOOP
        vPaisId := ((i-1) % 5) + 1; 

        -- Insertar Producto
        INSERT INTO Productos (skuInterno, nombreTecnico, nombreComun, marcaOriginalId, tipoProductoId, unidadMedidaProductoId, vidaUtilMeses, activo, usuarioAuditoria)
        VALUES ('SKU-ETH-' || LPAD(i::text, 4, '0'), 'Prod Técnico ' || i, 'Producto Común ' || i, 1, ((i%3)+1), ((i%3)+1), 24, TRUE, 1)
        ON CONFLICT (skuInterno) DO UPDATE SET nombreComun = EXCLUDED.nombreComun
        RETURNING productoId INTO vProdId;

        -- Característica (Ejemplo)
        IF i % 2 = 0 THEN
            SELECT tipoCaracteristicaId INTO vTipoCaractId FROM TiposCaracteristica WHERE nombreTipoCaracteristica LIKE 'Apto Ingesta%' LIMIT 1;
            IF vTipoCaractId IS NOT NULL THEN
                INSERT INTO CaracteristicasProducto (productoId, tipoCaracteristicaId, valorBoolean, vigenteDesde, activo) 
                VALUES (vProdId, vTipoCaractId, TRUE, CURRENT_DATE, TRUE) ON CONFLICT DO NOTHING;
            END IF;
        END IF;

        -- Precio Base
        INSERT INTO PreciosBaseProducto (productoId, currencyIdOrigen, precioLocal, valorTasaDeCambio, precioReferencia, fechaVigenciaDesde, activo)
        VALUES (vProdId, vCurrencyId, 10.00 + (i * 0.5), 1.0, 10.00 + (i * 0.5), CURRENT_DATE, TRUE);

        -- Lote Bulk
        INSERT INTO LotesBulk (productoId, proveedorId, numeroLoteProveedor, fechaRecepcionHub, fechaVencimiento, cantidadTotal, currencyId, costoLocal, exchangeRateApplied, costoTotalUsd, estadoInventarioId, activo)
        VALUES (vProdId, vProvId, 'LOT-'||i, CURRENT_TIMESTAMP, CURRENT_DATE + INTERVAL '2 years', 500+(i*10), vCurrencyId, 5.00+(i*0.1), 1.0, 5.00+(i*0.1), 2, TRUE)
        RETURNING loteBulkId INTO vLoteId;

        vContador := vContador + 1;
    END LOOP;

    CALL spRegistrarLogCarga('spCargarNegocioEtheria', '100 Productos y Lotes cargados', 'EXITO', 'Total: ' || vContador);
END;
$$;

-- ============================================================================
-- 5. SP ORQUESTADOR MAESTRO (LLAMADA PRINCIPAL)
-- ============================================================================
CREATE OR REPLACE PROCEDURE spOrquestarCargaCompletaEtheria()
LANGUAGE plpgsql
AS $$
BEGIN
    BEGIN
        -- FASE 0: Inicializar Auditoría
        CALL spInicializarMetadatosAuditoria();
        CALL spRegistrarLogCarga('spOrquestarCargaCompletaEtheria', 'Fase 0: Metadatos de auditoria listos', 'EXITO', NULL);

        -- FASE 1: Maestros
        CALL spCargarMaestrosEtheria();
        CALL spRegistrarLogCarga('spOrquestarCargaCompletaEtheria', 'Fase 1: Maestros completados', 'EXITO', NULL);

        -- FASE 2: Negocio
        CALL spCargarNegocioEtheria();
        CALL spRegistrarLogCarga('spOrquestarCargaCompletaEtheria', 'Fase 2: Negocio completado', 'EXITO', NULL);

        -- Validación Final
        IF (SELECT COUNT(*) FROM Productos) < 100 THEN RAISE EXCEPTION 'Validacion fallida: Menos de 100 productos.'; END IF;
        IF (SELECT COUNT(*) FROM Paises) < 5 THEN RAISE EXCEPTION 'Validacion fallida: Menos de 5 paises.'; END IF;

        CALL spRegistrarLogCarga('spOrquestarCargaCompletaEtheria', 'PROCESO FINALIZADO CON EXITO', 'EXITO', 'Datos verificados correctamente');

    EXCEPTION WHEN OTHERS THEN
        CALL spRegistrarLogCarga('spOrquestarCargaCompletaEtheria', 'FALLO CRITICO', 'ERROR', SQLERRM);
        RAISE;
    END;
END;
$$;


CALL spOrquestarCargaCompletaEtheria();

