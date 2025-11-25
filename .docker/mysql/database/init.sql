-- Base de datos para Sistema de Inventario
USE pablogarciajcbd;

-- Tablas de Django (requeridas por el framework)
CREATE TABLE IF NOT EXISTS django_session (
    session_key VARCHAR(40) NOT NULL PRIMARY KEY,
    session_data LONGTEXT NOT NULL,
    expire_date DATETIME(6) NOT NULL,
    INDEX django_session_expire_date_idx (expire_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS django_migrations (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    app VARCHAR(255) NOT NULL,
    name VARCHAR(255) NOT NULL,
    applied DATETIME(6) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS django_content_type (
    id INT AUTO_INCREMENT PRIMARY KEY,
    app_label VARCHAR(100) NOT NULL,
    model VARCHAR(100) NOT NULL,
    UNIQUE KEY django_content_type_app_label_model_uniq (app_label, model)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Tabla de roles
CREATE TABLE roles (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL UNIQUE,
    descripcion VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de usuarios
CREATE TABLE usuarios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(100) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    nombre_completo VARCHAR(150) NOT NULL,
    rol_id INT NOT NULL,
    activo BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (rol_id) REFERENCES roles(id)
);

-- Tabla de categorías
CREATE TABLE categorias (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    descripcion TEXT,
    activo BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de proveedores
CREATE TABLE proveedores (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL,
    ruc VARCHAR(20) UNIQUE,
    telefono VARCHAR(20),
    email VARCHAR(100),
    direccion TEXT,
    activo BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Tabla de almacenes
CREATE TABLE almacenes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    ubicacion VARCHAR(255),
    capacidad INT,
    activo BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de productos
CREATE TABLE productos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    codigo VARCHAR(50) NOT NULL UNIQUE,
    nombre VARCHAR(200) NOT NULL,
    descripcion TEXT,
    categoria_id INT NOT NULL,
    precio_compra DECIMAL(10,2) NOT NULL,
    precio_venta DECIMAL(10,2) NOT NULL,
    stock_minimo INT DEFAULT 10,
    stock_actual INT DEFAULT 0,
    proveedor_id INT,
    activo BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (categoria_id) REFERENCES categorias(id),
    FOREIGN KEY (proveedor_id) REFERENCES proveedores(id)
);

-- Tabla de clientes
CREATE TABLE clientes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL,
    documento VARCHAR(20) UNIQUE,
    telefono VARCHAR(20),
    email VARCHAR(100),
    direccion TEXT,
    activo BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Tabla de compras
CREATE TABLE compras (
    id INT AUTO_INCREMENT PRIMARY KEY,
    numero_factura VARCHAR(50) UNIQUE,
    proveedor_id INT NOT NULL,
    usuario_id INT NOT NULL,
    fecha DATE NOT NULL,
    total DECIMAL(10,2) NOT NULL,
    estado ENUM('pendiente', 'completada', 'cancelada') DEFAULT 'pendiente',
    notas TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (proveedor_id) REFERENCES proveedores(id),
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
);

-- Tabla de detalle de compras
CREATE TABLE detalle_compras (
    id INT AUTO_INCREMENT PRIMARY KEY,
    compra_id INT NOT NULL,
    producto_id INT NOT NULL,
    cantidad INT NOT NULL,
    precio_unitario DECIMAL(10,2) NOT NULL,
    subtotal DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (compra_id) REFERENCES compras(id) ON DELETE CASCADE,
    FOREIGN KEY (producto_id) REFERENCES productos(id)
);

-- Tabla de ventas
CREATE TABLE ventas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    numero_factura VARCHAR(50) UNIQUE,
    cliente_id INT NOT NULL,
    usuario_id INT NOT NULL,
    fecha DATE NOT NULL,
    total DECIMAL(10,2) NOT NULL,
    estado ENUM('pendiente', 'completada', 'cancelada') DEFAULT 'pendiente',
    tipo_pago ENUM('efectivo', 'tarjeta', 'transferencia') DEFAULT 'efectivo',
    notas TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (cliente_id) REFERENCES clientes(id),
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
);

-- Tabla de detalle de ventas
CREATE TABLE detalle_ventas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    venta_id INT NOT NULL,
    producto_id INT NOT NULL,
    cantidad INT NOT NULL,
    precio_unitario DECIMAL(10,2) NOT NULL,
    subtotal DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (venta_id) REFERENCES ventas(id) ON DELETE CASCADE,
    FOREIGN KEY (producto_id) REFERENCES productos(id)
);

-- Tabla de movimientos de inventario
CREATE TABLE movimientos_inventario (
    id INT AUTO_INCREMENT PRIMARY KEY,
    producto_id INT NOT NULL,
    almacen_id INT NOT NULL,
    tipo_movimiento ENUM('entrada', 'salida', 'ajuste') NOT NULL,
    cantidad INT NOT NULL,
    usuario_id INT NOT NULL,
    referencia VARCHAR(100),
    motivo TEXT,
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (producto_id) REFERENCES productos(id),
    FOREIGN KEY (almacen_id) REFERENCES almacenes(id),
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
);

-- Insertar roles por defecto
INSERT INTO roles (nombre, descripcion) VALUES
('Administrador', 'Acceso total al sistema'),
('Gerente', 'Gestión de inventario y reportes'),
('Vendedor', 'Registro de ventas y consultas'),
('Almacenero', 'Gestión de stock y almacenes');

-- Insertar usuarios por defecto (password: password para todos)
INSERT INTO usuarios (username, email, password, nombre_completo, rol_id) VALUES
('admin', 'admin@inventario.com', '240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9', 'Administrador Sistema', 1),
('superadmin', 'superadmin@superadmin.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5.dklB7qxL5fy', 'Super Administrador', 1),
('jperez', 'jperez@inventario.com', '56976bf24998ca63e35fe4f1e2469b5751d1856003e8d16fef0aafef496ed044', 'Juan Pérez', 2),
('mgonzalez', 'mgonzalez@inventario.com', '7439033334ff7f5d2d164c47fe54b5819c0f7cd1225ecbc3bbac5bc80206b01f', 'María González', 3),
('crodriguez', 'crodriguez@inventario.com', '5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8', 'Carlos Rodríguez', 4);

-- Insertar categorías de ejemplo
INSERT INTO categorias (nombre, descripcion) VALUES
('Electrónica', 'Productos electrónicos y tecnológicos'),
('Alimentos', 'Productos alimenticios no perecederos'),
('Ropa', 'Prendas de vestir y accesorios'),
('Hogar', 'Artículos para el hogar y decoración'),
('Oficina', 'Suministros y material de oficina'),
('Deportes', 'Artículos deportivos y fitness'),
('Juguetes', 'Juguetes y entretenimiento infantil');

-- Insertar almacenes
INSERT INTO almacenes (nombre, ubicacion, capacidad) VALUES
('Almacén Principal', 'Calle Principal 123, Centro', 1000),
('Almacén Secundario', 'Av. Comercio 456, Norte', 500),
('Almacén Zona Sur', 'Calle Los Olivos 789, Sur', 750);

-- Insertar proveedores
INSERT INTO proveedores (nombre, ruc, telefono, email, direccion) VALUES
('TecnoDistribuidora S.A.', '20123456789', '987654321', 'ventas@tecnodist.com', 'Av. Tecnología 100'),
('Alimentos del Valle', '20234567890', '987654322', 'contacto@alimentosvalle.com', 'Jr. Comercio 200'),
('Textiles Modernos', '20345678901', '987654323', 'info@textilesmodernos.com', 'Av. Industrial 300'),
('Hogar y Confort', '20456789012', '987654324', 'ventas@hogaryconfort.com', 'Calle Diseño 400'),
('Papelería Central', '20567890123', '987654325', 'pedidos@papeleriacentral.com', 'Jr. Oficinas 500');

-- Insertar productos (70+ productos para demo completa)
INSERT INTO productos (codigo, nombre, descripcion, categoria_id, precio_compra, precio_venta, stock_minimo, stock_actual, proveedor_id) VALUES
-- Electrónica (15 productos)
('ELEC-001', 'Laptop HP 15.6"', 'Laptop HP Intel Core i5, 8GB RAM, 256GB SSD', 1, 1500.00, 2200.00, 5, 12, 1),
('ELEC-002', 'Mouse Inalámbrico Logitech', 'Mouse óptico inalámbrico con receptor USB', 1, 25.00, 45.00, 20, 35, 1),
('ELEC-003', 'Teclado Mecánico RGB', 'Teclado mecánico gaming con iluminación RGB', 1, 80.00, 135.00, 10, 18, 1),
('ELEC-004', 'Monitor LED 24"', 'Monitor Full HD 1920x1080, 75Hz', 1, 350.00, 550.00, 8, 15, 1),
('ELEC-005', 'Auriculares Bluetooth', 'Auriculares inalámbricos con cancelación de ruido', 1, 60.00, 110.00, 15, 25, 1),
('ELEC-006', 'Tablet Samsung 10"', 'Tablet Android 64GB con lápiz óptico', 1, 450.00, 750.00, 8, 10, 1),
('ELEC-007', 'Webcam Full HD', 'Cámara web 1080p con micrófono', 1, 55.00, 95.00, 15, 22, 1),
('ELEC-008', 'Disco Duro Externo 1TB', 'HDD portátil USB 3.0', 1, 120.00, 185.00, 12, 28, 1),
('ELEC-009', 'Impresora Multifuncional', 'Impresora WiFi con escáner y copiadora', 1, 280.00, 450.00, 5, 8, 1),
('ELEC-010', 'Router WiFi 6', 'Router dual band hasta 1200Mbps', 1, 90.00, 155.00, 10, 16, 1),
('ELEC-011', 'Memoria USB 64GB', 'Pendrive USB 3.0 alta velocidad', 1, 18.00, 32.00, 30, 45, 1),
('ELEC-012', 'Cable HDMI 2m', 'Cable HDMI 2.0 4K Ultra HD', 1, 12.00, 22.00, 40, 68, 1),
('ELEC-013', 'Cargador Portátil 20000mAh', 'Power bank con doble puerto USB', 1, 35.00, 65.00, 20, 32, 1),
('ELEC-014', 'Adaptador Bluetooth USB', 'Adaptador Bluetooth 5.0 para PC', 1, 15.00, 28.00, 25, 40, 1),
('ELEC-015', 'Mousepad Gamer XXL', 'Alfombrilla gaming 90x40cm', 1, 20.00, 38.00, 15, 26, 1),

-- Alimentos (15 productos)
('ALIM-001', 'Arroz Premium 5kg', 'Arroz grano largo extra premium', 2, 12.50, 18.90, 50, 145, 2),
('ALIM-002', 'Aceite Vegetal 1L', 'Aceite vegetal 100% puro', 2, 8.00, 12.50, 30, 95, 2),
('ALIM-003', 'Azúcar Blanca 1kg', 'Azúcar refinada blanca', 2, 2.50, 4.20, 100, 180, 2),
('ALIM-004', 'Fideos Spaghetti 500g', 'Pasta italiana tipo spaghetti', 2, 1.80, 3.50, 80, 125, 2),
('ALIM-005', 'Café Molido 250g', 'Café premium 100% arábica', 2, 15.00, 24.00, 40, 68, 2),
('ALIM-006', 'Leche Evaporada x12', 'Pack de 12 latas de leche evaporada', 2, 28.00, 42.00, 35, 72, 2),
('ALIM-007', 'Atún en Lata x6', 'Pack de 6 latas de atún en aceite', 2, 22.00, 35.00, 40, 88, 2),
('ALIM-008', 'Harina de Trigo 1kg', 'Harina preparada para todo uso', 2, 3.20, 5.50, 60, 110, 2),
('ALIM-009', 'Sal de Mesa 1kg', 'Sal yodada de mesa', 2, 1.50, 2.80, 80, 140, 2),
('ALIM-010', 'Galletas Surtidas x6', 'Pack de galletas variadas', 2, 12.00, 19.50, 50, 95, 2),
('ALIM-011', 'Chocolate en Barra 90g', 'Chocolate con leche premium', 2, 3.50, 6.20, 70, 125, 2),
('ALIM-012', 'Mermelada Fresa 500g', 'Mermelada de fresa casera', 2, 8.50, 14.00, 35, 62, 2),
('ALIM-013', 'Conserva de Duraznos', 'Duraznos en almíbar lata 820g', 2, 9.00, 15.50, 45, 78, 2),
('ALIM-014', 'Avena en Hojuelas 500g', 'Avena integral en hojuelas', 2, 5.50, 9.80, 55, 98, 2),
('ALIM-015', 'Mayonesa 475g', 'Mayonesa tradicional', 2, 6.80, 11.50, 40, 72, 2),

-- Ropa (12 productos)
('ROPA-001', 'Camisa Manga Larga', 'Camisa formal de algodón para caballero', 3, 35.00, 65.00, 15, 32, 3),
('ROPA-002', 'Pantalón Jean Dama', 'Jean denim stretch para dama', 3, 45.00, 85.00, 20, 48, 3),
('ROPA-003', 'Polo Deportivo', 'Polo deportivo dry-fit unisex', 3, 18.00, 35.00, 30, 72, 3),
('ROPA-004', 'Zapatillas Running', 'Zapatillas deportivas para running', 3, 80.00, 150.00, 12, 26, 3),
('ROPA-005', 'Vestido Casual', 'Vestido de algodón manga corta', 3, 38.00, 72.00, 18, 34, 3),
('ROPA-006', 'Chaqueta Jean', 'Chaqueta denim unisex', 3, 55.00, 105.00, 12, 22, 3),
('ROPA-007', 'Shorts Deportivos', 'Shorts dry-fit para deporte', 3, 22.00, 42.00, 25, 48, 3),
('ROPA-008', 'Blusa Elegante', 'Blusa de gasa para dama', 3, 32.00, 62.00, 20, 38, 3),
('ROPA-009', 'Zapatillas Urbanas', 'Zapatillas casuales estilo urbano', 3, 65.00, 125.00, 15, 28, 3),
('ROPA-010', 'Medias Deportivas x3', 'Pack de 3 pares de medias', 3, 8.00, 15.50, 40, 76, 3),
('ROPA-011', 'Gorra Ajustable', 'Gorra deportiva ajustable', 3, 15.00, 28.00, 30, 58, 3),
('ROPA-012', 'Chompa Polar', 'Chompa polar con cierre', 3, 42.00, 80.00, 14, 25, 3),

-- Hogar (12 productos)
('HOGA-001', 'Juego de Sábanas 2 plazas', 'Sábanas 100% algodón egipcio', 4, 45.00, 85.00, 10, 22, 4),
('HOGA-002', 'Almohada Viscoelástica', 'Almohada memory foam ergonómica', 4, 30.00, 55.00, 15, 32, 4),
('HOGA-003', 'Toallas Set x4', 'Set de 4 toallas de baño premium', 4, 35.00, 65.00, 20, 38, 4),
('HOGA-004', 'Cortinas Blackout 2x2m', 'Cortinas blackout con aros', 4, 50.00, 95.00, 8, 18, 4),
('HOGA-005', 'Edredón Queen Size', 'Edredón acolchado antialérgico', 4, 85.00, 155.00, 8, 14, 4),
('HOGA-006', 'Organizador de Closet', 'Organizador colgante 6 niveles', 4, 25.00, 45.00, 15, 28, 4),
('HOGA-007', 'Alfombra 160x230cm', 'Alfombra decorativa antideslizante', 4, 95.00, 175.00, 6, 11, 4),
('HOGA-008', 'Espejo de Pared 60cm', 'Espejo decorativo redondo', 4, 38.00, 72.00, 10, 18, 4),
('HOGA-009', 'Set Cubiertos x24', 'Juego de cubiertos acero inoxidable', 4, 42.00, 78.00, 12, 22, 4),
('HOGA-010', 'Vajilla 20 Piezas', 'Vajilla de porcelana para 4 personas', 4, 68.00, 125.00, 8, 15, 4),
('HOGA-011', 'Lámpara de Mesa LED', 'Lámpara escritorio con regulador', 4, 32.00, 58.00, 15, 28, 4),
('HOGA-012', 'Cojines Decorativos x4', 'Set de 4 cojines con fundas', 4, 28.00, 52.00, 18, 34, 4),

-- Oficina (10 productos)
('OFIC-001', 'Papel Bond A4 x500', 'Resma papel bond blanco A4 75gr', 5, 12.00, 20.00, 50, 155, 5),
('OFIC-002', 'Lapiceros Azul x12', 'Caja de 12 lapiceros punta fina', 5, 4.50, 9.00, 40, 98, 5),
('OFIC-003', 'Archivador Palanca', 'Archivador palanca lomo ancho', 5, 6.00, 11.50, 30, 68, 5),
('OFIC-004', 'Calculadora Científica', 'Calculadora científica 252 funciones', 5, 25.00, 45.00, 10, 22, 5),
('OFIC-005', 'Engrapador Metálico', 'Engrapador hasta 40 hojas', 5, 15.00, 28.00, 20, 42, 5),
('OFIC-006', 'Corrector Líquido x6', 'Pack de 6 correctores líquidos', 5, 8.00, 15.00, 35, 72, 5),
('OFIC-007', 'Carpeta Manila x50', 'Pack de 50 carpetas manila A4', 5, 18.00, 32.00, 25, 58, 5),
('OFIC-008', 'Resaltadores x6 colores', 'Set de 6 resaltadores fluorescentes', 5, 9.50, 17.50, 30, 64, 5),
('OFIC-009', 'Tijera Profesional', 'Tijera de oficina 8 pulgadas', 5, 7.50, 14.00, 25, 48, 5),
('OFIC-010', 'Post-it Pack x4', 'Pack de 4 blocks de notas adhesivas', 5, 12.00, 22.00, 40, 82, 5),

-- Deportes (8 productos)
('DEPO-001', 'Balón de Fútbol N°5', 'Balón profesional cosido a mano', 6, 35.00, 65.00, 15, 32, 1),
('DEPO-002', 'Colchoneta Yoga', 'Colchoneta antideslizante con bolso', 6, 22.00, 42.00, 20, 42, 1),
('DEPO-003', 'Mancuernas 5kg Par', 'Par de mancuernas hexagonales', 6, 40.00, 75.00, 10, 22, 1),
('DEPO-004', 'Cuerda de Saltar', 'Cuerda ajustable con contador', 6, 12.00, 22.00, 30, 58, 1),
('DEPO-005', 'Guantes de Box', 'Guantes profesionales 12oz', 6, 45.00, 85.00, 12, 24, 1),
('DEPO-006', 'Banda Elástica Set x3', 'Set de 3 bandas de resistencia', 6, 18.00, 35.00, 25, 48, 1),
('DEPO-007', 'Botella Deportiva 1L', 'Botella térmica acero inoxidable', 6, 25.00, 45.00, 20, 38, 1),
('DEPO-008', 'Kit de Pesas 20kg', 'Set de barras y discos ajustables', 6, 85.00, 155.00, 8, 14, 1),

-- Juguetes (8 productos)
('JUGT-001', 'Lego Set Construcción', 'Set de 500 piezas para construcción', 7, 55.00, 95.00, 12, 25, 1),
('JUGT-002', 'Muñeca Interactiva', 'Muñeca con sonidos y movimientos', 7, 45.00, 85.00, 15, 28, 1),
('JUGT-003', 'Rompecabezas 1000 piezas', 'Rompecabezas paisaje premium', 7, 18.00, 35.00, 25, 48, 1),
('JUGT-004', 'Auto Control Remoto', 'Auto RC recargable con luces', 7, 65.00, 120.00, 10, 18, 1),
('JUGT-005', 'Peluche Oso 60cm', 'Peluche gigante suave', 7, 38.00, 72.00, 15, 28, 1),
('JUGT-006', 'Juego de Mesa Monopoly', 'Juego clásico familiar', 7, 42.00, 78.00, 12, 22, 1),
('JUGT-007', 'Pelota Inflable Grande', 'Pelota de playa 75cm', 7, 8.00, 15.50, 30, 58, 1),
('JUGT-008', 'Set Dinosaurios x12', 'Colección de figuras de dinosaurios', 7, 28.00, 52.00, 18, 34, 1);

-- Insertar clientes (empresas y personas)
INSERT INTO clientes (nombre, documento, telefono, email, direccion) VALUES
-- Clientes Corporativos
('Corporación ABC S.A.C.', '20111222333', '987111222', 'compras@abc.com', 'Av. Principal 1000, Lima'),
('Distribuidora XYZ', '20222333444', '987222333', 'ventas@xyz.com', 'Jr. Comercio 500, Lima'),
('Supermercados La Familia', '20333444555', '987333444', 'pedidos@lafamilia.com', 'Av. Los Próceres 200, Lima'),
('Tiendas Express', '20444555666', '987444555', 'contacto@express.com', 'Calle Lima 300, Callao'),
('Comercial El Sol E.I.R.L.', '20555666777', '987123456', 'ventas@elsol.com', 'Av. Grau 800, Cercado'),
('Inversiones Norte S.A.', '20666777888', '987234567', 'compras@invnorte.com', 'Jr. Unión 600, Los Olivos'),
('Distribuciones del Sur', '20777888999', '987345678', 'pedidos@delsur.com', 'Av. Aviación 1200, San Borja'),
('Grupo Retail Perú', '20888999000', '987456789', 'contacto@retailperu.com', 'Calle Real 400, Miraflores'),
('Mayoristas Asociados', '20999000111', '987567890', 'ventas@mayoristas.com', 'Jr. Cusco 300, Breña'),
('Comercializadora Global', '20000111222', '987678901', 'global@comercial.com', 'Av. Colonial 2000, Callao'),

-- Clientes Personas Naturales
('María López García', '12345678', '987555666', 'mlopez@gmail.com', 'Jr. Las Flores 150, San Juan'),
('José Ramírez Torres', '23456789', '987666777', 'jramirez@hotmail.com', 'Av. Los Jardines 250, Surco'),
('Ana Fernández Ruiz', '34567890', '987777888', 'afernandez@yahoo.com', 'Calle Las Rosas 350, Miraflores'),
('Carlos Mendoza Silva', '45678901', '987888999', 'cmendoza@gmail.com', 'Jr. Los Pinos 450, San Isidro'),
('Patricia Sánchez Rojas', '56789012', '987999000', 'psanchez@outlook.com', 'Av. Universitaria 800, San Miguel'),
('Roberto García Díaz', '67890123', '988000111', 'rgarcia@gmail.com', 'Calle Lima 200, Pueblo Libre'),
('Laura Martínez Cruz', '78901234', '988111222', 'lmartinez@hotmail.com', 'Jr. Junín 100, Magdalena'),
('Fernando Torres Vega', '89012345', '988222333', 'ftorres@yahoo.com', 'Av. Brasil 1500, Jesús María'),
('Carmen Flores Vargas', '90123456', '988333444', 'cflores@gmail.com', 'Calle 28 de Julio 600, Barranco'),
('Diego Castillo Ramos', '01234567', '988444555', 'dcastillo@outlook.com', 'Jr. Huancayo 250, Lince'),
('Sofía Morales Guzmán', '11111111', '988555666', 'smorales@gmail.com', 'Av. Javier Prado 3000, San Borja'),
('Miguel Herrera Campos', '22222222', '988666777', 'mherrera@hotmail.com', 'Calle Los Tulipanes 150, Santiago'),
('Isabel Romero Paredes', '33333333', '988777888', 'iromero@yahoo.com', 'Jr. Amazonas 500, Centro'),
('Andrés Peña Salazar', '44444444', '988888999', 'apena@gmail.com', 'Av. La Marina 2800, San Miguel'),
('Gabriela Quispe Luna', '55555555', '988999000', 'gquispe@outlook.com', 'Calle San Martín 350, Surquillo');

-- Índices para mejorar rendimiento
CREATE INDEX idx_productos_codigo ON productos(codigo);
CREATE INDEX idx_productos_categoria ON productos(categoria_id);
CREATE INDEX idx_ventas_fecha ON ventas(fecha);
CREATE INDEX idx_compras_fecha ON compras(fecha);
CREATE INDEX idx_usuarios_username ON usuarios(username);

-- Insertar compras de ejemplo (20 compras)
INSERT INTO compras (numero_factura, proveedor_id, usuario_id, fecha, total, estado, notas) VALUES
('C-2024-001', 1, 2, '2024-10-01', 5850.00, 'completada', 'Compra inicial equipos electrónicos Q4'),
('C-2024-002', 2, 2, '2024-10-03', 2450.00, 'completada', 'Reposición productos alimenticios octubre'),
('C-2024-003', 3, 2, '2024-10-05', 3200.00, 'completada', 'Stock de ropa temporada primavera'),
('C-2024-004', 4, 2, '2024-10-08', 2800.00, 'completada', 'Artículos para el hogar - colección nueva'),
('C-2024-005', 5, 2, '2024-10-10', 1890.00, 'completada', 'Material de oficina para trimestre'),
('C-2024-006', 1, 2, '2024-10-15', 2200.00, 'completada', 'Accesorios tecnológicos varios'),
('C-2024-007', 2, 2, '2024-10-18', 1850.00, 'completada', 'Alimentos no perecederos'),
('C-2024-008', 3, 2, '2024-10-20', 2650.00, 'completada', 'Colección deportiva y casual'),
('C-2024-009', 4, 2, '2024-10-22', 1950.00, 'completada', 'Decoración y textiles hogar'),
('C-2024-010', 1, 2, '2024-10-25', 3450.00, 'completada', 'Equipamiento electrónico empresarial'),
('C-2024-011', 5, 2, '2024-11-01', 1420.00, 'completada', 'Papelería inicio mes'),
('C-2024-012', 2, 3, '2024-11-03', 2180.00, 'completada', 'Stock alimentos noviembre'),
('C-2024-013', 1, 2, '2024-11-05', 4250.00, 'completada', 'Productos tecnológicos premium'),
('C-2024-014', 3, 2, '2024-11-08', 2890.00, 'completada', 'Ropa y calzado variado'),
('C-2024-015', 4, 2, '2024-11-10', 2350.00, 'completada', 'Menaje y decoración'),
('C-2024-016', 5, 3, '2024-11-12', 1680.00, 'completada', 'Útiles escolares y oficina'),
('C-2024-017', 1, 2, '2024-11-15', 2950.00, 'completada', 'Juguetes campaña navideña'),
('C-2024-018', 2, 2, '2024-11-18', 1950.00, 'completada', 'Conservas y productos básicos'),
('C-2024-019', 3, 2, '2024-11-20', 2150.00, 'completada', 'Deportes y fitness'),
('C-2024-020', 1, 2, '2024-11-22', 1850.00, 'pendiente', 'Pedido accesorios fin de mes');

-- Insertar detalles de compras (100+ líneas de detalle)
INSERT INTO detalle_compras (compra_id, producto_id, cantidad, precio_unitario, subtotal) VALUES
-- Compra 1: Electrónicos variados
(1, 1, 2, 1500.00, 3000.00),
(1, 2, 15, 25.00, 375.00),
(1, 4, 2, 350.00, 700.00),
(1, 5, 8, 60.00, 480.00),
(1, 7, 6, 55.00, 330.00),
(1, 11, 20, 18.00, 360.00),
(1, 13, 10, 35.00, 350.00),

-- Compra 2: Alimentos octubre
(2, 16, 40, 12.50, 500.00),
(2, 17, 30, 8.00, 240.00),
(2, 18, 60, 2.50, 150.00),
(2, 19, 50, 1.80, 90.00),
(2, 20, 40, 15.00, 600.00),
(2, 21, 35, 28.00, 980.00),
(2, 23, 25, 3.20, 80.00),

-- Compra 3: Ropa temporada
(3, 26, 18, 35.00, 630.00),
(3, 27, 25, 45.00, 1125.00),
(3, 28, 35, 18.00, 630.00),
(3, 29, 12, 80.00, 960.00),
(3, 30, 20, 38.00, 760.00),
(3, 35, 40, 8.00, 320.00),

-- Compra 4: Hogar decoración
(4, 38, 12, 45.00, 540.00),
(4, 39, 18, 30.00, 540.00),
(4, 40, 22, 35.00, 770.00),
(4, 41, 10, 50.00, 500.00),
(4, 42, 8, 85.00, 680.00),
(4, 46, 14, 38.00, 532.00),

-- Compra 5: Oficina trimestre
(5, 48, 60, 12.00, 720.00),
(5, 49, 50, 4.50, 225.00),
(5, 50, 35, 6.00, 210.00),
(5, 51, 12, 25.00, 300.00),
(5, 52, 25, 15.00, 375.00),
(5, 56, 30, 12.00, 360.00),

-- Compra 6: Accesorios tech
(6, 2, 20, 25.00, 500.00),
(6, 8, 15, 120.00, 1800.00),
(6, 11, 25, 18.00, 450.00),
(6, 12, 30, 12.00, 360.00),
(6, 14, 20, 15.00, 300.00),

-- Compra 7: Alimentos básicos
(7, 16, 50, 12.50, 625.00),
(7, 18, 80, 2.50, 200.00),
(7, 19, 60, 1.80, 108.00),
(7, 24, 40, 1.50, 60.00),
(7, 25, 45, 12.00, 540.00),
(7, 29, 30, 15.00, 450.00),

-- Compra 8: Deportiva y casual
(8, 28, 40, 18.00, 720.00),
(8, 32, 18, 55.00, 990.00),
(8, 34, 25, 22.00, 550.00),
(8, 36, 15, 15.00, 225.00),
(8, 58, 20, 35.00, 700.00),
(8, 61, 18, 22.00, 396.00),

-- Compra 9: Textiles hogar
(9, 38, 14, 45.00, 630.00),
(9, 40, 18, 35.00, 630.00),
(9, 43, 10, 25.00, 250.00),
(9, 45, 8, 95.00, 760.00),
(9, 49, 12, 28.00, 336.00),

-- Compra 10: Electrónica empresarial
(10, 1, 3, 1500.00, 4500.00),
(10, 4, 2, 350.00, 700.00),
(10, 6, 5, 450.00, 2250.00),
(10, 9, 4, 280.00, 1120.00),

-- Compra 11: Papelería mes
(11, 48, 45, 12.00, 540.00),
(11, 49, 35, 4.50, 157.50),
(11, 50, 28, 6.00, 168.00),
(11, 53, 22, 8.00, 176.00),
(11, 55, 30, 9.50, 285.00),
(11, 57, 18, 12.00, 216.00),

-- Compra 12: Alimentos noviembre
(12, 16, 60, 12.50, 750.00),
(12, 17, 45, 8.00, 360.00),
(12, 20, 38, 15.00, 570.00),
(12, 22, 30, 22.00, 660.00),
(12, 26, 25, 9.00, 225.00),

-- Compra 13: Tech premium
(13, 1, 4, 1500.00, 6000.00),
(13, 3, 8, 80.00, 640.00),
(13, 5, 12, 60.00, 720.00),
(13, 10, 10, 90.00, 900.00),
(13, 15, 6, 20.00, 120.00),

-- Compra 14: Ropa variada
(14, 26, 22, 35.00, 770.00),
(14, 27, 28, 45.00, 1260.00),
(14, 30, 18, 38.00, 684.00),
(14, 33, 14, 42.00, 588.00),
(14, 37, 20, 15.00, 300.00),

-- Compra 15: Menaje hogar
(15, 38, 16, 45.00, 720.00),
(15, 42, 10, 85.00, 850.00),
(15, 46, 14, 38.00, 532.00),
(15, 47, 12, 42.00, 504.00),
(15, 48, 18, 32.00, 576.00),

-- Compra 16: Útiles escolares
(16, 48, 55, 12.00, 660.00),
(16, 49, 48, 4.50, 216.00),
(16, 50, 38, 6.00, 228.00),
(16, 54, 28, 7.50, 210.00),
(16, 55, 32, 9.50, 304.00),
(16, 56, 35, 12.00, 420.00),

-- Compra 17: Juguetes navidad
(17, 64, 18, 55.00, 990.00),
(17, 65, 22, 45.00, 990.00),
(17, 66, 28, 18.00, 504.00),
(17, 68, 15, 38.00, 570.00),
(17, 70, 20, 28.00, 560.00),

-- Compra 18: Conservas básicos
(18, 17, 40, 8.00, 320.00),
(18, 22, 35, 22.00, 770.00),
(18, 27, 30, 9.00, 270.00),
(18, 28, 48, 1.50, 72.00),
(18, 31, 25, 18.00, 450.00),

-- Compra 19: Deportes fitness
(19, 58, 24, 35.00, 840.00),
(19, 59, 28, 22.00, 616.00),
(19, 60, 16, 40.00, 640.00),
(19, 62, 20, 45.00, 900.00),
(19, 64, 18, 25.00, 450.00),

-- Compra 20: Accesorios fin mes
(20, 2, 30, 25.00, 750.00),
(20, 11, 35, 18.00, 630.00),
(20, 13, 20, 35.00, 700.00),
(20, 15, 18, 20.00, 360.00);

-- Insertar ventas de ejemplo (35 ventas para demo completa)
INSERT INTO ventas (numero_factura, cliente_id, usuario_id, fecha, total, estado, tipo_pago, notas) VALUES
('V-2024-001', 1, 4, '2024-10-02', 4850.00, 'completada', 'transferencia', 'Venta corporativa - Equipos oficina'),
('V-2024-002', 11, 4, '2024-10-04', 285.00, 'completada', 'efectivo', 'Venta retail local'),
('V-2024-003', 2, 4, '2024-10-06', 1450.00, 'completada', 'transferencia', 'Pedido distribución XYZ'),
('V-2024-004', 12, 4, '2024-10-08', 425.00, 'completada', 'tarjeta', 'Venta productos mixtos'),
('V-2024-005', 3, 4, '2024-10-10', 2850.00, 'completada', 'transferencia', 'Pedido supermercado grande'),
('V-2024-006', 13, 4, '2024-10-12', 180.00, 'completada', 'efectivo', 'Venta particular'),
('V-2024-007', 4, 4, '2024-10-14', 650.00, 'completada', 'tarjeta', 'Venta tienda express'),
('V-2024-008', 14, 4, '2024-10-16', 320.00, 'completada', 'efectivo', 'Productos varios'),
('V-2024-009', 5, 4, '2024-10-18', 1250.00, 'completada', 'transferencia', 'Pedido comercial El Sol'),
('V-2024-010', 15, 4, '2024-10-20', 495.00, 'completada', 'tarjeta', 'Compra productos hogar'),
('V-2024-011', 6, 4, '2024-10-22', 2150.00, 'completada', 'transferencia', 'Venta corporativa Norte'),
('V-2024-012', 16, 4, '2024-10-24', 385.00, 'completada', 'efectivo', 'Venta retail'),
('V-2024-013', 7, 4, '2024-10-26', 1680.00, 'completada', 'transferencia', 'Pedido Distribuciones Sur'),
('V-2024-014', 17, 4, '2024-10-28', 245.00, 'completada', 'tarjeta', 'Compra personal'),
('V-2024-015', 8, 4, '2024-10-30', 3250.00, 'completada', 'transferencia', 'Venta mayorista Retail Perú'),
('V-2024-016', 18, 4, '2024-11-01', 528.00, 'completada', 'efectivo', 'Venta productos oficina'),
('V-2024-017', 9, 4, '2024-11-03', 1850.00, 'completada', 'transferencia', 'Pedido Mayoristas Asociados'),
('V-2024-018', 19, 4, '2024-11-05', 375.00, 'completada', 'tarjeta', 'Compra electrónicos'),
('V-2024-019', 10, 4, '2024-11-07', 2450.00, 'completada', 'transferencia', 'Venta Comercializadora Global'),
('V-2024-020', 20, 4, '2024-11-09', 680.00, 'completada', 'efectivo', 'Venta productos deportivos'),
('V-2024-021', 1, 4, '2024-11-11', 4200.00, 'completada', 'transferencia', 'Renovación equipamiento ABC'),
('V-2024-022', 21, 4, '2024-11-13', 295.00, 'completada', 'tarjeta', 'Compra personal hogar'),
('V-2024-023', 3, 4, '2024-11-15', 1980.00, 'completada', 'transferencia', 'Reposición supermercado'),
('V-2024-024', 22, 4, '2024-11-17', 425.00, 'completada', 'efectivo', 'Venta productos variados'),
('V-2024-025', 4, 4, '2024-11-19', 850.00, 'completada', 'tarjeta', 'Pedido Express'),
('V-2024-026', 23, 4, '2024-11-20', 385.00, 'completada', 'efectivo', 'Compra ropa'),
('V-2024-027', 6, 4, '2024-11-21', 1550.00, 'completada', 'transferencia', 'Venta corporativa'),
('V-2024-028', 24, 4, '2024-11-22', 695.00, 'completada', 'tarjeta', 'Productos tecnológicos'),
('V-2024-029', 2, 4, '2024-11-23', 2250.00, 'completada', 'transferencia', 'Gran pedido XYZ'),
('V-2024-030', 25, 4, '2024-11-24', 325.00, 'completada', 'efectivo', 'Venta juguetes'),
('V-2024-031', 7, 4, '2024-11-25', 1480.00, 'completada', 'transferencia', 'Pedido mensual'),
('V-2024-032', 11, 4, '2024-11-25', 255.00, 'completada', 'tarjeta', 'Compra personal'),
('V-2024-033', 5, 4, '2024-11-26', 3850.00, 'completada', 'transferencia', 'Pedido grande El Sol'),
('V-2024-034', 12, 4, '2024-11-26', 485.00, 'completada', 'efectivo', 'Venta productos mixtos'),
('V-2024-035', 1, 4, '2024-11-27', 1250.00, 'pendiente', 'transferencia', 'Pedido pendiente entrega');

-- Insertar detalles de ventas
INSERT INTO detalle_ventas (venta_id, producto_id, cantidad, precio_unitario, subtotal) VALUES
-- Venta 1: Equipos de oficina
(1, 1, 2, 2200.00, 4400.00),

-- Venta 2: Venta mixta
(2, 3, 1, 135.00, 135.00),

-- Venta 3: Productos varios
(3, 6, 20, 18.90, 378.00),
(3, 7, 15, 12.50, 187.50),
(3, 9, 50, 3.50, 175.00),
(3, 10, 10, 24.00, 240.00),

-- Venta 4: Ropa
(4, 13, 5, 35.00, 175.00),
(4, 11, 1, 65.00, 65.00),

-- Venta 5: Alimentos para supermercado
(5, 6, 40, 18.90, 756.00),
(5, 7, 30, 12.50, 375.00),
(5, 8, 50, 4.20, 210.00),
(5, 9, 30, 3.50, 105.00),

-- Venta 6: Artículos hogar
(6, 16, 2, 55.00, 110.00),
(6, 17, 1, 65.00, 65.00),

-- Venta 7: Oficina
(7, 19, 15, 20.00, 300.00),
(7, 20, 10, 9.00, 90.00),
(7, 21, 5, 11.50, 57.50),

-- Venta 8: Productos mixtos
(8, 2, 3, 45.00, 135.00),
(8, 5, 1, 110.00, 110.00),
(8, 20, 5, 9.00, 45.00),
(8, 19, 1, 20.00, 20.00),

-- Venta 9: Equipos electrónicos
(9, 4, 1, 550.00, 550.00);

-- Insertar movimientos de inventario
INSERT INTO movimientos_inventario (producto_id, almacen_id, tipo_movimiento, cantidad, usuario_id, referencia, motivo) VALUES
-- Entradas iniciales por compras
(1, 1, 'entrada', 2, 2, 'C-2024-001', 'Compra inicial de laptops'),
(2, 1, 'entrada', 10, 2, 'C-2024-001', 'Compra de mouse inalámbricos'),
(4, 1, 'entrada', 1, 2, 'C-2024-001', 'Compra de monitor'),
(5, 1, 'entrada', 4, 2, 'C-2024-001', 'Compra de auriculares'),
(6, 2, 'entrada', 30, 2, 'C-2024-002', 'Entrada de arroz'),
(7, 2, 'entrada', 25, 2, 'C-2024-002', 'Entrada de aceite'),
(8, 2, 'entrada', 50, 2, 'C-2024-002', 'Entrada de azúcar'),

-- Salidas por ventas
(1, 1, 'salida', 2, 4, 'V-2024-001', 'Venta corporativa'),
(3, 1, 'salida', 1, 4, 'V-2024-002', 'Venta al por menor'),
(6, 2, 'salida', 20, 4, 'V-2024-003', 'Venta a distribuidor'),
(7, 2, 'salida', 15, 4, 'V-2024-003', 'Venta a distribuidor'),

-- Ajustes de inventario
(2, 1, 'ajuste', -1, 5, 'AJ-001', 'Producto dañado durante manipulación'),
(8, 2, 'ajuste', 5, 5, 'AJ-002', 'Ajuste por inventario físico'),
(13, 1, 'ajuste', -2, 5, 'AJ-003', 'Productos con defecto de fábrica'),

-- Transferencias entre almacenes (entrada en destino, salida en origen)
(19, 1, 'entrada', 25, 5, 'TRF-001', 'Transferencia de almacén 2 a 1'),
(19, 2, 'salida', 25, 5, 'TRF-001', 'Transferencia de almacén 2 a 1'),
(10, 2, 'entrada', 10, 5, 'TRF-002', 'Redistribución de stock'),
(10, 1, 'salida', 10, 5, 'TRF-002', 'Redistribución de stock');
