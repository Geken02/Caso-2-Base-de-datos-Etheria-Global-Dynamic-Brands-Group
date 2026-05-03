import json
import psycopg2
import mysql.connector 
from sqlalchemy import create_engine
import pandas as pd
from datetime import datetime

# 1. Configuracion de conexiones

PG_ETHERIA_CONFIG = {
    'host': 'localhost',
    'port': 5432,
    'user': 'postgres',
    'password': '123456',
    'database': 'Etheria-db'
}

MYSQL_DYNAMIC_CONFIG = {
    'host': 'localhost',
    'user': 'root',
    'password': '123456',
    'database': 'dynamicbrands_db'
}

PG_DW_CONFIG = {
    'host': 'localhost',
    'port': 5432,
    'user': 'postgres',
    'password': '123456',
    'database': 'datawarehouse'
}


# 2. Extraccion de datos

def obtener_tasas_cambio_etheria(conn_pg):
    """
    Extrae las tasas reales y vigentes desde Etheria.
    Devuelve un diccionario: {'CRC': 0.00192, 'BRL': 0.181, ...}
    """
    print("Extrayendo tasas de cambio VIGENTES desde Etheria...")
    
    
    query = """
    SELECT c.codigoiso, tc.exchangerate
    FROM tasasdecambio tc
    JOIN currencies c ON tc.currencyid1 = c.currencyid
    JOIN currencies c_dest ON tc.currencyid2 = c_dest.currencyid
    WHERE c_dest.codigoiso = 'USD' 
      AND tc.activo = TRUE
    """
    
    try:
        df = pd.read_sql(query, conn_pg)
        if df.empty:
            print("ADVERTENCIA: No se encontraron tasas de cambio activas en Etheria.")
            return {'USD': 1.0} 
        
        tasas = dict(zip(df['codigoiso'], df['exchangerate']))
        tasas['USD'] = 1.0 
        print(f"Tasas cargadas: {tasas}")
        return tasas
    except Exception as e:
        print(f"Error crítico leyendo tasas: {e}")
        raise e

def obtener_costos_etheria(conn_pg, tasas):
    """
    Extrae costos desde Etheria calculando el Landed Cost real.
    """
    print("Extrayendo costos calculados (Landed Cost) desde Etheria...")
    
   
    query = """
    SELECT 
        p.skuinterno,
        lb.lotebulkid,
        lb.numeroLoteProveedor,
        lb.costototal,
        lb.cantidadtotal,
        COALESCE(SUM(co.montoconvertido), 0) as total_costos_operativos
    FROM lotesbulk lb
    JOIN productos p ON lb.productoid = p.productoid
    LEFT JOIN costosoperativos co ON lb.lotebulkid = co.lotebulkid
    GROUP BY p.skuinterno, lb.lotebulkid, lb.numeroLoteProveedor, lb.costototal, lb.cantidadtotal
    """
    
    try:
        df = pd.read_sql(query, conn_pg)
        
        if not df.empty:

            df['costo_operativo_rateado'] = df['total_costos_operativos'] / df['cantidadtotal']
            df['costo_base_unitario'] = df['costototal'] / df['cantidadtotal']
            df['costototalunitario'] = df['costo_base_unitario'] + df['costo_operativo_rateado']
            
            return df[['skuinterno', 'costototalunitario']]
        else:
            print("No se encontraron lotes en Etheria.")
            return pd.DataFrame()
    except Exception as e:
        print(f"Error extrayendo costos: {e}")
        return pd.DataFrame()

def extraer_ventas_dynamic(conn_mysql, tasas):
    print("Extrayendo ventas desde Dynamic Brands...")
    
    query = """
    SELECT 
        ov.fechaOrden,
        t.nombreTienda,
        p_dest.codigoIso as paisDestino,
        c.codigoIso as monedaVenta,
        
        p.skuInterno,
        p.nombreTecnico,          
        tp.nombreTipoProducto,    
        m.nombreMarcaOriginal,
        
        -- Ahora sí obtenemos el nombre REAL de la marca blanca desde su tabla maestra
        mb_master.nombreMarcaBlanca as nombreMarcaBlanca, 
        
        CASE WHEN mb_master.nombreMarcaBlanca LIKE '%IA%' OR mb_master.nombreMarcaBlanca LIKE '%Auto%' THEN TRUE ELSE FALSE END as esMarcaIa,
        
        dov.cantidad,
        dov.precioUnitarioLocal
    FROM OrdenesVenta ov
    JOIN DetallesOrdenesVenta dov ON ov.ordenVentaId = dov.ordenVentaId
    JOIN ProductosMarcasBlancas mb ON dov.productoMarcaId = mb.productoMarcaId
    -- JOIN CLAVE: Unir con la tabla maestra de marcas blancas
    JOIN MarcasBlancas mb_master ON mb.marcaBlancaId = mb_master.marcaBlancaId
    JOIN Productos p ON mb.productoId = p.productoId
    JOIN MarcasOriginales m ON p.marcaOriginalId = m.marcaOriginalId
    JOIN TiposProducto tp ON p.tipoProductoId = tp.tipoProductoId
    JOIN TiendasVirtualesGeneradas t ON ov.tiendaId = t.tiendaId
    JOIN Paises p_dest ON t.paisId = p_dest.paisId
    JOIN Currencies c ON t.currencyId = c.currencyId
    WHERE ov.activo = TRUE
    """
    
    try:
        df = pd.read_sql(query, conn_mysql)
        
        if df.empty:
            return pd.DataFrame()

        df['tasa_aplicada'] = df['monedaVenta'].map(tasas).fillna(1.0)
        df['precioUnitario'] = df['precioUnitarioLocal'] * df['tasa_aplicada']
        df['ingresoTotal'] = df['cantidad'] * df['precioUnitario']
        
        return df
    except Exception as e:
        print(f"Error en ventas: {e}")
        print("Verifica que la tabla 'MarcasBlancas' exista y tenga la columna 'nombreMarcaBlanca'.")
        return pd.DataFrame()

# ==============================================================================
# 3. TRANSFORMACIÓN Y CARGA

def transformar_y_cargar(df_costos, df_ventas):
    if df_ventas.empty or df_costos.empty:
        print("No hay datos suficientes para cruzar.")
        return pd.DataFrame()

    print("Cruzando datos (SKU)...")
    
    df_ventas.columns = [str(c).lower() for c in df_ventas.columns]
    df_costos.columns = [str(c).lower() for c in df_costos.columns]
    

    if 'skuinterno' not in df_ventas.columns:

        posibles = ['skuinterno', 'sku_interno', 'sku']
        encontrado = next((c for c in posibles if c in df_ventas.columns), None)
        if encontrado:
            df_ventas = df_ventas.rename(columns={encontrado: 'skuinterno'})
        else:
            print("No se encontró la columna SKU en ventas. Columnas disponibles:", df_ventas.columns.tolist())
            return pd.DataFrame()

    df = pd.merge(df_ventas, df_costos, on='skuinterno', how='left')
    
    if 'costototalunitario' in df.columns:
        df['costototalunitario'] = df['costototalunitario'].fillna(0)
        
        df['costototalventa'] = df['cantidad'] * df['costototalunitario']
        
        if 'preciounitario' not in df.columns:
             if 'preciounitariolocal' in df.columns and 'tasa_aplicada' in df.columns:
                 df['preciounitario'] = df['preciounitariolocal'] * df['tasa_aplicada']
             else:
                 print("Faltan columnas para calcular precio")
                 df['preciounitario'] = 0

        df['margenbrutounitario'] = df['preciounitario'] - df['costototalunitario']
        
        df['margenporcentaje'] = df.apply(
            lambda x: ((x['margenbrutounitario'] / x['preciounitario']) * 100) if x['preciounitario'] > 0 else 0, 
            axis=1
        ).round(2)
    else:
        print("Falta columna de costo.")
        return pd.DataFrame()

    mapa_columnas = {
        'fechaorden': 'fechaVenta',
        'skuinterno': 'skuProducto',
        'nombretecnicoproducto': 'nombreProducto', 
        'nombretipoproducto': 'tipoProducto',
        'nombremarcaoriginal': 'marcaBlanca',
        'paisdestino': 'paisVenta',
        'nombretienda': 'tiendaOrigen',
        'monedaventa': 'monedaOriginal',
        'cantidad': 'cantidad_vendida',
        'preciounitariolocal': 'precioUnitarioLocal',
        'preciounitario': 'precioUnitario',
        'ingresototal': 'ingresoTotal',
        'costototalventa': 'costoTotalVenta',
        'margenbrutounitario': 'margenBrutoUnitario',
        'margenporcentaje': 'margenPorcentaje',
        'costototalunitario': 'costoTotalUnitario',
        'esmarcaia': 'esMarcaIa',
        'ciudadventa': 'ciudadVenta' 
    }

    cols_existentes = [c for c in mapa_columnas.keys() if c in df.columns]
    df_final = df.rename(columns={k: mapa_columnas[k] for k in cols_existentes})

    columnas_destino = [
        'fechaVenta', 'skuProducto', 'nombreProducto', 'tipoProducto', 
        'esMarcaIa', 'marcaBlanca', 'paisVenta', 'ciudadVenta', 'tiendaOrigen',
        'cantidad_vendida', 'monedaOriginal', 'precioUnitarioLocal', 
        'precioUnitario', 'ingresoTotal', 'costoTotalUnitario', 
        'costoTotalVenta', 'margenBrutoUnitario', 'margenPorcentaje'
    ]
    
    for col in columnas_destino:
        if col not in df_final.columns:
            df_final[col] = None

    if 'esMarcaIa' in df_final.columns:
        df_final['esMarcaIa'] = df_final['esMarcaIa'].astype(bool)

    return df_final[columnas_destino]

def cargar_postgresql(df):
    if df.empty: return
    
    print("Cargando en DataWarehouse...")
    try:
        conn_string = f"postgresql://{PG_DW_CONFIG['user']}:{PG_DW_CONFIG['password']}@{PG_DW_CONFIG['host']}:{PG_DW_CONFIG['port']}/{PG_DW_CONFIG['database']}"
        engine = create_engine(conn_string)
        
        with engine.connect() as conn:
            df.to_sql(
                'reporterentabilidadglobal', 
                con=conn, 
                schema='dwanalytics', 
                if_exists='append', 
                index=False, 
                method='multi'
            )
        print(f"¡Éxito! {len(df)} registros cargados.")
    except Exception as e:
        print(f"Error al cargar: {e}")

        if not df.empty:
            print("Muestra de datos intentados:")
            print(df.head())

if __name__ == "__main__":
    try:
        conn_pg = psycopg2.connect(**PG_ETHERIA_CONFIG)
        conn_mysql = mysql.connector.connect(**MYSQL_DYNAMIC_CONFIG)
        
        tasas = obtener_tasas_cambio_etheria(conn_pg)
        
        df_costos = obtener_costos_etheria(conn_pg, tasas)
        
        df_ventas = extraer_ventas_dynamic(conn_mysql, tasas)
        
        conn_pg.close()
        conn_mysql.close()
        
        if not df_costos.empty and not df_ventas.empty:
            df_res = transformar_y_cargar(df_costos, df_ventas)
            cargar_postgresql(df_res)
        else:
            print("No hay datos suficientes (revisa logs).")
            
    except Exception as e:
        print(f"Error general: {e}")