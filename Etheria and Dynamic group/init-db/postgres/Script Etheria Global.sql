-- ============================================================================
-- ETHERIA GLOBAL - SCRIPT MAESTRO DE GENERACIÓN (Versión 0.8 Final)
-- Autor: Gerald Hernández Gamboa
-- Motor: PostgreSQL 15+
-- Fecha: 2-05-2026
-- ============================================================================
\c Etheria-db


CREATE TABLE Usuarios (
    usuarioId SERIAL PRIMARY KEY,
    nombreUsuario VARCHAR(50),
    apellido1 VARCHAR(50),
    apellido2 VARCHAR(50),
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
    nombreRol VARCHAR(50) UNIQUE NOT NULL,
    descripcion VARCHAR(255),
    nivelAcceso INTEGER,
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT REFERENCES Usuarios(usuarioId),
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE Permiso (
    permisoId SERIAL PRIMARY KEY,
    nombrePermiso VARCHAR(50) UNIQUE NOT NULL,
    descripcion VARCHAR(255),
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT REFERENCES Usuarios(usuarioId),
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE RolPermiso (
    rolId INT NOT NULL REFERENCES Roles(rolId),
    permisoId INT NOT NULL REFERENCES Permiso(permisoId),
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT REFERENCES Usuarios(usuarioId),
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE,
    CONSTRAINT pk_rol_permiso PRIMARY KEY (rolId, permisoId),
    CONSTRAINT uk_rol_permiso UNIQUE (rolId, permisoId)
);

CREATE TABLE UsuarioRol (
    usuarioId INT NOT NULL REFERENCES Usuarios(usuarioId),
    rolId INT NOT NULL REFERENCES Roles(rolId),
    asignadoPor INT REFERENCES Usuarios(usuarioId),
    asignadoEn TIMESTAMP,
    fechaExpiracion TIMESTAMP,
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT REFERENCES Usuarios(usuarioId),
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE,
    CONSTRAINT pk_usuario_rol PRIMARY KEY (usuarioId, rolId),
    CONSTRAINT uk_usuario_rol UNIQUE (usuarioId, rolId)
);

CREATE TABLE Objetos (
    objetoId SERIAL PRIMARY KEY,
    nombreObjeto VARCHAR(50) UNIQUE NOT NULL,
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT REFERENCES Usuarios(usuarioId),
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE Sources (
    sourceId SERIAL PRIMARY KEY,
    nombreSource VARCHAR(50) UNIQUE NOT NULL,
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT REFERENCES Usuarios(usuarioId),
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE TiposEvento (
    tipoEventoId SERIAL PRIMARY KEY,
    nombreEvento VARCHAR(50) UNIQUE NOT NULL,
    descripcion VARCHAR(255),
    requierePreguardado BOOLEAN DEFAULT TRUE,
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT REFERENCES Usuarios(usuarioId),
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE Severidades (
    severidadId SERIAL PRIMARY KEY,
    valorSeveridad INT NOT NULL,
    nombreSeveridad VARCHAR(50) UNIQUE NOT NULL,
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT REFERENCES Usuarios(usuarioId),
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE Logs (
    logId SERIAL PRIMARY KEY,
    tipoEventoId INT NOT NULL REFERENCES TiposEvento(tipoEventoId),
    severidadId INT NOT NULL REFERENCES Severidades(severidadId),
    descripcion VARCHAR(255) NOT NULL,
    sourceId INT NOT NULL REFERENCES Sources(sourceId),
    userAgent TEXT,
    computadora VARCHAR(100),
    usuarioId INT REFERENCES Usuarios(usuarioId),
    referenciaId1 BIGINT,
    referenciaId2 BIGINT,
    descripcionReferencia1 VARCHAR(200),
    descripcionReferencia2 VARCHAR(200),
    objetoId1 INT REFERENCES Objetos(objetoId),
    objetoId2 INT REFERENCES Objetos(objetoId),
    datosAnteriores JSONB,
    datosNuevos JSONB,
    checkSum VARCHAR(64),
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE CategoriasConfiguracion (
    categoriaConfiguracionId SERIAL PRIMARY KEY,
    nombreCategoriaConfiguracion VARCHAR(50) UNIQUE NOT NULL,
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT REFERENCES Usuarios(usuarioId),
    ultimaAuditoria TIMESTAMP,
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
    categoriaId INT NOT NULL REFERENCES CategoriasConfiguracion(categoriaConfiguracionId),
    descripcion VARCHAR(200) NOT NULL,
    esEditableUI BOOLEAN DEFAULT TRUE,
    requiereReinicioSistema BOOLEAN DEFAULT FALSE,
    ultimoCambioPor INT REFERENCES Usuarios(usuarioId),
    ultimoCambioEn TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

-- 2. GEOGRAFÍA Y UBICACIONES
CREATE TABLE Paises (
    paisId SERIAL PRIMARY KEY,
    nombrePais VARCHAR(50) UNIQUE NOT NULL,
    codigoIso CHAR(3) UNIQUE NOT NULL,
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT REFERENCES Usuarios(usuarioId),
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE Provincias (
    provinciaId SERIAL PRIMARY KEY,
    nombreProvincia VARCHAR(50) UNIQUE NOT NULL,
    paisId INT NOT NULL REFERENCES Paises(paisId),
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT REFERENCES Usuarios(usuarioId),
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE Ciudades (
    ciudadId SERIAL PRIMARY KEY,
    nombreCiudad VARCHAR(50) UNIQUE NOT NULL,
    provinciaId INT NOT NULL REFERENCES Provincias(provinciaId),
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT REFERENCES Usuarios(usuarioId),
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE TiposUbicacion (
    tipoUbicacionId SERIAL PRIMARY KEY,
    nombreTipoUbicacion VARCHAR(50) UNIQUE NOT NULL,
    descripcion VARCHAR(150),
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT REFERENCES Usuarios(usuarioId),
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE Ubicaciones (
    ubicacionId SERIAL PRIMARY KEY,
    nombreUbicacion VARCHAR(50) UNIQUE NOT NULL,
    tipoUbicacionId INT NOT NULL REFERENCES TiposUbicacion(tipoUbicacionId),
    ciudadId INT REFERENCES Ciudades(ciudadId),
    direccion VARCHAR(200),
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT REFERENCES Usuarios(usuarioId),
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

-- 3. MONEDAS Y TASAS
CREATE TABLE Currencies (
    currencyId SERIAL PRIMARY KEY,
    codigoIso CHAR(3) UNIQUE NOT NULL,
    currencySymbol CHAR,
    nombreCurrency VARCHAR(50) NOT NULL,
    activo BOOLEAN DEFAULT TRUE,
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT REFERENCES Usuarios(usuarioId),
    ultimaAuditoria TIMESTAMP
);

CREATE TABLE MonedasPorPais (
    monedaPaisId SERIAL PRIMARY KEY,
    currencyId INT NOT NULL REFERENCES Currencies(currencyId),
    paisId INT NOT NULL REFERENCES Paises(paisId),
    esOficial BOOLEAN DEFAULT TRUE,
    activo BOOLEAN DEFAULT TRUE,
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT REFERENCES Usuarios(usuarioId),
    ultimaAuditoria TIMESTAMP,
    CONSTRAINT uk_moneda_pais UNIQUE (currencyId, paisId)
);

CREATE TABLE TasasDeCambio (
    tasaDeCambioId SERIAL PRIMARY KEY,
    currencyId1 INT NOT NULL REFERENCES Currencies(currencyId),
    currencyId2 INT NOT NULL REFERENCES Currencies(currencyId),
    exchangeRate DECIMAL(12,6) NOT NULL,
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT REFERENCES Usuarios(usuarioId),
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE,
    CONSTRAINT uk_tasas_par_moneda UNIQUE (currencyId1, currencyId2)
);

CREATE TABLE HistorialTasasDeCambio (
    historialTasaDeCambio SERIAL PRIMARY KEY,
    fechaInicio TIMESTAMP,
    fechaFinal TIMESTAMP,
    currencyId1 INT REFERENCES Currencies(currencyId),
    currencyId2 INT REFERENCES Currencies(currencyId),
    exchangeRate DECIMAL(12,6),
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT REFERENCES Usuarios(usuarioId),
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE,
    tasaDeCambioId INT REFERENCES TasasDeCambio(tasaDeCambioId)
);

-- 4. LOGÍSTICA Y TRANSPORTES
CREATE TABLE TiposTransporte (
    tipoTransporteId SERIAL PRIMARY KEY,
    nombreTipoTransporte VARCHAR(50) UNIQUE NOT NULL,
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT REFERENCES Usuarios(usuarioId),
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE TiposServicio (
    tipoServicioId SERIAL PRIMARY KEY,
    nombreTipoServicio VARCHAR(50) UNIQUE NOT NULL,
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT REFERENCES Usuarios(usuarioId),
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE Courier (
    courierId SERIAL PRIMARY KEY,
    nombreCourier VARCHAR(50) UNIQUE NOT NULL,
    ciudadId INT NOT NULL REFERENCES Ciudades(ciudadId),
    tipoServicioId INT NOT NULL REFERENCES TiposServicio(tipoServicioId),
    tiempoEntregaPromedioDias INT,
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT REFERENCES Usuarios(usuarioId),
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

-- 5. PRODUCTOS Y CATÁLOGOS
CREATE TABLE TiposProducto (
    tipoProductoId SERIAL PRIMARY KEY,
    nombreTipoProducto VARCHAR(50) UNIQUE NOT NULL,
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT REFERENCES Usuarios(usuarioId),
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE UnidadesMedidaProducto (
    UnidadMedidaProductoId SERIAL PRIMARY KEY,
    nombreUnidadMedidaProducto VARCHAR(50) UNIQUE NOT NULL,
    descripcion VARCHAR(100),
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT REFERENCES Usuarios(usuarioId),
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE MarcasOriginales (
    marcaOriginalId SERIAL PRIMARY KEY,
    nombreMarca VARCHAR(100) UNIQUE NOT NULL,
    paisId INT NOT NULL REFERENCES Paises(paisId),
    descripcionMarca VARCHAR(250),
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT REFERENCES Usuarios(usuarioId),
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE Productos (
    productoId SERIAL PRIMARY KEY,
    skuInterno VARCHAR(20) UNIQUE NOT NULL,
    nombreTecnicoProducto VARCHAR(50) NOT NULL,
    nombreComunProducto VARCHAR(50),
    marcaOriginalId INT NOT NULL REFERENCES MarcasOriginales(marcaOriginalId),
    tipoProductoId INT NOT NULL REFERENCES TiposProducto(tipoProductoId),
    unidadMedidaProductoId INT REFERENCES UnidadesMedidaProducto(UnidadMedidaProductoId),
    vidaUtilMeses INT,
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT REFERENCES Usuarios(usuarioId),
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE TiposCaracteristica (
    tipoCaracteristicaId SERIAL PRIMARY KEY,
    nombreTipoCaracteristica VARCHAR(50) UNIQUE NOT NULL,
    descripcion VARCHAR(150),
    activo BOOLEAN DEFAULT TRUE,
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT REFERENCES Usuarios(usuarioId),
    ultimaAuditoria TIMESTAMP
);

CREATE TABLE CaracteristicasProducto (
    caracteristicaId SERIAL PRIMARY KEY,
    productoId INT NOT NULL REFERENCES Productos(productoId),
    tipoCaracteristicaId INT NOT NULL REFERENCES TiposCaracteristica(tipoCaracteristicaId),
    valorBoolean BOOLEAN,
    valorTexto VARCHAR(255),
    valorNumerico DECIMAL(10,2),
    paisId INT REFERENCES Paises(paisId),
    vigenteDesde DATE DEFAULT CURRENT_DATE,
    vigenteHasta DATE,
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT REFERENCES Usuarios(usuarioId),
    activo BOOLEAN DEFAULT TRUE,
    ultimaAuditoria TIMESTAMP,
    CONSTRAINT uk_caract_prod_tipo_pais UNIQUE (productoId, tipoCaracteristicaId, paisId)
);

CREATE TABLE PreciosBaseProducto (
    precioBaseId SERIAL PRIMARY KEY,
    productoId INT NOT NULL REFERENCES Productos(productoId),
    currencyIdOrigen INT NOT NULL REFERENCES Currencies(currencyId),
    precioLocal DECIMAL(14,2) NOT NULL,
    tasaDeCambioId INT NOT NULL REFERENCES TasasDeCambio(tasaDeCambioId),
    valorTasaDeCambio DECIMAL(12,6) NOT NULL,
    precioReferencia DECIMAL(14,2) NOT NULL,
    margenMinimoRecomendado DECIMAL(5,2),
    fechaVigenciaDesde DATE NOT NULL,
    fechaVigenciaHasta DATE,
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT REFERENCES Usuarios(usuarioId),
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE,
    CONSTRAINT uk_precio_prod_moneda_vigencia UNIQUE (productoId, currencyIdOrigen, fechaVigenciaDesde)
);

-- 6. IMPUESTOS
CREATE TABLE TiposImpuesto (
    tipoImpuestoId SERIAL PRIMARY KEY,
    nombreTipoImpuesto VARCHAR(50) UNIQUE NOT NULL,
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT REFERENCES Usuarios(usuarioId),
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE ImpuestosPorPais (
    impuestoId SERIAL PRIMARY KEY,
    productoId INT NOT NULL REFERENCES Productos(productoId),
    paisId INT NOT NULL REFERENCES Paises(paisId),
    tipoImpuestoId INT NOT NULL REFERENCES TiposImpuesto(tipoImpuestoId),
    descripcion VARCHAR(250),
    porcentaje DECIMAL(5,2),
    montoFijo DECIMAL(14,2),
    vigenciaDesde DATE,
    vigenciaHasta DATE,
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT REFERENCES Usuarios(usuarioId),
    activo BOOLEAN DEFAULT TRUE,
    CONSTRAINT uk_impuesto_prod_pais_tipo UNIQUE (productoId, paisId, tipoImpuestoId)
);

-- 7. COMPRAS Y PROVEEDORES
CREATE TABLE Proveedores (
    proveedorId SERIAL PRIMARY KEY,
    nombreProveedor VARCHAR(50) UNIQUE NOT NULL,
    paisId INT REFERENCES Paises(paisId),
    tiempoEntregaPromedioDias INT,
    calificacionConfianza DECIMAL(3,2),
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT REFERENCES Usuarios(usuarioId),
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE EstadosOrdenes (
    estadoOrdenId SERIAL PRIMARY KEY,
    nombreEstadoOrden VARCHAR(50) UNIQUE NOT NULL,
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT REFERENCES Usuarios(usuarioId),
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE ConfiguracionAprobacionOrdenes (
    configuracionAprobacionId SERIAL PRIMARY KEY,
    montoMinimoUsd DECIMAL(12,2) NOT NULL,
    montoMaximoUsd DECIMAL(12,2),
    rolRequeridoId INT NOT NULL REFERENCES Roles(rolId),
    nivelAprobacion INT NOT NULL,
    requiereDobleFirma BOOLEAN DEFAULT FALSE,
    tiempoMaximoAprobacionHoras INT DEFAULT 48,
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT REFERENCES Usuarios(usuarioId),
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE OrdenesCompra (
    ordenCompraId SERIAL PRIMARY KEY,
    proveedorId INT NOT NULL REFERENCES Proveedores(proveedorId),
    numeroPedido VARCHAR(20) UNIQUE NOT NULL,
    fechaSolicitud DATE NOT NULL,
    fechaRecepcion DATE,
    estadoOrdenId INT NOT NULL REFERENCES EstadosOrdenes(estadoOrdenId),
    tipoTransporteId INT REFERENCES TiposTransporte(tipoTransporteId),
    incoterm VARCHAR(10) DEFAULT 'FOB',
    ubicacionId INT REFERENCES Ubicaciones(ubicacionId),
    comentarios VARCHAR(200),
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT REFERENCES Usuarios(usuarioId),
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE TiposContactos (
    tipoContactoId SERIAL PRIMARY KEY,
    nombreTipoContacto VARCHAR(50) UNIQUE NOT NULL,
    descripcion VARCHAR(255),
    formatoValidacion VARCHAR(100),
    longitudMinima INT,
    longitudMaxima INT,
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT REFERENCES Usuarios(usuarioId),
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE InfoContactosProveedor (
    infoContactoProveedorId SERIAL PRIMARY KEY,
    tipoContactoId INT NOT NULL REFERENCES TiposContactos(tipoContactoId),
    proveedorId INT NOT NULL REFERENCES Proveedores(proveedorId),
    valor VARCHAR(100) NOT NULL,
    esPrincipal BOOLEAN DEFAULT FALSE,
    verificado BOOLEAN DEFAULT FALSE,
    fechaVerificacion TIMESTAMP,
    horarioAtencion VARCHAR(50),
    idiomaSoporte CHAR(2) DEFAULT 'en',
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT REFERENCES Usuarios(usuarioId),
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE EstadosItems (
    estadoItemId SERIAL PRIMARY KEY,
    nombreEstadoItem VARCHAR(50) UNIQUE NOT NULL,
    descripcion VARCHAR(255),
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT REFERENCES Usuarios(usuarioId),
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE ProductosPorOrden (
    productoPorOrdenId SERIAL PRIMARY KEY,
    ordenCompraId INT NOT NULL REFERENCES OrdenesCompra(ordenCompraId),
    productoId INT NOT NULL REFERENCES Productos(productoId),
    cantidadSolicitada DECIMAL(12,2) NOT NULL,
    currencyId INT NOT NULL REFERENCES Currencies(currencyId),
    precioUnitarioAcordado DECIMAL(14,2) NOT NULL,
    subtotal DECIMAL(14,2) NOT NULL,
    tasaDeCambioAplicada DECIMAL(12,6) NOT NULL,
    estadoItemId INT NOT NULL REFERENCES EstadosItems(estadoItemId),
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT REFERENCES Usuarios(usuarioId),
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE,
    CONSTRAINT uk_prod_orden UNIQUE (ordenCompraId, productoId)
);

CREATE TABLE InstruccionesCompra (
    instruccionCompraId SERIAL PRIMARY KEY,
    ordenVentaId INT, -- FK Lógica a Dynamic
    productoId INT NOT NULL REFERENCES Productos(productoId),
    cantidadSolicitada DECIMAL(12,2) NOT NULL,
    paisId INT NOT NULL REFERENCES Paises(paisId),
    tiendaId INT, -- FK Lógica a Dynamic
    fechaSolicitud TIMESTAMP NOT NULL,
    fechaLimiteEntrega DATE NOT NULL,
    ordenCompraId INT REFERENCES OrdenesCompra(ordenCompraId),
    margenObjetivoPorcentaje DECIMAL(5,2),
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT REFERENCES Usuarios(usuarioId),
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

-- 8. INVENTARIO Y LOTES
CREATE TABLE EstadosInventario (
    estadoInventarioId SERIAL PRIMARY KEY,
    nombreEstadoInventario VARCHAR(50) UNIQUE NOT NULL,
    descripcion VARCHAR(255),
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT REFERENCES Usuarios(usuarioId),
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE ConfiguracionesAceptacionBulks (
    configuracionAceptacionId SERIAL PRIMARY KEY,
    tipoProductoId INT REFERENCES TiposProducto(tipoProductoId),
    proveedorId INT REFERENCES Proveedores(proveedorId),
    mermaMaximaPorcentaje DECIMAL(5,2),
    vidaUtilMinimaRestantePorcentaje DECIMAL(5,2),
    desviacionTemperaturaMaxima DECIMAL(4,1),
    requiereMuestreoCalidad BOOLEAN DEFAULT TRUE,
    tiempoMaximoMuestreoHoras INT,
    accionSiFalla VARCHAR(100),
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT REFERENCES Usuarios(usuarioId),
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE LotesBulk (
    loteBulkId SERIAL PRIMARY KEY,
    productoId INT NOT NULL REFERENCES Productos(productoId),
    proveedorId INT NOT NULL REFERENCES Proveedores(proveedorId),
    ordenCompraId INT NOT NULL REFERENCES OrdenesCompra(ordenCompraId),
    numeroLoteProveedor VARCHAR(100) NOT NULL,
    ubicacionId INT REFERENCES Ubicaciones(ubicacionId),
    fechaRecepcionHub TIMESTAMP,
    fechaVencimiento DATE NOT NULL,
    cantidadTotal DECIMAL(12,2) NOT NULL,
    currencyId INT NOT NULL REFERENCES Currencies(currencyId),
    costoLocal DECIMAL(14,2) NOT NULL,
    tasaDeCambioId INT NOT NULL REFERENCES TasasDeCambio(tasaDeCambioId),
    tasaDeCambioAplicada DECIMAL(12,6) NOT NULL,
    costoTotal DECIMAL(14,2) NOT NULL,
    estadoInventarioId INT NOT NULL REFERENCES EstadosInventario(estadoInventarioId),
    tipoTransporteId INT REFERENCES TiposTransporte(tipoTransporteId),
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT REFERENCES Usuarios(usuarioId),
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE ConceptosCostos (
    conceptoCostoId SERIAL PRIMARY KEY,
    nombreConceptoCosto VARCHAR(50) UNIQUE NOT NULL,
    descripcion VARCHAR(255),
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT REFERENCES Usuarios(usuarioId),
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE CostosOperativos (
    costoId SERIAL PRIMARY KEY,
    conceptoCostoId INT NOT NULL REFERENCES ConceptosCostos(conceptoCostoId),
    loteBulkId INT NOT NULL REFERENCES LotesBulk(loteBulkId),
    currencyId INT NOT NULL REFERENCES Currencies(currencyId),
    montoLocal DECIMAL(14,2) NOT NULL,
    tasaDeCambioId INT REFERENCES TasasDeCambio(tasaDeCambioId),
    tasaDeCambioAplicada DECIMAL(12,6) NOT NULL,
    montoConvertido DECIMAL(14,2),
    fechaPago DATE,
    paisId INT REFERENCES Paises(paisId),
    tipoTransporteId INT REFERENCES TiposTransporte(tipoTransporteId),
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT REFERENCES Usuarios(usuarioId),
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

-- 9. TRAZABILIDAD
CREATE TABLE TrazabilidadOrdenes (
    trazabilidadId SERIAL PRIMARY KEY,
    ordenCompraId INT NOT NULL REFERENCES OrdenesCompra(ordenCompraId),
    estadoOrdenId INT NOT NULL REFERENCES EstadosOrdenes(estadoOrdenId),
    fechaCambioEtapa TIMESTAMP NOT NULL,
    ubicacionId INT NOT NULL REFERENCES Ubicaciones(ubicacionId),
    tipoTransporteEtapaId INT REFERENCES TiposTransporte(tipoTransporteId),
    numeroGuiaInternacional VARCHAR(100),
    fechaEstimadaLlegada DATE,
    fechaRealLlegada DATE,
    incidencias VARCHAR(200),
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT REFERENCES Usuarios(usuarioId),
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE,
    CONSTRAINT uk_traza_orden UNIQUE (ordenCompraId)
);

CREATE TABLE HistorialEtapasOrden (
    historialEtapaId SERIAL PRIMARY KEY,
    trazabilidadId INT NOT NULL REFERENCES TrazabilidadOrdenes(trazabilidadId),
    etapaAnterior INT NOT NULL REFERENCES EstadosOrdenes(estadoOrdenId),
    etapaNueva INT NOT NULL REFERENCES EstadosOrdenes(estadoOrdenId),
    fechaCambio TIMESTAMP,
    responsableCambioId INT REFERENCES Usuarios(usuarioId),
    comentarioCambio VARCHAR(200),
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- ÍNDICES ADICIONALES PARA RENDIMIENTO (OPCIONAL PERO RECOMENDADO)
-- ============================================================================
CREATE INDEX idx_productos_sku ON Productos(skuInterno);
CREATE INDEX idx_lotes_fecha_vencimiento ON LotesBulk(fechaVencimiento);
CREATE INDEX idx_ordenes_estado ON OrdenesCompra(estadoOrdenId);
CREATE INDEX idx_logs_fecha ON Logs(creadoEn);
CREATE INDEX idx_tasas_moneda ON TasasDeCambio(currencyId1, currencyId2);

