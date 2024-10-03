-- Active: 1710194808506@@127.0.0.1@3306@Ventas

--Crear BD
CREATE DATABASE IF NOT EXISTS Ventas;

DROP DATABASE IF EXISTS Ventas;

--Usar BD
USE Ventas;

--Crear Tablas

CREATE TABLE IF NOT EXISTS Clientes (
    IdCliente INT PRIMARY KEY AUTO_INCREMENT,
    Empresa VARCHAR(50) NOT NULL,
    Acumulado INT DEFAULT 0
);

DROP TABLE IF EXISTS Clientes;

CREATE TABLE IF NOT EXISTS Productos (
    IdProducto INT PRIMARY KEY AUTO_INCREMENT,
    Descripcion VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS Ventas (
    IdVenta INT PRIMARY KEY AUTO_INCREMENT,
    Fecha DATE NOT NULL DEFAULT(CURRENT_DATE),
    ProductoId INT NOT NULL,
    ClienteId INT NOT NULL,
    Monto INT,
    FOREIGN KEY (ProductoId) REFERENCES Productos (IdProducto),
    FOREIGN KEY (ClienteId) REFERENCES Clientes (IdCliente)
);

DROP TABLE Venta;

SHOW TABLES;

--Procedures
DELIMITER / /

CREATE PROCEDURE insert_client(IN emp VARCHAR(50), IN acum INT)
BEGIN
    INSERT INTO Clientes(Empresa, Acumulado) VALUES(emp, acum);
END//

DELIMITER;

DROP PROCEDURE insert_client;

DELIMITER / /

CREATE PROCEDURE insert_productos(IN descrip VARCHAR(100))
BEGIN
    INSERT INTO Productos(Descripcion) VALUES(descrip);
END//

DELIMITER;

DROP PROCEDURE insert_productos;

DELIMITER / /

CREATE PROCEDURE insert_ventas(IN p_id INT, IN c_id INT, IN mont INT)
BEGIN
    INSERT INTO Ventas ( `ProductoId`, `ClienteId`, `Monto`) VALUES(p_id, c_id, mont);
END//

DELIMITER;

DROP PROCEDURE insert_ventas;



DELIMITER / /
CREATE TRIGGER trigger_acumulado BEFORE INSERT ON Ventas 
FOR EACH ROW 
BEGIN

UPDATE Clientes 
SET
    Acumulado = Acumulado+NEW.Monto
WHERE
    IdCliente = NEW.ClienteId;
END //
DELIMITER;

DROP TRIGGER trigger_acumulado;



CREATE OR REPLACE VIEW productos_por_cliente AS
SELECT v.`ProductoId`, c.`IdCliente`, COUNT(`Monto`) AS cantidad_ventas
FROM `Ventas` v
    INNER JOIN `Clientes` c ON v.`ClienteId` = c.`IdCliente`
GROUP BY
    v.`ProductoId`,
    c.`IdCliente`;


SELECT * FROM productos_por_cliente;
