DELIMITER //

CREATE TRIGGER tr_updCliente
AFTER UPDATE ON Clientes
FOR EACH ROW
BEGIN

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        select ROLLBACK;
    END;

    START TRANSACTION;
    INSERT INTO log (clienteID, situacionAnterior, fecha) VALUES (NEW.clienteID, OLD.situacion, now());
    COMMIT;

END //

DELIMITER ;

-- Procedimientos Almacenados y Funciones
delimiter //

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

delimiter ;


delimiter //

CREATE PROCEDURE insNuevaOrden (in _clienteID INT, _cantidad INT, in _ordenFecha DATETIME, in _estado CHAR (1)/*, out numeroOrden int*/ )
BEGIN

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        select ROLLBACK;
    END;
    
    START TRANSACTION;
    INSERT INTO Orden (clienteID, ordenFecha, estado, cantidad) VALUES (_clienteID, _ordenFecha, _estado, _cantidad);
    UPDATE Clientes SET cantidadOrden = cantidadOrden + _cantidad WHERE clienteID = _clienteID;
    COMMIT;

END //

delimiter ;


delimiter //

CREATE PROCEDURE updCompletaOrden (in _ordenID INT, in _completadoFecha DATE)
BEGIN

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        select ROLLBACK;
    END;
    
    START TRANSACTION;
    UPDATE Orden SET estado = 'F', completadoFecha = _completadoFecha WHERE ordenID = _ordenID;
    UPDATE Clientes SET cantidadEntregado = cantidadEntregado + (SELECT cantidad FROM Orden WHERE ordenID = _ordenID) WHERE clienteID = (SELECT clienteID FROM Orden WHERE ordenID = _ordenID);
    COMMIT;
        
END //

delimiter ;


DELIMITER //

CREATE FUNCTION f_diferencia_cantidad( _clienteID INT)
RETURNS INT DETERMINISTIC -- Especificamos parámetro de salida
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        select ROLLBACK;
    END;

    DECLARE _cantidadOrden INT;
    DECLARE _cantidadEntregado INT;
    DECLARE _diferencia INT;

    SELECT cantidadOrden, cantidadEntregado
    INTO _cantidadOrden, _cantidadEntregado
    FROM Clientes
    WHERE clienteID = _clienteID;

    SET _diferencia = _cantidadOrden - _cantidadEntregado;

    RETURN _diferencia;
END // 

DELIMITER ;


delimiter //

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

delimiter ;