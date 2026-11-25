-- SubCompra – Parte 3: insertar 3 usuarios (ejecutar conectado a la BD 'subcompra')
-- =====================================================================
--  c) INSERTAR 3 REGISTROS EN LA TABLA DE USUARIOS
--     Un usuario por cada rol del sistema (administrador, encargado de
--     inventario y cliente). Las contraseñas están cifradas con bcrypt
--     (nunca se guardan en texto plano).
--     Contraseñas de prueba:  Admin2025 / Inventario2025 / Cliente2025
-- =====================================================================
INSERT INTO usuarios (nombre, apellidos, correo, telefono, contrasena_hash, rol, estado) VALUES
('Alejandro', 'Del Campo Guillén', 'admin@subcompra.mx',      '6671000001', '$2b$10$1Llqc35PBpAfAd8jU63zXeMSgMq/0XPYmIe7H7h.3J4JjVAOQ4mh2', 'administrador', 'activo'),
('Sergio',    'Valenzuela Camacho', 'inventario@subcompra.mx', '6671000002', '$2b$10$yCG6kHObz8Nji8euYHv0hOo4UUFRgCtsSRlfkjpP1J96rdoB6EsSi', 'inventario',    'activo'),
('María',     'López Hernández',    'cliente@subcompra.mx',    '6671000003', '$2b$10$nCMwV9if3eYR.bzzPQ5Hn.ZNqidq78jz.6bKwcoURfK7v4ONmYoDi', 'cliente',       'activo');

-- Verificación: debe mostrar los 3 usuarios
SELECT id_usuario, nombre, apellidos, correo, rol, estado FROM usuarios ORDER BY id_usuario;
