> **Nombre:** Dynamic Brands db
> **Motor de base de datos:** MySQL
> **Versión:** 0.2 
> **Fecha:** 4-04-2026 
> **Autor:** Gerald Hernández Gamboa  

## Tables 

# Ciudades
- ciudadId serial auto-increment (PK)
- nombre varchar(50)
- provinciaId //FK -> Provincias
- codigoPostal varchar(20)
- esHubLogistico boolean default false
- creadoEn TIMESTAMP
- usuarioAuditoria int //FK -> Usuarios
- ultimaAuditoria TIMESTAMP
- activo boolean

# Provincias
- provinciaId serial auto-increment (PK)
- nombre varchar(50)
- paisId //FK -> Paises
- creadoEn TIMESTAMP
- usuarioAuditoriaint //FK -> Usuarios
- ultimaAuditoria TIMESTAMP
- activo boolean

# Paises
- paisId serial auto-increment (PK)
- nombre varchar(50) not null
- codigoIso char(3) unique 
- requierePermisoSanitario boolean default true
- creadoEn TIMESTAMP
- usuarioAuditoria int //FK -> Usuarios
- ultimaAuditoria TIMESTAMP
- activo boolean default true

# Currencies
- currencyId serial auto-increment (PK)
- codigoIso char(3) unique not null
- currencySymbol char
- nombre varchar(50)
- activo boolean
- creadoEn TIMESTAMP
- usuarioAuditoria int //FK -> Usuarios
- ultimaAuditoria TIMESTAMP








# GeneracionSitiosWeb 
- generacionSitioWebId serial auto-increment (PK)
- tiendaId int not null //FK -> TiendaVirtual 
- versionSitio int default 1 
- estadoGeneracionId //FK -> EstadosGeneracion
- fechaSolicitud TIMESTAMP not null
- fechaCompletado TIMESTAMP nullable
- tiempoProcesamientoSegundos int
- errorMensaje VARCHAR(200) nullable 
- creadoEn TIMESTAMP
- usuarioAuditoria int //FK -> Usuarios
- activo boolean default true

# EstadosGeneracion
- estadoGeneracionId serial auto-increment (PK)
- nombre varchar(50) not null
- descripcion varchar(150)
- creadoEn TIMESTAMP
- usuarioAuditoria int //FK -> Usuarios
- activo boolean default true

# ParametrosIA 
- parametroIAId serial auto-increment (PK)
- generacionId int not null //FK -> GeneracionSitioWeb
- claveParametro varchar(50) not null 
- valorParametro varchar(200) not null 
- tipoDatoId not null //Fk -> TiposDatos
- creadoEn TIMESTAMP

# TiposDatos
- tipoDatoId serial auto-increment (PK)
- nombre varchar(50) not null
- descripcion varchar(150)
- creadoEn TIMESTAMP
- usuarioAuditoria int //FK -> Usuarios
- activo boolean default true

# TiendasVirtualesGeneradas
- tiendaId serial auto-increment (PK)
- nombreTienda varchar(100) not null
- paisObjetivoId int //FK -> Paises
- monedaLocalId int //FK -> Currencies
- estadoId int //FK -> EstadosTienda
- fechaApertura date
- fechaCierre date
- creadoEn TIEMSTAMP
- usuarioAuditoria int //FK -> Usuarios
- ultimaAuditoria TIMESTAMP
- activo boolean default true

# EstadosTienda 
- estadoTiendaId serial auto-increment (PK)
- nombre varchar(50) not null
- codigo varchar(20) unique not null
- permiteVentas boolean default false
- descripcion varchar(150)
- creadoEn TIMESTAMP
- usuarioAuditoria int //FK -> Usuarios
- activo boolean default true

# EnfoquesMarketing 
- enfoqueMarketingId serial auto-increment (PK)
- nombre varchar(50) not null 
- descripcion varchar(255) 
- publicoObjetivo varchar(100) 
- generadoPorIA boolean default true 
- tonoComunicacion varchar(50) 
- tipografiaSugerida varchar(100) // Fuentes recomendadas
- activo boolean default true
- fechaCreacion TIMESTAMP
- creadoPor int //FK -> Usuarios
- activo boolean default true





# Productos
- productoId serial auto-increment (PK)
- skuInterno varchar(20) unique not null //Código único del Holding
- nombreTecnico varchar(50) not null //Nombre científico
- nombreComun varchar(50) 
- marcaOriginalId int not null //FK -> MarcasOriginales 
- tipoProductoId int //FK -> TiposProducto
- unidadMedidaProductoId //FK -> UnidadesMedidaProducto
- requierePermisoSanitario boolean default true
- aptoParaIngesta boolean default false
- aptoParaPiel boolean default false
- vidaUtilMeses int
- creadoEn TIMESTAMP 
- usuarioAuditoria int //FK -> Usuarios
- ultimaAuditoria TIMESTAMP
- activo boolean default true

# TiposProducto
- tipoProductoId serial auto-increment (PK)
- nombre varchar(50) not null 
- requiereControlTemperatura boolean default false
- creadoEn TIMESTAMP 
- usuarioAuditoria int //FK -> Usuarios
- ultimaAuditoria TIMESTAMP
- activo boolean default true

# UnidadesMedidaProducto
- UnidadMedidaProductoId serial auto-increment (PK)
- nombre varchar(50) not null 
- descripcion varchar(100)
- creadoEn TIMESTAMP 
- usuarioAuditoria int //FK -> Usuarios
- ultimaAuditoria TIMESTAMP
- activo boolean default true

# MarcasOriginales 
- marcaOriginalId serial auto-increment (PK)
- nombreMarca varchar(100) not null 
- paisOrigenId int //FK -> Paises
- creadoEn TIMESTAMP
- usuarioAuditoria int //FK -> Usuarios
- ultimaAuditoria TIMESTAMP
- activo boolean default true

# MarcasBlancas 
- marcaBlancaId serial auto-increment (PK)
- nombreMarca varchar(100) not null 
- tiendaId int //FK -> TiendaVirtual
- productoRefId int //FK -> Productos
- paisMercadoId int //FK -> Paises
- logoId int //Fk -> Archivos
- publicoObjetivoId //FK -> PublicosObjetivo
- esMarcaPrincipal boolean default false // ¿Es la marca principal de esta tienda?
- fechaRegistroMarca date 
- creadoEn TIMESTAMP
- usuarioAuditoria int //FK > Usuarios
- ultimaAuditoria TIMESTAMP
- activo boolean default true

# PublicosObjetivo
- publicoObjetivoId serial auto-increment (PK)
- nombre varchar(50) not null
- descripcion varchar(150)
- creadoEn TIMESTAMP
- usuarioAuditoria int //FK -> Usuarios
- activo boolean default true

# ProductoMarcaBlanca
- productoMarcaId serial auto-increment (PK)
- productoBaseId int not null //FK -> Productos
- tiendaId int //FK -> TiendaVirtual
- skuComercial varchar(50) unique not null
- nombreComercial varchar(100) not null
- precioVentaLocal decimal(10,2) not null
- currencyId not null //FK -> Currencies
- stockDisponible decimal(12,2) default 0
- creadoEn TIMESTAMP
- usuarioAuditoria int //FK -> Usuarios
- ultimaAuditoria TIMESTAMP
- activo boolean default true

# PreciosVenta 
- precioVentaId serial auto-increment (PK)
- productoMarcaId int not null //FK -> ProductoMarca 
- precioVentaLocal decimal(12,2) not null
- currencyId not null //FK -> Currencies
- tipoPrecioId not null //FK -> TiposPrecio
- margenPorcentaje decimal(5,2) 
- costoBaseUsd decimal(10,4) 
- fechaVigenciaDesde date not null
- fechaVigenciaHasta date nullable 
- aprobadoPor int nullable  //FK -> Usuarios 
- fechaAprobacion TIMESTAMP nullable
- esPrecioActivo boolean default true
- creadoEn TIMESTAMP
- usuarioAuditoria int
- activo boolean default true

# TiposPrecios
- tipoPrecioId serial auto-increment (PK)
- nombre varchar(50) not null
- descripcion varchar(150)
- creadoEn TIMESTAMP
- usuarioAuditoria int //FK -> Usuarios
- activo boolean default true

# HistorialPrecios 
- historialPrecioId serial auto-increment (PK)
- precioVentaId int not null //FK -> PreciosVenta 
- precioAnterior decimal(12,2)
- precioNuevo decimal(12,2)
- fechaCambio TIMESTAMP
- usuarioCambioId int //FK -> Usuarios
- motivoCambio varchar(150)
- aprobadoPor int //FK -> Usuarios 
- creadoEn TIMESTAMP

# Descuentos  
- descuentoId serial auto-increment (PK)
- codigoCupon varchar(50) unique
- descripcion varchar(150)
- tipoDescuentoId not null //FK -> TiposDescuentos
- valorDescuento decimal(10,2) not null
- montoMinimoCompra decimal(12,2) nullable 
- fechaVigenciaDesde date
- fechaVigenciaHasta date
- cantidadUsosMaximos int nullable
- cantidadUsosActuales int default 0
- esAcumulable boolean default false 
- prioridad int default 0 
- activo boolean default true

# DescuentosPorTienda 
- descuentoTiendaId serial auto-increment (PK)
- descuentoId int not null //FK -> Descuentos 
- tiendaId int not null //FK -> TiendaVirtual 
- esExclusivo boolean default false
- fechaInicio TIMESTAMP
- fechaFin TIMESTAMP nullable
- creadoEn TIMESTAMP
- activo boolean default true


# DescuentosPorProducto 
- descuentoProductoId serial auto-increment (PK)
- descuentoId int not null //FK -> Descuentos 
- productoMarcaId int not null //FK -> ProductoMarca 
- aplicaAVariantes boolean default true 
- fechaInicio TIMESTAMP
- fechaFin TIMESTAMP nullable
- creadoEn TIMESTAMP
- activo boolean default true

# TiposDescuento
- tipoDescuentoId serial auto-increment (PK)
- nombre varchar(50) not null
- descripcion varchar(150)
- creadoEn TIMESTAMP
- usuarioAuditoria int //FK -> Usuarios
- activo boolean default true

# ReseñasProductos 
- reseñaId serial auto-increment (PK)
- productoMarcaId int not null //FK -> ProductoMarca 
- clienteId int not null //FK -> Cliente
- ordenVentaId int nullable //FK -> OrdenVenta 
- calificacion int not null // 1-5 estrellas
- titulo varchar(100)
- comentario text
- esCompraVerificada boolean default false
- esAprobada boolean default false
- fechaPublicacion TIMESTAMP
- creadoEn TIMESTAMP
- activo boolean default true








# Cliente // Independiente para no atarlo a todas las tiendas en general
- clienteId serial auto-increment (PK)
- tiendaId int //FK -> TiendaVirtual
- email varchar(100) not null
- nombre varchar(50)
- apellido1 varchar(40)
- apellido2 varchar(40)
- paisResidenciaId int //FK -> Paises
- telefono varchar(20)
- fechaRegistro TIMESTAMP
- ultimoAcceso TIMESTAMP
- activo boolean default true

# TiposContactoCliente 
- tipoContactoClienteId serial auto-increment (PK)
- nombre varchar(50) not null
- codigo varchar(20) unique not null
- formatoValidacion varchar(100)
- activo boolean default true

# ContactoCliente 
- contactoClienteId serial auto-increment (PK)
- clienteId int //FK -> Cliente
- tipoContactoClienteId int //FK -> TiposContactoCliente
- valor varchar(150) not null
- esPrincipal boolean default false
- verificado boolean default false
- creadoEn TIMESTAMP
- activo boolean default true

# OrdenVenta //Cambiar campos a Ids
- ordenVentaId serial auto-increment (PK)
- tiendaId int not null//FK -> TiendaVirtual 
- clienteId int not null //FK -> Clientes 
- fechaOrden TIMESTAMP
- numeroPedido varchar(50) unique not null
- estadoOrdenId int not null //FK -> EstadosOrdenVenta 
- montoSubtotal decimal(12,2) not null
- impuestoVentaMonto decimal(10,2) default 0
- descuentoMonto decimal(10,2) default 0
- envioMonto decimal(10,2) default 0
- montoTotalLocal decimal(12,2) not null
- currencyId not null //FK -> Currencies
- tasaCambioAplicada decimal(12,6) not null
- montoEquivalenteUsd decimal(12,2) not null
- paisEntrega char(2) not null
- metodoPagoId int nullable //FK -> MetodosPago 
- montoPagado decimal(12,2) nullable
- monedaPago char(3) nullable
- fechaPago timestamp nullable
- estadoPagoId int nullable //FK -> EstadosPago 
- intentoPagoCount int default 0 
- creadoEn timestamp default current_timestamp
- usuarioAuditoria int //FK -> Usuarios
- ultimaAuditoria timestamp
- activo boolean default true


# EstadosOrdenVenta 
- estadoOrdenVentaId serial auto-increment (PK)
- nombre varchar(50) not null
- descripcion varchar(150)
- creadoEn TIMESTAMP
- usuarioAuditoria int //FK -> Usuarios
- activo boolean default true

# DetalleOrdenVenta
- detalleId serial auto-increment (PK)
- ordenVentaId int //FK -> OrdenVenta
- productoMarcaId int //FK -> ProductoMarca
- cantidad int not null
- precioUnitarioLocal decimal(10,2) not null
- subtotalLocal decimal(12,2) not null
- creadoEn TIMESTAMP

# MetodosPago 
- metodoPagoId serial auto-increment (PK)
- nombre varchar(50) not null 
- codigo varchar(20) unique not null
- requiereValidacionAdicional boolean default false
- costoTransaccionPorcentaje decimal(5,2) default 0
- costoTransaccionFijo decimal(10,2) default 0
- tiempoConfirmacionMinutos int
- activo boolean default true

# EstadosPago
- estadoPagoId serial auto-increment (PK)
- nombre varchar(50) not null
- codigo varchar(20) unique not null
- descripcion varchar(150)
- activo boolean default true

# RegulacionesVentaPorPais
- regulacionVentaId serial auto-increment (PK)
- productoMarcaId int //FK -> ProductoMarca
- paisId int //FK -> Paises
- ivaPorcentaje decimal(5,2)
- impuestosAdicionales decimal(10,2) default 0
- vigenciaDesde date
- vigenciaHasta date
- creadoEn TIMESTAMP
- usuarioAuditoria int //FK -> Usuarios
- activo boolean default true





# TransformacionProductoLocal 
- transformacionLocalId serial auto-increment (PK)
- productoMarcaId int //FK -> ProductoMarca
- cantidadRecibida decimal(12,2) not null
- fechaRecepcion TIMESTAMP
- responsableRecepcionId //FK -> Usuarios
- costoUnitarioUsdReferencia decimal(10,4)
- activo boolean default true

# Envio
- envioId serial auto-increment (PK)
- ordenVentaId int //FK -> OrdenVenta
- courierId int //FK -> Couriers
- trackingNumber varchar(100) unique
- fechaDespacho TIMESTAMP
- fechaEntregaEstimada date
- fechaEntregaReal TIMESTAMP
- costoCourierLocal decimal(10,2)
- currencyId not null //FK -> Currencies
- estadoEnvioId int //FK -> EstadosEnvio
- creadoEn TIMESTAMP
- usuarioAuditoria int //FK -> Usuarios
- ultimaAuditoria TIMESTAMP
- activo boolean default true

# EstadosEnvio 
- estadoEnvioId serial auto-increment (PK)
- nombre varchar(50) not null
- descripcion varchar(150)
- creadoEn TIMESTAMP
- usuarioAuditoria int //FK -> Usuarios
- activo boolean default true







# Archivos
- archivoId serial auto-increment (PK)
- checksum varchar(64)
- tamaño INTEGER
- duracion FLOAT
- deleted boolean DEFAULT FALSE
- rutaAlmacenamiento varchar(500)
- tipoArchivo //FK -> TiposArchivos
- nombreOriginal varchar(255)
- hashContenido varchar(64)
- creadoEn TIMESTAMP
- usuarioAuditoria (FK)

# TiposArchivos 
- tipoArchivoId serial auto-increment (PK)
- nombre varchar(50) not null 
- creadoEn TIMESTAMP 
- usuarioAuditoria int //FK -> Usuarios
- ultimaAuditoria TIMESTAMP
- activo boolean default true

# TiposEvento 
- tipoEventoId serial auto-increment (PK)
- codigoEvento varchar(30) unique not null 
- descripcion varchar(100) not null
- requierePreguardado boolean default true 
- activo boolean default true

# Severidades 
- severidadId serial auto-increment (PK)
- valorSeveridad int not null 
- nombre varchar(20) not null
- activo boolean default true

# Objetos 
- objetoId serial auto-increment (PK)
- nombreObjeto varchar(50) unique not null 
- activo boolean default true

# Logs 
- logId serial auto-increment (PK)
- tipoEventoId int not null //FK -> TiposEvento 
- severidadId int not null default 2 //FK -> Severidades 
- descripcion varchar(100) not null 
- sourceId not null //FK -> Sources 
- userAgent text // Navegador o cliente HTTP si aplica
- computadora varchar(100) 
- usuarioId int //FK -> Usuarios
- referenciaId1 bigint 
- referenciaId2 bigint 
- descripcionReferencia1 varchar(200)
- descripcionReferencia2 varchar(200)
- objetoId1 int //FK -> Objetos
- objetoId2 int //FK -> Objetos
- datosAnteriores jsonb // Estado ANTES del cambio 
- datosNuevos jsonb // Estado DESPUÉS del cambio 
- checkSum varchar(64) // SHA256 de: tipoEventoId+referenciaId1+objetoId1+fecha+datosNuevos 
- creadoEn TIMESTAMP
- activo boolean default true

# Sources 
- sourceId serial auto-increment (PK)
- nombre varchar(50)
- creadoEn TIMESTAMP
- usuarioAuditoria int //FK -> Usuarios
- ultimaAuditoria TIMESTAMP
- activo boolean default true




# Usuarios
- usuarioId serial auto-increment (PK)
- nombre varchar(50)
- apellido1 varchar(40)
- apellido2 varchar(40)
- email varchar(255)
- contraseña VARBINARY(255)
- fechaNacimiento date
- creadoEn TIMESTAMP
- activo boolean

# Rol
- rolId serial auto-increment (PK)
- nombre varchar(50)
- codigo varchar(30) unique not null
- descripcion varchar(255)
- nivelAcceso int
- creadoEn TIMESTAMP
- usuarioAuditoria int //FK -> Usuarios
- ultimaAuditoria TIMESTAMP
- activo boolean default true

# Permiso
- permisoId serial auto-increment (PK)
- nombre varchar(50)
- codigo varchar(50) unique not null
- descripcion varchar(255)
- modulo varchar(30)
- accion varchar(20)
- creadoEn TIMESTAMP
- usuarioAuditoria int //FK -> Usuarios
- activo boolean default true

# RolPermiso
- rolId (FK)
- permisoId (FK)
- creadoEn TIMESTAMP
- activo boolean default true

# UsuarioRol
- usuarioId (FK)
- rolId (FK)
- asignadoPor int
- asignadoEn TIMESTAMP
- fechaExpiracion TIMESTAMP
- activo boolean default true





# ConfiguracionSistema // Configuraciones globales de Dynamic
- configuracionSistemaId serial auto-increment (PK)
- clave varchar(50) unique not null
- valor_text varchar(500)
- valor_int int
- valor_decimal decimal(18,6)
- valor_boolean boolean
- categoria varchar(30)
- descripcion varchar(200)
- esEditableUI boolean default true
- ultimoCambioPor int
- ultimoCambioEn TIMESTAMP
- activo boolean default true

# ConfiguracionPorTienda // Configuraciones específicas por tienda
- configuracionTiendaId serial auto-increment (PK)
- tiendaId int //FK -> TiendaVirtual
- clave varchar(50) not null
- valor_text varchar(500)
- valor_json json
- categoria varchar(30)
- creadoEn TIMESTAMP
- activo boolean default true