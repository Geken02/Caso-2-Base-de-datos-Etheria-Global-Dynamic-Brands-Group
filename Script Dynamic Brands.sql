SET FOREIGN_KEY_CHECKS=0;

-- 1. GEOGRAFÍA Y UBICACIONES (RÉPLICAS)
CREATE TABLE Ciudades (
    ciudadId INT NOT NULL,
    nombreCiudad VARCHAR(50),
    provinciaId INT,
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT,
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE,
    PRIMARY KEY (ciudadId)
);

CREATE TABLE Provincias (
    provinciaId INT NOT NULL,
    nombreProvincia VARCHAR(50),
    paisId INT,
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT,
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE,
    PRIMARY KEY (provinciaId)
);

CREATE TABLE Paises (
    paisId INT NOT NULL,
    nombrePais VARCHAR(50) NOT NULL,
    codigoIso CHAR(3) UNIQUE NOT NULL,
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT,
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE,
    PRIMARY KEY (paisId)
);

CREATE TABLE Ubicaciones (
    ubicacionId INT NOT NULL,
    nombreUbicacion VARCHAR(100) NOT NULL,
    tipoUbicacionRefId INT NOT NULL,
    ciudadRefId INT,
    direccion VARCHAR(200),
    coordenadasLatitud DECIMAL(10,8),
    coordenadasLongitud DECIMAL(11,8),
    operadorLogistico VARCHAR(100),
    activo BOOLEAN DEFAULT TRUE,
    fechaSincronizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (ubicacionId)
);

CREATE TABLE TiposUbicacion (
    tipoUbicacionId INT NOT NULL,
    nombreTipoUbicacion VARCHAR(50) NOT NULL,
    descripcion VARCHAR(150),
    esInterno BOOLEAN DEFAULT TRUE,
    requiereInspeccionEntrada BOOLEAN DEFAULT FALSE,
    requiereInspeccionSalida BOOLEAN DEFAULT FALSE,
    fechaSincronizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE,
    PRIMARY KEY (tipoUbicacionId)
);

-- 2. LOGÍSTICA Y SERVICIOS (RÉPLICAS)
CREATE TABLE Courier (
    courierId INT NOT NULL,
    nombreCourier VARCHAR(50),
    ciudadId INT,
    tipoServicioId INT,
    tiempoEntregaPromedioDias INT,
    fechaSincronizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT,
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE,
    PRIMARY KEY (courierId)
);

CREATE TABLE TiposServicios (
    tipoServicioId INT NOT NULL,
    nombreTipoServicio VARCHAR(50),
    fechaSincronizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT,
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE,
    PRIMARY KEY (tipoServicioId)
);

-- 3. MONEDAS Y TASAS (RÉPLICAS)
CREATE TABLE Currencies (
    currencyId INT NOT NULL,
    codigoIso CHAR(3) UNIQUE NOT NULL,
    currencySymbol CHAR,
    nombreCurrency VARCHAR(50),
    activo BOOLEAN DEFAULT TRUE,
    fechaSincronizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT,
    ultimaAuditoria TIMESTAMP,
    PRIMARY KEY (currencyId)
);

CREATE TABLE TasasDeCambio (
    tasaDeCambioId INT NOT NULL,
    currencyId1 INT,
    currencyId2 INT,
    exchangeRate DECIMAL(12,6),
    fechaSincronizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT,
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE,
    PRIMARY KEY (tasaDeCambioId)
);

CREATE TABLE HistorialTasasDeCambio (
    historialTasaDeCambio INT NOT NULL,
    fechaInicio TIMESTAMP,
    fechaFinal TIMESTAMP,
    currencyId1 INT,
    currencyId2 INT,
    exchangeRate DECIMAL(12,6),
    fechaSincronizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT,
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE,
    tasaDeCambioId INT,
    PRIMARY KEY (historialTasaDeCambio)
);

-- 4. IMPUESTOS LOCALES (NATIVOS)
CREATE TABLE ImpuestosVentaPorPais (
    impuestoVentaId INT AUTO_INCREMENT PRIMARY KEY,
    productoMarcaId INT,
    tipoProductoId INT,
    paisId INT NOT NULL,
    tipoImpuestoVentaId INT NOT NULL,
    porcentaje DECIMAL(5,2),
    montoFijoLocal DECIMAL(10,2),
    baseCalculoId INT,
    esRecuperable BOOLEAN DEFAULT FALSE,
    fechaVigenciaDesde DATE NOT NULL,
    fechaVigenciaHasta DATE,
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT,
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE BasesCalculoImpuestos (
    BaseCalculoId INT AUTO_INCREMENT PRIMARY KEY,
    nombreBaseCalculoImpuesto VARCHAR(50) NOT NULL,
    descripcion VARCHAR(150),
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT,
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE TiposImpuestosVenta (
    tipoImpuestoVentaId INT AUTO_INCREMENT PRIMARY KEY,
    nombreTipoImpuestoVenta VARCHAR(50) NOT NULL,
    descripcion VARCHAR(150),
    aplicaPorUnidad BOOLEAN DEFAULT FALSE,
    paisAplicacionId INT,
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT,
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

-- 5. TIENDAS, MARKETING Y CONFIGURACIÓN (NATIVOS)
CREATE TABLE TiendasVirtualesGeneradas (
    tiendaId INT AUTO_INCREMENT PRIMARY KEY,
    nombreTienda VARCHAR(100) NOT NULL,
    paisObjetivoId INT,
    monedaLocalId INT,
    estadoTiendaId INT,
    enfoqueMarketingId INT,
    fechaApertura DATE,
    fechaCierre DATE,
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT,
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE EstadosTienda (
    estadoTiendaId INT AUTO_INCREMENT PRIMARY KEY,
    nombreEstadoTienda VARCHAR(50) NOT NULL,
    codigo VARCHAR(20) UNIQUE NOT NULL,
    permiteVentas BOOLEAN DEFAULT FALSE,
    descripcion VARCHAR(150),
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT,
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE EnfoquesMarketing (
    enfoqueMarketingId INT AUTO_INCREMENT PRIMARY KEY,
    nombreEnfoqueMarketing VARCHAR(50) NOT NULL,
    descripcion VARCHAR(255),
    publicoObjetivoId INT,
    grupoConfiguracionId INT,
    generadoPorIA BOOLEAN DEFAULT TRUE,
    activo BOOLEAN DEFAULT TRUE,
    fechaCreacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    creadoPor INT,
    ultimaAuditoria TIMESTAMP
);

CREATE TABLE GeneracionSitiosWeb (
    generacionSitioWebId INT AUTO_INCREMENT PRIMARY KEY,
    tiendaId INT NOT NULL,
    versionSitio INT DEFAULT 1,
    estadoGeneracionId INT,
    fechaSolicitud TIMESTAMP NOT NULL,
    fechaCompletado TIMESTAMP,
    tiempoProcesamientoSegundos INT,
    errorMensaje VARCHAR(200),
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT,
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE EstadosGeneracion (
    estadoGeneracionId INT AUTO_INCREMENT PRIMARY KEY,
    nombreEstadoGeneracion VARCHAR(50) NOT NULL,
    descripcion VARCHAR(150),
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT,
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE TiposParametro (
    tipoParametroId INT AUTO_INCREMENT PRIMARY KEY,
    nombreTipoParametro VARCHAR(50) NOT NULL,
    tipoDatoId INT,
    valorPorDefecto VARCHAR(255),
    esActivo BOOLEAN DEFAULT TRUE,
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT,
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE GruposConfiguracion (
    grupoConfigId INT AUTO_INCREMENT PRIMARY KEY,
    nombreGrupoConfiguracion VARCHAR(50) NOT NULL,
    descripcion VARCHAR(255),
    esActivo BOOLEAN DEFAULT TRUE,
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT,
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE ValoresConfiguracion (
    valorConfigId INT AUTO_INCREMENT PRIMARY KEY,
    grupoConfigId INT NOT NULL,
    tipoParametroId INT NOT NULL,
    valorTexto VARCHAR(500),
    valorNumerico DECIMAL(10,2),
    valorBoolean BOOLEAN,
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT,
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE TiposDato (
    tipoDatoId INT AUTO_INCREMENT PRIMARY KEY,
    nombreTipoDato VARCHAR(50) NOT NULL,
    descripcion VARCHAR(150),
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT,
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

-- 6. PRODUCTOS Y CARACTERÍSTICAS (HÍBRIDO)
CREATE TABLE TiposCaracteristica (
    tipoCaracteristicaId INT AUTO_INCREMENT PRIMARY KEY,
    nombreTipoCaracteristica VARCHAR(50) NOT NULL,
    descripcion VARCHAR(150),
    activo BOOLEAN DEFAULT TRUE,
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT,
    ultimaAuditoria TIMESTAMP
);

CREATE TABLE CaracteristicasProducto (
    caracteristicaId INT AUTO_INCREMENT PRIMARY KEY,
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
    activo BOOLEAN DEFAULT TRUE,
    ultimaAuditoria TIMESTAMP
);

CREATE TABLE Productos (
    productoId INT NOT NULL,
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
    activo BOOLEAN DEFAULT TRUE,
    PRIMARY KEY (productoId)
);

CREATE TABLE TiposProducto (
    tipoProductoId INT NOT NULL,
    nombreTipoProducto VARCHAR(50) NOT NULL,
    fechaSincronizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT,
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE,
    PRIMARY KEY (tipoProductoId)
);

CREATE TABLE UnidadesMedidaProducto (
    UnidadMedidaProductoId INT NOT NULL,
    nombreUnidadMedidaProducto VARCHAR(50) NOT NULL,
    descripcion VARCHAR(100),
    fechaSincronizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT,
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE,
    PRIMARY KEY (UnidadMedidaProductoId)
);

CREATE TABLE MarcasOriginales (
    marcaOriginalId INT NOT NULL,
    nombreMarcaOriginal VARCHAR(100) NOT NULL,
    paisOrigenId INT,
    fechaSincronizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT,
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE,
    PRIMARY KEY (marcaOriginalId)
);

CREATE TABLE MarcasBlancas (
    marcaBlancaId INT AUTO_INCREMENT PRIMARY KEY,
    nombreMarcaBlanca VARCHAR(100) NOT NULL,
    tiendaId INT,
    paisId INT,
    archivoId INT,
    publicoObjetivoId INT,
    esMarcaPrincipal BOOLEAN DEFAULT FALSE,
    fechaRegistroMarca DATE,
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT,
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE PublicosObjetivo (
    publicoObjetivoId INT AUTO_INCREMENT PRIMARY KEY,
    nombrePublicoObjetivo VARCHAR(50) NOT NULL,
    descripcion VARCHAR(150),
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT,
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE ProductosMarcasBlancas (
    productoMarcaId INT AUTO_INCREMENT PRIMARY KEY,
    productoId INT NOT NULL,
    tiendaId INT,
    skuComercial VARCHAR(50) UNIQUE NOT NULL,
    nombreComercial VARCHAR(100) NOT NULL,
    marcaBlancaId INT NOT NULL,
    stockDisponible DECIMAL(12,2) DEFAULT 0,
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT,
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

-- 7. PRECIOS, DESCUENTOS Y REGULACIONES
CREATE TABLE PreciosVenta (
    precioVentaId INT AUTO_INCREMENT PRIMARY KEY,
    productoMarcaId INT NOT NULL,
    currencyId INT NOT NULL,
    precioVentaLocal DECIMAL(14,2) NOT NULL,
    tasaDeCambioId INT,
    tasaDeCambioAplicada DECIMAL(12,6) NOT NULL,
    tipoPrecioId INT NOT NULL,
    margenPorcentaje DECIMAL(5,2),
    costoBaseUsd DECIMAL(14,4),
    fechaVigenciaDesde DATE NOT NULL,
    fechaVigenciaHasta DATE,
    aprobadoPor INT,
    fechaAprobacion TIMESTAMP,
    esPrecioActivo BOOLEAN DEFAULT TRUE,
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT,
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE TiposPrecios (
    tipoPrecioId INT AUTO_INCREMENT PRIMARY KEY,
    nombreTipoPrecio VARCHAR(50) NOT NULL,
    descripcion VARCHAR(150),
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT,
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE ReglasAprobacionPrecios (
    reglaAprobacionId INT AUTO_INCREMENT PRIMARY KEY,
    tiendaId INT,
    tipoProductoId INT,
    rolRequeridoId INT NOT NULL,
    cambioMinimoPorcentaje DECIMAL(5,2),
    cambioMaximoPorcentaje DECIMAL(5,2),
    montoMinimoPrecio DECIMAL(12,2),
    montoMaximoPrecio DECIMAL(12,2),
    requiereDobleAprobacion BOOLEAN DEFAULT FALSE,
    tiempoMaximoAprobacionHoras INT DEFAULT 48,
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT,
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE Descuentos (
    descuentoId INT AUTO_INCREMENT PRIMARY KEY,
    codigoCupon VARCHAR(50) UNIQUE,
    descripcion VARCHAR(150),
    tipoDescuentoId INT NOT NULL,
    valorDescuento DECIMAL(10,2) NOT NULL,
    montoMinimoCompra DECIMAL(12,2),
    fechaVigenciaDesde DATE,
    fechaVigenciaHasta DATE,
    cantidadUsosMaximos INT,
    cantidadUsosActuales INT DEFAULT 0,
    esAcumulable BOOLEAN DEFAULT FALSE,
    prioridad INT DEFAULT 0,
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT,
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE DescuentosPorTienda (
    descuentoTiendaId INT AUTO_INCREMENT PRIMARY KEY,
    descuentoId INT NOT NULL,
    tiendaId INT NOT NULL,
    esExclusivo BOOLEAN DEFAULT FALSE,
    fechaInicio TIMESTAMP,
    fechaFin TIMESTAMP,
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT,
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE DescuentosPorProducto (
    descuentoProductoId INT AUTO_INCREMENT PRIMARY KEY,
    descuentoId INT NOT NULL,
    productoMarcaId INT NOT NULL,
    aplicaAVariantes BOOLEAN DEFAULT TRUE,
    fechaInicio TIMESTAMP,
    fechaFin TIMESTAMP,
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT,
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE TiposDescuento (
    tipoDescuentoId INT AUTO_INCREMENT PRIMARY KEY,
    nombreTipoDescuento VARCHAR(50) NOT NULL,
    descripcion VARCHAR(150),
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT,
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE TiposRegulacion (
    tipoRegulacionId INT AUTO_INCREMENT PRIMARY KEY,
    nombreTipoRegulacion VARCHAR(50) NOT NULL,
    tipoDatoId INT NOT NULL,
    descripcion VARCHAR(255),
    esActivo BOOLEAN DEFAULT TRUE,
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT,
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE RegulacionesPorPais (
    regulacionId INT AUTO_INCREMENT PRIMARY KEY,
    productoMarcaId INT,
    tipoProductoId INT,
    paisId INT NOT NULL,
    tipoRegulacionId INT NOT NULL,
    valorBoolean BOOLEAN,
    valorNumerico DECIMAL(10,2),
    valorTexto VARCHAR(255),
    autoridadCompetente VARCHAR(100),
    fechaUltimaVerificacion DATE,
    vigenciaDesde DATE NOT NULL,
    vigenciaHasta DATE,
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT,
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

-- 8. RESEÑAS Y TRANSFORMACIONES
CREATE TABLE ReseñasProductos (
    reseñaId INT AUTO_INCREMENT PRIMARY KEY,
    productoMarcaId INT NOT NULL,
    clienteId INT NOT NULL,
    ordenVentaId INT,
    calificacion INT NOT NULL,
    titulo VARCHAR(100),
    comentario VARCHAR(300),
    esCompraVerificada BOOLEAN DEFAULT FALSE,
    esAprobada BOOLEAN DEFAULT FALSE,
    fechaPublicacion TIMESTAMP,
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT,
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE ResumenReseñasProductos (
    resumenReseñaProductoId INT AUTO_INCREMENT PRIMARY KEY,
    productoMarcaId INT NOT NULL,
    calificacionPromedio DECIMAL(3,2) NOT NULL,
    totalReseñas INT NOT NULL,
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT,
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE DistribucionReseñasProductos (
    distribucionId INT AUTO_INCREMENT PRIMARY KEY,
    resumenReseñaProductoId INT NOT NULL,
    valorCalificacion INT NOT NULL,
    cantidad INT NOT NULL DEFAULT 0,
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT,
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE TransformacionesProductos (
    transformacionId INT AUTO_INCREMENT PRIMARY KEY,
    loteBulkId INT NOT NULL,
    productoMarcaId INT NOT NULL,
    productoBaseId INT NOT NULL,
    puntoRetiroId INT NOT NULL,
    cantidadTransformada DECIMAL(12,2) NOT NULL,
    cantidadMerma DECIMAL(12,2) DEFAULT 0,
    fechaTransformacion TIMESTAMP NOT NULL,
    responsableTransformacionId INT,
    ubicacionTransformacionId INT,
    estadoTransformacionId INT,
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT,
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE EstadosTransformacion (
    estadoTransformacionId INT AUTO_INCREMENT PRIMARY KEY,
    nombreEstadoTransformacion VARCHAR(50) NOT NULL,
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT,
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE SolicitudesRetiro (
    solicitudRetiroId INT AUTO_INCREMENT PRIMARY KEY,
    productoBaseReferencia INT NOT NULL,
    loteBulkReferencia VARCHAR(100) NOT NULL,
    cantidadSolicitada DECIMAL(12,2) NOT NULL,
    productoMarcaDestinoId INT,
    fechaSolicitud TIMESTAMP NOT NULL,
    fechaRetiroProgramado DATE,
    confirmacionEtheriaId INT,
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT,
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

-- 9. CLIENTES Y VENTAS
CREATE TABLE Clientes (
    clienteId INT AUTO_INCREMENT PRIMARY KEY,
    tiendaId INT,
    email VARCHAR(100) NOT NULL,
    nombreCliente VARCHAR(50),
    apellidoCliente1 VARCHAR(40),
    apellidoCliente2 VARCHAR(40),
    paisResidenciaId INT,
    telefono VARCHAR(20),
    fechaRegistro TIMESTAMP,
    ultimoAcceso TIMESTAMP,
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT,
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE TiposContactoCliente (
    tipoContactoClienteId INT AUTO_INCREMENT PRIMARY KEY,
    nombreTipoContactoCliente VARCHAR(50) NOT NULL,
    codigo VARCHAR(20) UNIQUE NOT NULL,
    formatoValidacion VARCHAR(100),
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT,
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE ContactosClientes (
    contactoClienteId INT AUTO_INCREMENT PRIMARY KEY,
    clienteId INT,
    tipoContactoClienteId INT,
    valor VARCHAR(150) NOT NULL,
    esPrincipal BOOLEAN DEFAULT FALSE,
    verificado BOOLEAN DEFAULT FALSE,
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT,
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE InteraccionesClientes (
    interaccionId INT AUTO_INCREMENT PRIMARY KEY,
    clienteId INT NOT NULL,
    tiendaId INT NOT NULL,
    tipoInteraccionId INT NOT NULL,
    referenciaId BIGINT,
    descripcion VARCHAR(200),
    fechaInteraccion TIMESTAMP,
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT,
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE TiposInteraccionesClientes (
    tipoInteraccionId INT AUTO_INCREMENT PRIMARY KEY,
    nombreTipoInteraccionCliente VARCHAR(50) NOT NULL,
    descripcion VARCHAR(150),
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT,
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE OrdenesVenta (
    ordenVentaId INT AUTO_INCREMENT PRIMARY KEY,
    tiendaId INT NOT NULL,
    clienteId INT NOT NULL,
    fechaOrden TIMESTAMP,
    numeroPedido VARCHAR(50) UNIQUE NOT NULL,
    estadoOrdenVentaId INT NOT NULL,
    montoSubtotal DECIMAL(14,2) NOT NULL,
    montoEnvio DECIMAL(14,2) DEFAULT 0,
    montoTotalLocal DECIMAL(14,2) NOT NULL,
    currencyId INT NOT NULL,
    tasaDeCambioId INT,
    tasaDeCambioAplicada DECIMAL(12,6) NOT NULL,
    montoConvertidoBase DECIMAL(14,2) NOT NULL,
    paisId INT,
    metodoPagoId INT,
    montoPagado DECIMAL(14,2),
    monedaPagoId INT,
    fechaPago TIMESTAMP,
    estadoPagoId INT,
    intentoPagoCount INT DEFAULT 0,
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT,
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE EstadosOrdenesVenta (
    estadoOrdenVentaId INT AUTO_INCREMENT PRIMARY KEY,
    nombreEstadoOrdenVenta VARCHAR(50) NOT NULL,
    descripcion VARCHAR(150),
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT,
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE DetallesOrdenesVenta (
    detalleId INT AUTO_INCREMENT PRIMARY KEY,
    ordenVentaId INT,
    productoMarcaId INT,
    cantidad INT NOT NULL,
    currencyId INT NOT NULL,
    precioUnitarioLocal DECIMAL(10,2) NOT NULL,
    subtotalLocal DECIMAL(12,2) NOT NULL,
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT,
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE MetodosPago (
    metodoPagoId INT AUTO_INCREMENT PRIMARY KEY,
    nombreMetodoPago VARCHAR(50) NOT NULL,
    requiereValidacionAdicional BOOLEAN DEFAULT FALSE,
    costoTransaccionPorcentaje DECIMAL(5,2) DEFAULT 0,
    costoTransaccionFijo DECIMAL(10,2) DEFAULT 0,
    tiempoConfirmacionMinutos INT,
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT,
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE EstadosPago (
    estadoPagoId INT AUTO_INCREMENT PRIMARY KEY,
    nombreEstadoPago VARCHAR(50) NOT NULL,
    descripcion VARCHAR(150),
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT,
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE ImpuestosOrdenesVenta (
    ordenImpuestoId INT AUTO_INCREMENT PRIMARY KEY,
    ordenVentaId INT NOT NULL,
    impuestoVentaId INT NOT NULL,
    montoImpuestoLocal DECIMAL(10,2) NOT NULL,
    baseCalculoId INT NOT NULL,
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT,
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE DescuentosOrdenVenta (
    ordenDescuentoId INT AUTO_INCREMENT PRIMARY KEY,
    ordenVentaId INT NOT NULL,
    descuentoId INT NOT NULL,
    montoDescuentoLocal DECIMAL(10,2) NOT NULL,
    codigoCuponUsado VARCHAR(50),
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT,
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE Envios (
    envioId INT AUTO_INCREMENT PRIMARY KEY,
    ordenVentaId INT,
    courierId INT,
    trackingNumber VARCHAR(100) UNIQUE,
    fechaDespacho TIMESTAMP,
    fechaEntregaEstimada DATE,
    fechaEntregaReal TIMESTAMP,
    costoCourierLocal DECIMAL(10,2),
    currencyId INT NOT NULL,
    estadoEnvioId INT,
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT,
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE EstadosEnvio (
    estadoEnvioId INT AUTO_INCREMENT PRIMARY KEY,
    nombreEstadoEnvio VARCHAR(50) NOT NULL,
    descripcion VARCHAR(150),
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT,
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

-- 10. ARCHIVOS, LOGS Y SEGURIDAD
CREATE TABLE Archivos (
    archivoId INT AUTO_INCREMENT PRIMARY KEY,
    checksum VARCHAR(64),
    tamaño INT,
    duracion FLOAT,
    deleted BOOLEAN DEFAULT FALSE,
    rutaAlmacenamiento VARCHAR(500),
    tipoArchivo INT,
    nombreOriginalArchivo VARCHAR(255),
    hashContenido VARCHAR(64),
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT,
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE TiposArchivos (
    tipoArchivoId INT AUTO_INCREMENT PRIMARY KEY,
    nombreTipoArchivo VARCHAR(50) NOT NULL,
    extension VARCHAR(100) NOT NULL,
    tamanioMaximoMB DECIMAL(6,2) NOT NULL,
    dimensionesMinimasPx VARCHAR(20),
    dimensionesMaximasPx VARCHAR(20),
    requiereCompresion BOOLEAN DEFAULT FALSE,
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT,
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE TiposEvento (
    tipoEventoId INT AUTO_INCREMENT PRIMARY KEY,
    codigoEvento VARCHAR(30) UNIQUE NOT NULL,
    descripcion VARCHAR(100) NOT NULL,
    requierePreguardado BOOLEAN DEFAULT TRUE,
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT,
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE Severidades (
    severidadId INT AUTO_INCREMENT PRIMARY KEY,
    valorSeveridad INT NOT NULL,
    nombreSeveridad VARCHAR(20) NOT NULL,
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT,
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE Objetos (
    objetoId INT AUTO_INCREMENT PRIMARY KEY,
    nombreObjeto VARCHAR(50) UNIQUE NOT NULL,
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT,
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE Sources (
    sourceId INT AUTO_INCREMENT PRIMARY KEY,
    nombreSource VARCHAR(50),
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT,
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE Logs (
    logId INT AUTO_INCREMENT PRIMARY KEY,
    tipoEventoId INT NOT NULL,
    severidadId INT NOT NULL DEFAULT 2,
    descripcion VARCHAR(255) NOT NULL,
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
    checkSum VARCHAR(64),
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE ConfiguracionesSistema (
    configuracionSistemaId INT AUTO_INCREMENT PRIMARY KEY,
    clave VARCHAR(50) UNIQUE NOT NULL,
    valorText VARCHAR(500),
    valorInt INT,
    valorDecimal DECIMAL(18,6),
    valorBoolean BOOLEAN,
    descripcion VARCHAR(200),
    esEditableUI BOOLEAN DEFAULT TRUE,
    ultimoCambioPor INT,
    ultimoCambioEn TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE ConfiguracionPorTienda (
    configuracionTiendaId INT AUTO_INCREMENT PRIMARY KEY,
    tiendaId INT,
    clave VARCHAR(50) NOT NULL,
    valorText VARCHAR(500),
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT,
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE Usuarios (
    usuarioId INT AUTO_INCREMENT PRIMARY KEY,
    nombreUsuario VARCHAR(50),
    apellido1 VARCHAR(40),
    apellido2 VARCHAR(40),
    email VARCHAR(255),
    contraseña VARBINARY(255),
    fechaNacimiento DATE,
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT,
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE Roles (
    rolId INT AUTO_INCREMENT PRIMARY KEY,
    nombreRol VARCHAR(50),
    descripcion VARCHAR(255),
    nivelAcceso INT,
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT,
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE Permiso (
    permisoId INT AUTO_INCREMENT PRIMARY KEY,
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
ALTER TABLE Ciudades ADD CONSTRAINT fk_ciu_prov FOREIGN KEY (provinciaId) REFERENCES Provincias(provinciaId);
ALTER TABLE Provincias ADD CONSTRAINT fk_prov_pais FOREIGN KEY (paisId) REFERENCES Paises(paisId);
ALTER TABLE Ubicaciones ADD CONSTRAINT fk_ubi_tip FOREIGN KEY (tipoUbicacionRefId) REFERENCES TiposUbicacion(tipoUbicacionId);
ALTER TABLE Ubicaciones ADD CONSTRAINT fk_ubi_ciu FOREIGN KEY (ciudadRefId) REFERENCES Ciudades(ciudadId);

-- Logística
ALTER TABLE Courier ADD CONSTRAINT fk_cou_ciu FOREIGN KEY (ciudadId) REFERENCES Ciudades(ciudadId);
ALTER TABLE Courier ADD CONSTRAINT fk_cou_tip FOREIGN KEY (tipoServicioId) REFERENCES TiposServicios(tipoServicioId);

-- Impuestos
ALTER TABLE ImpuestosVentaPorPais ADD CONSTRAINT fk_imp_pm FOREIGN KEY (productoMarcaId) REFERENCES ProductosMarcasBlancas(productoMarcaId);
ALTER TABLE ImpuestosVentaPorPais ADD CONSTRAINT fk_imp_tp FOREIGN KEY (tipoProductoId) REFERENCES TiposProducto(tipoProductoId);
ALTER TABLE ImpuestosVentaPorPais ADD CONSTRAINT fk_imp_pa FOREIGN KEY (paisId) REFERENCES Paises(paisId);
ALTER TABLE ImpuestosVentaPorPais ADD CONSTRAINT fk_imp_ti FOREIGN KEY (tipoImpuestoVentaId) REFERENCES TiposImpuestosVenta(tipoImpuestoVentaId);
ALTER TABLE ImpuestosVentaPorPais ADD CONSTRAINT fk_imp_bc FOREIGN KEY (baseCalculoId) REFERENCES BasesCalculoImpuestos(BaseCalculoId);
ALTER TABLE TiposImpuestosVenta ADD CONSTRAINT fk_tip_imp_pa FOREIGN KEY (paisAplicacionId) REFERENCES Paises(paisId);

-- Tiendas y Marketing
ALTER TABLE TiendasVirtualesGeneradas ADD CONSTRAINT fk_tie_pa FOREIGN KEY (paisObjetivoId) REFERENCES Paises(paisId);
ALTER TABLE TiendasVirtualesGeneradas ADD CONSTRAINT fk_tie_cu FOREIGN KEY (monedaLocalId) REFERENCES Currencies(currencyId);
ALTER TABLE TiendasVirtualesGeneradas ADD CONSTRAINT fk_tie_et FOREIGN KEY (estadoTiendaId) REFERENCES EstadosTienda(estadoTiendaId);
ALTER TABLE TiendasVirtualesGeneradas ADD CONSTRAINT fk_tie_en FOREIGN KEY (enfoqueMarketingId) REFERENCES EnfoquesMarketing(enfoqueMarketingId);

ALTER TABLE EnfoquesMarketing ADD CONSTRAINT fk_enf_pub FOREIGN KEY (publicoObjetivoId) REFERENCES PublicosObjetivo(publicoObjetivoId);
ALTER TABLE EnfoquesMarketing ADD CONSTRAINT fk_enf_grp FOREIGN KEY (grupoConfiguracionId) REFERENCES GruposConfiguracion(grupoConfigId);
ALTER TABLE EnfoquesMarketing ADD CONSTRAINT fk_enf_usr FOREIGN KEY (creadoPor) REFERENCES Usuarios(usuarioId);

ALTER TABLE GeneracionSitiosWeb ADD CONSTRAINT fk_gen_tie FOREIGN KEY (tiendaId) REFERENCES TiendasVirtualesGeneradas(tiendaId);
ALTER TABLE GeneracionSitiosWeb ADD CONSTRAINT fk_gen_est FOREIGN KEY (estadoGeneracionId) REFERENCES EstadosGeneracion(estadoGeneracionId);

-- Configuración
ALTER TABLE TiposParametro ADD CONSTRAINT fk_par_dat FOREIGN KEY (tipoDatoId) REFERENCES TiposDato(tipoDatoId);
ALTER TABLE ValoresConfiguracion ADD CONSTRAINT fk_val_grp FOREIGN KEY (grupoConfigId) REFERENCES GruposConfiguracion(grupoConfigId);
ALTER TABLE ValoresConfiguracion ADD CONSTRAINT fk_val_par FOREIGN KEY (tipoParametroId) REFERENCES TiposParametro(tipoParametroId);

-- Productos
ALTER TABLE CaracteristicasProducto ADD CONSTRAINT fk_car_pr FOREIGN KEY (productoId) REFERENCES Productos(productoId);
ALTER TABLE CaracteristicasProducto ADD CONSTRAINT fk_car_tc FOREIGN KEY (tipoCaracteristicaId) REFERENCES TiposCaracteristica(tipoCaracteristicaId);
ALTER TABLE CaracteristicasProducto ADD CONSTRAINT fk_car_pa FOREIGN KEY (paisId) REFERENCES Paises(paisId);

ALTER TABLE Productos ADD CONSTRAINT fk_pr_mo FOREIGN KEY (marcaOriginalId) REFERENCES MarcasOriginales(marcaOriginalId);
ALTER TABLE Productos ADD CONSTRAINT fk_pr_tp FOREIGN KEY (tipoProductoId) REFERENCES TiposProducto(tipoProductoId);
ALTER TABLE Productos ADD CONSTRAINT fk_pr_un FOREIGN KEY (unidadMedidaProductoId) REFERENCES UnidadesMedidaProducto(UnidadMedidaProductoId);

ALTER TABLE MarcasOriginales ADD CONSTRAINT fk_mo_pa FOREIGN KEY (paisOrigenId) REFERENCES Paises(paisId);

ALTER TABLE MarcasBlancas ADD CONSTRAINT fk_mb_tie FOREIGN KEY (tiendaId) REFERENCES TiendasVirtualesGeneradas(tiendaId);
ALTER TABLE MarcasBlancas ADD CONSTRAINT fk_mb_pa FOREIGN KEY (paisId) REFERENCES Paises(paisId);
ALTER TABLE MarcasBlancas ADD CONSTRAINT fk_mb_arch FOREIGN KEY (archivoId) REFERENCES Archivos(archivoId);
ALTER TABLE MarcasBlancas ADD CONSTRAINT fk_mb_pub FOREIGN KEY (publicoObjetivoId) REFERENCES PublicosObjetivo(publicoObjetivoId);

ALTER TABLE ProductosMarcasBlancas ADD CONSTRAINT fk_pmb_pr FOREIGN KEY (productoId) REFERENCES Productos(productoId);
ALTER TABLE ProductosMarcasBlancas ADD CONSTRAINT fk_pmb_tie FOREIGN KEY (tiendaId) REFERENCES TiendasVirtualesGeneradas(tiendaId);
ALTER TABLE ProductosMarcasBlancas ADD CONSTRAINT fk_pmb_mb FOREIGN KEY (marcaBlancaId) REFERENCES MarcasBlancas(marcaBlancaId);

-- Precios y Descuentos
ALTER TABLE PreciosVenta ADD CONSTRAINT fk_pv_pmb FOREIGN KEY (productoMarcaId) REFERENCES ProductosMarcasBlancas(productoMarcaId);
ALTER TABLE PreciosVenta ADD CONSTRAINT fk_pv_cu FOREIGN KEY (currencyId) REFERENCES Currencies(currencyId);
ALTER TABLE PreciosVenta ADD CONSTRAINT fk_pv_tc FOREIGN KEY (tasaDeCambioId) REFERENCES TasasDeCambio(tasaDeCambioId);
ALTER TABLE PreciosVenta ADD CONSTRAINT fk_pv_tpr FOREIGN KEY (tipoPrecioId) REFERENCES TiposPrecios(tipoPrecioId);
ALTER TABLE PreciosVenta ADD CONSTRAINT fk_pv_usr FOREIGN KEY (aprobadoPor) REFERENCES Usuarios(usuarioId);

ALTER TABLE ReglasAprobacionPrecios ADD CONSTRAINT fk_reg_tie FOREIGN KEY (tiendaId) REFERENCES TiendasVirtualesGeneradas(tiendaId);
ALTER TABLE ReglasAprobacionPrecios ADD CONSTRAINT fk_reg_tp FOREIGN KEY (tipoProductoId) REFERENCES TiposProducto(tipoProductoId);
ALTER TABLE ReglasAprobacionPrecios ADD CONSTRAINT fk_reg_rol FOREIGN KEY (rolRequeridoId) REFERENCES Roles(rolId);

ALTER TABLE Descuentos ADD CONSTRAINT fk_des_td FOREIGN KEY (tipoDescuentoId) REFERENCES TiposDescuento(tipoDescuentoId);
ALTER TABLE DescuentosPorTienda ADD CONSTRAINT fk_dpt_des FOREIGN KEY (descuentoId) REFERENCES Descuentos(descuentoId);
ALTER TABLE DescuentosPorTienda ADD CONSTRAINT fk_dpt_tie FOREIGN KEY (tiendaId) REFERENCES TiendasVirtualesGeneradas(tiendaId);
ALTER TABLE DescuentosPorProducto ADD CONSTRAINT fk_dpp_des FOREIGN KEY (descuentoId) REFERENCES Descuentos(descuentoId);
ALTER TABLE DescuentosPorProducto ADD CONSTRAINT fk_dpp_pmb FOREIGN KEY (productoMarcaId) REFERENCES ProductosMarcasBlancas(productoMarcaId);

-- Regulaciones
ALTER TABLE TiposRegulacion ADD CONSTRAINT fk_tr_dat FOREIGN KEY (tipoDatoId) REFERENCES TiposDato(tipoDatoId);
ALTER TABLE RegulacionesPorPais ADD CONSTRAINT fk_rp_pmb FOREIGN KEY (productoMarcaId) REFERENCES ProductosMarcasBlancas(productoMarcaId);
ALTER TABLE RegulacionesPorPais ADD CONSTRAINT fk_rp_tp FOREIGN KEY (tipoProductoId) REFERENCES TiposProducto(tipoProductoId);
ALTER TABLE RegulacionesPorPais ADD CONSTRAINT fk_rp_pa FOREIGN KEY (paisId) REFERENCES Paises(paisId);
ALTER TABLE RegulacionesPorPais ADD CONSTRAINT fk_rp_tr FOREIGN KEY (tipoRegulacionId) REFERENCES TiposRegulacion(tipoRegulacionId);

-- Reseñas y Transformaciones
ALTER TABLE ReseñasProductos ADD CONSTRAINT fk_res_pmb FOREIGN KEY (productoMarcaId) REFERENCES ProductosMarcasBlancas(productoMarcaId);
ALTER TABLE ReseñasProductos ADD CONSTRAINT fk_res_cli FOREIGN KEY (clienteId) REFERENCES Clientes(clienteId);
ALTER TABLE ReseñasProductos ADD CONSTRAINT fk_res_ov FOREIGN KEY (ordenVentaId) REFERENCES OrdenesVenta(ordenVentaId);

ALTER TABLE ResumenReseñasProductos ADD CONSTRAINT fk_rrp_pmb FOREIGN KEY (productoMarcaId) REFERENCES ProductosMarcasBlancas(productoMarcaId);
ALTER TABLE DistribucionReseñasProductos ADD CONSTRAINT fk_dis_rrp FOREIGN KEY (resumenReseñaProductoId) REFERENCES ResumenReseñasProductos(resumenReseñaProductoId);

ALTER TABLE TransformacionesProductos ADD CONSTRAINT fk_tra_lote FOREIGN KEY (loteBulkId) REFERENCES LotesBulk(loteBulkId); -- FK Lógica a Etheria
ALTER TABLE TransformacionesProductos ADD CONSTRAINT fk_tra_pmb FOREIGN KEY (productoMarcaId) REFERENCES ProductosMarcasBlancas(productoMarcaId);
ALTER TABLE TransformacionesProductos ADD CONSTRAINT fk_tra_punto FOREIGN KEY (puntoRetiroId) REFERENCES Ubicaciones(ubicacionId);
ALTER TABLE TransformacionesProductos ADD CONSTRAINT fk_tra_usr FOREIGN KEY (responsableTransformacionId) REFERENCES Usuarios(usuarioId);
ALTER TABLE TransformacionesProductos ADD CONSTRAINT fk_tra_ubi FOREIGN KEY (ubicacionTransformacionId) REFERENCES Ubicaciones(ubicacionId);
ALTER TABLE TransformacionesProductos ADD CONSTRAINT fk_tra_est FOREIGN KEY (estadoTransformacionId) REFERENCES EstadosTransformacion(estadoTransformacionId);

ALTER TABLE SolicitudesRetiro ADD CONSTRAINT fk_sol_pmb FOREIGN KEY (productoMarcaDestinoId) REFERENCES ProductosMarcasBlancas(productoMarcaId);

-- Clientes y Ventas
ALTER TABLE Clientes ADD CONSTRAINT fk_cli_tie FOREIGN KEY (tiendaId) REFERENCES TiendasVirtualesGeneradas(tiendaId);
ALTER TABLE Clientes ADD CONSTRAINT fk_cli_pa FOREIGN KEY (paisResidenciaId) REFERENCES Paises(paisId);

ALTER TABLE ContactosClientes ADD CONSTRAINT fk_con_cli FOREIGN KEY (clienteId) REFERENCES Clientes(clienteId);
ALTER TABLE ContactosClientes ADD CONSTRAINT fk_con_tc FOREIGN KEY (tipoContactoClienteId) REFERENCES TiposContactoCliente(tipoContactoClienteId);

ALTER TABLE InteraccionesClientes ADD CONSTRAINT fk_int_cli FOREIGN KEY (clienteId) REFERENCES Clientes(clienteId);
ALTER TABLE InteraccionesClientes ADD CONSTRAINT fk_int_tie FOREIGN KEY (tiendaId) REFERENCES TiendasVirtualesGeneradas(tiendaId);
ALTER TABLE InteraccionesClientes ADD CONSTRAINT fk_int_tip FOREIGN KEY (tipoInteraccionId) REFERENCES TiposInteraccionesClientes(tipoInteraccionId);

ALTER TABLE OrdenesVenta ADD CONSTRAINT fk_ov_tie FOREIGN KEY (tiendaId) REFERENCES TiendasVirtualesGeneradas(tiendaId);
ALTER TABLE OrdenesVenta ADD CONSTRAINT fk_ov_cli FOREIGN KEY (clienteId) REFERENCES Clientes(clienteId);
ALTER TABLE OrdenesVenta ADD CONSTRAINT fk_ov_est FOREIGN KEY (estadoOrdenVentaId) REFERENCES EstadosOrdenesVenta(estadoOrdenVentaId);
ALTER TABLE OrdenesVenta ADD CONSTRAINT fk_ov_cu FOREIGN KEY (currencyId) REFERENCES Currencies(currencyId);
ALTER TABLE OrdenesVenta ADD CONSTRAINT fk_ov_tc FOREIGN KEY (tasaDeCambioId) REFERENCES TasasDeCambio(tasaDeCambioId);
ALTER TABLE OrdenesVenta ADD CONSTRAINT fk_ov_pa FOREIGN KEY (paisId) REFERENCES Paises(paisId);
ALTER TABLE OrdenesVenta ADD CONSTRAINT fk_ov_mp FOREIGN KEY (metodoPagoId) REFERENCES MetodosPago(metodoPagoId);
ALTER TABLE OrdenesVenta ADD CONSTRAINT fk_ov_ep FOREIGN KEY (estadoPagoId) REFERENCES EstadosPago(estadoPagoId);

ALTER TABLE DetallesOrdenesVenta ADD CONSTRAINT fk_dov_ov FOREIGN KEY (ordenVentaId) REFERENCES OrdenesVenta(ordenVentaId);
ALTER TABLE DetallesOrdenesVenta ADD CONSTRAINT fk_dov_pmb FOREIGN KEY (productoMarcaId) REFERENCES ProductosMarcasBlancas(productoMarcaId);
ALTER TABLE DetallesOrdenesVenta ADD CONSTRAINT fk_dov_cu FOREIGN KEY (currencyId) REFERENCES Currencies(currencyId);

ALTER TABLE ImpuestosOrdenesVenta ADD CONSTRAINT fk_iov_ov FOREIGN KEY (ordenVentaId) REFERENCES OrdenesVenta(ordenVentaId);
ALTER TABLE ImpuestosOrdenesVenta ADD CONSTRAINT fk_iov_imp FOREIGN KEY (impuestoVentaId) REFERENCES ImpuestosVentaPorPais(impuestoVentaId);
ALTER TABLE ImpuestosOrdenesVenta ADD CONSTRAINT fk_iov_bc FOREIGN KEY (baseCalculoId) REFERENCES BasesCalculoImpuestos(BaseCalculoId);

ALTER TABLE DescuentosOrdenVenta ADD CONSTRAINT fk_dov_desc FOREIGN KEY (descuentoId) REFERENCES Descuentos(descuentoId);
ALTER TABLE DescuentosOrdenVenta ADD CONSTRAINT fk_dov_ov FOREIGN KEY (ordenVentaId) REFERENCES OrdenesVenta(ordenVentaId);

ALTER TABLE Envios ADD CONSTRAINT fk_env_ov FOREIGN KEY (ordenVentaId) REFERENCES OrdenesVenta(ordenVentaId);
ALTER TABLE Envios ADD CONSTRAINT fk_env_cou FOREIGN KEY (courierId) REFERENCES Courier(courierId);
ALTER TABLE Envios ADD CONSTRAINT fk_env_cu FOREIGN KEY (currencyId) REFERENCES Currencies(currencyId);
ALTER TABLE Envios ADD CONSTRAINT fk_env_est FOREIGN KEY (estadoEnvioId) REFERENCES EstadosEnvio(estadoEnvioId);

-- Archivos
ALTER TABLE Archivos ADD CONSTRAINT fk_arch_tip FOREIGN KEY (tipoArchivo) REFERENCES TiposArchivos(tipoArchivoId);

-- Logs y Seguridad
ALTER TABLE Logs ADD CONSTRAINT fk_log_ev FOREIGN KEY (tipoEventoId) REFERENCES TiposEvento(tipoEventoId);
ALTER TABLE Logs ADD CONSTRAINT fk_log_sev FOREIGN KEY (severidadId) REFERENCES Severidades(severidadId);
ALTER TABLE Logs ADD CONSTRAINT fk_log_src FOREIGN KEY (sourceId) REFERENCES Sources(sourceId);
ALTER TABLE Logs ADD CONSTRAINT fk_log_usr FOREIGN KEY (usuarioId) REFERENCES Usuarios(usuarioId);
ALTER TABLE Logs ADD CONSTRAINT fk_log_obj1 FOREIGN KEY (objetoId1) REFERENCES Objetos(objetoId);
ALTER TABLE Logs ADD CONSTRAINT fk_log_obj2 FOREIGN KEY (objetoId2) REFERENCES Objetos(objetoId);

ALTER TABLE ConfiguracionesSistema ADD CONSTRAINT fk_cs_usr FOREIGN KEY (ultimoCambioPor) REFERENCES Usuarios(usuarioId);

ALTER TABLE RolPermiso ADD CONSTRAINT fk_rp_rol FOREIGN KEY (rolId) REFERENCES Roles(rolId);
ALTER TABLE RolPermiso ADD CONSTRAINT fk_rp_per FOREIGN KEY (permisoId) REFERENCES Permiso(permisoId);

ALTER TABLE UsuarioRol ADD CONSTRAINT fk_ur_usr FOREIGN KEY (usuarioId) REFERENCES Usuarios(usuarioId);
ALTER TABLE UsuarioRol ADD CONSTRAINT fk_ur_rol FOREIGN KEY (rolId) REFERENCES Roles(rolId);
ALTER TABLE UsuarioRol ADD CONSTRAINT fk_ur_asig FOREIGN KEY (asignadoPor) REFERENCES Usuarios(usuarioId);

-- Configuración por Tienda
ALTER TABLE ConfiguracionPorTienda ADD CONSTRAINT fk_cpt_tie FOREIGN KEY (tiendaId) REFERENCES TiendasVirtualesGeneradas(tiendaId);

SET FOREIGN_KEY_CHECKS=1;