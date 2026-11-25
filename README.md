# SubCompra

Tienda en línea de productos tecnológicos (laptops, computadoras, celulares y consolas) con venta a todo México.
Proyecto de la materia **Ingeniería de Software** – Facultad de Informática, Universidad Autónoma de Sinaloa.

- **Grupo:** 3-2, Turno Vespertino
- **Profesor:** Fidel Bojórquez Solis

## Integrantes del equipo

- Alejandro Del Campo Guillén
- Sergio Leopoldo Valenzuela Camacho
- Jeffry Alejandro Montes Silva
- Isaac Alberto Sanz Cortez
- Said Fernando Vega Zepeda

## Estructura del repositorio

```
subcompra/
├── db/
│   ├── subcompra.sql                 # Script completo (crea la BD, las tablas y 3 usuarios)
│   ├── 01_crear_base_de_datos.sql    # Parte a) crear la base de datos
│   ├── 02_crear_tablas.sql           # Parte b) crear las tablas con llaves primarias y foráneas
│   └── 03_insertar_usuarios.sql      # Parte c) insertar 3 usuarios
├── docs/
│   ├── Diagrama_ER.png               # Diagrama Entidad-Relación
│   └── SubCompra_Diagrama_Entidad_Relacion.pdf
└── README.md
```

## Base de datos

Manejador: **PostgreSQL 14 o superior**. El modelo tiene **18 tablas** y **22 llaves foráneas**
(ver `docs/Diagrama_ER.png`).

### Ejecutar el script completo (psql)

```bash
psql -U postgres -f db/subcompra.sql
```

El script elimina la base `subcompra` si ya existía, la crea de nuevo, crea las tablas e inserta los usuarios.

### Ejecutarlo en pgAdmin (por partes)

pgAdmin no acepta el comando `\connect`, así que se corre en tres pasos:

1. Conectado a la base `postgres`, abrir y ejecutar `db/01_crear_base_de_datos.sql`.
2. Conectado a la base `subcompra`, abrir y ejecutar `db/02_crear_tablas.sql`.
3. Conectado a la base `subcompra`, abrir y ejecutar `db/03_insertar_usuarios.sql`.

### Usuarios de prueba

| Rol | Correo | Contraseña |
|---|---|---|
| Administrador | admin@subcompra.mx | Admin2025 |
| Encargado de inventario | inventario@subcompra.mx | Inventario2025 |
| Cliente | cliente@subcompra.mx | Cliente2025 |

Las contraseñas se guardan cifradas con bcrypt (columna `contrasena_hash`). Son datos de ejemplo solo para pruebas.
