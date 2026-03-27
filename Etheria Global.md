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
- creadoEn timestamp default current_timestamp
- usuarioAuditoria int // FK a Usuarios
- ultimaAuditoria timestamp
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
- descripcion text
- requiereControlTemperatura boolean default false
- creadoEn TIMESTAMP 
- usuarioAuditoria int //FK -> Usuarios
- ultimaAuditoria TIMESTAMP
- activo boolean default true

# Ordenes 
- ordenId
- fehaOrden
- numero pedido
- 

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
- creadoEn timestamp
- usuarioAuditoria int //FK -> Usuarios
- activo boolean default true

# Trazabilidad //saber donde está, y quien la está manipulando


# ProductosPorOrden

# Transacciones

# Marcas


# ImpuestosPorPais 
- impuestoId serial auto-increment (PK)
- productoBaseId int (FK -> Productoas
- paisDestinoId int (FK -> Paises.paisId)
- tipoImpuesto varchar(30) // 'arancel_ad_valorem', 'arancel_especifico', 'tasa_estadistica'
- porcentaje decimal(5,2) // Ej: 12.50 para 12.5%
- montoFijoUsd decimal(10,2) // Para aranceles específicos
- vigenciaDesde date
- vigenciaHasta date
- creadoEn timestamp default current_timestamp
- usuarioAuditoria int (FK -> Usuarios.usuarioId)
- activo boolean default true

# transacciones
- transaccionid (PK) GENERATED ALWAYS AS INDENTITY
- tipoTransaccionId (FK a tiposdetransacciones)
- monto money (12,2) -- 12 digitos de los cuales 2 son decimales
- detalle varchar(100)
- fechaHora TIMESTAMP
- usuarioId FK
- movimientoId FK movimientos

# movimientos
- movimientoId (PK) GENERATED ALWAYS AS INDENTITY
- tipoProductoId FK a tiposdeproducto
- tipoMovimientoId Fk
- cantidad Integer 
- creadoEn TIMESTAMP
- usuarioAuditoria (FK)
- ultimaAuditoria TIMESTAMP
- activo boolean





- Transactions, transacciones de compra de productos en el país de origen, montos positivos significa dinero a favor de Etheria, montos negativos dineros que Etheria paga, tienen su currency
- Productos 
- Categorías de productos 
- Brands , brands de origen 
- Proveedores del producto
- Informacio de contacto de proveedores
- Precios por producto, tomar en cuenta que cambian en el tiempo
- Ordenes, fecha, numero de pedido, la lista de productos con cantidad y precios, descuentos e impuestos, estado
- Trazabilidad de la orden, saber donde está, y quien la está manipulando
- Impuestos por país 
