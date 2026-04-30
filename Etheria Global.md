> **Nombre:** Etheria Global db
> **Motor de base de datos:** Postgres 
> **Versión:** 0.8
> **Fecha:** 7-04-2026 
> **Autor:** Gerald Hernández Gamboa  

## Tables 

# Ciudades
- ciudadId serial auto-increment (PK)
- nombreCiudad varchar(50) unique not null
- provinciaId int not null //FK -> Provincias
- creadoEn TIMESTAMP
- usuarioAuditoria int //FK -> Usuarios
- ultimaAuditoria TIMESTAMP
- activo boolean

# Provincias
- provinciaId serial auto-increment (PK)
- nombreProvincia varchar(50) unique not null
- paisId int not null //FK -> Paises
- creadoEn TIMESTAMP
- usuarioAuditoria int //FK -> Usuarios
- ultimaAuditoria TIMESTAMP
- activo boolean

# Paises
- paisId serial auto-increment (PK)
- nombrePais varchar(50) unique not null
- codigoIso char(3) unique 
- creadoEn TIMESTAMP
- usuarioAuditoria int //FK -> Usuarios
- ultimaAuditoria TIMESTAMP
- activo boolean default true

# ImpuestosPorPais 
- impuestoId serial auto-increment (PK)
- productoId int unique not null //FK -> Productos
- paisId int unique not null //FK -> Paises
- tipoImpuestoId int unique not null//FK -> TiposImpuesto
- descripcion varchar(250) nullable
- porcentaje decimal(5,2) nullable 
- montoFijo decimal(14,2) nullable
- vigenciaDesde date
- vigenciaHasta date
- creadoEn TIMESTAMP
- usuarioAuditoria int //FK -> Usuarios
- activo boolean default true

# TiposImpuesto
- tipoImpuestoId serial auto-increment (PK)
- nombreTipoImpuesto varchar(50) unique not null
- creadoEn TIMESTAMP
- usuarioAuditoria int //FK -> Usuarios
- ultimaAuditoria TIMESTAMP
- activo boolean

# Ubicaciones 
- ubicacionId serial auto-increment (PK)
- nombreUbicacion varchar(50) unique not null 
- tipoUbicacionId int not null // FK -> TiposUbicacion
- ciudadId int nullable // FK -> Ciudades
- direccion varchar(200) nullable
- creadoEn TIMESTAMP
- usuarioAuditoria int //FK -> Usuarios
- ultimaAuditoria TIMESTAMP
- activo boolean default true

# TiposUbicacion
- tipoUbicacionId serial auto-increment (PK)
- nombreTipoUbicacion varchar(50) unique not null 
- descripcion varchar(150)
- creadoEn TIMESTAMP
- usuarioAuditoria int //FK -> Usuarios
- activo boolean default true

# Courier
- courierId serial auto-increment (PK)
- nombreCourier varchar(50) unique not null
- ciudadId int not null //FK -> Ciudades
- tipoServicioId int not null //FK -> TiposServicios
- tiempoEntregaPromedioDias int
- creadoEn TIMESTAMP
- usuarioAuditoria int //FK -> Usuarios
- ultimaAuditoria TIMESTAMP
- activo boolean

# TiposServicio
- tipoServicioId serial auto-increment (PK)
- nombreTipoServicio varchar(50) unique not null 
- creadoEn TIMESTAMP
- usuarioAuditoria int //FK -> Usuarios
- ultimaAuditoria TIMESTAMP
- activo boolean

# TiposTransporte
- tipoTransporteId serial auto-increment (PK)
- nombreTipoTransporte varchar(50) unique not null 
- creadoEn TIMESTAMP
- usuarioAuditoria int //FK -> Usuarios
- ultimaAuditoria TIMESTAMP
- activo boolean







# Currencies
- currencyId serial auto-increment (PK)
- codigoIso char(3) unique not null
- currencySymbol char
- nombreCurrency varchar(50) not null
- activo boolean
- creadoEn TIMESTAMP
- usuarioAuditoria int //FK -> Usuarios
- ultimaAuditoria TIMESTAMP

# MonedasPorPais 
- monedaPaisId serial auto-increment (PK)
- currencyId int unique not null //FK -> Currencies 
- paisId int unique not null //FK -> Paises
- esOficial boolean default true 
- activo boolean
- creadoEn TIMESTAMP
- usuarioAuditoria int //FK -> Usuarios
- ultimaAuditoria TIMESTAMP

# TasasDeCambio
- tasaDeCambioId serial auto-increment (PK)
- currencyId1 unique not null //FK -> Currencies
- currencyId2 unique not null //FK -> Currencies
- exchangeRate //Factor multiplicativo
- creadoEn TIMESTAMP
- usuarioAuditoria int //FK -> Usuarios
- ultimaAuditoria TIMESTAMP
- activo boolean

# HistorialTasasDeCambio
- historialTasaDeCambio serial auto-increment (PK)
- fechaInicio TIMESTAMP
- fechaFinal TIMESTAMP //año 9999 si aun no termina
- currencyId1 int //FK -> Currencies
- currencyId2 int //FK -> Currencies
- exchangeRate //Factor multiplicativo
- creadoEn TIMESTAMP
- usuarioAuditoria int // FK -> Usuarios
- ultimaAuditoria TIMESTAMP
- activo boolean
- tasaDeCambioId

# InstruccionesCompra
- instruccionCompraId serial auto-increment (PK)
- OrdenVentaId int nullable //FK lógica a OrdenesVenta de Dynamic
- productoId int not null //FK -> Productos
- cantidadSolicitada decimal(12,2) not null
- paisId int not null // FK -> Paises
- tiendaId int nullable // Referencia lógica a Tiendas de Dynamic
- fechaSolicitud TIMESTAMP not null
- fechaLimiteEntrega date not null
- ordenCompraId int nullable // FK -> OrdenesCompra
- margenObjetivoPorcentaje decimal(5,2) nullable 
- creadoEn TIMESTAMP
- usuarioAuditoria int // FK -> Usuarios
- ultimaAuditoria TIMESTAMP
- activo boolean default true






# TiposCaracteristica 
- tipoCaracteristicaId serial auto-increment (PK)
- nombreTipoCaracteristica varchar(50) unique not null 
- descripcion varchar(150)
- activo boolean default true
- creadoEn TIMESTAMP
- usuarioAuditoria int // FK -> Usuarios
- ultimaAuditoria TIMESTAMP

# CaracteristicasProducto 
- caracteristicaId serial auto-increment (PK)
- productoId int unique not null // FK -> Productos
- tipoCaracteristicaId int unique not null // FK -> TiposCaracteristica
- valorBoolean boolean nullable 
- valorTexto varchar(255) nullable 
- valorNumerico decimal(10,2) nullable
- paisId int nullable //FK -> Paises
- vigenteDesde date default current_date
- vigenteHasta date nullable
- creadoEn TIMESTAMP
- usuarioAuditoria int // FK -> Usuarios
- activo boolean default true
- ultimaAuditoria TIMESTAMP


# Productos
- productoId serial auto-increment (PK)
- skuInterno varchar(20) unique not null
- nombreTecnicoProducto varchar(50) not null
- nombreComunProducto varchar(50)
- marcaOriginalId int not null //FK -> MarcasOriginales
- tipoProductoId int not null // FK -> TiposProducto
- unidadMedidaProductoId int // FK -> UnidadesMedidaProducto
- vidaUtilMeses int
- creadoEn TIMESTAMP
- usuarioAuditoria int
- ultimaAuditoria TIMESTAMP
- activo boolean default true


# TiposProducto 
- tipoProductoId serial auto-increment (PK)
- nombreTipoProducto varchar(50) unique not null
- creadoEn TIMESTAMP
- usuarioAuditoria int
- ultimaAuditoria TIMESTAMP
- activo boolean default true

# UnidadesMedidaProducto
- UnidadMedidaProductoId serial auto-increment (PK)
- nombreUnidadMedidaProducto varchar(50) unique not null 
- descripcion varchar(100)
- creadoEn TIMESTAMP 
- usuarioAuditoria int //FK -> Usuarios
- ultimaAuditoria TIMESTAMP
- activo boolean default true

# PreciosBaseProducto 
- precioBaseId serial auto-increment (PK)
- productoId int unique not null //FK -> Productos
- currencyIdOrigen int unique not null //FK -> Currencies
- precioLocal decimal(14,2) not null 
- tasaDeCambioId int not null //FK -> TasasDeCambio
- valorTasaDeCambio decimal(12,6) not null 
- precioReferencia decimal(14,2) not null 
- margenMinimoRecomendado decimal(5,2) 
- fechaVigenciaDesde date not null
- fechaVigenciaHasta date nullable
- creadoEn TIMESTAMP
- usuarioAuditoria int //FK -> Usuarios
- ultimaAuditoria TIMESTAMP
- activo boolean default true

# MarcasOriginales
- marcaOriginalId serial auto-increment (PK)
- nombreMarca varchar(100) unique not null
- paisId int not null //FK -> Paises
- descripcionMarca varchar(250) nullable 
- creadoEn TIMESTAMP
- usuarioAuditoria int //FK -> Usuarios
- ultimaAuditoria TIMESTAMP
- activo boolean default true





# OrdenesCompra
- ordenCompraId serial auto-increment (PK)
- proveedorId int not null //FK -> Proveedores
- numeroPedido unique not null varchar(20)
- fechaSolicitud date not null
- fechaRecepcion date
- estadoOrdenId int not null //FK ->EstadosOrdenes
- tipoTransporteId int not null  //FK -> TiposTransportes 
- incoterm varchar(10) default 'FOB'
- ubicacionId int nullable // FK -> Ubicaciones
- comentarios varchar(200)
- creadoEn TIMESTAMP
- usuarioAuditoria int //FK -> Usuarios
- ultimaAuditoria TIMESTAMP
- activo boolean default true

# EstadosOrdenes
- estadoOrdenId serial auto-increment (PK)
- nombreEstadoOrden varchar(50) unique not null 
- creadoEn TIMESTAMP 
- usuarioAuditoria int //FK -> Usuarios
- ultimaAuditoria TIMESTAMP
- activo boolean default true

# ConfiguracionAprobacionOrdenes 
- configuracionAprobacionId serial auto-increment (PK)
- montoMinimoUsd decimal(12,2) not null 
- montoMaximoUsd decimal(12,2) nullable 
- rolRequeridoId int not null  //FK -> Roles
- nivelAprobacion int not null 
- requiereDobleFirma boolean default false 
- tiempoMaximoAprobacionHoras int default 48 
- creadoEn TIMESTAMP
- usuarioAuditoria int //FK -> Usuarios
- activo boolean default true

# Proveedores
- proveedorId serial auto-increment (PK)
- nombreProveedor varchar(50) unique not null
- paisId int //FK -> Paises
- tiempoEntregaPromedioDias int
- calificacionConfianza decimal(3,2) // 1.00 a 5.00
- creadoEn TIMESTAMP
- usuarioAuditoria int //FK -> Usuarios
- ultimaAuditoria TIMESTAMP
- activo boolean default true

# TiposContactos
- tipoContactoId serial auto-increment (PK)
- nombreTipoContacto varchar(50) unique not null 
- descripcion varchar(255)
- formatoValidacion varchar(100)
- longitudMinima int 
- longitudMaxima int 
- creadoEn TIMESTAMP
- usuarioAuditoria int //FK -> Usuarios
- ultimaAuditoria TIMESTAMP
- activo boolean default true

# InfoContactosProveedor
- infoContactoProveedorId serial auto-increment (PK)
- tipoContactoId int not null //FK -> TipoContacto 
- proveedorId int not null //FK -> Proveedores
- valor varchar(100) not null 
- esPrincipal boolean default false 
- verificado boolean default false
- fechaVerificacion TIMESTAMP
- horarioAtencion varchar(50) 
- idiomaSoporte char(2) default 'en'
- creadoEn TIMESTAMP
- usuarioAuditoria int //FK -> Usuarios
- ultimaAuditoria TIMESTAMP
- activo boolean default true

# LotesBulk 
- loteBulkId serial auto-increment (PK)
- productoId int not null //FK -> Productos
- proveedorId int not null //FK -> Proveedores
- ordenCompraId int not null //FK -> OrdenesCompra
- numeroLoteProveedor varchar(100) not null
- ubicacionId int nullable //FK -> Ubicaciones
- fechaRecepcionHub TIMESTAMP
- fechaVencimiento date not null
- cantidadTotal decimal(12,2) not null
- currencyId int not null //FK -> Currencies
- costoLocal decimal(14,2) not null
- tasaDeCambioId int not null //FK -> TasasDeCambio
- tasaDeCambioAplicada decimal(12,6) not null
- costoTotal decimal(14,2) not null
- estadoInventarioId int not null //FK -> EstadosInventario
- tipoTransporteId int //FK -> TiposTransportes
- creadoEn TIMESTAMP 
- usuarioAuditoria int //FK -> Usuarios
- ultimaAuditoria TIMESTAMP
- activo boolean default true

# EstadosInventario
- estadoInventarioId serial auto-increment (PK)
- nombreEstadoInventario varchar(50) unique not null 
- descripcion varchar(255)
- creadoEn TIMESTAMP
- usuarioAuditoria int //FK -> Usuarios
- ultimaAuditoria TIMESTAMP
- activo boolean default true

# ConfiguracionesAceptacionBulks
- configuracionAceptacionId serial auto-increment (PK)
- tipoProductoId int nullable //FK -> TiposProducto
- proveedorId int nullable //FK -> Proveedores
- mermaMaximaPorcentaje decimal(5,2)  
- vidaUtilMinimaRestantePorcentaje decimal(5,2)
- desviacionTemperaturaMaxima decimal(4,1) 
- requiereMuestreoCalidad boolean default true 
- tiempoMaximoMuestreoHoras int 
- accionSiFalla varchar(100) 
- creadoEn TIMESTAMP
- usuarioAuditoria int //FK -> Usuarios
- activo boolean default true

# ProductosPorOrden  
- productoPorOrdenId serial auto-increment (PK)
- ordenCompraId int unique not null //FK -> OrdenesCompra
- productoId int unique not null //FK -> Productos
- cantidadSolicitada decimal(12,2) not null
- currencyId int not null //FK -> Currencies
- precioUnitarioAcordado decimal(14,2) not null 
- subtotal decimal(14,2) not null
- tasaDeCambioAplicada decimal(12,6) not null
- estadoItemId int not null //FK -> EstadosItems
- creadoEn TIMESTAMP 
- usuarioAuditoria int //FK -> Usuarios
- ultimaAuditoria TIMESTAMP
- activo boolean default true

# EstadosItems
- estadoItemId serial auto-increment (PK)
- nombreEstadoItem varchar(50) unique not null 
- descripcion varchar(255)
- creadoEn TIMESTAMP 
- usuarioAuditoria int //FK -> Usuarios
- ultimaAuditoria TIMESTAMP
- activo boolean default true

# TrazabilidadOrdenes 
- trazabilidadId serial auto-increment (PK)
- ordenCompraId int unique not null //FK -> OrdenesCompra 
- estadoOrdenId not null //FK -> EstadosOrdenes
- fechaCambioEtapa TIMESTAMP not null
- ubicacionId not null //FK -> Ubicaciones
- tipoTransporteEtapaId int nullable //FK -> TiposTransporte  
- numeroGuiaInternacional varchar(100) 
- fechaEstimadaLlegada date
- fechaRealLlegada date
- incidencias varchar(200)
- creadoEn TIMESTAMP
- usuarioAuditoria int //FK -> Usuarios
- ultimaAuditoria TIMESTAMP
- activo boolean default true

# HistorialEtapasOrden 
- historialEtapaId serial auto-increment (PK)
- trazabilidadId int not null //FK -> TrazabilidadOrdenes
- etapaAnterior int not null //FK -> EstadosOrdenes
- etapaNueva int not null //FK -> EstadosOrdenes 
- fechaCambio TIMESTAMP
- responsableCambioId int //FK -> Usuarios 
- comentarioCambio varchar(200)
- creadoEn TIMESTAMP

# CostosOperativos 
- costoId serial auto-increment (PK)
- conceptoCostoId int not null //FK -> ConceptosCostos
- loteBulkId int not null //FK -> LotesBulks
- currencyId int not null //FK -> Currencies
- montoLocal decimal(14,2) not null 
- tasaDeCambioId int //FK -> TasasDeCambio
- tasaDeCambioAplicada decimal(12,6) not null 
- montoConvertido decimal(14,2)
- fechaPago date nullable 
- paisId int //FK -> Paises
- tipoTransporteId int nullable // FK -> TiposTransporte
- creadoEn TIMESTAMP
- usuarioAuditoria int // FK -> Usuarios
- ultimaAuditoria TIMESTAMP
- activo boolean default true

# ConceptosCostos
- conceptoCostoId serial auto-increment (PK)
- nombreConceptoCosto varchar(50) unique not null 
- descripcion varchar(255) 
- creadoEn TIMESTAMP 
- usuarioAuditoria int //FK -> Usuarios
- ultimaAuditoria TIMESTAMP
- activo boolean default true











# TiposEvento 
- tipoEventoId serial auto-increment (PK)
- nombreEvento varchar(50) unique not null
- descripcion varchar(255) 
- requierePreguardado boolean default true 
- creadoEn TIMESTAMP
- usuarioAuditoria int //FK -> Usuarios
- ultimaAuditoria TIMESTAMP
- activo boolean

# Severidades 
- severidadId serial auto-increment (PK)
- valorSeveridad int not null 
- nombreSeveridad varchar(50) unique not null
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
- severidadId int not null //FK -> Severidades 
- descripcion varchar(255) not null 
- sourceId not null //FK -> Sources 
- userAgent text // Navegador o cliente HTTP si aplica
- computadora varchar(100) 
- usuarioId int //FK -> Usuarios
- referenciaId1 int 
- referenciaId2 int 
- descripcionReferencia1 varchar(200)
- descripcionReferencia2 varchar(200)
- objetoId1 bigint //FK -> Objetos
- objetoId2 bigint //FK -> Objetos
- datosAnteriores jsonb // Estado ANTES del cambio 
- datosNuevos jsonb // Estado DESPUÉS del cambio 
- checkSum varchar(64) // SHA256 de: tipoEventoId+referenciaId1+objetoId1+fecha+datosNuevos (para integridad)
- creadoEn TIMESTAMP
- activo boolean default true

# Sources 
- sourceId serial auto-increment (PK)
- nombreSource varchar(50) unique not null
- creadoEn TIMESTAMP
- usuarioAuditoria int //FK -> Usuarios
- ultimaAuditoria TIMESTAMP
- activo boolean default true

# ConfiguracionesSistema // Configuraciones globales del holding 
- configuracionSistemaId serial auto-increment (PK)
- clave varchar(50) unique not null 
- valorText varchar(300) nullable 
- valorInt int nullable 
- valorDecimal decimal(18,6) nullable 
- valorBoolean boolean nullable 
- valorJson jsonb nullable 
- categoriaId int not null //FK -> CategoriasConfiguracion
- descripcion varchar(200) not null 
- esEditableUI boolean default true 
- requiereReinicioSistema boolean default false 
- ultimoCambioPor int //FK -> Usuarios
- ultimoCambioEn TIMESTAMP
- activo boolean default true

# CategoriasConfiguracion
- categoriaConfiguracionId serial auto-increment (PK)
- nombreCategoriaConfiguracion varchar(50) unique not null
- creadoEn TIMESTAMP
- usuarioAuditoria int //FK -> Usuarios
- ultimaAuditoria TIMESTAMP
- activo boolean default true






# Usuarios
- usuarioId serial auto-increment (PK)
- nombreUsuario varchar(50) 
- apellido1 varchar(50) 
- apellido2 varchar(50) 
- email varchar(100)
- contraseña Bytea
- fechaNacimiento Date
- creadoEn TIMESTAMP
- usuarioAuditoria int //FK -> Usuarios
- ultimaAuditoria TIMESTAMP
- activo boolean

# Roles
- rolId serial auto-increment (PK)
- nombreRol varchar(50) unique not null
- descripcion varchar(255)
- nivelAcceso INTEGER
- creadoEn TIMESTAMP
- usuarioAuditoria int //FK -> Usuarios
- ultimaAuditoria TIMESTAMP
- activo boolean DEFAULT TRUE

# Permiso
- permisoId serial auto-increment (PK)
- nombrePermiso varchar(50) unique not null
- descripcion varchar(255)
- creadoEn TIMESTAMP
- usuarioAuditoria int //FK -> Usuarios
- ultimaAuditoria TIMESTAMP
- activo boolean DEFAULT TRUE

# RolPermiso
- rolId int unique not null //FK -> Roles
- permisoId int unique not null //FK -> Permisos
- creadoEn TIMESTAMP
- usuarioAuditoria int //FK -> Usuarios
- ultimaAuditoria TIMESTAMP
- activo boolean

# UsuarioRol
- usuarioId int unique not null //FK -> Usuarios
- rolId int unique not null //FK -> Roles
- asignadoPor int //FK -> Usuarios
- asignadoEn TIMESTAMP
- fechaExpiracion TIMESTAMP
- creadoEn TIMESTAMP
- usuarioAuditoria int //FK -> Usuarios
- ultimaAuditoria TIMESTAMP
- activo boolean




