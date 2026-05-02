-- ============================================================================
-- DYNAMIC BRANDS - SCRIPT MAESTRO (Estilo INLINE Fiel al Markdown)
-- Autor: Gerald Hernández Gamboa
-- Motor: MySQL 8.0+
-- Versión: 0.4
-- Nota: Uso exclusivo de sintaxis INLINE para FKs y Uniques simples.
-- ============================================================================

SET FOREIGN_KEY_CHECKS=0;

-- 1. GEOGRAFÍA Y UBICACIONES (Espejo Etheria)
CREATE TABLE Paises (
    paisId INT NOT NULL PRIMARY KEY,
    nombrePais VARCHAR(50) NOT NULL,
    codigoIso CHAR(3) UNIQUE NOT NULL,
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT REFERENCES Usuarios(usuarioId),
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE Provincias (
    provinciaId INT NOT NULL PRIMARY KEY,
    nombreProvincia VARCHAR(50) UNIQUE NOT NULL,
    paisId INT NOT NULL REFERENCES Paises(paisId),
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT REFERENCES Usuarios(usuarioId),
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE Ciudades (
    ciudadId INT NOT NULL PRIMARY KEY,
    nombreCiudad VARCHAR(50) UNIQUE NOT NULL,
    provinciaId INT NOT NULL REFERENCES Provincias(provinciaId),
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT REFERENCES Usuarios(usuarioId),
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE TiposUbicacion (
    tipoUbicacionId INT NOT NULL PRIMARY KEY,
    nombreTipoUbicacion VARCHAR(50) UNIQUE NOT NULL,
    descripcion VARCHAR(255),
    fechaSincronizacion TIMESTAMP,
    usuarioAuditoria INT REFERENCES Usuarios(usuarioId),
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE Ubicaciones (
    ubicacionId INT NOT NULL PRIMARY KEY,
    nombreUbicacion VARCHAR(100) UNIQUE NOT NULL,
    tipoUbicacionId INT NOT NULL REFERENCES TiposUbicacion(tipoUbicacionId),
    ciudadId INT REFERENCES Ciudades(ciudadId),
    direccion VARCHAR(200),
    activo BOOLEAN DEFAULT TRUE,
    fechaSincronizacion TIMESTAMP,
    usuarioAuditoria INT REFERENCES Usuarios(usuarioId),
    ultimaAuditoria TIMESTAMP
);

CREATE TABLE Courier (
    courierId INT NOT NULL PRIMARY KEY,
    nombreCourier VARCHAR(50) UNIQUE NOT NULL,
    ciudadId INT REFERENCES Ciudades(ciudadId),
    tipoServicioId INT REFERENCES TiposServicios(tipoServicioId),
    tiempoEntregaPromedioDias INT,
    fechaSincronizacion TIMESTAMP,
    usuarioAuditoria INT REFERENCES Usuarios(usuarioId),
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE TiposServicios (
    tipoServicioId INT NOT NULL PRIMARY KEY,
    nombreTipoServicio VARCHAR(50) UNIQUE NOT NULL,
    fechaSincronizacion TIMESTAMP,
    usuarioAuditoria INT REFERENCES Usuarios(usuarioId),
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

-- 2. MONEDAS Y TASAS
CREATE TABLE Currencies (
    currencyId INT NOT NULL PRIMARY KEY,
    codigoIso CHAR(3) UNIQUE NOT NULL,
    currencySymbol CHAR(5),
    nombreCurrency VARCHAR(50) NOT NULL,
    activo BOOLEAN DEFAULT TRUE,
    fechaSincronizacion TIMESTAMP,
    usuarioAuditoria INT REFERENCES Usuarios(usuarioId),
    ultimaAuditoria TIMESTAMP
);

CREATE TABLE TasasDeCambio (
    tasaDeCambioId INT NOT NULL PRIMARY KEY,
    currencyId1 INT NOT NULL REFERENCES Currencies(currencyId),
    currencyId2 INT NOT NULL REFERENCES Currencies(currencyId),
    exchangeRate DECIMAL(12,6),
    fechaSincronizacion TIMESTAMP,
    usuarioAuditoria INT REFERENCES Usuarios(usuarioId),
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE,
    CONSTRAINT uk_tasas_par_moneda UNIQUE (currencyId1, currencyId2)
);

CREATE TABLE HistorialTasasDeCambio (
    historialTasaDeCambio INT NOT NULL PRIMARY KEY,
    fechaInicio TIMESTAMP,
    fechaFinal TIMESTAMP,
    currencyId1 INT REFERENCES Currencies(currencyId),
    currencyId2 INT REFERENCES Currencies(currencyId),
    exchangeRate DECIMAL(12,6),
    fechaSincronizacion TIMESTAMP,
    usuarioAuditoria INT REFERENCES Usuarios(usuarioId),
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE,
    tasaDeCambioId INT REFERENCES TasasDeCambio(tasaDeCambioId)
);

-- 3. IMPUESTOS
CREATE TABLE BasesCalculoImpuestos (
    BaseCalculoId INT AUTO_INCREMENT PRIMARY KEY,
    nombreBaseCalculoImpuesto VARCHAR(50) UNIQUE NOT NULL,
    descripcion VARCHAR(255),
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT REFERENCES Usuarios(usuarioId),
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE TiposImpuestosVenta (
    tipoImpuestoVentaId INT AUTO_INCREMENT PRIMARY KEY,
    nombreTipoImpuestoVenta VARCHAR(50) UNIQUE NOT NULL,
    descripcion VARCHAR(255),
    aplicaPorUnidad BOOLEAN DEFAULT FALSE,
    paisId INT REFERENCES Paises(paisId),
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT REFERENCES Usuarios(usuarioId),
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE ImpuestosVentaPorPais (
    impuestoVentaId INT AUTO_INCREMENT PRIMARY KEY,
    productoMarcaId INT REFERENCES ProductosMarcasBlancas(productoMarcaId),
    tipoProductoId INT REFERENCES TiposProducto(tipoProductoId),
    paisId INT NOT NULL REFERENCES Paises(paisId),
    tipoImpuestoVentaId INT NOT NULL REFERENCES TiposImpuestosVenta(tipoImpuestoVentaId),
    porcentaje DECIMAL(5,2),
    montoFijoLocal DECIMAL(10,2),
    baseCalculoId INT REFERENCES BasesCalculoImpuestos(BaseCalculoId),
    fechaVigenciaDesde DATE NOT NULL,
    fechaVigenciaHasta DATE,
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT REFERENCES Usuarios(usuarioId),
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE,
    CONSTRAINT uk_imp_pais_tipo UNIQUE (paisId, tipoImpuestoVentaId)
);

-- 4. TIENDAS Y GENERACIÓN
CREATE TABLE EstadosGeneracion (
    estadoGeneracionId INT AUTO_INCREMENT PRIMARY KEY,
    nombreEstadoGeneracion VARCHAR(50) UNIQUE NOT NULL,
    descripcion VARCHAR(255),
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT REFERENCES Usuarios(usuarioId),
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE EstadosTienda (
    estadoTiendaId INT AUTO_INCREMENT PRIMARY KEY,
    nombreEstadoTienda VARCHAR(50) UNIQUE NOT NULL,
    permiteVentas BOOLEAN DEFAULT FALSE,
    descripcion VARCHAR(255),
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT REFERENCES Usuarios(usuarioId),
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE PublicosObjetivo (
    publicoObjetivoId INT AUTO_INCREMENT PRIMARY KEY,
    nombrePublicoObjetivo VARCHAR(50) UNIQUE NOT NULL,
    descripcion VARCHAR(255),
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT REFERENCES Usuarios(usuarioId),
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE EnfoquesMarketing (
    enfoqueMarketingId INT AUTO_INCREMENT PRIMARY KEY,
    nombreEnfoqueMarketing VARCHAR(50) UNIQUE NOT NULL,
    descripcion VARCHAR(255),
    publicoObjetivoId INT REFERENCES PublicosObjetivo(publicoObjetivoId),
    grupoConfiguracionId INT REFERENCES GruposConfiguracion(grupoConfigId),
    generadoPorIA BOOLEAN DEFAULT TRUE,
    activo BOOLEAN DEFAULT TRUE,
    fechaCreacion TIMESTAMP,
    creadoPor INT REFERENCES Usuarios(usuarioId),
    ultimaAuditoria TIMESTAMP
);

CREATE TABLE TiendasVirtualesGeneradas (
    tiendaId INT AUTO_INCREMENT PRIMARY KEY,
    nombreTienda VARCHAR(100) UNIQUE NOT NULL,
    paisId INT NOT NULL REFERENCES Paises(paisId),
    currencyId INT REFERENCES Currencies(currencyId),
    estadoTiendaId INT NOT NULL REFERENCES EstadosTienda(estadoTiendaId),
    enfoqueMarketingId INT REFERENCES EnfoquesMarketing(enfoqueMarketingId),
    fechaApertura DATE,
    fechaCierre DATE,
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT REFERENCES Usuarios(usuarioId),
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE GeneracionSitiosWeb (
    generacionSitioWebId INT AUTO_INCREMENT PRIMARY KEY,
    tiendaId INT NOT NULL REFERENCES TiendasVirtualesGeneradas(tiendaId),
    versionSitio INT DEFAULT 1,
    estadoGeneracionId INT NOT NULL REFERENCES EstadosGeneracion(estadoGeneracionId),
    fechaSolicitud TIMESTAMP NOT NULL,
    fechaCompletado TIMESTAMP,
    tiempoProcesamientoSegundos INT,
    errorMensaje VARCHAR(200),
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT REFERENCES Usuarios(usuarioId),
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

-- 5. CONFIGURACIÓN
CREATE TABLE TiposDato (
    tipoDatoId INT AUTO_INCREMENT PRIMARY KEY,
    nombreTipoDato VARCHAR(50) UNIQUE NOT NULL,
    descripcion VARCHAR(255),
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT REFERENCES Usuarios(usuarioId),
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE TiposParametro (
    tipoParametroId INT AUTO_INCREMENT PRIMARY KEY,
    nombreTipoParametro VARCHAR(50) UNIQUE NOT NULL,
    tipoDatoId INT NOT NULL REFERENCES TiposDato(tipoDatoId),
    valorPorDefecto VARCHAR(255),
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT REFERENCES Usuarios(usuarioId),
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE GruposConfiguracion (
    grupoConfigId INT AUTO_INCREMENT PRIMARY KEY,
    nombreGrupoConfiguracion VARCHAR(50) UNIQUE NOT NULL,
    descripcion VARCHAR(255),
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT REFERENCES Usuarios(usuarioId),
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE ValoresConfiguracion (
    valorConfigId INT AUTO_INCREMENT PRIMARY KEY,
    grupoConfigId INT NOT NULL REFERENCES GruposConfiguracion(grupoConfigId),
    tipoParametroId INT NOT NULL REFERENCES TiposParametro(tipoParametroId),
    valorTexto VARCHAR(500),
    valorNumerico DECIMAL(10,2),
    valorBoolean BOOLEAN,
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT REFERENCES Usuarios(usuarioId),
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

-- 6. PRODUCTOS Y MARCAS
CREATE TABLE TiposCaracteristica (
    tipoCaracteristicaId INT NOT NULL PRIMARY KEY,
    nombreTipoCaracteristica VARCHAR(50) UNIQUE NOT NULL,
    descripcion VARCHAR(150),
    activo BOOLEAN DEFAULT TRUE,
    fechaSincronizacion TIMESTAMP,
    usuarioAuditoria INT REFERENCES Usuarios(usuarioId),
    ultimaAuditoria TIMESTAMP
);

CREATE TABLE TiposProducto (
    tipoProductoId INT NOT NULL PRIMARY KEY,
    nombreTipoProducto VARCHAR(50) UNIQUE NOT NULL,
    fechaSincronizacion TIMESTAMP,
    usuarioAuditoria INT REFERENCES Usuarios(usuarioId),
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE UnidadesMedidaProducto (
    UnidadMedidaProductoId INT NOT NULL PRIMARY KEY,
    nombreUnidadMedidaProducto VARCHAR(50) UNIQUE NOT NULL,
    descripcion VARCHAR(255),
    fechaSincronizacion TIMESTAMP,
    usuarioAuditoria INT REFERENCES Usuarios(usuarioId),
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE MarcasOriginales (
    marcaOriginalId INT NOT NULL PRIMARY KEY,
    nombreMarcaOriginal VARCHAR(100) UNIQUE NOT NULL,
    paisId INT REFERENCES Paises(paisId),
    fechaSincronizacion TIMESTAMP,
    usuarioAuditoria INT REFERENCES Usuarios(usuarioId),
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE Productos (
    productoId INT NOT NULL PRIMARY KEY,
    skuInterno VARCHAR(20) UNIQUE NOT NULL,
    nombreTecnico VARCHAR(50) NOT NULL,
    nombreComun VARCHAR(50),
    marcaOriginalId INT NOT NULL REFERENCES MarcasOriginales(marcaOriginalId),
    tipoProductoId INT NOT NULL REFERENCES TiposProducto(tipoProductoId),
    unidadMedidaProductoId INT NOT NULL REFERENCES UnidadesMedidaProducto(UnidadMedidaProductoId),
    vidaUtilMeses INT,
    fechaSincronizacion TIMESTAMP,
    usuarioAuditoria INT REFERENCES Usuarios(usuarioId),
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE CaracteristicasProducto (
    caracteristicaId INT NOT NULL PRIMARY KEY,
    productoId INT NOT NULL REFERENCES Productos(productoId),
    tipoCaracteristicaId INT NOT NULL REFERENCES TiposCaracteristica(tipoCaracteristicaId),
    valorBoolean BOOLEAN,
    valorTexto VARCHAR(255),
    valorNumerico DECIMAL(10,2),
    paisId INT REFERENCES Paises(paisId),
    vigenteDesde DATE DEFAULT (CURRENT_DATE),
    vigenteHasta DATE,
    fechaSincronizacion TIMESTAMP,
    usuarioAuditoria INT REFERENCES Usuarios(usuarioId),
    activo BOOLEAN DEFAULT TRUE,
    ultimaAuditoria TIMESTAMP,
    CONSTRAINT uk_caract_prod_tipo UNIQUE (productoId, tipoCaracteristicaId)
);

CREATE TABLE MarcasBlancas (
    marcaBlancaId INT AUTO_INCREMENT PRIMARY KEY,
    nombreMarcaBlanca VARCHAR(100) UNIQUE NOT NULL,
    tiendaId INT NOT NULL REFERENCES TiendasVirtualesGeneradas(tiendaId),
    paisId INT NOT NULL REFERENCES Paises(paisId),
    archivoId INT REFERENCES Archivos(archivoId),
    publicoObjetivoId INT REFERENCES PublicosObjetivo(publicoObjetivoId),
    fechaRegistroMarca DATE,
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT REFERENCES Usuarios(usuarioId),
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE ProductosMarcasBlancas (
    productoMarcaId INT AUTO_INCREMENT PRIMARY KEY,
    productoId INT NOT NULL REFERENCES Productos(productoId),
    tiendaId INT NOT NULL REFERENCES TiendasVirtualesGeneradas(tiendaId),
    skuComercial VARCHAR(50) UNIQUE NOT NULL,
    nombreComercial VARCHAR(100) NOT NULL,
    marcaBlancaId INT NOT NULL REFERENCES MarcasBlancas(marcaBlancaId),
    stockDisponible DECIMAL(12,2) DEFAULT 0,
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT REFERENCES Usuarios(usuarioId),
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE,
    CONSTRAINT uk_pmb_prod_tienda UNIQUE (productoId, tiendaId, marcaBlancaId)
);

CREATE TABLE TiposPrecios (
    tipoPrecioId INT AUTO_INCREMENT PRIMARY KEY,
    nombreTipoPrecio VARCHAR(50) UNIQUE NOT NULL,
    descripcion VARCHAR(255),
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT REFERENCES Usuarios(usuarioId),
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE PreciosVenta (
    precioVentaId INT AUTO_INCREMENT PRIMARY KEY,
    productoMarcaId INT NOT NULL REFERENCES ProductosMarcasBlancas(productoMarcaId),
    currencyId INT NOT NULL REFERENCES Currencies(currencyId),
    precioVentaLocal DECIMAL(14,2) NOT NULL,
    tasaDeCambioId INT REFERENCES TasasDeCambio(tasaDeCambioId),
    tasaDeCambioAplicada DECIMAL(12,6) NOT NULL,
    tipoPrecioId INT NOT NULL REFERENCES TiposPrecios(tipoPrecioId),
    margenPorcentaje DECIMAL(5,2),
    costoBase DECIMAL(14,4),
    fechaVigenciaDesde DATE NOT NULL,
    fechaVigenciaHasta DATE,
    aprobadoPor INT REFERENCES Usuarios(usuarioId),
    fechaAprobacion TIMESTAMP,
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT REFERENCES Usuarios(usuarioId),
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE,
    CONSTRAINT uk_pv_prod_tipo_moneda UNIQUE (productoMarcaId, tipoPrecioId, currencyId)
);

-- 7. REGLAS, DESCUENTOS Y REGULACIONES
CREATE TABLE ReglasAprobacionPrecios (
    reglaAprobacionId INT AUTO_INCREMENT PRIMARY KEY,
    tiendaId INT REFERENCES TiendasVirtualesGeneradas(tiendaId),
    tipoProductoId INT REFERENCES TiposProducto(tipoProductoId),
    rolRequeridoId INT NOT NULL REFERENCES Roles(rolId),
    cambioMinimoPorcentaje DECIMAL(5,2),
    cambioMaximoPorcentaje DECIMAL(5,2),
    montoMinimoPrecio DECIMAL(12,2),
    montoMaximoPrecio DECIMAL(12,2),
    requiereDobleAprobacion BOOLEAN DEFAULT FALSE,
    tiempoMaximoAprobacionHoras INT DEFAULT 48,
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT REFERENCES Usuarios(usuarioId),
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE TiposDescuento (
    tipoDescuentoId INT AUTO_INCREMENT PRIMARY KEY,
    nombreTipoDescuento VARCHAR(50) UNIQUE NOT NULL,
    descripcion VARCHAR(255),
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT REFERENCES Usuarios(usuarioId),
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE Descuentos (
    descuentoId INT AUTO_INCREMENT PRIMARY KEY,
    codigoCupon VARCHAR(50) UNIQUE NOT NULL,
    descripcion VARCHAR(255),
    tipoDescuentoId INT NOT NULL REFERENCES TiposDescuento(tipoDescuentoId),
    valorDescuento DECIMAL(10,2) NOT NULL,
    montoMinimoCompra DECIMAL(12,2),
    fechaVigenciaDesde DATE,
    fechaVigenciaHasta DATE,
    cantidadUsosMaximos INT,
    cantidadUsosActuales INT DEFAULT 0,
    esAcumulable BOOLEAN DEFAULT FALSE,
    prioridad INT DEFAULT 0,
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT REFERENCES Usuarios(usuarioId),
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE DescuentosPorTienda (
    descuentoTiendaId INT AUTO_INCREMENT PRIMARY KEY,
    descuentoId INT NOT NULL REFERENCES Descuentos(descuentoId),
    tiendaId INT NOT NULL  REFERENCES TiendasVirtualesGeneradas(tiendaId),
    esExclusivo BOOLEAN DEFAULT FALSE,
    fechaInicio TIMESTAMP,
    fechaFin TIMESTAMP,
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT REFERENCES Usuarios(usuarioId),
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE,
    CONSTRAINT uk_dpt_desc_tienda UNIQUE (descuentoId, tiendaId)
);

CREATE TABLE DescuentosPorProducto (
    descuentoProductoId INT AUTO_INCREMENT PRIMARY KEY,
    descuentoId INT NOT NULL  REFERENCES Descuentos(descuentoId),
    productoMarcaId INT NOT NULL  REFERENCES ProductosMarcasBlancas(productoMarcaId),
    aplicaAVariantes BOOLEAN DEFAULT TRUE,
    fechaInicio TIMESTAMP,
    fechaFin TIMESTAMP,
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT REFERENCES Usuarios(usuarioId),
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE,
    CONSTRAINT uk_dpp_desc_prod UNIQUE (descuentoId, productoMarcaId)
);

CREATE TABLE TiposRegulacion (
    tipoRegulacionId INT AUTO_INCREMENT PRIMARY KEY,
    nombreTipoRegulacion VARCHAR(50) UNIQUE NOT NULL,
    tipoDatoId INT NOT NULL REFERENCES TiposDato(tipoDatoId),
    descripcion VARCHAR(255),
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT REFERENCES Usuarios(usuarioId),
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE RegulacionesPorPais (
    regulacionId INT AUTO_INCREMENT PRIMARY KEY,
    productoMarcaId INT REFERENCES ProductosMarcasBlancas(productoMarcaId),
    tipoProductoId INT REFERENCES TiposProducto(tipoProductoId),
    paisId INT NOT NULL REFERENCES Paises(paisId),
    tipoRegulacionId INT NOT NULL REFERENCES TiposRegulacion(tipoRegulacionId),
    valorBoolean BOOLEAN,
    valorNumerico DECIMAL(10,2),
    valorTexto VARCHAR(255),
    autoridadCompetente VARCHAR(100),
    fechaUltimaVerificacion DATE,
    vigenciaDesde DATE NOT NULL,
    vigenciaHasta DATE,
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT REFERENCES Usuarios(usuarioId),
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE,
    CONSTRAINT uk_reg_pais_tipo UNIQUE (paisId, tipoRegulacionId)
);

-- 8. CLIENTES Y VENTAS
CREATE TABLE Clientes (
    clienteId INT AUTO_INCREMENT PRIMARY KEY,
    tiendaId INT NOT NULL REFERENCES TiendasVirtualesGeneradas(tiendaId),
    email VARCHAR(100) UNIQUE NOT NULL,
    nombreCliente VARCHAR(50) NOT NULL,
    apellidoCliente1 VARCHAR(40) NOT NULL,
    apellidoCliente2 VARCHAR(40) NOT NULL,
    paisId INT REFERENCES Paises(paisId),
    telefono VARCHAR(20),
    fechaRegistro TIMESTAMP,
    ultimoAcceso TIMESTAMP,
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT REFERENCES Usuarios(usuarioId),
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE TiposContactoCliente (
    tipoContactoClienteId INT AUTO_INCREMENT PRIMARY KEY,
    nombreTipoContactoCliente VARCHAR(50) UNIQUE NOT NULL,
    formatoValidacion VARCHAR(100),
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT REFERENCES Usuarios(usuarioId),
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE ContactosClientes (
    contactoClienteId INT AUTO_INCREMENT PRIMARY KEY,
    clienteId INT NOT NULL REFERENCES Clientes(clienteId),
    tipoContactoClienteId INT NOT NULL REFERENCES TiposContactoCliente(tipoContactoClienteId),
    valor VARCHAR(150) NOT NULL,
    esPrincipal BOOLEAN DEFAULT FALSE,
    verificado BOOLEAN DEFAULT FALSE,
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT REFERENCES Usuarios(usuarioId),
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE TiposInteraccionesClientes (
    tipoInteraccionId INT AUTO_INCREMENT PRIMARY KEY,
    nombreTipoInteraccionCliente VARCHAR(50) UNIQUE NOT NULL,
    descripcion VARCHAR(150),
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT REFERENCES Usuarios(usuarioId),
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE InteraccionesClientes (
    interaccionId INT AUTO_INCREMENT PRIMARY KEY,
    clienteId INT NOT NULL REFERENCES Clientes(clienteId),
    tiendaId INT NOT NULL REFERENCES TiendasVirtualesGeneradas(tiendaId),
    tipoInteraccionId INT NOT NULL REFERENCES TiposInteraccionesClientes(tipoInteraccionId),
    referenciaId BIGINT,
    descripcion VARCHAR(200),
    fechaInteraccion TIMESTAMP,
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT REFERENCES Usuarios(usuarioId),
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE EstadosOrdenesVenta (
    estadoOrdenVentaId INT AUTO_INCREMENT PRIMARY KEY,
    nombreEstadoOrdenVenta VARCHAR(50) UNIQUE NOT NULL,
    descripcion VARCHAR(255),
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT REFERENCES Usuarios(usuarioId),
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE MetodosPago (
    metodoPagoId INT AUTO_INCREMENT PRIMARY KEY,
    nombreMetodoPago VARCHAR(50) UNIQUE NOT NULL,
    requiereValidacionAdicional BOOLEAN DEFAULT FALSE,
    costoTransaccionPorcentaje DECIMAL(5,2) DEFAULT 0,
    costoTransaccionFijo DECIMAL(10,2) DEFAULT 0,
    tiempoConfirmacionMinutos INT,
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT REFERENCES Usuarios(usuarioId),
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE EstadosPago (
    estadoPagoId INT AUTO_INCREMENT PRIMARY KEY,
    nombreEstadoPago VARCHAR(50) UNIQUE NOT NULL,
    descripcion VARCHAR(255),
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT REFERENCES Usuarios(usuarioId),
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE OrdenesVenta (
    ordenVentaId INT AUTO_INCREMENT PRIMARY KEY,
    tiendaId INT NOT NULL REFERENCES TiendasVirtualesGeneradas(tiendaId),
    clienteId INT NOT NULL REFERENCES Clientes(clienteId),
    fechaOrden TIMESTAMP,
    numeroPedido VARCHAR(50) UNIQUE NOT NULL,
    estadoOrdenVentaId INT NOT NULL REFERENCES EstadosOrdenesVenta(estadoOrdenVentaId),
    montoSubtotal DECIMAL(14,2) NOT NULL,
    montoEnvio DECIMAL(14,2) DEFAULT 0,
    montoTotalLocal DECIMAL(14,2) NOT NULL,
    currencyId INT NOT NULL REFERENCES Currencies(currencyId),
    tasaDeCambioId INT REFERENCES TasasDeCambio(tasaDeCambioId),
    tasaDeCambioAplicada DECIMAL(12,6) NOT NULL,
    montoConvertidoBase DECIMAL(14,2) NOT NULL,
    paisId INT REFERENCES Paises(paisId),
    metodoPagoId INT REFERENCES MetodosPago(metodoPagoId),
    montoPagado DECIMAL(14,2),
    monedaPagoId INT REFERENCES Currencies(currencyId),
    fechaPago TIMESTAMP,
    estadoPagoId INT REFERENCES EstadosPago(estadoPagoId),
    intentoPagoCount INT DEFAULT 0,
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT REFERENCES Usuarios(usuarioId),
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE DetallesOrdenesVenta (
    detalleId INT AUTO_INCREMENT PRIMARY KEY,
    ordenVentaId INT NOT NULL REFERENCES OrdenesVenta(ordenVentaId),
    productoMarcaId INT NOT NULL REFERENCES ProductosMarcasBlancas(productoMarcaId),
    cantidad INT NOT NULL,
    currencyId INT NOT NULL REFERENCES Currencies(currencyId),
    precioUnitarioLocal DECIMAL(10,2) NOT NULL,
    subtotalLocal DECIMAL(12,2) NOT NULL,
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT REFERENCES Usuarios(usuarioId),
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE ImpuestosOrdenesVenta (
    ordenImpuestoId INT AUTO_INCREMENT PRIMARY KEY,
    ordenVentaId INT NOT NULL REFERENCES OrdenesVenta(ordenVentaId),
    impuestoVentaId INT NOT NULL REFERENCES ImpuestosVentaPorPais(impuestoVentaId),
    montoImpuestoLocal DECIMAL(10,2) NOT NULL,
    baseCalculoId INT NOT NULL REFERENCES BasesCalculoImpuestos(BaseCalculoId),
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT REFERENCES Usuarios(usuarioId),
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE,
    CONSTRAINT uk_impord_ord_imp UNIQUE (ordenVentaId, impuestoVentaId)
);

CREATE TABLE DescuentosOrdenVenta (
    ordenDescuentoId INT AUTO_INCREMENT PRIMARY KEY,
    ordenVentaId INT NOT NULL REFERENCES OrdenesVenta(ordenVentaId),
    descuentoId INT NOT NULL REFERENCES Descuentos(descuentoId),
    montoDescuentoLocal DECIMAL(10,2) NOT NULL,
    codigoCuponUsado VARCHAR(50),
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT REFERENCES Usuarios(usuarioId),
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE,
    CONSTRAINT uk_descord_ord_desc UNIQUE (ordenVentaId, descuentoId)
);

-- 9. LOGÍSTICA Y ARCHIVOS
CREATE TABLE SolicitudesRetiro (
    solicitudRetiroId INT AUTO_INCREMENT PRIMARY KEY,
    productoBaseReferencia INT NOT NULL,
    loteBulkReferencia INT NOT NULL,
    cantidadSolicitada DECIMAL(12,2) NOT NULL,
    productoMarcaId INT REFERENCES ProductosMarcasBlancas(productoMarcaId),
    fechaSolicitud TIMESTAMP NOT NULL,
    fechaRetiroProgramado DATE,
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT REFERENCES Usuarios(usuarioId),
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE EstadosEnvio (
    estadoEnvioId INT AUTO_INCREMENT PRIMARY KEY,
    nombreEstadoEnvio VARCHAR(50) UNIQUE NOT NULL,
    descripcion VARCHAR(255),
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT REFERENCES Usuarios(usuarioId),
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE Envios (
    envioId INT AUTO_INCREMENT PRIMARY KEY,
    ordenVentaId INT NOT NULL REFERENCES OrdenesVenta(ordenVentaId),
    courierId INT NOT NULL REFERENCES Courier(courierId),
    trackingNumber VARCHAR(100) UNIQUE NOT NULL,
    fechaDespacho TIMESTAMP,
    fechaEntregaEstimada DATE,
    fechaEntregaReal TIMESTAMP,
    costoCourierLocal DECIMAL(10,2),
    currencyId INT NOT NULL REFERENCES Currencies(currencyId),
    estadoEnvioId INT NOT NULL REFERENCES EstadosEnvio(estadoEnvioId),
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT REFERENCES Usuarios(usuarioId),
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE TiposArchivos (
    tipoArchivoId INT AUTO_INCREMENT PRIMARY KEY,
    nombreTipoArchivo VARCHAR(50) UNIQUE NOT NULL,
    extension VARCHAR(100) NOT NULL,
    tamanioMaximoMB DECIMAL(6,2) NOT NULL,
    dimensionesMinimasPx VARCHAR(20),
    dimensionesMaximasPx VARCHAR(20),
    requiereCompresion BOOLEAN DEFAULT FALSE,
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT REFERENCES Usuarios(usuarioId),
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE Archivos (
    archivoId INT AUTO_INCREMENT PRIMARY KEY,
    checksum VARCHAR(64),
    tamaño INTEGER,
    duracion FLOAT,
    deleted BOOLEAN DEFAULT FALSE,
    rutaAlmacenamiento VARCHAR(500) NOT NULL,
    tipoArchivo INT REFERENCES TiposArchivos(tipoArchivoId),
    nombreOriginalArchivo VARCHAR(255) UNIQUE NOT NULL,
    hashContenido VARCHAR(64),
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT REFERENCES Usuarios(usuarioId),
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

-- 10. RESÉÑAS Y TRANSFORMACIONES
CREATE TABLE ReseñasProductos (
    reseñaId INT AUTO_INCREMENT PRIMARY KEY,
    productoMarcaId INT NOT NULL REFERENCES ProductosMarcasBlancas(productoMarcaId),
    clienteId INT NOT NULL REFERENCES Clientes(clienteId),
    ordenVentaId INT REFERENCES OrdenesVenta(ordenVentaId),
    calificacion INT NOT NULL,
    titulo VARCHAR(100),
    comentario VARCHAR(300),
    esCompraVerificada BOOLEAN DEFAULT FALSE,
    esAprobada BOOLEAN DEFAULT FALSE,
    fechaPublicacion TIMESTAMP,
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT REFERENCES Usuarios(usuarioId),
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE ResumenReseñasProductos (
    resumenReseñaProductoId INT AUTO_INCREMENT PRIMARY KEY,
    productoMarcaId INT UNIQUE NOT NULL REFERENCES ProductosMarcasBlancas(productoMarcaId),
    calificacionPromedio DECIMAL(3,2) NOT NULL,
    totalReseñas INT NOT NULL,
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT REFERENCES Usuarios(usuarioId),
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE DistribucionReseñasProductos (
    distribucionId INT AUTO_INCREMENT PRIMARY KEY,
    resumenReseñaProductoId INT NOT NULL REFERENCES ResumenReseñasProductos(resumenReseñaProductoId),
    valorCalificacion INT NOT NULL,
    cantidad INT NOT NULL DEFAULT 0,
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT REFERENCES Usuarios(usuarioId),
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE,
    CONSTRAINT uk_dist_resumen_valor UNIQUE (resumenReseñaProductoId, valorCalificacion)
);

CREATE TABLE EstadosTransformacion (
    estadoTransformacionId INT AUTO_INCREMENT PRIMARY KEY,
    nombreEstadoTransformacion VARCHAR(50) NOT NULL,
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT REFERENCES Usuarios(usuarioId),
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE TransformacionesProductos (
    transformacionId INT AUTO_INCREMENT PRIMARY KEY,
    loteBulkId INT NOT NULL, -- FK Lógica a Etheria
    productoMarcaId INT NOT NULL REFERENCES ProductosMarcasBlancas(productoMarcaId),
    productoBaseId INT NOT NULL, -- FK Lógica a Etheria
    ubicacionId INT NOT NULL REFERENCES Ubicaciones(ubicacionId),
    cantidadTransformada DECIMAL(12,2) NOT NULL,
    cantidadMerma DECIMAL(12,2) DEFAULT 0,
    fechaTransformacion TIMESTAMP NOT NULL,
    responsableTransformacionId INT REFERENCES Usuarios(usuarioId),
    ubicacionTransformacionId INT REFERENCES Ubicaciones(ubicacionId),
    estadoTransformacionId INT REFERENCES EstadosTransformacion(estadoTransformacionId),
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT REFERENCES Usuarios(usuarioId),
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

-- 11. AUDITORÍA Y SEGURIDAD (Igual que Etheria)
CREATE TABLE TiposEvento (
    tipoEventoId INT AUTO_INCREMENT PRIMARY KEY,
    nombreEvento VARCHAR(30) UNIQUE NOT NULL,
    descripcion VARCHAR(255) NOT NULL,
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT REFERENCES Usuarios(usuarioId),
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE Severidades (
    severidadId INT AUTO_INCREMENT PRIMARY KEY,
    valorSeveridad INT NOT NULL,
    nombreSeveridad VARCHAR(50) UNIQUE NOT NULL,
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT REFERENCES Usuarios(usuarioId),
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE Objetos (
    objetoId INT AUTO_INCREMENT PRIMARY KEY,
    nombreObjeto VARCHAR(50) UNIQUE NOT NULL,
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT REFERENCES Usuarios(usuarioId),
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE Sources (
    sourceId INT AUTO_INCREMENT PRIMARY KEY,
    nombreSource VARCHAR(50) UNIQUE NOT NULL,
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT REFERENCES Usuarios(usuarioId),
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE Logs (
    logId INT AUTO_INCREMENT PRIMARY KEY,
    tipoEventoId INT NOT NULL REFERENCES TiposEvento(tipoEventoId),
    severidadId INT NOT NULL DEFAULT 2 REFERENCES Severidades(severidadId),
    descripcion VARCHAR(255) NOT NULL,
    sourceId INT NOT NULL REFERENCES Sources(sourceId),
    userAgent TEXT,
    computadora VARCHAR(100),
    usuarioId INT REFERENCES Usuarios(usuarioId),
    referenciaId1 BIGINT,
    referenciaId2 BIGINT,
    descripcionReferencia1 VARCHAR(255),
    descripcionReferencia2 VARCHAR(255),
    objetoId1 INT REFERENCES Objetos(objetoId),
    objetoId2 INT REFERENCES Objetos(objetoId),
    checkSum VARCHAR(64),
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE Usuarios (
    usuarioId INT AUTO_INCREMENT PRIMARY KEY,
    nombreUsuario VARCHAR(50) NOT NULL,
    apellido1 VARCHAR(40) NOT NULL,
    apellido2 VARCHAR(40) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    contraseña VARBINARY(255),
    fechaNacimiento DATE,
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT REFERENCES Usuarios(usuarioId),
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE Roles (
    rolId INT AUTO_INCREMENT PRIMARY KEY,
    nombreRol VARCHAR(50) UNIQUE NOT NULL,
    descripcion VARCHAR(255),
    nivelAcceso INT,
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT REFERENCES Usuarios(usuarioId),
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE Permiso (
    permisoId INT AUTO_INCREMENT PRIMARY KEY,
    nombrePermiso VARCHAR(50) UNIQUE NOT NULL,
    descripcion VARCHAR(255),
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT REFERENCES Usuarios(usuarioId),
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE RolPermiso (
    rolId INT UNIQUE NOT NULL REFERENCES Roles(rolId),
    permisoId INT UNIQUE NOT NULL REFERENCES Permiso(permisoId),
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT REFERENCES Usuarios(usuarioId),
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE,
    PRIMARY KEY (rolId, permisoId)
);

CREATE TABLE UsuarioRol (
    usuarioId INT UNIQUE NOT NULL REFERENCES Usuarios(usuarioId),
    rolId INT UNIQUE NOT NULL REFERENCES Roles(rolId),
    asignadoPor INT REFERENCES Usuarios(usuarioId),
    asignadoEn TIMESTAMP,
    fechaExpiracion TIMESTAMP,
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT REFERENCES Usuarios(usuarioId),
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE,
    PRIMARY KEY (usuarioId, rolId)
);

-- 12. CONFIGURACIÓN FINAL
CREATE TABLE ConfiguracionSistema (
    configuracionSistemaId INT AUTO_INCREMENT PRIMARY KEY,
    clave VARCHAR(50) UNIQUE NOT NULL,
    valorText VARCHAR(500),
    valorInt INT,
    valorDecimal DECIMAL(18,6),
    valorBoolean BOOLEAN,
    descripcion VARCHAR(200),
    esEditableUI BOOLEAN DEFAULT TRUE,
    ultimoCambioPor INT REFERENCES Usuarios(usuarioId),
    ultimoCambioEn TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE ConfiguracionPorTienda (
    configuracionTiendaId INT AUTO_INCREMENT PRIMARY KEY,
    tiendaId INT NOT NULL REFERENCES TiendasVirtualesGeneradas(tiendaId),
    clave VARCHAR(50) NOT NULL,
    valorText VARCHAR(500),
    creadoEn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarioAuditoria INT REFERENCES Usuarios(usuarioId),
    ultimaAuditoria TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

SET FOREIGN_KEY_CHECKS=1;