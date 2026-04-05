> **Nombre:** Etheria Global db
> **Motor de base de datos:** Postgres 
> **Versión:** 0.7
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

# ImpuestosPorPais 
- impuestoId serial auto-increment (PK)
- productoId int //FK -> Productos
- paisDestinoId int //FK -> Paises
- tipoImpuestoId //FK -> TiposImpuestos
- porcentaje decimal(5,2) // Ej: 12.50 para 12.5%
- montoFijoUsd decimal(10,2)
- vigenciaDesde date
- vigenciaHasta date
- creadoEn TIMESTAMP
- usuarioAuditoria int //FK -> Usuarios
- activo boolean default true

# TiposImpuestos
- tipoImpuestoId serial auto-increment (PK)
- nombre varchar(50)
- creadoEn TIMESTAMP
- usuarioAuditoriaint //FK -> Usuarios
- ultimaAuditoria TIMESTAMP
- activo boolean

# Puertos 
- puertoId serial auto-increment (PK)
- nombre varchar(50)
- ciudadId //FK -> Ciudades
- codigoIso varchar(10) 
- capacidadMaximaToneladas decimal(12,2)
- creadoEn TIMESTAMP
- usuarioAuditoria int //FK -> Usuarios
- ultimaAuditoria TIMESTAMP
- activo boolean

# Aeropuertos
- aeropuertoId serial auto-increment (PK)
- nombre varchar(50)
- ciudadId //FK -> Ciudades
- creadoEn TIMESTAMP
- usuarioAuditoria int //FK -> Usuarios
- ultimaAuditoria TIMESTAMP
- activo boolean

# Courier
- courierId serial auto-increment (PK)
- nombre varchar(50)
- ciudadId //FK -> Ciudades
- tipoServicioId //Crearlo
- tiempoEntregaPromedioDias int
- creadoEn TIMESTAMP
- usuarioAuditoria int //FK -> Usuarios
- ultimaAuditoria TIMESTAMP
- activo boolean

# TiposServicios
- tipoServicioId
- nombre varchar(50)
- creadoEn TIMESTAMP
- usuarioAuditoria //FK -> Usuarios
- ultimaAuditoria TIMESTAMP
- activo boolean

# TiposTransportes 
- tipoTransporteId serial auto-increment (PK)
- nombre varchar(30) not null 
- descripcion varchar(100)
- tiempoTransitoPromedioDias int
- requiereDocumentacionEspecial boolean default false 
- activo boolean default true







# Currencies
- currencyId serial auto-increment (PK)
- codigoIso char(3) unique not null
- currencySymbol char
- nombre varchar(50)
- activo boolean
- creadoEn TIMESTAMP
- usuarioAuditoria int // FK -> Usuarios
- ultimaAuditoria TIMESTAMP


# MonedasPorPais 
- monedaPaisId serial auto-increment (PK)
- currencyId int not null //FK -> Currencies 
- paisId int not null FK -> Paises
- esOficial boolean default true 
- creadoEn TIMESTAMP
- activo boolean default true

# TasasDeCambio
- tasaDeCambioId serial auto-increment (PK)
- currencyId1 //FK -> Currencies
- currencyId2 //FK -> Currencies
- exchangeRate //Factor multiplicativo
- creadoEn TIMESTAMP
- usuarioAuditoria int //FK -> Usuarios
- ultimaAuditoria TIMESTAMP
- activo boolean

# HistorialTasasDeCambio
- historialTasaDeCambio serial auto-increment (PK)
- fechaIncio TIMESTAMP
- fechaFinal TIMESTAMP //año 9999 si aun no termina
- currencyId1 //FK -> Currencies
- currencyId2 //FK -> Currencies
- exchangeRate //Factor multiplicativo
- creadoEn TIMESTAMP
- usuarioAuditoria int // FK -> Usuarios
- ultimaAuditoria TIMESTAMP
- activo boolean
- tasaDeCambioId

# ConfiguracionTasasCambio 
- configuracionTasaId serial auto-increment (PK)
- currencyId1 int not null //FK -> Currencies 
- currencyId2 int not null //FK -> Currencies 
- fuentePrincipalId int //FK -> Sources
- fuenteSecundariaId int //FK -> Sources
- frecuenciaActualizacionHoras int default 24 
- variacionMaximaDiariaPorcentaje decimal(5,2) default 5.00 
- requiereValidacionManual boolean default false 
- rolValidadorId int //FK -> Rol 
- redondeoDecimales int 
- creadoEn TIMESTAMP
- usuarioAuditoria int //FK -> Usuarios
- activo boolean default true






# Productos
- productoId serial auto-increment (PK)
- skuInterno varchar(20) unique not null //Código único del Holding
- nombreTecnico varchar(50) not null //Nombre científico
- nombreComun varchar(50) 
- marcaOriginalId int not null  //FK -> MarcasOriginales
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

# ConfiguracionAlmacenamientoPorTipoProducto 
- configuracionId serial auto-increment (PK)
- tipoProductoId int not null //FK -> TiposProducto 
- temperaturaMinimaPermitida decimal(4,1) not null
- temperaturaMaximaPermitida decimal(4,1) not null 
- humedadMinimaPorcentaje decimal(5,2) nullable 
- humedadMaximaPorcentaje decimal(5,2) nullable 
- vidaUtilMinimaAceptableMeses int 
- requiereControlContinuo boolean default false 
- alertaDesviacionTemperatura decimal(4,1) default 2.0 
- creadoEn TIMESTAMP
- usuarioAuditoria int //FK -> Usuarios
- activo boolean default true

# UnidadesMedidaProducto
- UnidadMedidaProductoId serial auto-increment (PK)
- nombre varchar(50) not null 
- descripcion varchar(100)
- creadoEn TIMESTAMP 
- usuarioAuditoria int //FK -> Usuarios
- ultimaAuditoria TIMESTAMP
- activo boolean default true

# PropiedadesMedicinales
- propiedadMedicinalId serial auto-increment (PK)
- productoId int //FK -> ProductoBase
- descripcion varchar(250) not null 
- contraindicaciones varchar(250)
- dosisRecomendada varchar(50)
- creadoEn TIMESTAMP
- usuarioAuditoria int //FK -> Usuarios
- ultimaAuditoria TIMESTAMP
- activo boolean default true

# PreciosBaseProducto // Precio de referencia en USD 
- precioBaseId serial auto-increment (PK)
- productoId int //FK -> Productos
- precioReferenciaUsd decimal(10,2) not null
- margenMinimoRecomendado decimal(5,2) // Ej: 30.00 para 30%
- fechaVigenciaDesde date
- fechaVigenciaHasta date
- creadoEn TIMESTAMP
- usuarioAuditoria int //FK -> Usuarios
- activo boolean default true

# MarcasOriginales 
- marcaOriginalId serial auto-increment (PK)
- nombreMarca varchar(100) not null 
- paisOrigenId int //FK -> Paises
- esProveedorExclusivo boolean default false
- contactoComercialId int //FK -> InfoContactoProveedores
- creadoEn TIMESTAMP
- usuarioAuditoria int //FK -> Usuarios
- ultimaAuditoria TIMESTAMP
- activo boolean default true





# Orden
- ordenCompraId serial auto-increment (PK)
- proveedorId int //FK -> Proveedores
- numeroPedido varchar(20)
- fechaSolicitud date not null
- fechaRecepcion date
- estadoOrdenId int //FK ->EstadosOrdenes
- tipoTransporteId int not null  //FK -> TiposTransporte 
- puertoDestinoId int nullable  //FK -> Puertos 
- aeropuertoDestinoId int  nullable  //FK -> Aeropuertos
- comentarios varchar(200)
- creadoEn TIMESTAMP
- usuarioAuditoria int //FK -> Usuarios
- ultimaAuditoria TIMESTAMP
- activo boolean default true

# EstadosOrdenes
- estadoOrdenId serial auto-increment (PK)
- nombre varchar(50) not null 
- creadoEn TIMESTAMP 
- usuarioAuditoria int //FK -> Usuarios
- ultimaAuditoria TIMESTAMP
- activo boolean default true

# ConfiguracionAprobacionOrdenes // Umbrales de aprobación por monto y rol
- configuracionAprobacionId serial auto-increment (PK)
- montoMinimoUsd decimal(12,2) not null 
- montoMaximoUsd decimal(12,2) nullable 
- rolRequeridoId int //FK -> Rol not null // Rol que debe aprobar
- nivelAprobacion int not null 
- requiereDobleFirma boolean default false 
- tiempoMaximoAprobacionHoras int default 48 
- creadoEn TIMESTAMP
- usuarioAuditoria int //FK -> Usuarios
- activo boolean default true

# Proveedores
- proveedorId serial auto-increment (PK)
- nombreEmpresa varchar(50) not null
- paisOrigenId int //FK -> Paises
- tiempoEntregaPromedioDias int
- calificacionConfianza decimal(3,2) // 1.00 a 5.00
- creadoEn TIMESTAMP
- usuarioAuditoria int //FK -> Usuarios
- ultimaAuditoria TIMESTAMP
- activo boolean default true

# TipoContacto 
- tipoContactoId serial auto-increment (PK)
- nombre varchar(30) not null 
- descripcion varchar(100)
- formatoValidacion varchar(100)
- longitudMinima int 
- longitudMaxima int 
- esActivo boolean default true
- creadoEn TIMESTAMP
- usuarioAuditoria int //FK -> Usuarios
- ultimaAuditoria TIMESTAMP
- activo boolean default true

# InfoContactosProveedor
- infoContactoProveedorId serial auto-increment (PK)
- tipoContactoId int not null //FK -> TipoContacto 
- proveedorId //FK -> Proveedores
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

# LoteBulk 
- loteBulkId serial auto-increment (PK)
- productoId int //FK -> Productos
- proveedorId int //FK -> Proveedores
- ordenCompraId int //FK -> Ordenes
- numeroLoteProveedor varchar(100) // Lote asignado por proveedor extranjero
- fechaRecepcionHub timestamp not null
- fechaVencimiento date not null
- cantidadTotal decimal(12,2) not null
- costoTotalUsd decimal(12,2) not null 
- estadoOrdenesId //FK -> EstadosOrdenes
- tipoTransporteUtilizadoId int //FK -> TiposTransportes
- creadoEn TIMESTAMP
- usuarioAuditoria int //FK -> Usuarios
- ultimaAuditoria TIMESTAMP
- activo boolean default true

# ConfiguracionAceptacionBulks// Reglas de aceptación/rechazo de bulks recibidos
- configuracionAceptacionId serial auto-increment (PK)
- tipoProductoId int nullable //FK -> TiposProducto
- proveedorId int nullable //FK -> Proveedores
- mermaMaximaPorcentaje decimal(5,2)  
- vidaUtilMinimaRestantePorcentaje decimal(5,2)
- desviacionTemperaturaMaxima decimal(4,1) 
- requiereMuestreoCalidad boolean default true 
- tiempoMaximoMuestreoHoras int 
- accionSiFalla varchar(30) 
- creadoEn TIMESTAMP
- usuarioAuditoria int //FK -> Usuarios
- activo boolean default true

# MovimientoInventario 
- movimientoId serial auto-increment (PK)
- loteBulkId int FK -> LoteBulk
- tipoMovimientoId //FK -> TiposMovimientos not null 
- cantidadAnterior decimal(12,2)
- cantidadNueva decimal(12,2)
- cantidadMovida decimal(12,2)
- ubicacionOrigen varchar(100) 
- ubicacionDestino varchar(100)
- responsableId int //FK -> Usuarios
- fechaMovimiento TIMESTAMP
- observaciones varchar(200)
- creadoEn TIMESTAMP
- usuarioAuditoria int //FK -> Usuarios
- activo boolean default true

# TiposMovimientos
- tipoMovimientoId serial auto-increment (PK)
- nombre varchar(50) not null 
- creadoEn TIMESTAMP 
- usuarioAuditoria int //FK -> Usuarios
- ultimaAuditoria TIMESTAMP
- activo boolean default true

# ProductosPorOrden  
- productoPorOrdenId serial auto-increment (PK)
- ordenId int //FK -> Orden
- productoId int //FK -> Productos
- cantidadSolicitada decimal(12,2) not null
- precioUnitarioAcordadoUsd decimal(10,2) not null 
- subtotalUsd decimal(12,2) not null 
- estadoItemId //FK -> EstadosItems
- creadoEn TIMESTAMP
- usuarioAuditoria int //FK -> Usuarios
- ultimaAuditoria TIMESTAMP
- activo boolean default true

# EstadosItems
- estadoItemId serial auto-increment (PK)
- nombre varchar(50) not null 
- creadoEn TIMESTAMP 
- usuarioAuditoria int //FK -> Usuarios
- ultimaAuditoria TIMESTAMP
- activo boolean default true

# TrazabilidadOrdenes 
- trazabilidadId serial auto-increment (PK)
- ordenCompraId int //FK -> Ordenes not null
- productoPorOrdenId int //FK -> ProductosPorOrden 
- etapaActualId not null //FK -> EstadosOrdenes
- fechaCambioEtapa TIMESTAMP not null
- ubicacionActual varchar(100) 
- tipoTransporteEtapaId int nullable //FK -> TiposTransporte  
- transportistaNombre varchar(100) 
- numeroGuiaInternacional varchar(100) // Tracking number del transportista principal
- fechaEstimadaLlegada date
- fechaRealLlegada date
- incidencias varchar(200)
- creadoEn TIMESTAMP
- usuarioAuditoria int //FK -> Usuarios
- ultimaAuditoria TIMESTAMP
- activo boolean default true

# HistorialEtapasOrden 
- historialEtapaId serial auto-increment (PK)
- trazabilidadId int //FK -> TrazabilidadOrdenes not null
- etapaAnterior //FK -> EstadosOrdenes
- etapaNueva //FK -> EstadosOrdenes not null
- fechaCambio TIMESTAMP
- responsableCambioId //FK -> Usuarios 
- comentarioCambio varchar(200)
- creadoEn TIMESTAMP

# CostosOperativos 
- costoId serial auto-increment (PK)
- loteBulkId int not null // FK -> LoteBulk
- concepto varchar(30) not null 
- montoUsd decimal(10,2) not null 
- currencyId not null //FK -> Currencies
- fechaPago date nullable 
- paisAfectado int //FK -> Paises
- documentoSoporte varchar(200) nullable 
- tipoTransporteAsociadoId int nullable // FK -> TiposTransporte
- creadoEn TIMESTAMP
- usuarioAuditoria int // FK -> Usuarios
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
- checkSum varchar(64) // SHA256 de: tipoEventoId+referenciaId1+objetoId1+fecha+datosNuevos (para integridad)
- creadoEn TIMESTAMP
- activo boolean default true

# Sources 
- sourceId serial auto-increment (PK)
- nombre varchar(50)
- creadoEn TIMESTAMP
- usuarioAuditoria int //FK -> Usuarios
- ultimaAuditoria TIMESTAMP
- activo boolean default true

# ConfiguracionSistema // Configuraciones globales del holding 
- configuracionSistemaId serial auto-increment (PK)
- clave varchar(50) unique not null 
- valorText varchar(300) nullable 
- valorInt int nullable 
- valorDecimal decimal(18,6) nullable 
- valorBoolean boolean nullable 
- valorJson jsonb nullable 
- categoriaId not null //FK -> CategoriasConfiguracion
- descripcion varchar(200) not null 
- esEditableUI boolean default true 
- requiereReinicioSistema boolean default false 
- ultimoCambioPor int //FK -> Usuarios
- ultimoCambioEn TIMESTAMP
- activo boolean default true

# CategoriasConfiguracion
- categoriaConfiguracionId
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
- email varchar(100)
- contraseña VARBINARY(255)
- fechaNacimiento Date
- creadoEn TIMESTAMP
- activo boolean

# Rol
- rolId serial auto-increment (PK)
- nombre varchar(50)
- descripcion varchar(255)
- nivelAcceso INTEGER
- creadoEn TIMESTAMP
- usuarioAuditoria //FK -> Usuarios
- ultimaAuditoria TIMESTAMP
- activo boolean DEFAULT TRUE

# Permiso
- permisoId serial auto-increment (PK)
- nombre varchar(50)
- descripcion varchar(255)
- creadoEn TIMESTAMP
- usuarioAuditoria //FK -> Usuarios
- ultimaAuditoria TIMESTAMP
- activo boolean DEFAULT TRUE

# RolPermiso
- rolId (FK)
- permisoId //FK -> Permisos
- creadoEn TIMESTAMP
- usuarioAuditoria //FK -> Usuarios
- activo boolean DEFAULT TRUE

# UsuarioRol
- usuarioId (FK)
- rolId //FK -> Roles
- asignadoPor //FK -> Usuarios
- asignadoEn TIMESTAMP
- fechaExpiracion TIMESTAMP
- activo boolean DEFAULT TRUE




