-- Base de Datos ventas
create database ventas;

use ventas;

CREATE TABLE Clientes (
    clienteID   INT  auto_increment primary key,
    nombre VARCHAR (40)  NOT NULL,
    cantidadOrden  INT           NOT NULL DEFAULT 0,
    cantidadEntregado INT           NOT NULL DEFAULT 0,
    situacion char(1) not null default 'A'
);
-- drop table Orden;
CREATE TABLE Orden (
    clienteID INT      NOT NULL,
    ordenID    INT      auto_increment primary key,
    ordenFecha  DATETIME NOT NULL DEFAULT now() CHECK ((ordenFecha > '2024-01-01') and (ordenFecha < '3030-01-01')),
    completadoFecha DATETIME NULL, -- CHECK ((completadoFecha >= OrdenFecha) AND (completadoFecha < '2030-01-01')),
    estado     CHAR (1) NOT NULL DEFAULT 'O',
    cantidad   INT      NOT NULL,
    FOREIGN KEY (clienteID) REFERENCES Clientes(clienteID)
);

CREATE TABLE log (
	logID    INT      auto_increment primary key,
    clienteID int,
    situacionAnterior char(1),
    fecha DATETIME
);


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

-- Test 1
delimiter //
create procedure test1 (out resultado int )
begin
    -- Variables trabajo
    declare _numeroCliente int;
    declare _nombreCliente varchar(50);

    -- Variables resultados
    declare _clienteID int;
    declare _nombre varchar(50);
    declare _cantidadOrden int;
    declare _cantidadEntregado int;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        select 'Error' as mensaje;
        set resultado = -1;
    END;

    set _nombreCliente = 'Cliente 1';
    call insCliente (_nombreCliente);

    select clienteID, nombre, cantidadOrden, cantidadEntregado
    into _clienteID, _nombre, _cantidadOrden, _cantidadEntregado
    from Clientes
    where clienteID = (SELECT LAST_INSERT_ID());

    if (_nombreCliente = 'Cliente 1' and _cantidadOrden = 0 and _cantidadEntregado = 0) then
        set resultado = 1;
    else
        set resultado = -1;
    end if;
end //
delimiter ;

-- Test 2
delimiter //
create procedure test2 (out resultado int )
begin

    -- Variables trabajo
    declare _numeroCliente int;
    declare _nombreCliente varchar(50);

    -- Variables resultados
    declare _clienteID int;
    declare _nombre varchar(50);
    declare _cantidadOrden int;
    declare _cantidadEntregado int;
    declare _ordenID INT;
    declare _ordenFecha DATETIME;
    declare _completadoFecha DATETIME;
    declare _estado CHAR (1);
    declare _cantidad int;

    set _nombreCliente = 'Cliente 1';

    SELECT clienteID into _clienteID FROM  Clientes WHERE nombre = _nombreCliente;

    set _cantidad = 100;
    set _ordenFecha = now();
    set _estado = 'O';

    call insNuevaOrden (_clienteID, _cantidad, _ordenFecha, _estado);

    -- Toma datos orden creada
    select ordenID, ordenFecha, completadoFecha, estado, cantidad
    into _ordenID, _ordenFecha, _completadoFecha, _estado, _cantidad
    from Orden
    where ordenID = (SELECT LAST_INSERT_ID());

    -- Toma datos del cliente Par control de actualizcion
    select clienteID, nombre, cantidadOrden, cantidadEntregado
    into _clienteID, _nombre, _cantidadOrden, _cantidadEntregado
    from Clientes
    where clienteID = _clienteID;

    -- Control de orden ingresada
    if (_estado = 'O' and _cantidadOrden = _cantidad) then
        set resultado = 1;
    else
        set resultado = -1;
    end if;

    if (_nombreCliente = 'Cliente 1' and _cantidadOrden = _cantidad and _cantidadEntregado = 0) then
        set resultado = 1;
    else
        set resultado = -1;
    end if;
end //
delimiter ;

-- Test 3

delimiter //
create procedure test3 (out resultado int )
begin
    -- Variables trabajo
    declare _numeroCliente int;
    declare _nombreCliente varchar(50);

    -- Variables resultados
    declare _clienteID int;
    declare _nombre varchar(50);
    declare _cantidadOrden int;
    declare _cantidadEntregado int;
    declare _ordenID INT;
    declare _ordenFecha DATETIME;
    declare _completadoFecha DATETIME;
    declare _estado CHAR (1);
    declare _cantidad int;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        select 'Error' as mensaje;
        set resultado = -1;
    END;

    set _nombreCliente = 'Cliente 1';

    SELECT clienteID into _clienteID FROM  Clientes WHERE nombre = _nombreCliente;

    SELECT MAX( ordenID ) into _ordenID FROM  Orden  WHERE  clienteID  = _clienteID;

    call updCompletaOrden (_ordenID);

    -- Toma datos orden actualizada
    select ordenID, ordenFecha, completadoFecha, estado, cantidad
    into _ordenID, _ordenFecha, _completadoFecha, _estado, _cantidad
    from Orden
    where ordenID = _ordenID;

    -- Control de orden ingresada
    if (_estado = 'F') then
        set resultado = 1;
        -- Toma datos del cliente Par control de actualizcion
        select clienteID, nombre, cantidadOrden, cantidadEntregado
        into _clienteID, _nombre, _cantidadOrden, _cantidadEntregado
        from Clientes
        where clienteID = _clienteID;

        if (_nombre = 'Cliente 1' and _cantidadOrden = _cantidadEntregado) then
            set resultado = 1;
        else
            set resultado = -1;
        end if;

    else
        set resultado = -1;
    end if;


end //
delimiter ;

-- Test 4

delimiter //
create procedure test4 (out resultado int )
begin
    -- Variables trabajo
    declare _numeroCliente int;
    declare _nombreCliente varchar(50);
	declare _resultadoFuncion int;

    -- Variables resultados
    declare _clienteID int;
    declare _nombre varchar(50);
    declare _cantidadOrden int;
    declare _cantidadEntregado int;
    declare _ordenID INT;
    declare _ordenFecha DATETIME;
    declare _completadoFecha DATETIME;
    declare _estado CHAR (1);
    declare _cantidad int;
    

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        select 'Error' as mensaje;
        set resultado = -1;
    END;
	
    set _nombreCliente = 'Cliente 1';

    SELECT clienteID into _clienteID FROM  Clientes WHERE nombre = _nombreCliente;

    SELECT MAX( ordenID ) into _ordenID FROM  Orden  WHERE  clienteID  = _clienteID;

    set _resultadoFuncion = f_diferencia_cantidad( _clienteID);
	
    select clienteID, nombre, cantidadOrden, cantidadEntregado
    into _clienteID, _nombre, _cantidadOrden, _cantidadEntregado
    from Clientes
    where clienteID = _clienteID;
    
    -- Control valor de función
    if (_resultadoFuncion = (_cantidadOrden - _cantidadEntregado)) then
        set resultado = 1;
    else
        set resultado = -1;
    end if;
    
end //
delimiter ;

-- Test 5

delimiter //
create procedure test5 (out resultado int )
begin
    -- Variables trabajo
    declare _numeroCliente int;
    declare _nombreCliente varchar(50);

    -- Variables resultados
    declare _clienteID int;
    declare _nombre varchar(50);
    declare _cantidadOrden int;
    declare _cantidadEntregado int;
    declare _ordenID INT;
    declare _ordenFecha DATETIME;
    declare _completadoFecha DATETIME;
    declare _estado CHAR (1);
    declare _cantidad int;
    declare _situacion CHAR (1);
    declare _situacionAnterior CHAR (1);

    set _nombreCliente = 'Cliente 1';

    SELECT clienteID into _clienteID FROM  Clientes WHERE nombre = _nombreCliente;

    call updCliente (_clienteID);

    -- Toma datos del cliente Par control de actualizcion
    select clienteID, situacion
    into _clienteID, _situacion
    from Clientes
    where clienteID = _clienteID;

    -- Control de orden ingresada
    if (_situacion = 'X') then
        set resultado = 1;

        select situacionAnterior
        into _situacionAnterior
        from log
        where clienteID = _clienteID
        order by logID desc
        limit 1;

        if (_situacionAnterior = 'A') then
            set resultado = 1;
        else
            set resultado = -1;
        end if;
    else
        set resultado = -1;
    end if;

end //
delimiter ;


/* Test integrado */
delimiter //
create procedure test ()
begin
    -- Variables trabajo
    declare _numeroCliente int;
    declare _nombreCliente varchar(50);
    declare _paso1 varchar(5);
    declare _paso2 varchar(5);
    declare _paso3 varchar(5);
    declare _paso4 varchar(5);
    declare _paso5 varchar(5);
    declare _puntos1 int;
    declare _puntos2 int;
	declare _puntos3 int;
	declare _puntos4 int;
	declare _puntos5 int;
    
    -- Variables resultados
    declare _clienteID int;
    declare _nombre varchar(50);
    declare _cantidadOrden int;
    declare _cantidadEntregado int;
    declare _ordenID INT;
    declare _ordenFecha DATETIME;
    declare _completadoFecha DATETIME;
    declare _estado CHAR (1);
    declare _cantidad int;
    declare _resultado int;

	DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        select 'Error En Test' as mensaje;
    END;

    set _resultado = -1;

	-- Paso 1
    call test1 (_resultado);
    if _resultado <> -1 then
		set _paso1 ='OK';
        set _puntos1=20;
    else 
		set _paso1 ='Error';
        set _puntos1=0;
    end if;
    
    -- Paso 2
	call test2 (_resultado);
    if _resultado <> -1 then
 		set _paso2 ='OK';
        set _puntos2=20;
   else 
		set _paso2 ='Error';
        set _puntos2=0;
    end if;
    
    -- Paso 3
    call test3 (_resultado);
    if _resultado <> -1 then
    begin 
		set _paso3 ='OK';
        set _puntos3=20;
	end;
    else 
		set _paso3 ='Error';
        set _puntos3=0;
    end if;
    
    -- Paso 4
    call test4 (_resultado);
    if _resultado <> -1 then
    	set _paso4 ='OK';
        set _puntos4=20;
	else 
		set _paso4 ='Error';
        set _puntos4=0;
    end if;
    
    -- Paso 5
    call test5 (_resultado);
    if _resultado <> -1 then
		set _paso5 ='OK';
        set _puntos5=20;
	else 
		set _paso5 ='Error';
        set _puntos5=0;
    end if;
    
    select 'Paso: ', _paso1, 'Puntos: ', _puntos1;
    select 'Paso: ', _paso2, 'Puntos: ', _puntos2;
    select 'Paso: ', _paso3, 'Puntos: ', _puntos3;
    select 'Paso: ', _paso4, 'Puntos: ', _puntos4;
    select 'Paso: ', _paso5, 'Puntos: ', _puntos5;

    select 'Total Puntos: ' , (_puntos1 + _puntos2 +_puntos3 +_puntos4 + _puntos5);


end //
delimiter ;