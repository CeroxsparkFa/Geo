-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 19-07-2024 a las 22:22:49
-- Versión del servidor: 10.4.32-MariaDB
-- Versión de PHP: 8.0.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `geoblast`
--

DELIMITER $$
--
-- Procedimientos
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `actualizar_excepcion_pedido` (IN `p_id` INT, IN `p_usuario_id` INT, IN `p_fecha_inicio` DATE, IN `p_fecha_fin` DATE)   BEGIN
    UPDATE excepciones_pedidos
    SET usuario_id = p_usuario_id,
        fecha_inicio = p_fecha_inicio,
        fecha_fin = p_fecha_fin
    WHERE id = p_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `actualizar_menu` (IN `p_id` INT, IN `p_menu_principal` VARCHAR(100), IN `p_acompañamiento` VARCHAR(100), IN `p_bebestible` VARCHAR(100), IN `p_postre` VARCHAR(100), IN `p_fecha_disponible` DATE)   BEGIN
    UPDATE menu
    SET menu_principal = p_menu_principal,
        acompañamiento = p_acompañamiento,
        bebestible = p_bebestible,
        postre = p_postre,
        fecha_disponible = p_fecha_disponible
    WHERE id = p_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `actualizar_pedido` (IN `p_id` INT, IN `p_numero_pedido` VARCHAR(50), IN `p_usuario_id` INT, IN `p_menu_id` INT, IN `p_qr_code` VARCHAR(255))   BEGIN
    UPDATE pedidos
    SET numero_pedido = p_numero_pedido,
        usuario_id = p_usuario_id,
        menu_id = p_menu_id,
        qr_code = p_qr_code
    WHERE id = p_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `actualizar_registro_fechas` (IN `p_id` INT, IN `p_turno_id` INT, IN `p_fecha_inicio` DATE, IN `p_fecha_fin` DATE, IN `p_fecha_inicio_descanso` DATE, IN `p_fecha_fin_descanso` DATE)   BEGIN
    UPDATE registro_fechas
    SET turno_id = p_turno_id,
        fecha_inicio = p_fecha_inicio,
        fecha_fin = p_fecha_fin,
        fecha_inicio_descanso = p_fecha_inicio_descanso,
        fecha_fin_descanso = p_fecha_fin_descanso
    WHERE id = p_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `actualizar_turno` (IN `p_id` INT, IN `p_nombre_turno` VARCHAR(50), IN `p_tipo_turno` ENUM('Día','Noche'))   BEGIN
    UPDATE turnos
    SET nombre_turno = p_nombre_turno,
        tipo_turno = p_tipo_turno
    WHERE id = p_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `actualizar_usuario` (IN `p_id` INT, IN `p_nombres` VARCHAR(100), IN `p_apellidos` VARCHAR(100), IN `p_rut` VARCHAR(12), IN `p_cargo` ENUM('Usuario','Administrador','Encargado'), IN `p_turno_id` INT, IN `p_email` VARCHAR(100), IN `p_contraseña` VARCHAR(255))   BEGIN
    UPDATE usuarios
    SET nombres = p_nombres,
        apellidos = p_apellidos,
        rut = p_rut,
        cargo = p_cargo,
        turno_id = p_turno_id,
        email = p_email,
        contraseña = p_contraseña
    WHERE id = p_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `auditoria_insertar_usuario` (IN `p_usuario_id` INT, IN `p_detalles` TEXT)   BEGIN
    INSERT INTO auditoria (tabla_afectada, accion_realizada, usuario_id, detalles)
    VALUES ('usuarios', 'insert/update/delete', p_usuario_id, p_detalles);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `buscar_excepcion_pedido_por_id` (IN `p_id` INT)   BEGIN
    SELECT * FROM excepciones_pedidos WHERE id = p_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `buscar_menu_por_id` (IN `p_id` INT)   BEGIN
    SELECT * FROM menu WHERE id = p_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `buscar_pedido_por_id` (IN `p_id` INT)   BEGIN
    SELECT * FROM pedidos WHERE id = p_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `buscar_registro_fechas_por_id` (IN `p_id` INT)   BEGIN
    SELECT * FROM registro_fechas WHERE id = p_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `buscar_turno_por_id` (IN `p_id` INT)   BEGIN
    SELECT * FROM turnos WHERE id = p_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `buscar_usuario_por_id` (IN `p_id` INT)   BEGIN
    SELECT * FROM usuarios WHERE id = p_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `buscar_usuario_por_rut` (IN `p_rut` VARCHAR(12))   BEGIN
    SELECT * FROM usuarios WHERE rut = p_rut;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `eliminar_excepcion_pedido` (IN `p_id` INT)   BEGIN
    DELETE FROM excepciones_pedidos WHERE id = p_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `eliminar_menu` (IN `p_id` INT)   BEGIN
    DELETE FROM menu WHERE id = p_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `eliminar_pedido` (IN `p_id` INT)   BEGIN
    DELETE FROM pedidos WHERE id = p_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `eliminar_registro_fechas` (IN `p_id` INT)   BEGIN
    DELETE FROM registro_fechas WHERE id = p_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `eliminar_turno` (IN `p_id` INT)   BEGIN
    DELETE FROM turnos WHERE id = p_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `eliminar_usuario` (IN `p_id` INT)   BEGIN
    DELETE FROM usuarios WHERE id = p_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `generar_numero_pedido` (OUT `numero_pedido` VARCHAR(50))   BEGIN
    DECLARE ultimo_numero INT;
    DECLARE ciclo_letra CHAR(1);
    DECLARE ciclo_numero INT;


    SELECT MAX(SUBSTRING(numero_pedido, 2)) INTO ultimo_numero FROM pedidos WHERE numero_pedido LIKE 'P%';


    SET ciclo_numero = IFNULL(ultimo_numero, 0) + 1;
    SET ciclo_letra = CHAR(65 + FLOOR(ciclo_numero / 500));

    SET numero_pedido = CONCAT(ciclo_letra, LPAD(MOD(ciclo_numero - 1, 500) + 1, 3, '0'));
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `insertar_excepcion_pedido` (IN `p_usuario_id` INT, IN `p_fecha_inicio` DATE, IN `p_fecha_fin` DATE)   BEGIN
    INSERT INTO excepciones_pedidos (usuario_id, fecha_inicio, fecha_fin)
    VALUES (p_usuario_id, p_fecha_inicio, p_fecha_fin);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `insertar_menu` (IN `p_menu_principal` VARCHAR(100), IN `p_acompañamiento` VARCHAR(100), IN `p_bebestible` VARCHAR(100), IN `p_postre` VARCHAR(100), IN `p_fecha_disponible` DATE)   BEGIN
    INSERT INTO menu (menu_principal, acompañamiento, bebestible, postre, fecha_disponible)
    VALUES (p_menu_principal, p_acompañamiento, p_bebestible, p_postre, p_fecha_disponible);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `insertar_pedido` (IN `p_numero_pedido` VARCHAR(50), IN `p_usuario_id` INT, IN `p_menu_id` INT, IN `p_qr_code` VARCHAR(255))   BEGIN
    INSERT INTO pedidos (numero_pedido, usuario_id, menu_id, qr_code)
    VALUES (p_numero_pedido, p_usuario_id, p_menu_id, p_qr_code);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `insertar_registro_fechas` (IN `p_turno_id` INT, IN `p_fecha_inicio` DATE, IN `p_fecha_fin` DATE, IN `p_fecha_inicio_descanso` DATE, IN `p_fecha_fin_descanso` DATE)   BEGIN
    INSERT INTO registro_fechas (turno_id, fecha_inicio, fecha_fin, fecha_inicio_descanso, fecha_fin_descanso)
    VALUES (p_turno_id, p_fecha_inicio, p_fecha_fin, p_fecha_inicio_descanso, p_fecha_fin_descanso);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `insertar_turno` (IN `p_nombre_turno` VARCHAR(50), IN `p_tipo_turno` ENUM('Día','Noche'))   BEGIN
    INSERT INTO turnos (nombre_turno, tipo_turno)
    VALUES (p_nombre_turno, p_tipo_turno);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `insertar_usuario` (IN `p_nombres` VARCHAR(100), IN `p_apellidos` VARCHAR(100), IN `p_rut` VARCHAR(12), IN `p_cargo` ENUM('Usuario','Administrador','Encargado'), IN `p_turno_id` INT, IN `p_email` VARCHAR(100), IN `p_contraseña` VARCHAR(255))   BEGIN
    INSERT INTO usuarios (nombres, apellidos, rut, cargo, turno_id, email, contraseña)
    VALUES (p_nombres, p_apellidos, p_rut, p_cargo, p_turno_id, p_email, p_contraseña);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `listar_excepciones_pedidos` ()   BEGIN
    SELECT * FROM excepciones_pedidos;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `listar_menus_disponibles` ()   BEGIN
    SELECT * FROM menu WHERE fecha_disponible <= CURDATE();
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `listar_pedidos_por_usuario` (IN `p_usuario_id` INT)   BEGIN
    SELECT * FROM pedidos WHERE usuario_id = p_usuario_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `listar_registros_fechas` ()   BEGIN
    SELECT * FROM registro_fechas;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `listar_turnos` ()   BEGIN
    SELECT * FROM turnos;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `listar_usuarios` ()   BEGIN
    SELECT * FROM usuarios;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `listar_usuarios_por_cargo` (IN `p_cargo` ENUM('Usuario','Administrador','Encargado'))   BEGIN
    SELECT * FROM usuarios WHERE cargo = p_cargo;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `auditoria`
--

CREATE TABLE `auditoria` (
  `id` int(11) NOT NULL,
  `tabla_afectada` varchar(100) NOT NULL,
  `accion_realizada` varchar(100) NOT NULL,
  `usuario_id` int(11) NOT NULL,
  `fecha_hora` timestamp NOT NULL DEFAULT current_timestamp(),
  `detalles` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `excepciones_pedidos`
--

CREATE TABLE `excepciones_pedidos` (
  `id` int(11) NOT NULL,
  `usuario_id` int(11) NOT NULL,
  `fecha_inicio` datetime NOT NULL,
  `fecha_fin` datetime NOT NULL,
  `fecha_creacion` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `menu`
--

CREATE TABLE `menu` (
  `id` int(11) NOT NULL,
  `menu_principal` varchar(100) NOT NULL,
  `acompanamiento` varchar(100) NOT NULL,
  `bebestible` varchar(100) NOT NULL,
  `postre` varchar(100) NOT NULL,
  `fecha_disponible` date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `menu`
--

INSERT INTO `menu` (`id`, `menu_principal`, `acompanamiento`, `bebestible`, `postre`, `fecha_disponible`) VALUES
(1, 'Plato Principal 1', 'Acompañamiento 1', 'Bebestible 1', 'Postre 1', '2024-07-18'),
(2, 'Plato Principal 2', 'Acompañamiento 2', 'Bebestible 2', 'Postre 2', '2024-07-19'),
(3, 'Plato Principal 3', 'Acompañamiento 3', 'Bebestible 3', 'Postre 3', '2024-07-20'),
(4, 'Plato Principal 4', 'Acompañamiento 4', 'Bebestible 4', 'Postre 4', '2024-07-21'),
(5, 'Plato Principal 5', 'Acompañamiento 5', 'Bebestible 5', 'Postre 5', '2024-07-22'),
(6, 'Plato Principal 6', 'Acompañamiento 6', 'Bebestible 6', 'Postre 6', '2024-07-18'),
(7, 'Plato Principal 7', 'Acompañamiento 7', 'Bebestible 7', 'Postre 7', '2024-07-19'),
(8, 'Plato Principal 8', 'Acompañamiento 8', 'Bebestible 8', 'Postre 8', '2024-07-20'),
(9, 'Plato Principal 9', 'Acompañamiento 9', 'Bebestible 9', 'Postre 9', '2024-07-21'),
(10, 'Plato Principal 10', 'Acompañamiento 10', 'Bebestible 10', 'Postre 10', '2024-07-22');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `pedidos`
--

CREATE TABLE `pedidos` (
  `id` int(11) NOT NULL,
  `numero_pedido` varchar(50) NOT NULL,
  `usuario_id` int(11) NOT NULL,
  `menu_principal` varchar(100) NOT NULL,
  `acompanamiento` varchar(100) NOT NULL,
  `bebestible` varchar(100) NOT NULL,
  `postre` varchar(100) NOT NULL,
  `fecha_pedido` timestamp NOT NULL DEFAULT current_timestamp(),
  `qr_code` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `pedidos`
--

INSERT INTO `pedidos` (`id`, `numero_pedido`, `usuario_id`, `menu_principal`, `acompanamiento`, `bebestible`, `postre`, `fecha_pedido`, `qr_code`) VALUES
(21, 'B1', 4, 'Plato Principal 3', 'Acompañamiento 3', 'Bebestible 3', 'Postre 3', '2024-07-19 04:00:00', NULL),
(22, 'C2', 4, 'Plato Principal 1', 'Acompañamiento 1', 'Bebestible 6', 'Postre 6', '2024-07-18 04:00:00', NULL),
(23, 'D3', 4, 'Plato Principal 7', 'Acompañamiento 7', 'Bebestible 7', 'Postre 2', '2024-07-19 04:00:00', NULL),
(24, 'E4', 4, 'Plato Principal 9', 'Acompañamiento 4', 'Bebestible 9', 'Postre 9', '2024-07-21 04:00:00', NULL),
(25, 'F5', 4, 'Plato Principal 3', 'Acompañamiento 3', 'Bebestible 8', 'Postre 3', '2024-07-20 04:00:00', NULL),
(26, 'G6', 4, 'Plato Principal 5', 'Acompañamiento 10', 'Bebestible 10', 'Postre 10', '2024-07-22 04:00:00', NULL),
(27, 'H7', 4, 'Plato Principal 7', 'Acompañamiento 7', 'Bebestible 2', 'Postre 2', '2024-07-19 04:00:00', NULL),
(34, 'A0', 0, 'Plato Principal 2', 'Acompañamiento 7', 'Bebestible 2', 'Postre 7', '2024-07-19 04:00:00', NULL),
(35, 'I8', 0, 'Plato Principal 6', 'Acompañamiento 1', 'Bebestible 1', 'Postre 1', '2024-07-18 04:00:00', NULL),
(36, 'J9', 0, 'Plato Principal 6', 'Acompañamiento 6', 'Bebestible 6', 'Postre 6', '2024-07-18 04:00:00', NULL),
(47, 'N13', 9, 'Plato Principal 7sa', 'Acompañamiento 2sa', 'Bebestible 7saa', 'Postre 7sa', '2024-07-19 04:00:00', NULL),
(56, 'B12', 9, 'Plato Principal 3', 'Acompañamiento 3', 'Bebestible 3', 'Postre 3', '2024-07-15 04:00:00', NULL),
(57, 'B23', 9, 'Plato Principal 4', 'Acompañamiento 4', 'Bebestible 4', 'Postre 4', '2024-07-16 04:00:00', NULL),
(58, 'B34', 6, 'Plato Principal 5', 'Acompañamiento 5', 'Bebestible 5', 'Postre 5', '2024-07-17 04:00:00', NULL);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `registro_fechas`
--

CREATE TABLE `registro_fechas` (
  `id` int(11) NOT NULL,
  `turno_id` int(11) NOT NULL,
  `fecha_inicio` date NOT NULL,
  `fecha_fin` date NOT NULL,
  `fecha_inicio_descanso` date DEFAULT NULL,
  `fecha_fin_descanso` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `turnos`
--

CREATE TABLE `turnos` (
  `id` int(11) NOT NULL,
  `nombre_turno` varchar(50) NOT NULL,
  `tipo_turno` enum('Día','Noche') NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `turnos`
--

INSERT INTO `turnos` (`id`, `nombre_turno`, `tipo_turno`) VALUES
(1, 'Turno A', 'Día');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuarios`
--

CREATE TABLE `usuarios` (
  `id` int(11) NOT NULL,
  `nombres` varchar(100) NOT NULL,
  `apellidos` varchar(100) NOT NULL,
  `rut` varchar(12) NOT NULL,
  `cargo` enum('Usuario','Administrador','Encargado') NOT NULL,
  `turno_id` int(11) NOT NULL,
  `email` varchar(100) NOT NULL,
  `contrasena` varchar(255) NOT NULL,
  `fecha_registro` timestamp NOT NULL DEFAULT current_timestamp(),
  `Modal_Trabajo` enum('Diurno','Nocturno') NOT NULL DEFAULT 'Diurno'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `usuarios`
--

INSERT INTO `usuarios` (`id`, `nombres`, `apellidos`, `rut`, `cargo`, `turno_id`, `email`, `contrasena`, `fecha_registro`, `Modal_Trabajo`) VALUES
(9, 'Cristian', 'Faundes', '19397251-9', 'Administrador', 1, 'cfaundes@cafware.cl', '0c85eddc1f15505d82e9299f85cff9dfee8f7299022565e7505bd952c5c3af2e', '2024-07-17 03:27:45', 'Diurno');

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `auditoria`
--
ALTER TABLE `auditoria`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `excepciones_pedidos`
--
ALTER TABLE `excepciones_pedidos`
  ADD PRIMARY KEY (`id`),
  ADD KEY `usuario_id` (`usuario_id`);

--
-- Indices de la tabla `pedidos`
--
ALTER TABLE `pedidos`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `numero_pedido` (`numero_pedido`);

--
-- Indices de la tabla `registro_fechas`
--
ALTER TABLE `registro_fechas`
  ADD PRIMARY KEY (`id`),
  ADD KEY `turno_id` (`turno_id`);

--
-- Indices de la tabla `turnos`
--
ALTER TABLE `turnos`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `usuarios`
--
ALTER TABLE `usuarios`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `rut` (`rut`),
  ADD UNIQUE KEY `email` (`email`),
  ADD KEY `turno_id` (`turno_id`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `auditoria`
--
ALTER TABLE `auditoria`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `excepciones_pedidos`
--
ALTER TABLE `excepciones_pedidos`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `pedidos`
--
ALTER TABLE `pedidos`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=59;

--
-- AUTO_INCREMENT de la tabla `registro_fechas`
--
ALTER TABLE `registro_fechas`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `turnos`
--
ALTER TABLE `turnos`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `usuarios`
--
ALTER TABLE `usuarios`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `excepciones_pedidos`
--
ALTER TABLE `excepciones_pedidos`
  ADD CONSTRAINT `excepciones_pedidos_ibfk_1` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`);

--
-- Filtros para la tabla `registro_fechas`
--
ALTER TABLE `registro_fechas`
  ADD CONSTRAINT `registro_fechas_ibfk_1` FOREIGN KEY (`turno_id`) REFERENCES `turnos` (`id`);

--
-- Filtros para la tabla `usuarios`
--
ALTER TABLE `usuarios`
  ADD CONSTRAINT `usuarios_ibfk_1` FOREIGN KEY (`turno_id`) REFERENCES `turnos` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
