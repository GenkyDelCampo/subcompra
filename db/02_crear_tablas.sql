-- SubCompra – Parte 2: crear las tablas (ejecutar conectado a la BD 'subcompra')
-- =====================================================================
--  b) CREAR LAS ENTIDADES (TABLAS)
--     PK = llave primaria, FK = llave foránea, UNIQUE = valor único
-- =====================================================================

-- USUARIO: Persona con cuenta en el sistema. Un mismo registro representa al cliente, al administrador o al encargado de inventario según su rol.
CREATE TABLE usuarios (
    id_usuario            SERIAL PRIMARY KEY,
    nombre                VARCHAR(60) NOT NULL,
    apellidos             VARCHAR(80) NOT NULL,
    correo                VARCHAR(120) NOT NULL UNIQUE,
    telefono              VARCHAR(10) NOT NULL,
    contrasena_hash       VARCHAR(100) NOT NULL,
    rol                   VARCHAR(15) NOT NULL DEFAULT 'cliente',
    estado                VARCHAR(12) NOT NULL DEFAULT 'pendiente',
    intentos_fallidos     INT NOT NULL DEFAULT 0,
    bloqueado_hasta       TIMESTAMPTZ,
    creado_en             TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CHECK (rol IN ('cliente','administrador','inventario')),
    CHECK (estado IN ('pendiente','activo','desactivado')),
    CHECK (intentos_fallidos >= 0)
);

-- TOKEN_USUARIO: Enlaces de un solo uso para activar la cuenta o recuperar la contraseña.
CREATE TABLE tokens_usuario (
    id_token              SERIAL PRIMARY KEY,
    id_usuario            INT NOT NULL,
    tipo                  VARCHAR(12) NOT NULL,
    token_hash            VARCHAR(100) NOT NULL,
    expira_en             TIMESTAMPTZ NOT NULL,
    usado                 BOOLEAN NOT NULL DEFAULT FALSE,
    FOREIGN KEY (id_usuario) REFERENCES usuarios (id_usuario) ON DELETE CASCADE,
    CHECK (tipo IN ('activacion','recuperacion'))
);

-- BITACORA: Registro de acciones importantes (inicios de sesión, cambios de precio, ofertas, ajustes de inventario) para auditoría.
CREATE TABLE bitacora (
    id_bitacora           SERIAL PRIMARY KEY,
    id_usuario            INT,
    accion                VARCHAR(200) NOT NULL,
    ip                    VARCHAR(45),
    fecha                 TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    FOREIGN KEY (id_usuario) REFERENCES usuarios (id_usuario) ON DELETE SET NULL
);

-- DIRECCION_ENVIO: Domicilios de entrega que el cliente registra; uno puede marcarse como predeterminado.
CREATE TABLE direcciones_envio (
    id_direccion          SERIAL PRIMARY KEY,
    id_usuario            INT NOT NULL,
    calle                 VARCHAR(100) NOT NULL,
    num_exterior          VARCHAR(10) NOT NULL,
    num_interior          VARCHAR(10),
    colonia               VARCHAR(80) NOT NULL,
    codigo_postal         CHAR(5) NOT NULL,
    municipio             VARCHAR(80) NOT NULL,
    estado                VARCHAR(40) NOT NULL,
    referencias           VARCHAR(200),
    predeterminada        BOOLEAN NOT NULL DEFAULT FALSE,
    FOREIGN KEY (id_usuario) REFERENCES usuarios (id_usuario) ON DELETE CASCADE
);

-- CARRITO: Carrito de compras persistente de un cliente (uno por cliente).
CREATE TABLE carritos (
    id_carrito            SERIAL PRIMARY KEY,
    id_usuario            INT NOT NULL UNIQUE,
    actualizado_en        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    FOREIGN KEY (id_usuario) REFERENCES usuarios (id_usuario) ON DELETE CASCADE
);

-- CATEGORIA: Clasificación de los productos (laptops, computadoras de escritorio, celulares, consolas, accesorios, etc.).
CREATE TABLE categorias (
    id_categoria          SERIAL PRIMARY KEY,
    nombre                VARCHAR(60) NOT NULL,
    descripcion           VARCHAR(200),
    activa                BOOLEAN NOT NULL DEFAULT TRUE
);

-- PRODUCTO: Artículo tecnológico a la venta, con su precio, existencias y stock mínimo.
CREATE TABLE productos (
    id_producto           SERIAL PRIMARY KEY,
    id_categoria          INT NOT NULL,
    nombre                VARCHAR(120) NOT NULL,
    marca                 VARCHAR(60) NOT NULL,
    modelo                VARCHAR(60) NOT NULL,
    descripcion           TEXT,
    especificaciones      TEXT,
    precio                NUMERIC(10,2) NOT NULL,
    garantia              VARCHAR(40),
    existencias           INT NOT NULL DEFAULT 0,
    stock_minimo          INT NOT NULL DEFAULT 5,
    estado                VARCHAR(12) NOT NULL DEFAULT 'activo',
    fecha_alta            TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    FOREIGN KEY (id_categoria) REFERENCES categorias (id_categoria) ON DELETE RESTRICT,
    CHECK (precio > 0),
    CHECK (existencias >= 0),
    CHECK (stock_minimo >= 0),
    CHECK (estado IN ('activo','baja'))
);

-- DETALLE_CARRITO: Productos y cantidades que están dentro de un carrito. Resuelve la relación muchos a muchos entre CARRITO y PRODUCTO.
CREATE TABLE detalle_carrito (
    id_detalle_carrito    SERIAL PRIMARY KEY,
    id_carrito            INT NOT NULL,
    id_producto           INT NOT NULL,
    cantidad              INT NOT NULL,
    FOREIGN KEY (id_carrito) REFERENCES carritos (id_carrito) ON DELETE CASCADE,
    FOREIGN KEY (id_producto) REFERENCES productos (id_producto) ON DELETE RESTRICT,
    CHECK (cantidad > 0),
    UNIQUE (id_carrito, id_producto)
);

-- IMAGEN_PRODUCTO: Fotografías de un producto.
CREATE TABLE imagenes_producto (
    id_imagen             SERIAL PRIMARY KEY,
    id_producto           INT NOT NULL,
    url                   VARCHAR(255) NOT NULL,
    orden                 INT NOT NULL DEFAULT 1,
    FOREIGN KEY (id_producto) REFERENCES productos (id_producto) ON DELETE CASCADE
);

-- OFERTA: Promoción con porcentaje de descuento y vigencia, creada por un administrador.
CREATE TABLE ofertas (
    id_oferta             SERIAL PRIMARY KEY,
    id_usuario            INT NOT NULL,
    nombre                VARCHAR(80) NOT NULL,
    porcentaje_descuento  INT NOT NULL,
    fecha_inicio          TIMESTAMPTZ NOT NULL,
    fecha_fin             TIMESTAMPTZ NOT NULL,
    estado                VARCHAR(12) NOT NULL DEFAULT 'programada',
    FOREIGN KEY (id_usuario) REFERENCES usuarios (id_usuario) ON DELETE RESTRICT,
    CHECK (porcentaje_descuento BETWEEN 1 AND 90),
    CHECK (fecha_fin > fecha_inicio),
    CHECK (estado IN ('programada','vigente','finalizada'))
);

-- OFERTA_PRODUCTO: Productos a los que aplica cada oferta. Resuelve la relación muchos a muchos entre OFERTA y PRODUCTO.
CREATE TABLE oferta_producto (
    id_oferta             INT NOT NULL,
    id_producto           INT NOT NULL,
    PRIMARY KEY (id_oferta, id_producto),
    FOREIGN KEY (id_oferta) REFERENCES ofertas (id_oferta) ON DELETE CASCADE,
    FOREIGN KEY (id_producto) REFERENCES productos (id_producto) ON DELETE RESTRICT
);

-- PEDIDO: Compra confirmada por un cliente, con folio único, dirección de envío, totales y seguimiento.
CREATE TABLE pedidos (
    id_pedido             SERIAL PRIMARY KEY,
    id_usuario            INT NOT NULL,
    id_direccion          INT NOT NULL,
    folio                 VARCHAR(20) NOT NULL UNIQUE,
    fecha                 TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    metodo_pago           VARCHAR(20) NOT NULL,
    subtotal              NUMERIC(10,2) NOT NULL,
    costo_envio           NUMERIC(10,2) NOT NULL DEFAULT 0,
    iva                   NUMERIC(10,2) NOT NULL,
    total                 NUMERIC(10,2) NOT NULL,
    estado                VARCHAR(20) NOT NULL DEFAULT 'pagado',
    paqueteria            VARCHAR(40),
    numero_guia           VARCHAR(40),
    FOREIGN KEY (id_usuario) REFERENCES usuarios (id_usuario) ON DELETE RESTRICT,
    FOREIGN KEY (id_direccion) REFERENCES direcciones_envio (id_direccion) ON DELETE RESTRICT,
    CHECK (subtotal >= 0 AND costo_envio >= 0 AND iva >= 0 AND total >= 0),
    CHECK (metodo_pago IN ('tarjeta','spei','tienda','contra_entrega')),
    CHECK (estado IN ('pagado','en_preparacion','enviado','entregado','cancelado'))
);

-- DETALLE_PEDIDO: Productos incluidos en un pedido con el precio y descuento vigentes al comprar (historial de ventas).
CREATE TABLE detalle_pedido (
    id_detalle_pedido     SERIAL PRIMARY KEY,
    id_pedido             INT NOT NULL,
    id_producto           INT NOT NULL,
    cantidad              INT NOT NULL,
    precio_unitario       NUMERIC(10,2) NOT NULL,
    descuento             NUMERIC(10,2) NOT NULL DEFAULT 0,
    FOREIGN KEY (id_pedido) REFERENCES pedidos (id_pedido) ON DELETE CASCADE,
    FOREIGN KEY (id_producto) REFERENCES productos (id_producto) ON DELETE RESTRICT,
    CHECK (cantidad > 0),
    CHECK (precio_unitario >= 0 AND descuento >= 0)
);

-- VENTA: Registro del cobro de un pedido, generado cuando la pasarela de pago autoriza el pago.
CREATE TABLE ventas (
    id_venta              SERIAL PRIMARY KEY,
    id_pedido             INT NOT NULL UNIQUE,
    fecha                 TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    metodo_pago           VARCHAR(20) NOT NULL,
    monto                 NUMERIC(10,2) NOT NULL,
    estado_pago           VARCHAR(15) NOT NULL DEFAULT 'pendiente',
    referencia_pago       VARCHAR(40),
    vigencia_referencia   TIMESTAMPTZ,
    FOREIGN KEY (id_pedido) REFERENCES pedidos (id_pedido) ON DELETE RESTRICT,
    CHECK (monto >= 0),
    CHECK (estado_pago IN ('pendiente','autorizado','rechazado','reembolsado'))
);

-- FACTURA: Datos fiscales para emitir la factura electrónica (CFDI) de un pedido.
CREATE TABLE facturas (
    id_factura            SERIAL PRIMARY KEY,
    id_pedido             INT NOT NULL UNIQUE,
    rfc                   VARCHAR(13) NOT NULL,
    razon_social          VARCHAR(150) NOT NULL,
    regimen_fiscal        VARCHAR(60) NOT NULL,
    codigo_postal_fiscal  CHAR(5) NOT NULL,
    uso_cfdi              VARCHAR(40) NOT NULL,
    fecha_emision         TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    FOREIGN KEY (id_pedido) REFERENCES pedidos (id_pedido) ON DELETE RESTRICT
);

-- PROVEEDOR: Empresa o persona que surte productos a SubCompra.
CREATE TABLE proveedores (
    id_proveedor          SERIAL PRIMARY KEY,
    nombre                VARCHAR(100) NOT NULL,
    telefono              VARCHAR(10),
    correo                VARCHAR(120),
    activo                BOOLEAN NOT NULL DEFAULT TRUE
);

-- PRODUCTO_PROVEEDOR: Productos que suministra cada proveedor. Resuelve la relación muchos a muchos entre PRODUCTO y PROVEEDOR.
CREATE TABLE producto_proveedor (
    id_producto           INT NOT NULL,
    id_proveedor          INT NOT NULL,
    PRIMARY KEY (id_producto, id_proveedor),
    FOREIGN KEY (id_producto) REFERENCES productos (id_producto) ON DELETE RESTRICT,
    FOREIGN KEY (id_proveedor) REFERENCES proveedores (id_proveedor) ON DELETE RESTRICT
);

-- REABASTECIMIENTO: Entrada de mercancía al inventario; al registrarla se suman las existencias del producto.
CREATE TABLE reabastecimientos (
    id_reabastecimiento   SERIAL PRIMARY KEY,
    id_producto           INT NOT NULL,
    id_proveedor          INT NOT NULL,
    id_usuario            INT NOT NULL,
    cantidad_recibida     INT NOT NULL,
    costo_unitario        NUMERIC(10,2) NOT NULL,
    fecha                 TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    FOREIGN KEY (id_producto) REFERENCES productos (id_producto) ON DELETE RESTRICT,
    FOREIGN KEY (id_proveedor) REFERENCES proveedores (id_proveedor) ON DELETE RESTRICT,
    FOREIGN KEY (id_usuario) REFERENCES usuarios (id_usuario) ON DELETE RESTRICT,
    CHECK (cantidad_recibida > 0),
    CHECK (costo_unitario >= 0)
);

-- Índices para las consultas más frecuentes
CREATE INDEX idx_productos_categoria   ON productos (id_categoria);
CREATE INDEX idx_pedidos_usuario       ON pedidos (id_usuario);
CREATE INDEX idx_detalle_pedido_pedido ON detalle_pedido (id_pedido);
CREATE INDEX idx_bitacora_usuario      ON bitacora (id_usuario);
