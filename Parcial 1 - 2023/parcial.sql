CREATE DATABASE IF NOT EXISTS Asistencia;

USE Asistencia;

CREATE TABLE IF NOT EXISTS Empleados(
  idEmpleado INT AUTO_INCREMENT PRIMARY KEY,
  Apellido VARCHAR(50),
  Nombres VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS Registros(
  idRegistro INT AUTO_INCREMENT PRIMARY KEY,
  Fecha DATE,
  idEmpleado INT,
  Estado ENUM('Presente', 'Ausente'),
  FOREIGN KEY (idEmpleado) REFERENCES Empleados(idEmpleado)
);

CREATE TABLE IF NOT EXISTS Log(
  id INT AUTO_INCREMENT PRIMARY KEY,
  Fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  Cambio TEXT,
  Usuario VARCHAR(50)
);

DELIMITER //

DROP PROCEDURE InsertarEmpleado;
CREATE PROCEDURE InsertarEmpleado (
  IN apell VARCHAR(50),
  IN nom VARCHAR(50)
)
BEGIN
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
  END;

  INSERT INTO Empleados(Apellido, Nombres)
  VALUES (apell, nom);
END //

DELIMITER ;

DELIMITER //

CREATE PROCEDURE IF NOT EXISTS IngresarRegistro (
  IN fech DATE,
  IN empleado INT,
  IN est VARCHAR(10)
)
BEGIN
  INSERT INTO Registros(Fecha, idEmpleado, Estado)
  VALUES (fech, empleado, est)
END //

DELIMITER ;

DELMITER //

CREATE TRIGGER ActualizarLog
AFTER UPDATE ON Registros
FOR EACH ROW
BEGIN
  INSERT INTO Log(Fecha, Cambio, Usuario)
  VALUES (CURRENT_TIMESTAMP, CONCAT('Estado cambiado de ', OLD.Estado, ' a ', NEW.Estado, ' para el empleado ', NEW.idEmpleado), USER())
END //
DELIMITER ;

CREATE VIEW VistaAsistencia AS
SELECT Empleados.Apellido, Empleados.Nombres, Registros.Fecha, Registros.Estado
FROM Empleados
JOIN Registros ON Empleados.idEmpleado = Registros.idEmpleado

SELECT Empleados.Apellido, Empleados.Nombres, COUNT(Registros.idRegistro) AS Faltas
FROM Empleados
JOIN Registros ON Empleados.idEmpleado = Registros.idEmpleado
WHERE Registros.Estado = 'Ausente'
GROUP BY Empleados.Apellido, Empleados.Nombres