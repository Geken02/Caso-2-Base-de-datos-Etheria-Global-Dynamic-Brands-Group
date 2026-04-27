
-- 1. GEOGRAFÍA Y UBICACIONES
CREATE TABLE Ciudades (
    ciudadId SERIAL PRIMARY KEY,
    nombreCiudad VARCHAR(50),
    provinciaId INT,
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT,
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE Provincias (
    provinciaId SERIAL PRIMARY KEY,
    nombreProvincia VARCHAR(50),
    paisId INT,
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT,
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE Paises (
    paisId SERIAL PRIMARY KEY,
    nombrePais VARCHAR(50) NOT NULL,
    codigoIso CHAR(3) UNIQUE NOT NULL,
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT,
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE Ubicaciones (
    ubicacionId SERIAL PRIMARY KEY,
    nombreUbicacion VARCHAR(50) NOT NULL,
    tipoUbicacionId INT NOT NULL,
    ciudadId INT,
    direccion VARCHAR(200),
    esActiva BOOLEAN DEFAULT TRUE,
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT,
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE TiposUbicacion (
    tipoUbicacionId SERIAL PRIMARY KEY,
    nombreTipoUbicacion VARCHAR(50) NOT NULL,
    descripcion VARCHAR(150),
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT,
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE Puertos (
    puertoId SERIAL PRIMARY KEY,
    nombrePuerto VARCHAR(50),
    ubicacionId INT NOT NULL UNIQUE,
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT,
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE Aeropuertos (
    aeropuertoId SERIAL PRIMARY KEY,
    nombreAeropuerto VARCHAR(50),
    ubicacionId INT NOT NULL UNIQUE,
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT,
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

-- 2. LOGÍSTICA Y TRANSPORTES
CREATE TABLE Courier (
    courierId SERIAL PRIMARY KEY,
    nombreCourier VARCHAR(50),
    ciudadId INT,
    tipoServicioId INT,
    tiempoEntregaPromedioDias INT,
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT,
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE TiposServicio (
    tipoServicioId SERIAL PRIMARY KEY,
    nombreTipoServicio VARCHAR(50),
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT,
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE TiposTransporte (
    tipoTransporteId SERIAL PRIMARY KEY,
    nombreTipoTransporte VARCHAR(50) NOT NULL,
    descripcion VARCHAR(100),
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT,
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

-- 3. MONEDAS Y TASAS
CREATE TABLE Currencies (
    currencyId SERIAL PRIMARY KEY,
    codigoIso CHAR(3) UNIQUE NOT NULL,
    currencySymbol CHAR,
    nombreCurrency VARCHAR(50),
    activo BOOLEAN DEFAULT TRUE,
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT,
    ultimaAuditoria TIMESTAMP
);

CREATE TABLE MonedasPorPais (
    monedaPaisId SERIAL PRIMARY KEY,
    currencyId INT NOT NULL,
    paisId INT NOT NULL,
    esOficial BOOLEAN DEFAULT TRUE,
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE TasasDeCambio (
    tasaDeCambioId SERIAL PRIMARY KEY,
    currencyId1 INT,
    currencyId2 INT,
    exchangeRate DECIMAL(12,6),
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT,
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE HistorialTasasDeCambio (
    historialTasaDeCambioId SERIAL PRIMARY KEY,
    fechaInicio TIMESTAMP,
    fechaFinal TIMESTAMP,
    currencyId1 INT,
    currencyId2 INT,
    exchangeRate DECIMAL(12,6),
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT,
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE,
    tasaDeCambioId INT
);

CREATE TABLE ConfiguracionTasasCambio (
    configuracionTasaId SERIAL PRIMARY KEY,
    currencyId1 INT NOT NULL,
    currencyId2 INT NOT NULL,
    frecuenciaActualizacionHoras INT DEFAULT 24,
    variacionMaximaDiariaPorcentaje DECIMAL(5,2) DEFAULT 5.00,
    requiereValidacionManual BOOLEAN DEFAULT FALSE,
    rolValidadorId INT,
    redondeoDecimales INT,
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT,
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

-- 4. PRODUCTOS Y CARACTERÍSTICAS
CREATE TABLE TiposCaracteristica (
    tipoCaracteristicaId SERIAL PRIMARY KEY,
    nombreTipoCaracteristica VARCHAR(50) NOT NULL,
    descripcion VARCHAR(150),
    activo BOOLEAN DEFAULT TRUE,
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT,
    ultimaAuditoria TIMESTAMP
);

CREATE TABLE CaracteristicasProducto (
    caracteristicaId SERIAL PRIMARY KEY,
    productoId INT NOT NULL,
    tipoCaracteristicaId INT NOT NULL,
    valorBoolean BOOLEAN,
    valorTexto VARCHAR(255),
    valorNumerico DECIMAL(10,2),
    paisId INT,
    vigenteDesde DATE DEFAULT CURRENT_DATE,
    vigenteHasta DATE,
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT,
    activa BOOLEAN DEFAULT TRUE,
    ultimaAuditoria TIMESTAMP
);

CREATE TABLE Productos (
    productoId SERIAL PRIMARY KEY,
    skuInterno VARCHAR(20) UNIQUE NOT NULL,
    nombreTecnico VARCHAR(50) NOT NULL,
    nombreComun VARCHAR(50),
    marcaOriginalId INT NOT NULL,
    tipoProductoId INT,
    unidadMedidaProductoId INT,
    vidaUtilMeses INT,
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT,
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE TiposProducto (
    tipoProductoId SERIAL PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT,
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE UnidadesMedidaProducto (
    unidadMedidaProductoId SERIAL PRIMARY KEY,
    nombreUnidadMedidaProducto VARCHAR(50) NOT NULL,
    descripcion VARCHAR(100),
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT,
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE PreciosBaseProducto (
    precioBaseId SERIAL PRIMARY KEY,
    productoId INT,
    currencyIdOrigen INT NOT NULL,
    precioLocal DECIMAL(14,2) NOT NULL,
    tasaDeCambioId INT,
    valorTasaDeCambio DECIMAL(12,6) NOT NULL,
    precioReferencia DECIMAL(14,2) NOT NULL,
    margenMinimoRecomendado DECIMAL(5,2),
    fechaVigenciaDesde DATE NOT NULL,
    fechaVigenciaHasta DATE,
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT,
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE MarcasOriginales (
    marcaOriginalId SERIAL PRIMARY KEY,
    nombreMarca VARCHAR(100) NOT NULL,
    paisId INT,
    descripcionMarca VARCHAR(250),
    esActiva BOOLEAN DEFAULT TRUE,
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT,
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

-- 5. COMPRAS Y PROVEEDORES
CREATE TABLE OrdenesCompra (
    ordenCompraId SERIAL PRIMARY KEY,
    proveedorId INT,
    numeroPedido VARCHAR(20),
    fechaSolicitud DATE NOT NULL,
    fechaRecepcion DATE,
    estadoOrdenId INT,
    tipoTransporteId INT NOT NULL,
    incoterm VARCHAR(10) DEFAULT 'FOB',
    puntoEntradaId INT,
    comentarios VARCHAR(200),
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT,
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE EstadosOrdenes (
    estadoOrdenId SERIAL PRIMARY KEY,
    nombreEstadoOrden VARCHAR(50) NOT NULL,
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT,
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE ConfiguracionAprobacionOrdenes (
    configuracionAprobacionId SERIAL PRIMARY KEY,
    montoMinimoUsd DECIMAL(12,2) NOT NULL,
    montoMaximoUsd DECIMAL(12,2),
    rolRequeridoId INT NOT NULL,
    nivelAprobacion INT NOT NULL,
    requiereDobleFirma BOOLEAN DEFAULT FALSE,
    tiempoMaximoAprobacionHoras INT DEFAULT 48,
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT,
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE Proveedores (
    proveedorId SERIAL PRIMARY KEY,
    nombreProveedor VARCHAR(50) NOT NULL,
    paisOrigenId INT,
    tiempoEntregaPromedioDias INT,
    calificacionConfianza DECIMAL(3,2),
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT,
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE TiposContactos (
    tipoContactoId SERIAL PRIMARY KEY,
    nombreTipoContacto VARCHAR(30) NOT NULL,
    descripcion VARCHAR(100),
    formatoValidacion VARCHAR(100),
    longitudMinima INT,
    longitudMaxima INT,
    esActivo BOOLEAN DEFAULT TRUE,
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT,
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE InfoContactosProveedor (
    infoContactoProveedorId SERIAL PRIMARY KEY,
    tipoContactoId INT NOT NULL,
    proveedorId INT,
    valor VARCHAR(100) NOT NULL,
    esPrincipal BOOLEAN DEFAULT FALSE,
    verificado BOOLEAN DEFAULT FALSE,
    fechaVerificacion TIMESTAMP,
    horarioAtencion VARCHAR(50),
    idiomaSoporte CHAR(2) DEFAULT 'en',
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT,
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE InstruccionesCompra (
    instruccionCompraId SERIAL PRIMARY KEY,
    referenciaOrdenVentaId INT,
    productoBaseId INT NOT NULL,
    cantidadSolicitada DECIMAL(12,2) NOT NULL,
    paisDestinoId INT NOT NULL,
    tiendaOrigenId INT,
    fechaSolicitud TIMESTAMP NOT NULL,
    fechaLimiteEntrega DATE NOT NULL,
    ordenCompraId INT,
    margenObjetivoPorcentaje DECIMAL(5,2),
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT,
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

-- 6. INVENTARIO BULK
CREATE TABLE LotesBulk (
    loteBulkId SERIAL PRIMARY KEY,
    productoId INT NOT NULL,
    proveedorId INT NOT NULL,
    ordenCompraId INT,
    numeroLoteProveedor VARCHAR(100) NOT NULL,
    ubicacionId INT,
    fechaRecepcionHub TIMESTAMP NOT NULL,
    fechaVencimiento DATE NOT NULL,
    cantidadTotal DECIMAL(12,2) NOT NULL,
    currencyId INT NOT NULL,
    costoLocal DECIMAL(14,2) NOT NULL,
    tasaDeCambioId INT,
    exchangeRateApplied DECIMAL(12,6) NOT NULL,
    costoTotalUsd DECIMAL(14,2) NOT NULL,
    estadoInventarioId INT NOT NULL,
    tipoTransporteId INT,
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT,
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE EstadosInventario (
    estadoInventarioId SERIAL PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    permiteVenta BOOLEAN,
    requiereInspeccion BOOLEAN,
    descripcion VARCHAR(150),
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT,
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE ConfiguracionesAceptacionBulks (
    configuracionAceptacionId SERIAL PRIMARY KEY,
    tipoProductoId INT,
    proveedorId INT,
    mermaMaximaPorcentaje DECIMAL(5,2),
    vidaUtilMinimaRestantePorcentaje DECIMAL(5,2),
    desviacionTemperaturaMaxima DECIMAL(4,1),
    requiereMuestreoCalidad BOOLEAN DEFAULT TRUE,
    tiempoMaximoMuestreoHoras INT,
    accionSiFalla VARCHAR(30),
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT,
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE ProductosPorOrden (
    productoPorOrdenId SERIAL PRIMARY KEY,
    ordenCompraId INT NOT NULL,
    productoId INT NOT NULL,
    cantidadSolicitada DECIMAL(12,2) NOT NULL,
    currencyId INT NOT NULL,
    precioUnitarioAcordado DECIMAL(14,2) NOT NULL,
    subtotal DECIMAL(14,2) NOT NULL,
    tasaDeCambioAplicada DECIMAL(12,6) NOT NULL,
    estadoItemId INT NOT NULL,
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT,
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE EstadosItems (
    estadoItemId SERIAL PRIMARY KEY,
    nombreEstadoItem VARCHAR(50) NOT NULL,
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT,
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

-- 7. TRAZABILIDAD Y COSTOS
CREATE TABLE TrazabilidadOrdenes (
    trazabilidadId SERIAL PRIMARY KEY,
    ordenCompraId INT NOT NULL,
    productoPorOrdenId INT,
    etapaActualId INT NOT NULL,
    fechaCambioEtapa TIMESTAMP NOT NULL,
    ubicacionActual VARCHAR(100),
    tipoTransporteEtapaId INT,
    transportistaNombre VARCHAR(100),
    numeroGuiaInternacional VARCHAR(100),
    fechaEstimadaLlegada DATE,
    fechaRealLlegada DATE,
    incidencias VARCHAR(200),
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT,
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE HistorialEtapasOrden (
    historialEtapaId SERIAL PRIMARY KEY,
    trazabilidadId INT NOT NULL,
    etapaAnterior INT,
    etapaNueva INT NOT NULL,
    fechaCambio TIMESTAMP,
    responsableCambioId INT,
    comentarioCambio VARCHAR(200),
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE CostosOperativos (
    costoId SERIAL PRIMARY KEY,
    loteBulkId INT NOT NULL,
    concepto VARCHAR(30) NOT NULL,
    currencyId INT NOT NULL,
    montoLocal DECIMAL(14,2) NOT NULL,
    tasaDeCambioId INT,
    tasaDeCambioAplicada DECIMAL(12,6) NOT NULL,
    montoConvertidoUsd DECIMAL(14,2),
    fechaPago DATE,
    paisId INT,
    documentoSoporte VARCHAR(200),
    tipoTransporteId INT,
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT,
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE ConceptosCostos (
    conceptoCostoId SERIAL PRIMARY KEY,
    nombreConceptoCosto VARCHAR(50) NOT NULL,
    descripcion VARCHAR(150),
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT,
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

-- 8. IMPUESTOS
CREATE TABLE ImpuestosPorPais (
    impuestoId SERIAL PRIMARY KEY,
    productoId INT,
    paisId INT,
    tipoImpuestoId INT,
    descripcion VARCHAR(250),
    porcentaje DECIMAL(5,2),
    montoFijo DECIMAL(14,2),
    vigenciaDesde DATE,
    vigenciaHasta DATE,
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE TiposImpuesto (
    tipoImpuestoId SERIAL PRIMARY KEY,
    nombreTipoImpuesto VARCHAR(50),
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT,
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

-- 9. SEGURIDAD Y AUDITORÍA
CREATE TABLE TiposEvento (
    tipoEventoId SERIAL PRIMARY KEY,
    nombreEvento VARCHAR(30),
    descripcion VARCHAR(100) NOT NULL,
    requierePreguardado BOOLEAN DEFAULT TRUE,
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT,
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE Severidades (
    severidadId SERIAL PRIMARY KEY,
    valorSeveridad INT NOT NULL,
    nombreSeveridad VARCHAR(20) NOT NULL,
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT,
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE Objetos (
    objetoId SERIAL PRIMARY KEY,
    nombreObjeto VARCHAR(50) UNIQUE NOT NULL,
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT,
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE Sources (
    sourceId SERIAL PRIMARY KEY,
    nombreSource VARCHAR(50),
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT,
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE Logs (
    logId SERIAL PRIMARY KEY,
    tipoEventoId INT NOT NULL,
    severidadId INT NOT NULL DEFAULT 2,
    descripcion VARCHAR(100) NOT NULL,
    sourceId INT NOT NULL,
    userAgent TEXT,
    computadora VARCHAR(100),
    usuarioId INT,
    referenciaId1 BIGINT,
    referenciaId2 BIGINT,
    descripcionReferencia1 VARCHAR(200),
    descripcionReferencia2 VARCHAR(200),
    objetoId1 INT,
    objetoId2 INT,
    datosAnteriores JSONB,
    datosNuevos JSONB,
    checkSum VARCHAR(64),
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE ConfiguracionesSistema (
    configuracionSistemaId SERIAL PRIMARY KEY,
    clave VARCHAR(50) UNIQUE NOT NULL,
    valorText VARCHAR(300),
    valorInt INT,
    valorDecimal DECIMAL(18,6),
    valorBoolean BOOLEAN,
    valorJson JSONB,
    categoriaId INT NOT NULL,
    descripcion VARCHAR(200) NOT NULL,
    esEditableUI BOOLEAN DEFAULT TRUE,
    requiereReinicioSistema BOOLEAN DEFAULT FALSE,
    ultimoCambioPor INT,
    ultimoCambioEn TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE CategoriasConfiguracion (
    categoriaConfiguracionId SERIAL PRIMARY KEY,
    nombreCategoriaConfiguracion VARCHAR(50),
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT,
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE Usuarios (
    usuarioId SERIAL PRIMARY KEY,
    nombreUsuario VARCHAR(50),
    apellido1 VARCHAR(40),
    apellido2 VARCHAR(40),
    email VARCHAR(100),
    contraseña BYTEA,
    fechaNacimiento DATE,
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT,
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE Roles (
    rolId SERIAL PRIMARY KEY,
    nombreRol VARCHAR(50),
    descripcion VARCHAR(255),
    nivelAcceso INTEGER,
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT,
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE Permiso (
    permisoId SERIAL PRIMARY KEY,
    nombrePermiso VARCHAR(50),
    descripcion VARCHAR(255),
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT,
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE RolPermiso (
    rolId INT NOT NULL,
    permisoId INT NOT NULL,
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT,
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE,
    PRIMARY KEY (rolId, permisoId)
);

CREATE TABLE UsuarioRol (
    usuarioId INT NOT NULL,
    rolId INT NOT NULL,
    asignadoPor INT,
    asignadoEn TIMESTAMP,
    fechaExpiracion TIMESTAMP,
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT,
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE,
    PRIMARY KEY (usuarioId, rolId)
);

-- ============================================================================
-- FOREIGN KEY CONSTRAINTS (RELACIONES EXPLÍCITAS)
-- ============================================================================

-- Geografía
ALTER TABLE Ciudades ADD CONSTRAINT fk_ciudades_provincias FOREIGN KEY (provinciaId) REFERENCES Provincias(provinciaId);
ALTER TABLE Provincias ADD CONSTRAINT fk_provincias_paises FOREIGN KEY (paisId) REFERENCES Paises(paisId);
ALTER TABLE Ubicaciones ADD CONSTRAINT fk_ubicaciones_tipos FOREIGN KEY (tipoUbicacionId) REFERENCES TiposUbicacion(tipoUbicacionId);
ALTER TABLE Ubicaciones ADD CONSTRAINT fk_ubicaciones_ciudades FOREIGN KEY (ciudadId) REFERENCES Ciudades(ciudadId);
ALTER TABLE Puertos ADD CONSTRAINT fk_puertos_ubicaciones FOREIGN KEY (ubicacionId) REFERENCES Ubicaciones(ubicacionId);
ALTER TABLE Aeropuertos ADD CONSTRAINT fk_aeropuertos_ubicaciones FOREIGN KEY (ubicacionId) REFERENCES Ubicaciones(ubicacionId);

-- Logística
ALTER TABLE Courier ADD CONSTRAINT fk_courier_ciudades FOREIGN KEY (ciudadId) REFERENCES Ciudades(ciudadId);
ALTER TABLE Courier ADD CONSTRAINT fk_courier_tipos FOREIGN KEY (tipoServicioId) REFERENCES TiposServicio(tipoServicioId);

-- Monedas
ALTER TABLE MonedasPorPais ADD CONSTRAINT fk_monedas_currency FOREIGN KEY (currencyId) REFERENCES Currencies(currencyId);
ALTER TABLE MonedasPorPais ADD CONSTRAINT fk_monedas_paises FOREIGN KEY (paisId) REFERENCES Paises(paisId);
ALTER TABLE TasasDeCambio ADD CONSTRAINT fk_tasas_c1 FOREIGN KEY (currencyId1) REFERENCES Currencies(currencyId);
ALTER TABLE TasasDeCambio ADD CONSTRAINT fk_tasas_c2 FOREIGN KEY (currencyId2) REFERENCES Currencies(currencyId);
ALTER TABLE HistorialTasasDeCambio ADD CONSTRAINT fk_hist_tasas_c1 FOREIGN KEY (currencyId1) REFERENCES Currencies(currencyId);
ALTER TABLE HistorialTasasDeCambio ADD CONSTRAINT fk_hist_tasas_c2 FOREIGN KEY (currencyId2) REFERENCES Currencies(currencyId);
ALTER TABLE HistorialTasasDeCambio ADD CONSTRAINT fk_hist_tasas_ref FOREIGN KEY (tasaDeCambioId) REFERENCES TasasDeCambio(tasaDeCambioId);
ALTER TABLE ConfiguracionTasasCambio ADD CONSTRAINT fk_config_tasas_c1 FOREIGN KEY (currencyId1) REFERENCES Currencies(currencyId);
ALTER TABLE ConfiguracionTasasCambio ADD CONSTRAINT fk_config_tasas_c2 FOREIGN KEY (currencyId2) REFERENCES Currencies(currencyId);
ALTER TABLE ConfiguracionTasasCambio ADD CONSTRAINT fk_config_tasas_rol FOREIGN KEY (rolValidadorId) REFERENCES Roles(rolId);

-- Productos
ALTER TABLE CaracteristicasProducto ADD CONSTRAINT fk_caract_prod FOREIGN KEY (productoId) REFERENCES Productos(productoId);
ALTER TABLE CaracteristicasProducto ADD CONSTRAINT fk_caract_tipo FOREIGN KEY (tipoCaracteristicaId) REFERENCES TiposCaracteristica(tipoCaracteristicaId);
ALTER TABLE CaracteristicasProducto ADD CONSTRAINT fk_caract_pais FOREIGN KEY (paisId) REFERENCES Paises(paisId);
ALTER TABLE Productos ADD CONSTRAINT fk_prod_marca FOREIGN KEY (marcaOriginalId) REFERENCES MarcasOriginales(marcaOriginalId);
ALTER TABLE Productos ADD CONSTRAINT fk_prod_tipo FOREIGN KEY (tipoProductoId) REFERENCES TiposProducto(tipoProductoId);
ALTER TABLE Productos ADD CONSTRAINT fk_prod_unidad FOREIGN KEY (unidadMedidaProductoId) REFERENCES UnidadesMedidaProducto(unidadMedidaProductoId);
ALTER TABLE PreciosBaseProducto ADD CONSTRAINT fk_precios_prod FOREIGN KEY (productoId) REFERENCES Productos(productoId);
ALTER TABLE PreciosBaseProducto ADD CONSTRAINT fk_precios_currency FOREIGN KEY (currencyIdOrigen) REFERENCES Currencies(currencyId);
ALTER TABLE PreciosBaseProducto ADD CONSTRAINT fk_precios_tasa FOREIGN KEY (tasaDeCambioId) REFERENCES TasasDeCambio(tasaDeCambioId);
ALTER TABLE MarcasOriginales ADD CONSTRAINT fk_marcas_pais FOREIGN KEY (paisId) REFERENCES Paises(paisId);

-- Compras
ALTER TABLE OrdenesCompra ADD CONSTRAINT fk_ordenes_prov FOREIGN KEY (proveedorId) REFERENCES Proveedores(proveedorId);
ALTER TABLE OrdenesCompra ADD CONSTRAINT fk_ordenes_estado FOREIGN KEY (estadoOrdenId) REFERENCES EstadosOrdenes(estadoOrdenId);
ALTER TABLE OrdenesCompra ADD CONSTRAINT fk_ordenes_transporte FOREIGN KEY (tipoTransporteId) REFERENCES TiposTransporte(tipoTransporteId);
ALTER TABLE OrdenesCompra ADD CONSTRAINT fk_ordenes_ubicacion FOREIGN KEY (puntoEntradaId) REFERENCES Ubicaciones(ubicacionId);
ALTER TABLE ConfiguracionAprobacionOrdenes ADD CONSTRAINT fk_config_aprob_rol FOREIGN KEY (rolRequeridoId) REFERENCES Roles(rolId);
ALTER TABLE Proveedores ADD CONSTRAINT fk_prov_pais FOREIGN KEY (paisOrigenId) REFERENCES Paises(paisId);
ALTER TABLE InfoContactosProveedor ADD CONSTRAINT fk_info_contacto_tipo FOREIGN KEY (tipoContactoId) REFERENCES TiposContactos(tipoContactoId);
ALTER TABLE InfoContactosProveedor ADD CONSTRAINT fk_info_contacto_prov FOREIGN KEY (proveedorId) REFERENCES Proveedores(proveedorId);
ALTER TABLE InstruccionesCompra ADD CONSTRAINT fk_instrucc_prod FOREIGN KEY (productoBaseId) REFERENCES Productos(productoId);
ALTER TABLE InstruccionesCompra ADD CONSTRAINT fk_instrucc_pais FOREIGN KEY (paisDestinoId) REFERENCES Paises(paisId);
ALTER TABLE InstruccionesCompra ADD CONSTRAINT fk_instrucc_orden FOREIGN KEY (ordenCompraId) REFERENCES OrdenesCompra(ordenCompraId);

-- Inventario
ALTER TABLE LotesBulk ADD CONSTRAINT fk_lotes_prod FOREIGN KEY (productoId) REFERENCES Productos(productoId);
ALTER TABLE LotesBulk ADD CONSTRAINT fk_lotes_prov FOREIGN KEY (proveedorId) REFERENCES Proveedores(proveedorId);
ALTER TABLE LotesBulk ADD CONSTRAINT fk_lotes_orden FOREIGN KEY (ordenCompraId) REFERENCES OrdenesCompra(ordenCompraId);
ALTER TABLE LotesBulk ADD CONSTRAINT fk_lotes_ubicacion FOREIGN KEY (ubicacionId) REFERENCES Ubicaciones(ubicacionId);
ALTER TABLE LotesBulk ADD CONSTRAINT fk_lotes_currency FOREIGN KEY (currencyId) REFERENCES Currencies(currencyId);
ALTER TABLE LotesBulk ADD CONSTRAINT fk_lotes_tasa FOREIGN KEY (tasaDeCambioId) REFERENCES TasasDeCambio(tasaDeCambioId);
ALTER TABLE LotesBulk ADD CONSTRAINT fk_lotes_estado_inv FOREIGN KEY (estadoInventarioId) REFERENCES EstadosInventario(estadoInventarioId);
ALTER TABLE LotesBulk ADD CONSTRAINT fk_lotes_transporte FOREIGN KEY (tipoTransporteId) REFERENCES TiposTransporte(tipoTransporteId);
ALTER TABLE ConfiguracionesAceptacionBulks ADD CONSTRAINT fk_config_acept_tipo FOREIGN KEY (tipoProductoId) REFERENCES TiposProducto(tipoProductoId);
ALTER TABLE ConfiguracionesAceptacionBulks ADD CONSTRAINT fk_config_acept_prov FOREIGN KEY (proveedorId) REFERENCES Proveedores(proveedorId);
ALTER TABLE ProductosPorOrden ADD CONSTRAINT fk_prod_ord_orden FOREIGN KEY (ordenCompraId) REFERENCES OrdenesCompra(ordenCompraId);
ALTER TABLE ProductosPorOrden ADD CONSTRAINT fk_prod_ord_prod FOREIGN KEY (productoId) REFERENCES Productos(productoId);
ALTER TABLE ProductosPorOrden ADD CONSTRAINT fk_prod_ord_currency FOREIGN KEY (currencyId) REFERENCES Currencies(currencyId);
ALTER TABLE ProductosPorOrden ADD CONSTRAINT fk_prod_ord_estado FOREIGN KEY (estadoItemId) REFERENCES EstadosItems(estadoItemId);

-- Trazabilidad y Costos
ALTER TABLE TrazabilidadOrdenes ADD CONSTRAINT fk_traza_orden FOREIGN KEY (ordenCompraId) REFERENCES OrdenesCompra(ordenCompraId);
ALTER TABLE TrazabilidadOrdenes ADD CONSTRAINT fk_traza_prod_ord FOREIGN KEY (productoPorOrdenId) REFERENCES ProductosPorOrden(productoPorOrdenId);
ALTER TABLE TrazabilidadOrdenes ADD CONSTRAINT fk_traza_estado FOREIGN KEY (etapaActualId) REFERENCES EstadosOrdenes(estadoOrdenId);
ALTER TABLE TrazabilidadOrdenes ADD CONSTRAINT fk_traza_transporte FOREIGN KEY (tipoTransporteEtapaId) REFERENCES TiposTransporte(tipoTransporteId);
ALTER TABLE HistorialEtapasOrden ADD CONSTRAINT fk_hist_etapa_traza FOREIGN KEY (trazabilidadId) REFERENCES TrazabilidadOrdenes(trazabilidadId);
ALTER TABLE HistorialEtapasOrden ADD CONSTRAINT fk_hist_etapa_ant FOREIGN KEY (etapaAnterior) REFERENCES EstadosOrdenes(estadoOrdenId);
ALTER TABLE HistorialEtapasOrden ADD CONSTRAINT fk_hist_etapa_nueva FOREIGN KEY (etapaNueva) REFERENCES EstadosOrdenes(estadoOrdenId);
ALTER TABLE HistorialEtapasOrden ADD CONSTRAINT fk_hist_etapa_resp FOREIGN KEY (responsableCambioId) REFERENCES Usuarios(usuarioId);
ALTER TABLE CostosOperativos ADD CONSTRAINT fk_costos_lotes FOREIGN KEY (loteBulkId) REFERENCES LotesBulk(loteBulkId);
ALTER TABLE CostosOperativos ADD CONSTRAINT fk_costos_currency FOREIGN KEY (currencyId) REFERENCES Currencies(currencyId);
ALTER TABLE CostosOperativos ADD CONSTRAINT fk_costos_tasa FOREIGN KEY (tasaDeCambioId) REFERENCES TasasDeCambio(tasaDeCambioId);
ALTER TABLE CostosOperativos ADD CONSTRAINT fk_costos_pais FOREIGN KEY (paisId) REFERENCES Paises(paisId);
ALTER TABLE CostosOperativos ADD CONSTRAINT fk_costos_transporte FOREIGN KEY (tipoTransporteId) REFERENCES TiposTransporte(tipoTransporteId);

-- Impuestos
ALTER TABLE ImpuestosPorPais ADD CONSTRAINT fk_impuestos_prod FOREIGN KEY (productoId) REFERENCES Productos(productoId);
ALTER TABLE ImpuestosPorPais ADD CONSTRAINT fk_impuestos_pais FOREIGN KEY (paisId) REFERENCES Paises(paisId);
ALTER TABLE ImpuestosPorPais ADD CONSTRAINT fk_impuestos_tipo FOREIGN KEY (tipoImpuestoId) REFERENCES TiposImpuesto(tipoImpuestoId);

-- Logs y Seguridad
ALTER TABLE Logs ADD CONSTRAINT fk_logs_evento FOREIGN KEY (tipoEventoId) REFERENCES TiposEvento(tipoEventoId);
ALTER TABLE Logs ADD CONSTRAINT fk_logs_severidad FOREIGN KEY (severidadId) REFERENCES Severidades(severidadId);
ALTER TABLE Logs ADD CONSTRAINT fk_logs_source FOREIGN KEY (sourceId) REFERENCES Sources(sourceId);
ALTER TABLE Logs ADD CONSTRAINT fk_logs_usuario FOREIGN KEY (usuarioId) REFERENCES Usuarios(usuarioId);
ALTER TABLE Logs ADD CONSTRAINT fk_logs_obj1 FOREIGN KEY (objetoId1) REFERENCES Objetos(objetoId);
ALTER TABLE Logs ADD CONSTRAINT fk_logs_obj2 FOREIGN KEY (objetoId2) REFERENCES Objetos(objetoId);
ALTER TABLE ConfiguracionesSistema ADD CONSTRAINT fk_config_sis_cat FOREIGN KEY (categoriaId) REFERENCES CategoriasConfiguracion(categoriaConfiguracionId);
ALTER TABLE ConfiguracionesSistema ADD CONSTRAINT fk_config_sis_usr FOREIGN KEY (ultimoCambioPor) REFERENCES Usuarios(usuarioId);
ALTER TABLE RolPermiso ADD CONSTRAINT fk_rol_perm_rol FOREIGN KEY (rolId) REFERENCES Roles(rolId);
ALTER TABLE RolPermiso ADD CONSTRAINT fk_rol_perm_perm FOREIGN KEY (permisoId) REFERENCES Permiso(permisoId);
ALTER TABLE UsuarioRol ADD CONSTRAINT fk_usr_rol_usr FOREIGN KEY (usuarioId) REFERENCES Usuarios(usuarioId);
ALTER TABLE UsuarioRol ADD CONSTRAINT fk_usr_rol_rol FOREIGN KEY (rolId) REFERENCES Roles(rolId);
ALTER TABLE UsuarioRol ADD CONSTRAINT fk_usr_rol_asign FOREIGN KEY (asignadoPor) REFERENCES Usuarios(usuarioId);

-- Índices básicos
CREATE INDEX idx_productos_sku ON Productos(skuInterno);
CREATE INDEX idx_lotes_fecha_vencimiento ON LotesBulk(fechaVencimiento);
CREATE INDEX idx_ordenes_estado ON OrdenesCompra(estadoOrdenId);
CREATE INDEX idx_logs_fecha ON Logs(creadoEn);