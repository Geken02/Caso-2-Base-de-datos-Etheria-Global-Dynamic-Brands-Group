Nombre: Etheria Global db
Motor de base de datos: Postgres 

## Tables 

# Ciudades
- ciudadId serial auto-increment (PK)
- nombre varchar(50)
- provinciaId (FK)
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
- nombre varchar(50)
- codigoIso varchar(3)
- creadoEn TIMESTAMP
- usuarioAuditoria (FK)
- ultimaAuditoria TIMESTAMP
- activo boolean

# Puertos 
- puertoId serial auto-increment (PK)
- nombre varchar(50)
- ciudadId FK
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
- creadoEn TIMESTAMP
- usuarioAuditoria (FK)
- ultimaAuditoria TIMESTAMP
- activo boolean

# Currencies
- currencyId serial auto-increment (PK)
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

# Ordenes 
- ordenId
- fehaOrden
- numero pedido
- 

# Productos

# ProductosPorOrden

# Transacciones

# TiposProductos

# Marcas

# Proveedores

# InfoContactoProveedores

# PreciosPorProducto

# Trazabilidad //saber donde está, y quien la está manipulando

# ImpuestosPorPais



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
