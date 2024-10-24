use ventas;

DELIMITER //

DROP TRIGGER IF EXISTS tr_updCliente;
CREATE TRIGGER tr_updCliente
AFTER UPDATE ON Clientes
FOR EACH ROW
BEGIN
    INSERT INTO log(clienteID, situacionAnterior, fecha) VALUES (NEW.clienteID, OLD.situacion, now());
END //

DELIMITER ;

-- Procedimientos Almacenados y Funciones
DELIMITER //

DROP PROCEDURE IF EXISTS insCliente;
CREATE PROCEDURE insCliente  (IN nom VARCHAR(50))

BEGIN

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        select ROLLBACK;
    END;

    START TRANSACTION;
    INSERT INTO Clientes (nombre) VALUES (nom);
    INSERT INTO log (clienteID, situacionAnterior, fecha) VALUES (LAST_INSERT_ID(), 'A', now());
    COMMIT;

END //

DELIMITER ;


DELIMITER //

DROP PROCEDURE IF EXISTS insNuevaOrden;
CREATE PROCEDURE insNuevaOrden (in _clienteID INT, _cantidad INT, in _ordenFecha DATETIME, in _estado CHAR (1)/*, out numeroOrden int*/ )
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;
    INSERT INTO Orden (clienteID, ordenFecha, estado, cantidad) VALUES (_clienteID, _ordenFecha, _estado, _cantidad);
    UPDATE Clientes SET cantidadOrden = cantidadOrden + _cantidad WHERE clienteID = _clienteID;
    COMMIT;
END //

DELIMITER ;


DELIMITER //

DROP PROCEDURE IF EXISTS updCompletaOrden;
CREATE PROCEDURE updCompletaOrden (in _ordenID INT, in _completadoFecha DATE)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;
    UPDATE Orden SET estado = 'F', completadoFecha = _completadoFecha WHERE ordenID = _ordenID;
    UPDATE Clientes SET cantidadEntregado = cantidadEntregado + (SELECT cantidad FROM Orden WHERE ordenID = _ordenID) WHERE clienteID = (SELECT clienteID FROM Orden WHERE ordenID = _ordenID);
    COMMIT;
END //

DELIMITER ;


DELIMITER //

DROP FUNCTION IF EXISTS f_diferencia_cantidad;
CREATE FUNCTION f_diferencia_cantidad(_clienteID INT)
RETURNS INT DETERMINISTIC
BEGIN
    DECLARE _cantidadOrden INT;
    DECLARE _cantidadEntregado INT;
    DECLARE _diferencia INT;
    DECLARE _error INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET _error = 1;
    END;

    SELECT cantidadOrden, cantidadEntregado
    INTO _cantidadOrden, _cantidadEntregado
    FROM Clientes
    WHERE clienteID = _clienteID;

    IF _error = 0 THEN
        SET _diferencia = _cantidadOrden - _cantidadEntregado;
    ELSE
        SET _diferencia = NULL;
    END IF;

    RETURN _diferencia;
END //

DELIMITER ;


DELIMITER //

DROP PROCEDURE IF EXISTS updCliente;
CREATE PROCEDURE updCliente (in _clienteID INT)
BEGIN 

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        select ROLLBACK;
    END;

    START TRANSACTION;
    UPDATE Clientes SET situacion = 'X' WHERE clienteID = _clienteID;
    COMMIT;
        
END //

DELIMITER ;

CALL test();