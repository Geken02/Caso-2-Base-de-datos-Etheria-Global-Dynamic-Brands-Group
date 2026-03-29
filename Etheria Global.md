> **Nombre:** Etheria Global db
> **Motor de base de datos:** Postgres 
> **Versión:** 0.2  
> **Fecha:** 26-03-2026 
> **Autor:** Gerald Hernández Gamboa  

## Tables 

# Ciudades
- ciudadId serial auto-increment (PK)
- nombre varchar(50)
- provinciaId (FK)
- codigoPostal varchar(20)
- esHubLogistico boolean default false
- creadoEn TIMESTAMP
- usuarioAuditoria (FK)
- ultimaAuditoria TIMESTAMP
- activo boolean

# Provincias
- provinciaId serial auto-increment (PK)
- nombre varchar(50)
- paisId (FK)
- creadoEn TIMESTAMP
- usuarioAuditoria (FK)
- ultimaAuditoria TIMESTAMP
- activo boolean

# Paises
- paisId serial auto-increment (PK)
- nombre varchar(50) not null
- codigoIso char(3) unique 
- requierePermisoSanitario boolean default true
- zonaHoraria varchar(30) 
- creadoEn TIMESTAMP
- usuarioAuditoria int // FK a Usuarios
- ultimaAuditoria TIMESTAMP
- activo boolean default true

# Puertos 
- puertoId serial auto-increment (PK)
- nombre varchar(50)
- ciudadId FK
- codigoIso varchar(10) 
- capacidadMaximaToneladas decimal(12,2)
- creadoEn TIMESTAMP
- usuarioAuditoria (FK)
- ultimaAuditoria TIMESTAMP
- activo boolean

# Aeropuertos
- aeropuertoId serial auto-increment (PK)
- nombre varchar(50)
- ciudadId FK
- creadoEn TIMESTAMP
- usuarioAuditoria (FK)
- ultimaAuditoria TIMESTAMP
- activo boolean

# Courier
- courierId serial auto-increment (PK)
- nombre varchar(50)
- ciudadId FK
- tipoServicioId //Crearlo
- tiempoEntregaPromedioDias int
- creadoEn TIMESTAMP
- usuarioAuditoria (FK)
- ultimaAuditoria TIMESTAMP
- activo boolean

# TiposServicios
- tipoServicioId
- nombre varchar(50)
- creadoEn TIMESTAMP
- usuarioAuditoria (FK)
- ultimaAuditoria TIMESTAMP
- borrado boolean

# Currencies
- currencyId serial auto-increment (PK)
- codigoIso char(3) unique not null
- currencySymbol char
- nombre varchar(50)
- activo boolean
- creadoEn TIMESTAMP
- usuarioAuditoria (FK)
- ultimaAuditoria TIMESTAMP
- paisId

# TasasDeCambio
- tasaDeCambioId serial auto-increment (PK)
- currencyId1 (FK)
- currencyId2 (FK)
- exchangeRate //Factor multiplicativo
- creadoEn TIMESTAMP
- usuarioAuditoria (FK)
- ultimaAuditoria TIMESTAMP
- activo boolean

# HistorialTasasDeCambio
- historialTasaDeCambio serial auto-increment (PK)
- fechaIncio TIMESTAMP
- fechaFinal TIMESTAMP //año 9999 si aun no termina
- currencyId1 (FK)
- currencyId2 (FK)
- exchangeRate //Factor multiplicativo
- creadoEn TIMESTAMP
- usuarioAuditoria (FK)
- ultimaAuditoria TIMESTAMP
- activo boolean
- tasaDeCambioId

# TiposProducto
- tipoProductoId serial auto-increment (PK)
- nombre varchar(50) not null 
- requiereControlTemperatura boolean default false
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
- puertoDestinoId int //FK -> Puertos
- comentarios varchar(200)
- creadoEn timestamp 
- usuarioAuditoria int //FK -> Usuarios
- ultimaAuditoria timestamp
- activo boolean default true

# EstadosOrdenes
- estadoOrdenId serial auto-increment (PK)
- nombre varchar(50) not null 
- creadoEn TIMESTAMP 
- usuarioAuditoria int //FK -> Usuarios
- ultimaAuditoria TIMESTAMP
- activo boolean default true

# Productos
- productoId serial auto-increment (PK)
- skuInterno varchar(20) unique not null // Código único del Holding
- nombreTecnico varchar(50) not null // Nombre científico
- nombreComun varchar(100) // Nombre comercial genérico
- tipoProductoId int //FK -> TiposProducto
- unidadMedidaProductoId //FK -> UnidadesMedidaProducto
- requierePermisoSanitario boolean default true
- aptoParaIngesta boolean default false
- aptoParaPiel boolean default false
- temperaturaMinAlmacenamiento decimal(4,1) // °C
- temperaturaMaxAlmacenamiento decimal(4,1) // °C
- vidaUtilMeses int
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

# UnidadesMedidaProducto
- UnidadMedidaProductoId serial auto-increment (PK)
- nombre varchar(50) not null 
- descripcion text
- requiereControlTemperatura boolean default false
- creadoEn TIMESTAMP 
- usuarioAuditoria int //FK -> Usuarios
- ultimaAuditoria TIMESTAMP
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

# InfoContactoProveedores
- contactoId serial auto-increment (PK)
- proveedorId int //FK -> Proveedores
- tipoContactoId
- nombrePersona varchar(50)
- email varchar(60)
- telefono varchar(20)
- whatsapp varchar(20)
- esPrincipal boolean default false
- creadoEn TIMESTAMP
- usuarioAuditoria int //FK -> Usuarios
- ultimaAuditoria TIMESTAMP
- activo boolean default true

# PreciosBaseProducto // Precio de referencia en USD 
- precioBaseId serial auto-increment (PK)
- productoBaseId int //FK -> Productos
- precioReferenciaUsd decimal(10,2) not null
- margenMinimoRecomendado decimal(5,2) // Ej: 30.00 para 30%
- fechaVigenciaDesde date
- fechaVigenciaHasta date
- creadoEn TIMESTAMP
- usuarioAuditoria int //FK -> Usuarios
- activo boolean default true

# MovimientoInventario // Trazabilidad de stock
- movimientoId serial auto-increment (PK)
- loteBulkId int FK -> LoteBulk.loteBulkId
- tipoMovimiento varchar(30) not null 
- cantidadAnterior decimal(12,2)
- cantidadNueva decimal(12,2)
- cantidadMovida decimal(12,2)
- ubicacionOrigen varchar(100) 
- ubicacionDestino varchar(100)
- responsableId int //FK -> Usuarios
- fechaMovimiento TIMESTAMP
- observaciones varchar(200)
- transformacionIdReferencia int //FK -> TransformacionProducto
- creadoEn TIMESTAMP
- usuarioAuditoria int //FK -> Usuarios
- activo boolean default true

# ProductosPorOrden // 
- productoPorOrdenId serial auto-increment (PK)
- ordenId int FK -> Orden
- productoId int //FK -> Productos
- cantidadSolicitada decimal(12,2) not null
- precioUnitarioAcordadoUsd decimal(10,2) not null 
- subtotalUsd decimal(12,2) not null // Calculado: cantidadSolicitada * precioUnitarioAcordadoUsd
- estadoItem varchar(20) 
- creadoEn timestamp default current_timestamp
- usuarioAuditoria int (FK -> Usuarios.usuarioId)
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
- tipoEventoId int //FK -> TiposEvento not null
- severidadId int //FK -> Severidades not null default 2
- descripcion varchar(100) not null 
- sourceId   //FK -> Sources not null
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

# MarcasOriginales 
- marcaOriginalId serial auto-increment (PK)
- nombreMarca varchar(50) not null 
- paisOrigenId int //FK -> Paises
- esProveedorExclusivo boolean default false
- contactoComercialId int //FK -> InfoContactoProveedores
- creadoEn TIMESTAMP
- usuarioAuditoria int //FK -> Usuarios
- ultimaAuditoria TIMESTAMP
- activo boolean default true


# ProductosPorMarca 
- productoPorMarcaId serial auto-increment (PK)
- productoBaseId int //FK -> Producto
- marcaOriginalId int //FK -> MarcasOriginales
- proveedorId int //FK -> Proveedores
- fechaInicioVigencia date 
- fechaFinVigencia date 
- creadoEn TIMESTAMP
- usuarioAuditoria int //FK -> Usuarios
- ultimaAuditoria TIMESTAMP
- activo boolean default true


# TrazabilidadOrdenes 
- trazabilidadId serial auto-increment (PK)
- ordenCompraId int //FK -> Ordenes not null
- productoPorOrdenId int //FK -> ProductosPorOrden 
- etapaActual varchar(30) not null 
- fechaCambioEtapa timestamp not null
- ubicacionActual varchar(100) 
- transportistaNombre varchar(100) 
- numeroGuiaInternacional varchar(100) // Tracking number del transportista principal
- fechaEstimadaLlegada date
- fechaRealLlegada date
- incidencias varchar(200)
- creadoEn TIMESTAMP
- usuarioAuditoria int //FK -> Usuarios
- ultimaAuditoria TIMESTAMP
- activo boolean default true


# HistorialEtapasOrden // Registro histórico de cada cambio de etapa (para auditoría y métricas)
- historialEtapaId serial auto-increment (PK)
- trazabilidadId int //FK -> TrazabilidadOrdenes not null
- etapaAnterior varchar(30)
- etapaNueva varchar(30) not null
- fechaCambio TIMESTAMP
- responsableCambio varchar(100) 
- comentarioCambio varchar(200)
- creadoEn TIMESTAMP

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
- estado varchar(20) 
- puertoLlegadaId int //FK -> Puertos
- creadoEn TIMESTAMP
- usuarioAuditoria int //FK -> Usuarios
- ultimaAuditoria TIMESTAMP
- activo boolean default true

# ImpuestosPorPais 
- impuestoId serial auto-increment (PK)
- productoBaseId int //FK -> Productoas
- paisDestinoId int //FK -> Paises.paisId
- tipoImpuesto varchar(30) 
- porcentaje decimal(5,2) // Ej: 12.50 para 12.5%
- montoFijoUsd decimal(10,2) // Para aranceles específicos
- vigenciaDesde date
- vigenciaHasta date
- creadoEn TIMESTAMP
- usuarioAuditoria int //FK -> Usuarios
- activo boolean default true

# Usuarios
- usuarioId serial auto-increment (PK)
- nombre varchar(50)
- apellido1 varchar(40)
- apellido2 varchar(40)
- email varchar(255)
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
- usuarioAuditoria (FK)
- ultimaAuditoria TIMESTAMP
- activo boolean DEFAULT TRUE

# Permiso
- permisoId serial auto-increment (PK)
- nombre varchar(50)
- descripcion varchar(255)
- creadoEn TIMESTAMP
- usuarioAuditoria (FK)
- ultimaAuditoria TIMESTAMP
- activo boolean DEFAULT TRUE

# RolPermiso
- rolId (FK)
- permisoId (FK)
- creadoEn TIMESTAMP
- usuarioAuditoria (FK)
- activo boolean DEFAULT TRUE

# UsuarioRol
- usuarioId (FK)
- rolId (FK)
- asignadoPor (FK)
- asignadoEn TIMESTAMP
- fechaExpiracion TIMESTAMP
- activo boolean DEFAULT TRUE




