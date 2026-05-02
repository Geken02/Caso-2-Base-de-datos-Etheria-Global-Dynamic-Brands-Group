> **Nombre:** Dynamic Brands db
> **Motor de base de datos:** MySQL
> **Versión:** 0.4 
> **Fecha:** 7-04-2026 
> **Autor:** Gerald Hernández Gamboa  

## Tables 

# Ciudades
- ciudadId int unique not null // Id original de Etheria (PK lógica, sin auto-increment)
- nombreCiudad varchar(50) unique not null
- provinciaId int not null //FK -> Provincias
- creadoEn TIMESTAMP
- usuarioAuditoria int //FK -> Usuarios
- ultimaAuditoria TIMESTAMP
- activo boolean

# Provincias
- provinciaId int unique not null // Id original de Etheria (PK lógica, sin auto-increment)
- nombreProvincia varchar(50) unique not null
- paisId int not null //FK -> Paises
- creadoEn TIMESTAMP
- usuarioAuditoria int //FK -> Usuarios
- ultimaAuditoria TIMESTAMP
- activo boolean

# Paises
- paisId int unique not null // Id original de Etheria (PK lógica, sin auto-increment)
- nombrePais varchar(50) not null
- codigoIso char(3) unique not null
- creadoEn TIMESTAMP
- usuarioAuditoria int //FK -> Usuarios
- ultimaAuditoria TIMESTAMP
- activo boolean default true

# Courier
- courierId int unique not null // Id original de Etheria (PK lógica, sin auto-increment)
- nombreCourier varchar(50) unique not null
- ciudadId int //FK -> Ciudades
- tipoServicioId int //FK -> TiposServicio
- tiempoEntregaPromedioDias int
- fechaSincronizacion TIMESTAMP
- usuarioAuditoria int //FK -> Usuarios
- ultimaAuditoria TIMESTAMP
- activo boolean

# TiposUbicacion
- tipoUbicacionId int unique not null  // Id original de Etheria (PK lógica, sin auto-increment)
- nombreTipoUbicacion varchar(50) unique not null
- descripcion varchar(255)
- fechaSincronizacion TIMESTAMP
- usuarioAuditoria int //FK -> Usuarios
- ultimaAuditoria TIMESTAMP
- activo boolean


# Ubicaciones 
- ubicacionId int unique not null // ID original de Etheria (PK lógica, sin auto-increment)
- nombreUbicacion varchar(100) unique not null
- tipoUbicacionId int not null // FK -> TiposUbicacion
- ciudadId int nullable // FK -> Ciudades
- direccion varchar(200) nullable
- activo boolean default true
- fechaSincronizacion TIMESTAMP
- usuarioAuditoria int //FK -> Usuarios
- ultimaAuditoria TIMESTAMP


# TiposServicios
- tipoServicioId int unique not null // Id original de Etheria (PK lógica, sin auto-increment)
- nombreTipoServicio varchar(50) unique not null
- fechaSincronizacion TIMESTAMP
- usuarioAuditoria int //FK -> Usuarios
- ultimaAuditoria TIMESTAMP
- activo boolean

# Currencies
- currencyId int not null // Id original de Etheria (PK lógica, sin auto-increment)
- codigoIso char(3) unique not null
- currencySymbol char
- nombreCurrency varchar(50) not null
- activo boolean
- fechaSincronizacion TIMESTAMP
- usuarioAuditoria int //FK -> Usuarios
- ultimaAuditoria TIMESTAMP

# TasasDeCambio
- tasaDeCambioId int not null // Id original de Etheria (PK lógica, sin auto-increment)
- currencyId1 int unique not null //FK -> Currencies
- currencyId2 int unique not null //FK -> Currencies
- exchangeRate //Factor multiplicativo
- fechaSincronizacion TIMESTAMP
- usuarioAuditoria int //FK -> Usuarios
- ultimaAuditoria TIMESTAMP
- activo boolean

# HistorialTasasDeCambio
- historialTasaDeCambio int not null // Id original de Etheria (PK lógica, sin auto-increment)
- fechaInicio TIMESTAMP
- fechaFinal TIMESTAMP //año 9999 si aun no termina
- currencyId1 int //FK -> Currencies
- currencyId2 int //FK -> Currencies
- exchangeRate //Factor multiplicativo
- fechaSincronizacion TIMESTAMP
- usuarioAuditoria int // FK -> Usuarios
- ultimaAuditoria TIMESTAMP
- activo boolean
- tasaDeCambioId

# ImpuestosVentaPorPais 
- impuestoVentaId serial auto-increment (PK)
- productoMarcaId int nullable // FK -> ProductosMarcasBlancas
- tipoProductoId int nullable // FK -> TiposProductos
- paisId int unique not null // FK -> Paises
- tipoImpuestoVentaId int unique not null // FK -> TiposImpuestosVenta
- porcentaje decimal(5,2) nullable 
- montoFijoLocal decimal(10,2) nullable 
- baseCalculoId int //FK -> BasesCalculoImpuestos 
- fechaVigenciaDesde date not null
- fechaVigenciaHasta date nullable 
- creadoEn TIMESTAMP
- usuarioAuditoria int // FK -> Usuarios
- ultimaAuditoria TIMESTAMP
- activo boolean default true

# BasesCalculoImpuestos
- BaseCalculoId serial auto-increment (PK)
- nombreBaseCalculoImpuesto varchar(50) unique not null
- descripcion varchar(255)
- creadoEn TIMESTAMP
- usuarioAuditoria int //FK -> Usuarios
- ultimaAuditoria TIMESTAMP
- activo boolean

# TiposImpuestosVenta 
- tipoImpuestoVentaId serial auto-increment (PK)
- nombreTipoImpuestoVenta varchar(50) unique not null
- descripcion varchar(255)
- aplicaPorUnidad boolean default false 
- paisId int // FK -> Paises
- creadoEn TIMESTAMP
- usuarioAuditoria int //FK -> Usuarios
- ultimaAuditoria TIMESTAMP
- activo boolean








# GeneracionSitiosWeb 
- generacionSitioWebId serial auto-increment (PK)
- tiendaId int not null//FK -> TiendasVirtualesGeneradas
- versionSitio int default 1 
- estadoGeneracionId not null //FK -> EstadosGeneracion
- fechaSolicitud TIMESTAMP not null
- fechaCompletado TIMESTAMP nullable
- tiempoProcesamientoSegundos int
- errorMensaje VARCHAR(200) nullable 
- creadoEn TIMESTAMP
- usuarioAuditoria int //FK -> Usuarios
- ultimaAuditoria TIMESTAMP
- activo boolean

# EstadosGeneracion
- estadoGeneracionId serial auto-increment (PK)
- nombreEstadoGeneracion varchar(50) unique not null
- descripcion varchar(255)
- creadoEn TIMESTAMP
- usuarioAuditoria int //FK -> Usuarios
- ultimaAuditoria TIMESTAMP
- activo boolean

# TiposDato
- tipoDatoId serial auto-increment (PK)
- nombreTipoDato varchar(50) unique not null
- descripcion varchar(255)
- creadoEn TIMESTAMP
- usuarioAuditoria int //FK -> Usuarios
- ultimaAuditoria TIMESTAMP
- activo boolean

# TiendasVirtualesGeneradas
- tiendaId serial auto-increment (PK)
- nombreTienda varchar(100) unique not null
- paisId int not null //FK -> Paises
- currencyId int //FK -> Currencies
- estadoTiendaId int not null //FK -> EstadosTienda
- enfoqueMarketingId int // FK -> EnfoquesMarketing
- fechaApertura date
- fechaCierre date nullable
- creadoEn TIMESTAMP
- usuarioAuditoria int //FK -> Usuarios
- ultimaAuditoria TIMESTAMP
- activo boolean default true

# EstadosTienda 
- estadoTiendaId serial auto-increment (PK)
- nombreEstadoTienda varchar(50) unique not null
- permiteVentas boolean default false
- descripcion varchar(255)
- creadoEn TIMESTAMP
- usuarioAuditoria int //FK -> Usuarios
- ultimaAuditoria TIMESTAMP
- activo boolean

# EnfoquesMarketing 
- enfoqueMarketingId serial auto-increment (PK)
- nombreEnfoqueMarketing varchar(50) unique not null
- descripcion varchar(255) 
- publicoObjetivoId int //FK -> PublicosObjetivo
- grupoConfiguracionId int nullable // FK -> GruposConfiguracion
- generadoPorIA boolean default true 
- activo boolean default true
- fechaCreacion TIMESTAMP
- creadoPor int //FK -> Usuarios
- ultimaAuditoria TIMESTAMP

# TiposParametro 
- tipoParametroId serial auto-increment (PK)
- nombreTipoParametro varchar(50) unique not null
- tipoDatoId int not null //FK -> TiposDato
- valorPorDefecto varchar(255) nullable
- creadoEn TIMESTAMP
- usuarioAuditoria int
- ultimaAuditoria TIMESTAMP
- activo boolean default true

# GruposConfiguracion 
- grupoConfigId serial auto-increment (PK)
- nombreGrupoConfiguracion varchar(50) unique not null
- descripcion varchar(255) nullable
- creadoEn TIMESTAMP
- usuarioAuditoria int
- ultimaAuditoria TIMESTAMP
- activo boolean default true

# ValoresConfiguracion 
- valorConfigId serial auto-increment (PK)
- grupoConfigId int not null // FK -> GruposConfiguracion
- tipoParametroId int not null // FK -> TiposParametro
- valorTexto varchar(500) nullable 
- valorNumerico decimal(10,2) nullable 
- valorBoolean boolean nullable 
- creadoEn TIMESTAMP
- usuarioAuditoria int
- ultimaAuditoria TIMESTAMP
- activo boolean default true







# TiposCaracteristica 
- tipoCaracteristicaId int unique not null // Id original de Etheria (PK lógica, sin auto-increment)
- nombreTipoCaracteristica varchar(50) unique not null
- descripcion varchar(150)
- activo boolean default true
- fechaSincronizacion TIMESTAMP
- usuarioAuditoria int // FK -> Usuarios
- ultimaAuditoria TIMESTAMP

# CaracteristicasProducto 
- caracteristicaId int unique not null// Id original de Etheria (PK lógica, sin auto-increment)
- productoId int unique not null // FK -> Productos
- tipoCaracteristicaId int unique not null // FK -> TiposCaracteristica
- valorBoolean boolean nullable 
- valorTexto varchar(255) nullable 
- valorNumerico decimal(10,2) nullable
- paisId int nullable // FK -> Paises
- vigenteDesde date default current_date
- vigenteHasta date nullable
- fechaSincronizacion TIMESTAMP
- usuarioAuditoria int // FK -> Usuarios
- activo boolean default true
- ultimaAuditoria TIMESTAMP


# Productos
- productoId int unique not null // Id original de Etheria (PK lógica, sin auto-increment)
- skuInterno varchar(20) unique not null
- nombreTecnico varchar(50) not null
- nombreComun varchar(50)
- marcaOriginalId int not null
- tipoProductoId int not null // FK -> TiposProducto
- unidadMedidaProductoId int not null // FK -> UnidadesMedidaProducto
- vidaUtilMeses int
- fechaSincronizacion TIMESTAMP
- usuarioAuditoria int
- ultimaAuditoria TIMESTAMP
- activo boolean default true

# TiposProducto
- tipoProductoId int unique not null // Id original de Etheria (PK lógica, sin auto-increment)
- nombreTipoProducto varchar(50) unique not null
- fechaSincronizacion TIMESTAMP
- usuarioAuditoria int //FK -> Usuarios
- ultimaAuditoria TIMESTAMP
- activo boolean default true

# UnidadesMedidaProducto
- UnidadMedidaProductoId int unique not null // Id original de Etheria (PK lógica, sin auto-increment)
- nombreUnidadMedidaProducto varchar(50) unique not null
- descripcion varchar(255)
- fechaSincronizacion TIMESTAMP
- usuarioAuditoria int //FK -> Usuarios
- ultimaAuditoria TIMESTAMP
- activo boolean default true

# MarcasOriginales 
- marcaOriginalId int unique not null // Id original de Etheria (PK lógica, sin auto-increment)
- nombreMarcaOriginal varchar(100) unique not null 
- paisId int //FK -> Paises
- fechaSincronizacion TIMESTAMP
- usuarioAuditoria int //FK -> Usuarios
- ultimaAuditoria TIMESTAMP
- activo boolean default true

# MarcasBlancas 
- marcaBlancaId serial auto-increment (PK)
- nombreMarcaBlanca varchar(100) unique not null
- tiendaId int not null //FK -> TiendasVirtualesGeneradas
- paisId int not null //FK -> Paises
- archivoId int //Fk -> Archivos
- publicoObjetivoId int //FK -> PublicosObjetivo
- fechaRegistroMarca date 
- creadoEn TIMESTAMP
- usuarioAuditoria int //FK > Usuarios
- ultimaAuditoria TIMESTAMP
- activo boolean default true

# PublicosObjetivo
- publicoObjetivoId serial auto-increment (PK)
- nombrePublicoObjetivo varchar(50) unique not null
- descripcion varchar(255)
- creadoEn TIMESTAMP
- usuarioAuditoria int //FK -> Usuarios
- ultimaAuditoria TIMESTAMP
- activo boolean

# ProductosMarcasBlancas
- productoMarcaId serial auto-increment (PK)
- productoId int unique not null //FK -> Productos
- tiendaId int unique not null //FK -> TiendasVirtualesGeneradas
- skuComercial varchar(50) unique not null
- nombreComercial varchar(100) not null
- marcaBlancaId int unique not null // FK -> MarcasBlancas
- stockDisponible decimal(12,2) default 0
- creadoEn TIMESTAMP
- usuarioAuditoria int //FK -> Usuarios
- ultimaAuditoria TIMESTAMP
- activo boolean default true

# PreciosVenta 
- precioVentaId serial auto-increment (PK)
- productoMarcaId int unique not null //FK -> ProductosMarcasBlancas
- currencyId int unique not null // FK -> Currencies
- precioVentaLocal decimal(14,2) not null 
- tasaDeCambioId int //FK -> TasasDeCambio
- tasaDeCambioAplicada decimal(12,6) not null 
- tipoPrecioId int unique not null // FK -> TiposPrecio
- margenPorcentaje decimal(5,2) 
- costoBase decimal(14,4) // Costo base en USD (viene de Etheria)
- fechaVigenciaDesde date not null
- fechaVigenciaHasta date nullable 
- aprobadoPor int nullable  //FK -> Usuarios 
- fechaAprobacion TIMESTAMP nullable
- creadoEn TIMESTAMP
- usuarioAuditoria int //FK -> Usuarios
- ultimaAuditoria TIMESTAMP
- activo boolean

# TiposPrecios
- tipoPrecioId serial auto-increment (PK)
- nombreTipoPrecio varchar(50) unique not null
- descripcion varchar(255)
- creadoEn TIMESTAMP
- usuarioAuditoria int //FK -> Usuarios
- ultimaAuditoria TIMESTAMP
- activo boolean

# ReglasAprobacionPrecios 
- reglaAprobacionId serial auto-increment (PK)
- tiendaId int nullable // FK -> TiendasVirtualesGeneradas 
- tipoProductoId int nullable // FK -> TiposProducto
- rolRequeridoId int not null //FK -> Roles 
- cambioMinimoPorcentaje decimal(5,2) nullable 
- cambioMaximoPorcentaje decimal(5,2) nullable 
- montoMinimoPrecio decimal(12,2) nullable 
- montoMaximoPrecio decimal(12,2) nullable 
- requiereDobleAprobacion boolean default false 
- tiempoMaximoAprobacionHoras int default 48 
- creadoEn TIMESTAMP
- usuarioAuditoria int //FK -> Usuarios
- ultimaAuditoria TIMESTAMP
- activo boolean

# Descuentos  
- descuentoId serial auto-increment (PK)
- codigoCupon varchar(50) unique not null
- descripcion varchar(255)
- tipoDescuentoId not null //FK -> TiposDescuentos
- valorDescuento decimal(10,2) not null
- montoMinimoCompra decimal(12,2) nullable 
- fechaVigenciaDesde date
- fechaVigenciaHasta date
- cantidadUsosMaximos int nullable
- cantidadUsosActuales int default 0
- esAcumulable boolean default false 
- prioridad int default 0 
- creadoEn TIMESTAMP
- usuarioAuditoria int //FK -> Usuarios
- ultimaAuditoria TIMESTAMP
- activo boolean

# DescuentosPorTienda 
- descuentoTiendaId serial auto-increment (PK)
- descuentoId int unique not null //FK -> Descuentos 
- tiendaId int unique not null //FK -> TiendasVirtualesGeneradas
- esExclusivo boolean default false
- fechaInicio TIMESTAMP
- fechaFin TIMESTAMP nullable
- creadoEn TIMESTAMP
- usuarioAuditoria int //FK -> Usuarios
- ultimaAuditoria TIMESTAMP
- activo boolean

# DescuentosPorProducto 
- descuentoProductoId serial auto-increment (PK)
- descuentoId int unique not null //FK -> Descuentos 
- productoMarcaId int unique not null //FK -> ProductosMarcaBlancas
- aplicaAVariantes boolean default true 
- fechaInicio TIMESTAMP
- fechaFin TIMESTAMP nullable
- creadoEn TIMESTAMP
- usuarioAuditoria int //FK -> Usuarios
- ultimaAuditoria TIMESTAMP
- activo boolean

# TiposDescuento
- tipoDescuentoId serial auto-increment (PK)
- nombreTipoDescuento varchar(50) unique not null
- descripcion varchar(255)
- creadoEn TIMESTAMP
- usuarioAuditoria int //FK -> Usuarios
- ultimaAuditoria TIMESTAMP
- activo boolean

# TiposRegulacion 
- tipoRegulacionId serial auto-increment (PK)
- nombreTipoRegulacion varchar(50) unique not null
- tipoDatoId not null //FK -> TiposDato
- descripcion varchar(255)
- creadoEn TIMESTAMP
- usuarioAuditoria int
- ultimaAuditoria TIMESTAMP
- activo boolean default true

# RegulacionesPorPais
- regulacionId serial auto-increment (PK)
- productoMarcaId int nullable // FK -> ProductoMarcaBlanca
- tipoProductoId int nullable // FK -> TiposProducto
- paisId int unique not null // FK -> Paises
- tipoRegulacionId int unique not null // FK -> TiposRegulacion
- valorBoolean boolean nullable 
- valorNumerico decimal(10,2) nullable 
- valorTexto varchar(255) nullable 
- autoridadCompetente varchar(100) nullable 
- fechaUltimaVerificacion date nullable
- vigenciaDesde date not null
- vigenciaHasta date nullable
- creadoEn TIMESTAMP
- usuarioAuditoria int
- ultimaAuditoria TIMESTAMP
- activo boolean default true


# ReseñasProductos 
- reseñaId serial auto-increment (PK)
- productoMarcaId int not null //FK -> ProductosMarcasBlancas
- clienteId int not null //FK -> Clientes
- ordenVentaId int nullable //FK -> OrdenesVenta 
- calificacion int not null 
- titulo varchar(100)
- comentario varchar(300)
- esCompraVerificada boolean default false
- esAprobada boolean default false
- fechaPublicacion TIMESTAMP
- creadoEn TIMESTAMP
- usuarioAuditoria int //FK -> Usuarios
- ultimaAuditoria TIMESTAMP
- activo boolean

# ResumenReseñasProductos
- resumenReseñaProductoId serial auto-increment (PK)
- productoMarcaId int not null // FK -> ProductoMarcaBlanca
- calificacionPromedio decimal(3,2) not null 
- totalReseñas int not null
- creadoEn TIMESTAMP
- usuarioAuditoria int
- ultimaAuditoria TIMESTAMP
- activo boolean default true


# DistribucionReseñasProductos
- distribucionId serial auto-increment (PK)
- resumenReseñaProductoId int not null // FK -> ResumenReseñasProductos
- valorCalificacion int not null 
- cantidad int not null default 0 
- creadoEn TIMESTAMP
- usuarioAuditoria int
- ultimaAuditoria TIMESTAMP
- activo boolean default true


# TransformacionesProductos 
- transformacionId serial auto-increment (PK)
- loteBulkId int not null //FK lógica a LotesBulks de Etheria
- productoMarcaId int not null // FK -> ProductosMarcasBlancas
- productoBaseId int not null // FK lógica a Productos de Etheria
- ubicacionId int not null // FK -> Ubicaciones
- cantidadTransformada decimal(12,2) not null 
- cantidadMerma decimal(12,2) default 0 
- fechaTransformacion timestamp not null
- responsableTransformacionId int // FK -> Usuarios
- ubicacionTransformacionId int // FK -> Ubicaciones
- estadoTransformacionId int //FK -> EstadosTransformacion
- creadoEn TIMESTAMP
- usuarioAuditoria int // FK -> Usuarios
- ultimaAuditoria TIMESTAMP
- activo boolean default true

# EstadosTransformacion
- estadoTransformacionId serial auto-increment (PK)
- nombreEstadoTransformacion varchar(50) not null 
- creadoEn TIMESTAMP 
- usuarioAuditoria int //FK -> Usuarios
- ultimaAuditoria TIMESTAMP
- activo boolean default true









# Clientes // Independiente para no atarlo a todas las tiendas en general
- clienteId serial auto-increment (PK)
- tiendaId int not null //FK -> TiendasVirtualesGeneradas
- email varchar(100) unique not null
- nombreCliente varchar(50) not null
- apellidoCliente1 varchar(40) not null
- apellidoCliente2 varchar(40) not null
- paisId int //FK -> Paises
- telefono varchar(20)
- fechaRegistro TIMESTAMP
- ultimoAcceso TIMESTAMP
- creadoEn TIMESTAMP
- usuarioAuditoria int //FK -> Usuarios
- ultimaAuditoria TIMESTAMP
- activo boolean

# TiposContactoCliente 
- tipoContactoClienteId serial auto-increment (PK)
- nombreTipoContactoCliente varchar(50) unique not null
- formatoValidacion varchar(100)
- creadoEn TIMESTAMP
- usuarioAuditoria int //FK -> Usuarios
- ultimaAuditoria TIMESTAMP
- activo boolean

# ContactosClientes
- contactoClienteId serial auto-increment (PK)
- clienteId int not null //FK -> Clientes
- tipoContactoClienteId int not null //FK -> TiposContactosClientes
- valor varchar(150) not null
- esPrincipal boolean default false
- verificado boolean default false
- creadoEn TIMESTAMP
- usuarioAuditoria int //FK -> Usuarios
- ultimaAuditoria TIMESTAMP
- activo boolean

# InteraccionesClientes
- interaccionId serial auto-increment (PK)
- clienteId int not null //FK -> Clientes
- tiendaId int not null //FK -> TiendasVirtualesGeneradas
- tipoInteraccionId int not null //FK -> TiposInteraccionesClientes
- referenciaId bigint nullable // ID de la orden/ticket relacionado
- descripcion varchar(255)
- fechaInteraccion TIMESTAMP
- creadoEn TIMESTAMP
- usuarioAuditoria int //FK -> Usuarios
- ultimaAuditoria TIMESTAMP
- activo boolean

# TiposInteraccionesClientes
- tipoInteraccionId serial auto-increment (PK)
- nombreTipoInteraccionCliente varchar(50) unique not null
- descripcion varchar(255)
- creadoEn TIMESTAMP
- usuarioAuditoria int //FK -> Usuarios
- ultimaAuditoria TIMESTAMP
- activo boolean

# OrdenesVenta
- ordenVentaId serial auto-increment (PK)
- tiendaId int not null // FK -> TiendasVirtualesGeneradas
- clienteId int not null // FK -> Clientes
- fechaOrden TIMESTAMP
- numeroPedido varchar(50) unique not null
- estadoOrdenVentaId int not null // FK -> EstadosOrdenesVenta
- montoSubtotal decimal(14,2) not null 
- montoEnvio decimal(14,2) default 0 
- montoTotalLocal decimal(14,2) not null 
- currencyId int not null // FK -> Currencies
- tasaDeCambioId int // FK -> TasasDeCambio
- tasaDeCambioAplicada decimal(12,6) not null 
- montoConvertidoBase decimal(14,2) not null 
- paisId int // FK -> Paises.paisId
- metodoPagoId int nullable // FK -> MetodosPago
- montoPagado decimal(14,2) nullable
- monedaPagoId int nullable // FK -> Currencies
- fechaPago TIMESTAMP nullable
- estadoPagoId int nullable // FK -> EstadosPago
- intentoPagoCount int default 0
- creadoEn TIMESTAMP 
- usuarioAuditoria int // FK -> Usuarios
- ultimaAuditoria TIMESTAMP
- activo boolean default true

# EstadosOrdenesVenta 
- estadoOrdenVentaId serial auto-increment (PK)
- nombreEstadoOrdenVenta varchar(50) unique not null
- descripcion varchar(255)
- creadoEn TIMESTAMP
- usuarioAuditoria int //FK -> Usuarios
- ultimaAuditoria TIMESTAMP
- activo boolean

# DetallesOrdenesVenta
- detalleId serial auto-increment (PK)
- ordenVentaId int not null //FK -> OrdenesVenta
- productoMarcaId int not null //FK -> ProductosMarcasBlancas
- cantidad int not null
- currencyId int not null // FK -> Currencies
- precioUnitarioLocal decimal(10,2) not null
- subtotalLocal decimal(12,2) not null
- creadoEn TIMESTAMP
- usuarioAuditoria int //FK -> Usuarios
- ultimaAuditoria TIMESTAMP
- activo boolean

# MetodosPago 
- metodoPagoId serial auto-increment (PK)
- nombreMetodoPago varchar(50) unique not null
- requiereValidacionAdicional boolean default false
- costoTransaccionPorcentaje decimal(5,2) default 0
- costoTransaccionFijo decimal(10,2) default 0
- tiempoConfirmacionMinutos int
- creadoEn TIMESTAMP
- usuarioAuditoria int //FK -> Usuarios
- ultimaAuditoria TIMESTAMP
- activo boolean

# EstadosPago
- estadoPagoId serial auto-increment (PK)
- nombreEstadoPago varchar(50) unique not null
- descripcion varchar(255)
- creadoEn TIMESTAMP
- usuarioAuditoria int //FK -> Usuarios
- ultimaAuditoria TIMESTAMP
- activo boolean

# ImpuestosOrdenesVenta 
- ordenImpuestoId serial auto-increment (PK)
- ordenVentaId int unique not null // FK -> OrdenesVenta
- impuestoVentaId int unique not null // FK -> ImpuestosVentaPorPais
- montoImpuestoLocal decimal(10,2) not null 
- baseCalculoId int not null //FK -> BasesCalculoImpuestos
- creadoEn TIMESTAMP
- usuarioAuditoria int //FK -> Usuarios
- ultimaAuditoria TIMESTAMP
- activo boolean

# DescuentosOrdenVenta
- ordenDescuentoId serial auto-increment (PK)
- ordenVentaId int unique not null// FK -> OrdenesVenta
- descuentoId int unique not null // FK -> Descuentos
- montoDescuentoLocal decimal(10,2) not null 
- codigoCuponUsado varchar(50) nullable 
- creadoEn TIMESTAMP
- usuarioAuditoria int //FK -> Usuarios
- ultimaAuditoria TIMESTAMP
- activo boolean








# SolicitudesRetiro 
- solicitudRetiroId serial auto-increment (PK)
- productoBaseReferencia int not null 
- loteBulkReferencia int not null 
- cantidadSolicitada decimal(12,2) not null
- productoMarcaId int // FK -> ProductosMarcasBlancas
- fechaSolicitud TIMESTAMP not null
- fechaRetiroProgramado date nullable
- creadoEn TIMESTAMP
- usuarioAuditoria int //FK -> Usuarios
- ultimaAuditoria TIMESTAMP
- activo boolean

# Envios
- envioId serial auto-increment (PK)
- ordenVentaId int not null //FK -> OrdenesVenta
- courierId int not null //FK -> Couriers
- trackingNumber varchar(100) unique not null
- fechaDespacho TIMESTAMP
- fechaEntregaEstimada date
- fechaEntregaReal TIMESTAMP
- costoCourierLocal decimal(10,2)
- currencyId int not null //FK -> Currencies
- estadoEnvioId int not null //FK -> EstadosEnvio
- creadoEn TIMESTAMP
- usuarioAuditoria int //FK -> Usuarios
- ultimaAuditoria TIMESTAMP
- activo boolean default true

# EstadosEnvio 
- estadoEnvioId serial auto-increment (PK)
- nombreEstadoEnvio varchar(50) unique not null
- descripcion varchar(255)
- creadoEn TIMESTAMP
- usuarioAuditoria int //FK -> Usuarios
- ultimaAuditoria TIMESTAMP
- activo boolean







# Archivos
- archivoId serial auto-increment (PK)
- checksum varchar(64)
- tamaño INTEGER
- duracion FLOAT
- deleted boolean DEFAULT FALSE
- rutaAlmacenamiento varchar(500) not null
- tipoArchivo int //FK -> TiposArchivos
- nombreOriginalArchivo varchar(255) unique not null
- hashContenido varchar(64)
- creadoEn TIMESTAMP
- usuarioAuditoria int //FK -> Usuarios
- ultimaAuditoria TIMESTAMP
- activo boolean

# TiposArchivos 
- tipoArchivoId serial auto-increment (PK)
- nombreTipoArchivo varchar(50) unique not null
- extension varchar(100) not null 
- tamanioMaximoMB decimal(6,2) not null 
- dimensionesMinimasPx varchar(20) nullable 
- dimensionesMaximasPx varchar(20) nullable 
- requiereCompresion boolean default false 
- creadoEn TIMESTAMP
- usuarioAuditoria int //FK -> Usuarios
- ultimaAuditoria TIMESTAMP
- activo boolean

# TiposEvento 
- tipoEventoId serial auto-increment (PK)
- nombreEvento varchar(50) unique not null 
- descripcion varchar(255) not null
- creadoEn TIMESTAMP
- usuarioAuditoria int //FK -> Usuarios
- ultimaAuditoria TIMESTAMP
- activo boolean

# Severidades 
- severidadId serial auto-increment (PK)
- valorSeveridad int not null 
- nombreSeveridad varchar(50) not null
- creadoEn TIMESTAMP
- usuarioAuditoria int //FK -> Usuarios
- ultimaAuditoria TIMESTAMP
- activo boolean

# Objetos 
- objetoId serial auto-increment (PK)
- nombreObjeto varchar(50) unique not null 
- creadoEn TIMESTAMP
- usuarioAuditoria int //FK -> Usuarios
- ultimaAuditoria TIMESTAMP
- activo boolean

# Logs 
- logId serial auto-increment (PK)
- tipoEventoId int not null //FK -> TiposEvento 
- severidadId int not null default 2 //FK -> Severidades 
- descripcion varchar(255) not null 
- sourceId not null //FK -> Sources 
- userAgent text // Navegador o cliente HTTP si aplica
- computadora varchar(100) 
- usuarioId int //FK -> Usuarios
- referenciaId1 bigint 
- referenciaId2 bigint 
- descripcionReferencia1 varchar(255)
- descripcionReferencia2 varchar(255)
- objetoId1 int //FK -> Objetos
- objetoId2 int //FK -> Objetos
- checkSum varchar(64) // SHA256 de: tipoEventoId+referenciaId1+objetoId1+fecha+datosNuevos 
- creadoEn TIMESTAMP
- activo boolean

# Sources 
- sourceId serial auto-increment (PK)
- nombreSource varchar(50) unique not null
- creadoEn TIMESTAMP
- usuarioAuditoria int //FK -> Usuarios
- ultimaAuditoria TIMESTAMP
- activo boolean default true




# Usuarios
- usuarioId serial auto-increment (PK)
- nombreUsuario varchar(50) not null
- apellido1 varchar(40) not null
- apellido2 varchar(40) not null
- email varchar(255) unique not null
- contraseña VARBINARY(255)
- fechaNacimiento date
- creadoEn TIMESTAMP
- usuarioAuditoria int //FK -> Usuarios
- ultimaAuditoria TIMESTAMP
- activo boolean

# Roles
- rolId serial auto-increment (PK)
- nombreRol varchar(50) unique not null
- descripcion varchar(255)
- nivelAcceso int
- creadoEn TIMESTAMP
- usuarioAuditoria int //FK -> Usuarios
- ultimaAuditoria TIMESTAMP
- activo boolean default true

# Permiso
- permisoId serial auto-increment (PK)
- nombrePermiso varchar(50) unique not null
- descripcion varchar(255)
- creadoEn TIMESTAMP
- usuarioAuditoria int //FK -> Usuarios
- ultimaAuditoria TIMESTAMP
- activo boolean

# RolPermiso
- rolId int unique not null  //FK -> Roles
- permisoId int unique not null //Fk -> Permisos
- creadoEn TIMESTAMP
- usuarioAuditoria int //FK -> Usuarios
- ultimaAuditoria TIMESTAMP
- activo boolean

# UsuarioRol
- usuarioId int unique not null //FK -> Usuarios
- rolId int unique not null //FK -> Roles
- asignadoPor int
- asignadoEn TIMESTAMP
- fechaExpiracion TIMESTAMP
- creadoEn TIMESTAMP
- usuarioAuditoria int //FK -> Usuarios
- ultimaAuditoria TIMESTAMP
- activo boolean





# ConfiguracionSistema // Configuraciones globales de Dynamic
- configuracionSistemaId serial auto-increment (PK)
- clave varchar(50) unique not null
- valorText varchar(500)
- valorInt int
- valorDecimal decimal(18,6)
- valorBoolean boolean
- descripcion varchar(200)
- esEditableUI boolean default true
- ultimoCambioPor int
- ultimoCambioEn TIMESTAMP
- activo boolean default true

# ConfiguracionPorTienda // Configuraciones específicas por tienda
- configuracionTiendaId serial auto-increment (PK)
- tiendaId int not null //FK -> TiendasVirtualesGeneradas
- clave varchar(50) not null
- valorText varchar(500)
- creadoEn TIMESTAMP
- usuarioAuditoria int //FK -> Usuarios
- ultimaAuditoria TIMESTAMP
- activo boolean