import psycopg2 # <--- Cambiar import
import pandas as pd

# Configuración para PostgreSQL
CONFIG_DW = {
    'host': 'localhost',
    'port': 5432,          # Puerto default de Postgres
    'user': 'tu_usuario',
    'password': 'tu_password',
    'database': 'dynamic_dw' # O el nombre de tu BD en Postgres
}

def load_to_dw(df):
    if df.empty: return
    
    print("Cargando datos en PostgreSQL...")
    conn = psycopg2.connect(**CONFIG_DW)
    
    # to_sql funciona genial con psycopg2
    df.to_sql(
        'reporterentabilidadglobal', # Nombre de tabla en minúsculas (Postgres es case-sensitive con comillas)
        con=conn, 
        schema='dw_analytics',       # Especificar esquema
        if_exists='append', 
        index=False, 
        method='multi'
    )
    
    conn.close()
    print(f"¡Éxito! {len(df)} registros cargados.")

def extract_costs_etheria():
    """
    Calcula el Costo Total Unitario (Landed Cost) prorrateando todos los costos operativos
    encontrados en el array 'costos' del JSON original (ya cargado en BD).
    """
    print("📥 Extrayendo y calculando costos rateados desde Etheria...")
    
    # Esta consulta asume que ya cargaste el JSON en las tablas LotesBulk y CostosOperativos
    # Agrupa por Lote (Pedido) para sumar todos los costos extra
    query = """
    SELECT 
        lb.loteBulkId,
        lb.numeroPedido,
        p.skuInterno,
        lb.cantidadTotal as cantidad_lote,
        
        -- 1. Costo Base de Compra (Producto * Cantidad)
        SUM(p.precioUnitarioAcordado * lb.cantidadSolicitada) as costo_base_total,
        
        -- 2. Suma de TODOS los costos operativos del array 'costos' asociados a este lote
        -- Asumimos que ya fueron convertidos a USD en la carga o aquí los convertimos
        COALESCE(SUM(co.montoConvertidoUsd), 0) as costos_operativos_totales_usd
        
    FROM etheria_db.LotesBulk lb
    JOIN etheria_db.Productos p ON lb.productoId = p.productoId -- Join correcto según tu esquema
    LEFT JOIN etheria_db.CostosOperativos co ON lb.loteBulkId = co.loteBulkId
    GROUP BY lb.loteBulkId, lb.numeroPedido, p.skuInterno, lb.cantidadTotal
    """
    
    df = pd.read_sql(query, CONN_ETHERIA)
    
    if not df.empty:
        # --- CÁLCULO DEL RATEO ---
        
        # Costo Total del Lote (Base + Operativos)
        df['costo_total_lote_usd'] = df['costo_base_total'] + df['costos_operativos_totales_usd']
        
        # Costo Unitario Real (Prorrateado)
        # Dividimos el costo total del lote entre la cantidad total de items en ese lote
        df['costo_total_unitario_usd'] = df['costo_total_lote_usd'] / df['cantidad_lote']
        
        # Retornamos solo lo necesario para el merge posterior
        return df[['skuInterno', 'loteBulkId', 'costo_total_unitario_usd']]
    
    return pd.DataFrame(columns=['skuInterno', 'loteBulkId', 'costo_total_unitario_usd'])

def extract_sales_dynamic():
    """
    Extrae ventas detalladas desde Dynamic Brands con información de producto y tienda.
    """
    print("Extrayendo ventas desde Dynamic Brands...")
    query = """
    SELECT 
        ov.fechaOrden,
        ov.tiendaId,
        t.nombreTienda,
        p_dest.codigoIso as paisDestino,
        c.codigoIso as monedaVenta,
        tc.exchangeRate as tasaCambio, -- Asumimos tasa guardada en la orden o tabla tasas
        
        p.skuInterno,
        p.nombreTecnicoProducto as nombreProducto,
        tp.nombreTipoProducto as categoria,
        m.nombreMarcaOriginal as marcaOriginal,
        p_orig.codigoIso as paisOrigen,
        
        mb.nombreMarcaBlanca as marcaBlanca,
        -- Lógica simple para detectar marca IA (ej. si tiene nombre específico o flag)
        CASE WHEN mb.nombreMarcaBlanca LIKE '%IA%' OR mb.nombreMarcaBlanca LIKE '%Auto%' THEN TRUE ELSE FALSE END as esMarcaIA,
        
        dov.cantidad,
        dov.precioUnitarioLocal
    FROM dynamic_brands_db.OrdenesVenta ov
    JOIN dynamic_brands_db.DetallesOrdenesVenta dov ON ov.ordenVentaId = dov.ordenVentaId
    JOIN dynamic_brands_db.ProductosMarcasBlancas mb ON dov.productoMarcaId = mb.productoMarcaId
    JOIN dynamic_brands_db.Productos p ON mb.productoId = p.productoId
    JOIN dynamic_brands_db.MarcasOriginales m ON p.marcaOriginalId = m.marcaOriginalId
    JOIN dynamic_brands_db.Paises p_orig ON m.paisId = p_orig.paisId
    JOIN dynamic_brands_db.TiposProducto tp ON p.tipoProductoId = tp.tipoProductoId
    JOIN dynamic_brands_db.TiendasVirtualesGeneradas t ON ov.tiendaId = t.tiendaId
    JOIN dynamic_brands_db.Paises p_dest ON t.paisId = p_dest.paisId
    JOIN dynamic_brands_db.Currencies c ON t.currencyId = c.currencyId
    LEFT JOIN dynamic_brands_db.TasasDeCambio tc ON c.currencyId = tc.currencyId1 AND tc.currencyId2 = 2 -- Asumiendo USD=2
    WHERE ov.activo = TRUE
    """
    return pd.read_sql(query, CONN_DYNAMIC)

def transform_data(df_costs, df_sales):
    """
    Cruza datos y calcula márgenes.
    """
    print("Calculando márgenes...")
    if df_sales.empty:
        return pd.DataFrame()

    # Merge (Join) por SKU
    df = pd.merge(df_sales, df_costs, on='skuInterno', how='left')
    
    # Si no hay costo registrado (producto nuevo sin lote), asumimos 0 o un valor estándar
    df['costo_total_unitario_usd'] = df['costo_total_unitario_usd'].fillna(0)
    
    # Normalización de Moneda
    df['tasa_aplicada'] = df['tasaCambio'].fillna(1) # Si es null, asume 1 (misma moneda o error)
    
    # Cálculos Financieros
    df['precio_unitario_usd'] = df['precioUnitarioLocal'] / df['tasa_aplicada']
    df['ingreso_total_usd'] = df['cantidad'] * df['precio_unitario_usd']
    
    df['costo_total_venta_usd'] = df['cantidad'] * df['costo_total_unitario_usd']
    
    df['margen_bruto_total_usd'] = df['ingreso_total_usd'] - df['costo_total_venta_usd']
    
    # Evitar división por cero
    df['porcentaje_margen'] = df.apply(
        lambda x: ((x['margen_bruto_total_usd'] / x['ingreso_total_usd']) * 100) if x['ingreso_total_usd'] > 0 else 0, 
        axis=1
    ).round(2)
    
    # Renombrar columnas para coincidir con el DW
    df_final = df.rename(columns={
        'fechaOrden': 'fecha_venta',
        'skuInterno': 'sku_producto',
        'nombreProducto': 'nombre_producto',
        'categoria': 'categoria',
        'marcaOriginal': 'marca_original',
        'marcaBlanca': 'marca_blanca',
        'esMarcaIA': 'es_marca_ia',
        'paisOrigen': 'pais_origen',
        'paisDestino': 'pais_destino',
        'tiendaId': 'tienda_id',
        'nombreTienda': 'nombre_tienda',
        'monedaVenta': 'moneda_venta',
        'tasa_aplicada': 'tasa_cambio_aplicada',
        'cantidad': 'cantidad_vendida',
        'precioUnitarioLocal': 'precio_unitario_local'
    })
    
    # Seleccionar columnas exactas del DW
    cols_dw = [
        'fecha_venta', 'sku_producto', 'nombre_producto', 'categoria', 
        'marca_original', 'marca_blanca', 'es_marca_ia', 'pais_origen', 
        'pais_destino', 'tienda_id', 'nombre_tienda', 'moneda_venta', 
        'cantidad_vendida', 'precio_unitario_local', 'tasa_cambio_aplicada', 
        'precio_unitario_usd', 'ingreso_total_usd', 'costo_total_unitario_usd', 
        'costo_total_venta_usd', 'margen_bruto_total_usd', 'porcentaje_margen'
    ]
    
    return df_final[cols_dw]

def load_to_dw(df):
    if df.empty:
        print("No hay datos para cargar.")
        return

    print("💾 Cargando datos en el Data Warehouse...")
    # Usamos to_sql para una carga rápida y sencilla
    df.to_sql('fact_rentabilidad_global', con=CONN_DW, if_exists='append', index=False, method='multi')
    
    print(f"¡Éxito! {len(df)} registros procesados y cargados en el DW.")

if __name__ == "__main__":
    try:
        df_costs = extract_costs_etheria()
        df_sales = extract_sales_dynamic()
        
        df_result = transform_data(df_costs, df_sales)
        load_to_dw(df_result)
        
    except Exception as e:
        print(f"Error crítico en el ETL: {e}")
    finally:
        CONN_ETHERIA.close()
        CONN_DYNAMIC.close()
        CONN_DW.close()